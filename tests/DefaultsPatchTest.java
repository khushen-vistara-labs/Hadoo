// SPDX-License-Identifier: GPL-3.0-only
package app.hadoo.patches;

import app.morphe.patcher.extensions.InstructionExtensions;
import app.morphe.patcher.util.proxy.mutableTypes.MutableMethod;
import com.android.tools.smali.dexlib2.Opcode;
import com.android.tools.smali.dexlib2.iface.instruction.ReferenceInstruction;
import com.android.tools.smali.dexlib2.iface.reference.FieldReference;
import com.android.tools.smali.dexlib2.iface.reference.MethodReference;
import com.android.tools.smali.dexlib2.immutable.*;
import com.android.tools.smali.dexlib2.immutable.instruction.ImmutableInstruction10x;
import java.util.*;

public final class DefaultsPatchTest {
    static MutableMethod fixture(String name, String returnType, int registers, boolean isStatic, String code) {
        var parameters = isStatic ? List.<ImmutableMethodParameter>of() : List.of(
                new ImmutableMethodParameter("Ljava/lang/String;", Set.of(), null),
                new ImmutableMethodParameter("Z", Set.of(), null));
        var body = new ImmutableMethodImplementation(registers, List.of(new ImmutableInstruction10x(Opcode.RETURN_VOID)), List.of(), List.of());
        var method = new MutableMethod(new ImmutableMethod("Lfixture;", name, parameters, returnType,
                isStatic ? 8 : 1, Set.of(), Set.of(), body));
        InstructionExtensions.INSTANCE.addInstructions(method, 0, code);
        return method;
    }

    static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    public static void main(String[] args) {
        var settings = fixture("<clinit>", "V", 3, true, """
                sget-object v0, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;
                new-instance v1, Lapp/morphe/extension/shared/settings/BooleanSetting;
                const-string v2, "morphe_selected"
                invoke-direct {v1, v2, v0}, Lapp/morphe/extension/shared/settings/BooleanSetting;-><init>(Ljava/lang/String;Ljava/lang/Boolean;)V
                new-instance v1, Lapp/morphe/extension/shared/settings/BooleanSetting;
                const-string v2, "morphe_unrelated"
                invoke-direct {v1, v2, v0}, Lapp/morphe/extension/shared/settings/BooleanSetting;-><init>(Ljava/lang/String;Ljava/lang/Boolean;)V
                """);
        var seen = new HashMap<String, Integer>();
        HadooDefaultsPatch.patchSettingsMethod(settings, Map.of("morphe_selected", true), seen, field -> {});
        var calls = HadooDefaultsPatch.settingCalls(settings);
        require(((FieldReference) calls.get(0).value()).getName().equals("TRUE"), "Selected default must change");
        require(((FieldReference) calls.get(1).value()).getName().equals("FALSE"), "Shared register must be restored for unrelated settings");
        require(seen.equals(Map.of("morphe_selected", 1)), "Each configured constructor is counted");

        var getter = fixture("getBoolean", "Z", 4, false, """
                iget-object v0, p0, Lfixture;->delegate:Landroid/content/SharedPreferences;
                invoke-interface {v0, p1, p2}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z
                move-result v0
                return v0
                """);
        HadooDefaultsPatch.patchNativeGetter(getter, new TreeMap<>(Map.of("pref_key_dont_play_video", true, "pref_key_dont_play_nma_video", true)));
        long reads = HadooDefaultsPatch.instructions(getter).stream().filter(i -> i instanceof ReferenceInstruction r
                && r.getReference() instanceof MethodReference m && m.getDefiningClass().equals(HadooDefaultsPatch.PREFERENCES)
                && m.getName().equals("getBoolean")).count();
        require(reads == 1, "The native persisted-value lookup must remain intact");
        for (var instruction : HadooDefaultsPatch.instructions(getter)) {
            if (instruction instanceof ReferenceInstruction r && r.getReference() instanceof MethodReference m)
                require(!Set.of("putBoolean", "edit", "clear", "apply").contains(m.getName()), "Defaults must not overwrite saved choices");
        }
        var malformed = fixture("getBoolean", "Z", 4, false, "const/4 v0, 0x0\nreturn v0");
        boolean rejected = false;
        try { HadooDefaultsPatch.patchNativeGetter(malformed, Map.of("pref_key_dont_play_video", true)); }
        catch (IllegalStateException expected) { rejected = true; }
        require(rejected, "A changed native getter must fail closed");
        System.out.println("Defaults regression checks passed");
    }
}
