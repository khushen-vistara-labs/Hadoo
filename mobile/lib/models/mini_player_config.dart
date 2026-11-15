enum MiniPlayerWidthMode { matchNavigation, custom }

enum MiniPlayerShadow { off, subtle, strong }

enum MiniPlayerTitleMode { truncate, scroll }

class MiniPlayerConfig {
  final MiniPlayerWidthMode widthMode;
  final double widthFraction;
  final double height;
  final double cornerRadius;
  final double navigationGap;
  final bool showArtwork;
  final bool showArtist;
  final bool showProgress;
  final bool showPrevious;
  final bool showNext;
  final double backgroundOpacity;
  final bool showBorder;
  final MiniPlayerShadow shadow;
  final double textScale;
  final MiniPlayerTitleMode titleMode;

  const MiniPlayerConfig({
    this.widthMode = MiniPlayerWidthMode.matchNavigation,
    this.widthFraction = 1,
    this.height = 56,
    this.cornerRadius = 16,
    this.navigationGap = 8,
    this.showArtwork = true,
    this.showArtist = true,
    this.showProgress = true,
    this.showPrevious = false,
    this.showNext = false,
    this.backgroundOpacity = 0.94,
    this.showBorder = true,
    this.shadow = MiniPlayerShadow.subtle,
    this.textScale = 1,
    this.titleMode = MiniPlayerTitleMode.scroll,
  });

  static const defaultConfig = MiniPlayerConfig();

  MiniPlayerConfig copyWith({
    MiniPlayerWidthMode? widthMode,
    double? widthFraction,
    double? height,
    double? cornerRadius,
    double? navigationGap,
    bool? showArtwork,
    bool? showArtist,
    bool? showProgress,
    bool? showPrevious,
    bool? showNext,
    double? backgroundOpacity,
    bool? showBorder,
    MiniPlayerShadow? shadow,
    double? textScale,
    MiniPlayerTitleMode? titleMode,
  }) => MiniPlayerConfig.fromJson({
    ...toJson(),
    'widthMode': ?widthMode?.name,
    'widthFraction': ?widthFraction,
    'height': ?height,
    'cornerRadius': ?cornerRadius,
    'navigationGap': ?navigationGap,
    'showArtwork': ?showArtwork,
    'showArtist': ?showArtist,
    'showProgress': ?showProgress,
    'showPrevious': ?showPrevious,
    'showNext': ?showNext,
    'backgroundOpacity': ?backgroundOpacity,
    'showBorder': ?showBorder,
    'shadow': ?shadow?.name,
    'textScale': ?textScale,
    'titleMode': ?titleMode?.name,
  });

  Map<String, Object> toJson() => {
    'widthMode': widthMode.name,
    'widthFraction': widthFraction,
    'height': height,
    'cornerRadius': cornerRadius,
    'navigationGap': navigationGap,
    'showArtwork': showArtwork,
    'showArtist': showArtist,
    'showProgress': showProgress,
    'showPrevious': showPrevious,
    'showNext': showNext,
    'backgroundOpacity': backgroundOpacity,
    'showBorder': showBorder,
    'shadow': shadow.name,
    'textScale': textScale,
    'titleMode': titleMode.name,
  };

  factory MiniPlayerConfig.fromJson(Map<String, dynamic> json) {
    double number(String key, double fallback, double min, double max) {
      final value = json[key];
      return value is num && value.isFinite
          ? value.toDouble().clamp(min, max)
          : fallback;
    }

    bool flag(String key, bool fallback) =>
        json[key] is bool ? json[key] as bool : fallback;

    T choice<T extends Enum>(String key, List<T> values, T fallback) =>
        values.where((value) => value.name == json[key]).firstOrNull ??
        fallback;

    return MiniPlayerConfig(
      widthMode: choice(
        'widthMode',
        MiniPlayerWidthMode.values,
        MiniPlayerWidthMode.matchNavigation,
      ),
      widthFraction: number('widthFraction', 1, 0.7, 1),
      height: number('height', 56, 48, 88),
      cornerRadius: number('cornerRadius', 16, 0, 32),
      navigationGap: number('navigationGap', 8, 0, 24),
      showArtwork: flag('showArtwork', true),
      showArtist: flag('showArtist', true),
      showProgress: flag('showProgress', true),
      showPrevious: flag('showPrevious', false),
      showNext: flag('showNext', false),
      backgroundOpacity: number('backgroundOpacity', 0.94, 0, 1),
      showBorder: flag('showBorder', true),
      shadow: choice(
        'shadow',
        MiniPlayerShadow.values,
        MiniPlayerShadow.subtle,
      ),
      textScale: number('textScale', 1, 0.85, 1.3),
      titleMode: choice(
        'titleMode',
        MiniPlayerTitleMode.values,
        MiniPlayerTitleMode.scroll,
      ),
    );
  }
}
