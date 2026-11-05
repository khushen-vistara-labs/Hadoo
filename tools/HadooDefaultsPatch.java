// SPDX-License-Identifier: GPL-3.0-only
package app.hadoo.patches;

import app.morphe.patcher.extensions.InstructionExtensions;
import app.morphe.patcher.patch.BytecodePatch;
import app.morphe.patcher.patch.BytecodePatchBuilder;
import app.morphe.patcher.patch.BytecodePatchContext;
import app.morphe.patcher.patch.Compatibility;
import app.morphe.patcher.util.proxy.mutableTypes.MutableMethod;
import com.android.tools.smali.dexlib2.DexFileFactory;
import com.android.tools.smali.dexlib2.Opcode;
import com.android.tools.smali.dexlib2.Opcodes;
import com.android.tools.smali.dexlib2.builder.BuilderInstruction;
import com.android.tools.smali.dexlib2.builder.instruction.BuilderInstruction21c;
import com.android.tools.smali.dexlib2.iface.ClassDef;
import com.android.tools.smali.dexlib2.iface.Method;
import com.android.tools.smali.dexlib2.iface.instruction.*;
import com.android.tools.smali.dexlib2.iface.reference.*;
import com.android.tools.smali.dexlib2.immutable.reference.ImmutableFieldReference;
import com.android.tools.smali.dexlib2.immutable.reference.ImmutableStringReference;
import kotlin.Pair;
import kotlin.Unit;

import java.io.File;
import java.io.InputStream;
import java.util.*;
import java.util.function.Consumer;

/** Local add-on to the checksum-pinned, unmodified upstream patch bundle. */
public final class HadooDefaultsPatch {
    static final String SETTING = "Lapp/morphe/extension/shared/settings/";
    static final String PREFERENCES = "Landroid/content/SharedPreferences;";
    static final String NATIVE_ANCHOR = "pref_key_dont_play_video";
    static final String SETTINGS_SCREEN = "Lcom/google/android/apps/youtube/music/settings/fragment/DataSavingSettingsFragment;";
    static final String SPLASH_KEY = "morphe_splash_screen_style";
    static final String SPLASH_CLASS = "Lapp/morphe/extension/shared/patches/SplashAnimationPatch;";
    static final String SPLASH_ENUM = SPLASH_CLASS.substring(0, SPLASH_CLASS.length() - 1) + "$SplashScreenAnimationStyle;";
    static final String SETTINGS_NAME_CLASS = "Lapp/morphe/extension/shared/patches/SettingsNamePatch;";

    record Defaults(Map<String, Object> morphe, Map<String, Boolean> nativeValues) {}
    record Call(int index, String key, int register, Object value, String settingType) {}
    record Edit(int index, int register, Object before, Object after) {}

    public static BytecodePatch getHadooDefaultsPatch() {
        var builder = new BytecodePatchBuilder("Hadoo defaults",
                "Includes Hadoo's changeable music, navigation and branding defaults in the APK.", true);
        builder.compatibleWith(Compatibility.Companion.fromLegacy(new Pair<>("com.google.android.apps.youtube.music",
                Set.of("9.30.53", "9.20.53", "9.15.51"))));
        // Finalize runs after upstream extension merging and patch execution.
        builder.finalize(context -> { apply(context); return Unit.INSTANCE; });
        return builder.build$morphe_patcher();
    }

    static Defaults loadDefaults() {
        var properties = new Properties();
        try (InputStream stream = HadooDefaultsPatch.class.getResourceAsStream("/hadoo-defaults.properties")) {
            if (stream == null) throw new IllegalStateException("Missing Hadoo defaults resource");
            properties.load(stream);
        } catch (java.io.IOException e) {
            throw new IllegalStateException("Cannot read Hadoo defaults", e);
        }
        Map<String, Object> morphe = new TreeMap<>();
        Map<String, Boolean> nativeValues = new TreeMap<>();
        for (String key : properties.stringPropertyNames()) {
            String value = properties.getProperty(key);
            if (key.startsWith("morphe.boolean.")) morphe.put(key.substring(15), booleanValue(value));
            else if (key.startsWith("morphe.string.")) morphe.put(key.substring(14), value);
            else if (key.startsWith("native.boolean.")) nativeValues.put(key.substring(15), booleanValue(value));
            else throw new IllegalStateException("Unknown defaults entry: " + key);
        }
        if (morphe.isEmpty() || nativeValues.isEmpty()) throw new IllegalStateException("Empty Hadoo defaults");
        return new Defaults(morphe, nativeValues);
    }

    private static boolean booleanValue(String value) {
        if (!value.equals("true") && !value.equals("false")) throw new IllegalStateException("Invalid boolean default");
        return Boolean.parseBoolean(value);
    }

    static List<Instruction> instructions(Method method) {
        var result = new ArrayList<Instruction>();
        if (method.getImplementation() != null) method.getImplementation().getInstructions().forEach(result::add);
        return result;
    }

    /** Track constant arguments, including shared registers, without assuming compiler register numbers. */
    static List<Call> settingCalls(Method method) {
        var result = new ArrayList<Call>();
        Map<Integer, Object> values = new HashMap<>();
        List<Instruction> code = instructions(method);
        for (int i = 0; i < code.size(); i++) {
            Instruction instruction = code.get(i);
            Opcode opcode = instruction.getOpcode();
            if (instruction instanceof ReferenceInstruction reference && reference.getReference() instanceof MethodReference target
                    && target.getName().equals("<init>") && target.getDefiningClass().startsWith(SETTING)
                    && target.getParameterTypes().size() >= 2 && target.getParameterTypes().get(0).equals("Ljava/lang/String;")) {
                int keyRegister, valueRegister;
                if (instruction instanceof FiveRegisterInstruction args) {
                    keyRegister = args.getRegisterD(); valueRegister = args.getRegisterE();
                } else if (instruction instanceof RegisterRangeInstruction args) {
                    keyRegister = args.getStartRegister() + 1; valueRegister = args.getStartRegister() + 2;
                } else throw new IllegalStateException("Unknown settings constructor format");
                if (values.get(keyRegister) instanceof String key) {
                    result.add(new Call(i, key, valueRegister, values.get(valueRegister), target.getDefiningClass()));
                }
            }
            if (opcode == Opcode.CONST_STRING || opcode == Opcode.CONST_STRING_JUMBO) {
                values.put(((OneRegisterInstruction) instruction).getRegisterA(),
                        ((StringReference) ((ReferenceInstruction) instruction).getReference()).getString());
            } else if (opcode == Opcode.SGET_OBJECT) {
                values.put(((OneRegisterInstruction) instruction).getRegisterA(),
                        ImmutableFieldReference.of((FieldReference) ((ReferenceInstruction) instruction).getReference()));
            } else if (opcode == Opcode.MOVE_OBJECT || opcode == Opcode.MOVE_OBJECT_FROM16 || opcode == Opcode.MOVE_OBJECT_16) {
                var move = (TwoRegisterInstruction) instruction;
                values.put(move.getRegisterA(), values.get(move.getRegisterB()));
            } else if (opcode.setsRegister() && instruction instanceof OneRegisterInstruction register) {
                values.remove(register.getRegisterA());
            }
        }
        return result;
    }

    static Object desiredConstant(Call call, Object desired, Consumer<FieldReference> validateEnum) {
        if (desired instanceof Boolean b && call.settingType.equals(SETTING + "BooleanSetting;")
                && call.value instanceof FieldReference previous && previous.getDefiningClass().equals("Ljava/lang/Boolean;")
                && Set.of("TRUE", "FALSE").contains(previous.getName())) {
            return new ImmutableFieldReference("Ljava/lang/Boolean;", b ? "TRUE" : "FALSE", "Ljava/lang/Boolean;");
        }
        if (desired instanceof String value) {
            if (call.settingType.equals(SETTING + "StringSetting;") && call.value instanceof String) return value;
            if (call.settingType.equals(SETTING + "EnumSetting;") && call.value instanceof FieldReference previous) {
                var field = new ImmutableFieldReference(previous.getDefiningClass(), value, previous.getType());
                validateEnum.accept(field);
                return field;
            }
        }
        throw new IllegalStateException("Cannot safely change the default for " + call.key);
    }

    static BuilderInstruction constant(int register, Object value) {
        if (value instanceof FieldReference field) return new BuilderInstruction21c(Opcode.SGET_OBJECT, register, field);
        if (value instanceof String text) return new BuilderInstruction21c(Opcode.CONST_STRING, register, new ImmutableStringReference(text));
        throw new IllegalStateException("Unsupported settings constant");
    }

    static void patchSettingsMethod(MutableMethod method, Map<String, Object> defaults,
                                    Map<String, Integer> seen, Consumer<FieldReference> validateEnum) {
        var edits = new ArrayList<Edit>();
        for (Call call : settingCalls(method)) {
            if (!defaults.containsKey(call.key)) continue;
            seen.merge(call.key, 1, Integer::sum);
            Object desired = desiredConstant(call, defaults.get(call.key), validateEnum);
            if (!desired.equals(call.value)) edits.add(new Edit(call.index, call.register, call.value, desired));
        }
        // Restore the original register after each constructor. Other settings can reuse it.
        edits.sort(Comparator.comparingInt(Edit::index).reversed());
        for (Edit edit : edits) {
            var implementation = method.getImplementation();
            implementation.addInstruction(edit.index + 1, constant(edit.register, edit.before));
            implementation.addInstruction(edit.index, constant(edit.register, edit.after));
        }
    }

    static boolean nativeGetter(Method method) {
        return method.getName().equals("getBoolean") && method.getReturnType().equals("Z")
                && method.getParameterTypes().equals(List.of("Ljava/lang/String;", "Z"));
    }

    /** Identify the account-aware preferences wrapper from the native settings screen. */
    static String nativePreferencesOwner(ClassDef screen) {
        Set<String> owners = new HashSet<>();
        for (Method method : screen.getMethods()) {
            var code = instructions(method);
            for (int i = 0; i < code.size(); i++) {
                if (!(code.get(i) instanceof ReferenceInstruction r) || !(r.getReference() instanceof StringReference s)
                        || !s.getString().equals(NATIVE_ANCHOR)) continue;
                int register = ((OneRegisterInstruction) code.get(i)).getRegisterA();
                for (int j = i + 1; j < Math.min(code.size(), i + 20); j++) {
                    Instruction next = code.get(j);
                    if (next instanceof ReferenceInstruction ref && ref.getReference() instanceof MethodReference target
                            && target.getName().equals("getBoolean") && target.getParameterTypes().equals(List.of("Ljava/lang/String;", "Z"))
                            && next instanceof FiveRegisterInstruction args && args.getRegisterD() == register
                            && !target.getDefiningClass().equals(PREFERENCES)) owners.add(target.getDefiningClass());
                    if (next.getOpcode().setsRegister() && next instanceof OneRegisterInstruction write && write.getRegisterA() == register) break;
                }
            }
        }
        if (owners.size() != 1) throw new IllegalStateException("Cannot identify one native preferences wrapper: " + owners);
        return owners.iterator().next();
    }

    static void patchNativeGetter(MutableMethod method, Map<String, Boolean> defaults) {
        if (!nativeGetter(method)) throw new IllegalStateException("Unexpected native preferences method");
        boolean delegates = instructions(method).stream().anyMatch(i -> i instanceof ReferenceInstruction ref
                && ref.getReference() instanceof MethodReference target && target.getDefiningClass().equals(PREFERENCES)
                && target.getName().equals("getBoolean"));
        int registers = method.getImplementation().getRegisterCount();
        if (!delegates || registers < 4 || registers > 16) throw new IllegalStateException("Native preferences getter contract changed");
        int keyRegister = registers - 2, defaultRegister = registers - 1;
        StringBuilder prefix = new StringBuilder();
        int index = 0;
        for (var entry : defaults.entrySet()) {
            if (!entry.getKey().matches("pref_key_[a-z_]+")) throw new IllegalStateException("Invalid native preference key");
            prefix.append("const-string v0, \"").append(entry.getKey()).append("\"\n")
                    .append("invoke-virtual {v0, v").append(keyRegister).append("}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n")
                    .append("move-result v0\nif-eqz v0, :hadoo_default_").append(index).append('\n')
                    .append("const/16 v").append(defaultRegister).append(", ").append(entry.getValue() ? "0x1" : "0x0").append('\n')
                    .append(":hadoo_default_").append(index++).append("\nnop\n");
        }
        // Only the fallback argument changes. Stored true/false values and account scoping remain native.
        InstructionExtensions.INSTANCE.addInstructions(method, 0, prefix.toString());
    }

    private static void apply(BytecodePatchContext context) {
        Defaults defaults = loadDefaults();
        Map<String, Object> settings = new TreeMap<>(defaults.morphe);
        Map<String, Integer> seen = new TreeMap<>();
        if (settings.containsKey("morphe_settings_name")) {
            var method = context.mutableClassDefBy(SETTINGS_NAME_CLASS).getMethods().stream()
                    .filter(m -> m.getName().equals("getCustomSettingsName")).findFirst().orElseThrow();
            int changed = 0;
            var code = instructions(method);
            for (int i = 0; i < code.size(); i++) {
                Instruction instruction = code.get(i);
                if (instruction.getOpcode() == Opcode.IGET_OBJECT && instruction instanceof ReferenceInstruction r
                        && r.getReference() instanceof FieldReference field && field.getName().equals("defaultValue")) {
                    // The upstream resolver treats the constructor default as "use Morphe's name".
                    // Keep the explicit DEFAULT preset as its sentinel when Hadoo supplies a custom default.
                    method.getImplementation().replaceInstruction(i,
                            constant(((OneRegisterInstruction) instruction).getRegisterA(), "DEFAULT"));
                    changed++;
                }
            }
            if (changed != 1) throw new IllegalStateException("Settings-name default comparison changed");
        }
        if (settings.containsKey(SPLASH_KEY)) {
            Object style = settings.remove(SPLASH_KEY);
            ClassDef enumClass = context.classDefBy(SPLASH_ENUM);
            boolean exists = false;
            for (var field : enumClass.getStaticFields()) if (field.getName().equals(style)) exists = true;
            if (!(style instanceof String) || !exists) throw new IllegalStateException("Unknown startup animation default");
            var getter = context.mutableClassDefBy(SPLASH_CLASS).getMethods().stream()
                    .filter(m -> m.getName().equals("getDefaultStyle") && m.getParameterTypes().isEmpty()
                            && m.getReturnType().equals(SPLASH_ENUM)).findFirst().orElseThrow();
            if (getter.getImplementation().getRegisterCount() < 1) throw new IllegalStateException("Startup default getter changed");
            InstructionExtensions.INSTANCE.addInstructions(getter, 0,
                    "sget-object v0, " + SPLASH_ENUM + "->" + style + ":" + SPLASH_ENUM + "\nreturn-object v0");
            seen.put(SPLASH_KEY, 1);
        }
        context.classDefForEach(cls -> {
            if (cls.getType().startsWith("Lapp/morphe/extension/") && cls.getType().contains("/settings/")) {
                for (Method method : cls.getMethods()) {
                    if (!method.getName().equals("<clinit>")) continue;
                    boolean relevant = settingCalls(method).stream().anyMatch(c -> settings.containsKey(c.key));
                    if (!relevant) continue;
                    var mutable = context.mutableClassDefBy(cls).getMethods().stream()
                            .filter(m -> m.getName().equals("<clinit>")).findFirst().orElseThrow();
                    patchSettingsMethod(mutable, settings, seen, field -> {
                        ClassDef enumClass = context.classDefBy(field.getDefiningClass());
                        boolean present = false;
                        for (var candidate : enumClass.getStaticFields()) if (candidate.getName().equals(field.getName())) present = true;
                        if (!present) throw new IllegalStateException("Unknown default enum: " + field);
                    });
                }
            }
            return Unit.INSTANCE;
        });
        for (String key : defaults.morphe.keySet()) if (seen.getOrDefault(key, 0) != 1)
            throw new IllegalStateException("Expected one settings constructor for " + key + "; found " + seen.getOrDefault(key, 0));
        String owner = nativePreferencesOwner(context.classDefBy(SETTINGS_SCREEN));
        var nativeClass = context.mutableClassDefBy(owner);
        if (!nativeClass.getInterfaces().contains(PREFERENCES)) throw new IllegalStateException("Native wrapper is not SharedPreferences");
        var methods = nativeClass.getMethods().stream().filter(HadooDefaultsPatch::nativeGetter).toList();
        if (methods.size() != 1) throw new IllegalStateException("Expected one native boolean preferences getter");
        patchNativeGetter(methods.get(0), defaults.nativeValues);
        System.out.println("Hadoo defaults: " + seen.size() + " Morphe settings and " + defaults.nativeValues.size() + " native audio preferences");
    }

    /** Validate the final signed APK, independently of the patcher's success report. */
    public static void main(String[] args) throws Exception {
        if (args.length != 2 || !args[0].equals("verify")) throw new IllegalArgumentException("Usage: verify APK");
        Defaults defaults = loadDefaults();
        var container = DexFileFactory.loadDexContainer(new File(args[1]), Opcodes.getDefault());
        Map<String, ClassDef> classes = new HashMap<>();
        for (String entry : container.getDexEntryNames()) for (ClassDef cls : container.getEntry(entry).getDexFile().getClasses()) classes.put(cls.getType(), cls);
        Map<String, Integer> seen = new TreeMap<>();
        Map<String, Object> settings = new TreeMap<>(defaults.morphe);
        if (settings.containsKey("morphe_settings_name")) {
            boolean sentinel = false;
            for (Method method : classes.get(SETTINGS_NAME_CLASS).getMethods()) if (method.getName().equals("getCustomSettingsName")) {
                for (Instruction instruction : instructions(method)) if (instruction instanceof ReferenceInstruction r) {
                    if (r.getReference() instanceof StringReference s && s.getString().equals("DEFAULT")) sentinel = true;
                    if (r.getReference() instanceof FieldReference f && f.getName().equals("defaultValue"))
                        throw new IllegalStateException("Settings-name resolver still ignores the configured default");
                }
            }
            if (!sentinel) throw new IllegalStateException("Settings-name preset sentinel missing");
        }
        if (settings.containsKey(SPLASH_KEY)) {
            Object desired = settings.remove(SPLASH_KEY);
            Method getter = null;
            for (Method method : classes.get(SPLASH_CLASS).getMethods()) if (method.getName().equals("getDefaultStyle")) getter = method;
            var code = instructions(Objects.requireNonNull(getter));
            if (code.size() < 2 || code.get(0).getOpcode() != Opcode.SGET_OBJECT || code.get(1).getOpcode() != Opcode.RETURN_OBJECT
                    || !((FieldReference) ((ReferenceInstruction) code.get(0)).getReference()).getName().equals(desired))
                throw new IllegalStateException("APK startup animation default differs");
            seen.put(SPLASH_KEY, 1);
        }
        for (ClassDef cls : classes.values()) {
            if (!cls.getType().startsWith("Lapp/morphe/extension/") || !cls.getType().contains("/settings/")) continue;
            for (Method method : cls.getMethods()) if (method.getName().equals("<clinit>")) {
                for (Call call : settingCalls(method)) if (settings.containsKey(call.key)) {
                    Object expected = desiredConstant(call, settings.get(call.key), field -> {});
                    if (!expected.equals(call.value)) throw new IllegalStateException("APK default differs: " + call.key);
                    seen.merge(call.key, 1, Integer::sum);
                }
            }
        }
        for (String key : defaults.morphe.keySet()) if (seen.getOrDefault(key, 0) != 1) throw new IllegalStateException("APK default missing or duplicated: " + key);
        String owner = nativePreferencesOwner(classes.get(SETTINGS_SCREEN));
        Method getter = null;
        for (Method method : classes.get(owner).getMethods()) if (nativeGetter(method)) getter = method;
        if (getter == null) throw new IllegalStateException("APK native getter missing");
        var code = instructions(getter);
        int index = 0, fallback = getter.getImplementation().getRegisterCount() - 1;
        for (var entry : defaults.nativeValues.entrySet()) {
            Instruction key = code.get(index), branch = code.get(index + 3), value = code.get(index + 4);
            if (!(key instanceof ReferenceInstruction r) || !(r.getReference() instanceof StringReference s)
                    || !s.getString().equals(entry.getKey()) || branch.getOpcode() != Opcode.IF_EQZ
                    || !(value instanceof NarrowLiteralInstruction n) || n.getNarrowLiteral() != (entry.getValue() ? 1 : 0)
                    || ((OneRegisterInstruction) value).getRegisterA() != fallback) throw new IllegalStateException("APK native fallback differs: " + entry.getKey());
            index += 6;
        }
        System.out.println("Verified " + seen.size() + " Morphe defaults and " + defaults.nativeValues.size() + " native fallbacks in the signed APK.");
    }
}
