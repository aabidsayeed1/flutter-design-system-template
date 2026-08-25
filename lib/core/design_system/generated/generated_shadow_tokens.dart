import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

abstract class GeneratedThemeShadowTokens {
  const GeneratedThemeShadowTokens();
  List<BoxShadow> card(context);
  List<BoxShadow> floating(context);
}

class GeneratedLightShadowTokens extends GeneratedThemeShadowTokens {
  const GeneratedLightShadowTokens();
  @override
  List<BoxShadow> card(context) {
    return [BoxShadow(color: Theme.of(context).extension<AppThemeExtension>()!.colors.shadow.withValues(alpha: 0.12), offset: Offset(0.0, 4.0), blurRadius: 12.0, spreadRadius: 0.0)];
  }
  @override
  List<BoxShadow> floating(context) {
    return [BoxShadow(color: Theme.of(context).extension<AppThemeExtension>()!.colors.shadow.withValues(alpha: 0.18), offset: Offset(0.0, 8.0), blurRadius: 24.0, spreadRadius: -4.0), BoxShadow(color: Theme.of(context).extension<AppThemeExtension>()!.colors.shadow.withValues(alpha: 0.08), offset: Offset(0.0, 2.0), blurRadius: 6.0, spreadRadius: 0.0)];
  }
}

class GeneratedDarkShadowTokens extends GeneratedThemeShadowTokens {
  const GeneratedDarkShadowTokens();
  @override
  List<BoxShadow> card(context) {
    return [BoxShadow(color: Theme.of(context).extension<AppThemeExtension>()!.colors.shadow.withValues(alpha: 0.32), offset: Offset(0.0, 4.0), blurRadius: 14.0, spreadRadius: 0.0)];
  }
  @override
  List<BoxShadow> floating(context) {
    return [BoxShadow(color: Theme.of(context).extension<AppThemeExtension>()!.colors.shadow.withValues(alpha: 0.42), offset: Offset(0.0, 10.0), blurRadius: 28.0, spreadRadius: -6.0), BoxShadow(color: Theme.of(context).extension<AppThemeExtension>()!.colors.shadow.withValues(alpha: 0.22), offset: Offset(0.0, 3.0), blurRadius: 8.0, spreadRadius: 0.0)];
  }
}

class GeneratedAuroraShadowTokens extends GeneratedThemeShadowTokens {
  const GeneratedAuroraShadowTokens();
  @override
  List<BoxShadow> card(context) {
    return [BoxShadow(color: Theme.of(context).extension<AppThemeExtension>()!.colors.shadow.withValues(alpha: 0.14), offset: Offset(0.0, 4.0), blurRadius: 12.0, spreadRadius: 0.0)];
  }
  @override
  List<BoxShadow> floating(context) {
    return [BoxShadow(color: Theme.of(context).extension<AppThemeExtension>()!.colors.shadow.withValues(alpha: 0.2), offset: Offset(0.0, 9.0), blurRadius: 26.0, spreadRadius: -5.0), BoxShadow(color: Theme.of(context).extension<AppThemeExtension>()!.colors.shadow.withValues(alpha: 0.1), offset: Offset(0.0, 2.0), blurRadius: 7.0, spreadRadius: 0.0)];
  }
}
