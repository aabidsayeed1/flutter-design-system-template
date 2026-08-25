import '../generated/generated_color_tokens.dart';
import 'package:flutter/material.dart';

abstract class ColorTokensBase extends GeneratedThemeColorTokens {
  const ColorTokensBase();
}

class LightColorTokens extends GeneratedLightColorTokens implements ColorTokensBase {
  const LightColorTokens();

  @override
  Color get primary => const Color(0xff0066FF);

  @override
  Color get surface => const Color(0xffF5F7FA);

  @override
  Color get background => const Color(0xffffffff);

  @override
  Color get textPrimary => const Color(0xffFF22FF);

  @override
  Color get error => const Color(0xffD32F2F);
}

class DarkColorTokens extends GeneratedDarkColorTokens implements ColorTokensBase {
  const DarkColorTokens();
}

class AuroraColorTokens extends GeneratedAuroraColorTokens implements ColorTokensBase {
  const AuroraColorTokens();
}
