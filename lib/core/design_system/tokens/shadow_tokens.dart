import '../generated/generated_shadow_tokens.dart';

abstract class ShadowTokensBase extends GeneratedThemeShadowTokens {
  const ShadowTokensBase();
}


class LightShadowTokens extends GeneratedLightShadowTokens implements ShadowTokensBase {
  const LightShadowTokens();
}

class DarkShadowTokens extends GeneratedDarkShadowTokens implements ShadowTokensBase {
  const DarkShadowTokens();
}

class AuroraShadowTokens extends GeneratedAuroraShadowTokens implements ShadowTokensBase {
  const AuroraShadowTokens();
}
