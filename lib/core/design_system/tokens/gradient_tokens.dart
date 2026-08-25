import '../generated/generated_gradient_tokens.dart';

abstract class GradientTokensBase extends GeneratedThemeGradientTokens {
  const GradientTokensBase();
}


class LightGradientTokens extends GeneratedLightGradientTokens implements GradientTokensBase {
  const LightGradientTokens();
}

class DarkGradientTokens extends GeneratedDarkGradientTokens implements GradientTokensBase {
  const DarkGradientTokens();
}

class AuroraGradientTokens extends GeneratedAuroraGradientTokens implements GradientTokensBase {
  const AuroraGradientTokens();
}
