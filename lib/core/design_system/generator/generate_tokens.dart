import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('lib/core/design_system/generator/tokens.json');
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  validateTokensSchema(data);

  generateColors(data);
  generateGradients(data);
  generateShadows(data);
  generateSpacing(data);
  generateRadius(data);
  generateTypography(data);
  generateDimensions(data);
  generateElevations(data);
  updateTokenWrappers(data);
  updateTokensBarrel();
  updateAppThemeExtension(data);
  updateAppTheme(data);
  updateContextExtension(data);
  ensureResponsiveFiles();

  print('All tokens generated');
}

Map<String, dynamic> _map(dynamic value, String message) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw StateError(message);
}

List<MapEntry<String, dynamic>> _orderedEntries(Map<String, dynamic> map) {
  return map.entries.toList(growable: false);
}

String _pascalCase(String value) {
  final parts = value.split(RegExp(r'[^A-Za-z0-9]+')).where((part) => part.isNotEmpty);
  return parts.map((part) => part[0].toUpperCase() + part.substring(1)).join();
}

String _camelCase(String value) {
  final pascal = _pascalCase(value);
  if (pascal.isEmpty) {
    return value;
  }
  return pascal[0].toLowerCase() + pascal.substring(1);
}

String _themeClassName(String themeName) => 'Generated${_pascalCase(themeName)}ColorTokens';

String _themeBaseClassName() => 'GeneratedThemeColorTokens';

String _tokenThemeClassName(String themeName) {
  if (themeName.toLowerCase() == 'light') {
    return 'LightColorTokens';
  }
  return '${_pascalCase(themeName)}ColorTokens';
}

String _tokenThemeBaseClassName() => 'ColorTokensBase';

String _themeGradientClassName(String themeName) =>
    'Generated${_pascalCase(themeName)}GradientTokens';

String _themeGradientBaseClassName() => 'GeneratedThemeGradientTokens';

String _tokenGradientThemeClassName(String themeName) {
  if (themeName.toLowerCase() == 'light') {
    return 'LightGradientTokens';
  }
  return '${_pascalCase(themeName)}GradientTokens';
}

String _tokenGradientThemeBaseClassName() => 'GradientTokensBase';

String _themeShadowClassName(String themeName) => 'Generated${_pascalCase(themeName)}ShadowTokens';

String _themeShadowBaseClassName() => 'GeneratedThemeShadowTokens';

String _tokenShadowThemeClassName(String themeName) {
  if (themeName.toLowerCase() == 'light') {
    return 'LightShadowTokens';
  }
  return '${_pascalCase(themeName)}ShadowTokens';
}

String _tokenShadowThemeBaseClassName() => 'ShadowTokensBase';

final RegExp _hexColorRegex = RegExp(r'^#[0-9A-Fa-f]{6}$');
final RegExp _dartIdentifierRegex = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
final RegExp _tokenKeyRegex = RegExp(r'^[A-Za-z0-9_]+$');

String _tokenMemberName(String tokenKey) {
  // Keep existing Dart identifier keys unchanged to preserve public APIs.
  if (_dartIdentifierRegex.hasMatch(tokenKey)) {
    return tokenKey;
  }

  final normalized = tokenKey.replaceAll(RegExp(r'[^A-Za-z0-9_]+'), '_');
  final parts = normalized.split('_').where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    throw StateError('Token key "$tokenKey" cannot be converted to a Dart member name.');
  }

  var member = parts.first;
  for (final part in parts.skip(1)) {
    member += part[0].toUpperCase() + part.substring(1);
  }

  if (RegExp(r'^[0-9]').hasMatch(member)) {
    member = 'x$member';
  }

  if (!_dartIdentifierRegex.hasMatch(member)) {
    throw StateError('Token key "$tokenKey" cannot be converted to a valid Dart member name.');
  }

  return member;
}

Map<String, String> _tokenMemberMap(Iterable<dynamic> keys, String sectionPath) {
  final result = <String, String>{};
  final usedMemberNames = <String, String>{};

  for (final raw in keys) {
    final key = raw.toString();
    final memberName = _tokenMemberName(key);
    final existing = usedMemberNames[memberName];
    if (existing != null && existing != key) {
      throw StateError(
        'Token keys "$existing" and "$key" in "$sectionPath" both map to "$memberName". '
        'Rename one of them to keep generated Dart members unique.',
      );
    }
    usedMemberNames[memberName] = key;
    result[key] = memberName;
  }

  return result;
}

Set<String> _collectWrapperMethods(String path, String returnType) {
  final file = File(path);
  if (!file.existsSync()) {
    return <String>{};
  }

  final content = file.readAsStringSync();
  final regex = RegExp(
    '\\b${RegExp.escape(returnType)}\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*\\(\\s*context\\s*\\)',
  );

  return regex.allMatches(content).map((match) => match.group(1)).whereType<String>().toSet();
}

void validateTokensSchema(Map<String, dynamic> data) {
  const requiredTopLevel = [
    'themes',
    'spacing',
    'radius',
    'typography',
    'dimensions',
    'elevations',
  ];
  for (final key in requiredTopLevel) {
    if (!data.containsKey(key)) {
      throw StateError('Missing "$key" in tokens.json');
    }
  }

  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  if (themes.isEmpty) {
    throw StateError('"themes" must define at least one theme');
  }
  if (!themes.containsKey('light')) {
    throw StateError('"themes" must include a "light" theme');
  }

  final lightTheme = _map(themes['light'], 'Invalid theme definition for "light"');
  final lightColors = _map(
    lightTheme['colors'],
    'Missing "themes.light.colors" in tokens.json',
  );
  if (lightColors.isEmpty) {
    throw StateError('"themes.light.colors" must not be empty');
  }

  final baselineColorKeys = <String>{};
  for (final entry in lightColors.entries) {
    final key = entry.key;
    _validateTokenName('themes.light.colors', key);
    _validateHexColor(entry.value, 'themes.light.colors.$key');
    baselineColorKeys.add(key);
  }

  for (final themeEntry in _orderedEntries(themes)) {
    final themeName = themeEntry.key;
    final pascal = _pascalCase(themeName);
    if (pascal.isEmpty || !_dartIdentifierRegex.hasMatch(pascal)) {
      throw StateError(
        'Invalid theme key "$themeName". Theme keys must produce valid Dart identifiers.',
      );
    }

    final theme = _map(themeEntry.value, 'Invalid theme definition for "$themeName"');
    final colors = _map(
      theme['colors'],
      'Missing "themes.$themeName.colors" in tokens.json',
    );

    for (final colorEntry in colors.entries) {
      final colorKey = colorEntry.key;
      _validateTokenName('themes.$themeName.colors', colorKey);
      _validateHexColor(colorEntry.value, 'themes.$themeName.colors.$colorKey');
    }

    final colorKeys = colors.keys.cast<String>().toSet();
    final missingKeys = baselineColorKeys.difference(colorKeys);
    final extraKeys = colorKeys.difference(baselineColorKeys);

    if (missingKeys.isNotEmpty || extraKeys.isNotEmpty) {
      throw StateError(
        'Theme "$themeName" color keys must match "light" exactly. '
        'Missing: ${missingKeys.join(', ')}. Extra: ${extraKeys.join(', ')}.',
      );
    }
  }

  _validateThemeGradients(themes);
  _validateThemeShadows(themes);

  if (data.containsKey('designSizes')) {
    _validateDesignSizeSection(
      _map(data['designSizes'], 'Invalid "designSizes" in tokens.json'),
      sectionName: 'designSizes',
    );
  }
  _validateResponsiveSection(
    _map(data['spacing'], 'Missing "spacing" in tokens.json'),
    sectionName: 'spacing',
    allowNumericLeadingKey: true,
  );
  _validateResponsiveSection(
    _map(data['radius'], 'Missing "radius" in tokens.json'),
    sectionName: 'radius',
    allowNumericLeadingKey: true,
  );
  _validateResponsiveSection(
    _map(data['dimensions'], 'Missing "dimensions" in tokens.json'),
    sectionName: 'dimensions',
    requireType: true,
  );
  _validateResponsiveSection(
    _map(data['elevations'], 'Missing "elevations" in tokens.json'),
    sectionName: 'elevations',
  );
  _validateElevationAliases(
    data,
    elevations: _map(data['elevations'], 'Missing "elevations" in tokens.json'),
  );

  _validateTypography(
    _map(data['typography'], 'Missing "typography" in tokens.json'),
    availableColorKeys: baselineColorKeys,
  );
}

void _validateTokenName(String sectionPath, String key) {
  if (!_dartIdentifierRegex.hasMatch(key)) {
    throw StateError(
        'Invalid token name "$sectionPath.$key". Use Dart-safe names like sm, md, bodyText.');
  }
}

void _validateFlexibleTokenName(String sectionPath, String key) {
  if (!_tokenKeyRegex.hasMatch(key)) {
    throw StateError(
      'Invalid token name "$sectionPath.$key". Use only letters, numbers, and underscore.',
    );
  }

  _tokenMemberName(key);
}

void _validateHexColor(dynamic value, String path) {
  if (value is! String || !_hexColorRegex.hasMatch(value)) {
    throw StateError('Invalid color at "$path": "$value". Expected format: #RRGGBB');
  }
}

void _validateResponsiveSection(
  Map<String, dynamic> section, {
  required String sectionName,
  bool requireType = false,
  bool allowNumericLeadingKey = false,
}) {
  if (section.isEmpty) {
    throw StateError('"$sectionName" must not be empty');
  }

  for (final entry in section.entries) {
    final tokenName = entry.key;
    if (allowNumericLeadingKey) {
      _validateFlexibleTokenName(sectionName, tokenName);
    } else {
      _validateTokenName(sectionName, tokenName);
    }

    final token = _map(entry.value, 'Invalid token "$sectionName.$tokenName"');
    _requireNum(token['mobile'], '$sectionName.$tokenName.mobile');
    _requireNum(token['tablet'], '$sectionName.$tokenName.tablet');
    _requireNum(token['desktop'], '$sectionName.$tokenName.desktop');

    if (requireType) {
      final type = token['type'];
      const allowed = {'width', 'height', 'radius'};
      if (type is! String || !allowed.contains(type)) {
        throw StateError(
          'Invalid type at "$sectionName.$tokenName.type": "$type". Allowed: width, height, radius.',
        );
      }
    }
  }
}

void _validateResponsiveSizeSection(
  Map<String, dynamic> section, {
  required String sectionName,
}) {
  if (section.isEmpty) {
    throw StateError('"$sectionName" must not be empty');
  }

  const allowed = {'mobile', 'tablet', 'desktop'};
  final keys = section.keys.cast<String>().toSet();
  final missing = allowed.difference(keys);
  final extra = keys.difference(allowed);
  if (missing.isNotEmpty || extra.isNotEmpty) {
    throw StateError(
      '"$sectionName" must define exactly: mobile, tablet, desktop. '
      'Missing: ${missing.join(', ')}. Extra: ${extra.join(', ')}.',
    );
  }

  for (final entry in section.entries) {
    final name = entry.key;
    _validateTokenName(sectionName, name);
    final token = _map(entry.value, 'Invalid token "$sectionName.$name"');
    _requireNum(token['width'], '$sectionName.$name.width');
    _requireNum(token['height'], '$sectionName.$name.height');
  }
}

void _validateDesignSizeSection(
  Map<String, dynamic> section, {
  required String sectionName,
}) {
  if (section.isEmpty) {
    throw StateError('"$sectionName" must not be empty');
  }

  const allowed = {'mobile', 'tablet', 'desktop'};
  final keys = section.keys.cast<String>().toSet();
  final missing = allowed.difference(keys);
  final extra = keys.difference(allowed);
  if (missing.isNotEmpty || extra.isNotEmpty) {
    throw StateError(
      '"$sectionName" must define exactly: mobile, tablet, desktop. '
      'Missing: ${missing.join(', ')}. Extra: ${extra.join(', ')}.',
    );
  }

  for (final entry in section.entries) {
    final name = entry.key;
    _validateTokenName(sectionName, name);
    final token = _map(entry.value, 'Invalid token "$sectionName.$name"');
    _requireNum(token['width'], '$sectionName.$name.width');
    _requireNum(token['height'], '$sectionName.$name.height');
  }
}

void _validateTypography(
  Map<String, dynamic> typography, {
  required Set<String> availableColorKeys,
}) {
  if (typography.isEmpty) {
    throw StateError('"typography" must not be empty');
  }

  for (final entry in typography.entries) {
    final name = entry.key;
    _validateTokenName('typography', name);
    final token = _map(entry.value, 'Invalid typography token "typography.$name"');

    final size = _map(token['size'], 'Missing "typography.$name.size"');
    _requireNum(size['mobile'], 'typography.$name.size.mobile');
    _requireNum(size['tablet'], 'typography.$name.size.tablet');
    _requireNum(size['desktop'], 'typography.$name.size.desktop');

    final lineHeight = token['lineHeight'];
    if (lineHeight != null) {
      final lh = _map(lineHeight, 'Invalid "typography.$name.lineHeight"');
      _requireNum(lh['mobile'], 'typography.$name.lineHeight.mobile');
      _requireNum(lh['tablet'], 'typography.$name.lineHeight.tablet');
      _requireNum(lh['desktop'], 'typography.$name.lineHeight.desktop');
    }

    final letterSpacing = token['letterSpacing'];
    if (letterSpacing != null && letterSpacing is! num) {
      throw StateError(
        'Invalid letterSpacing at "typography.$name.letterSpacing": "$letterSpacing". Expected numeric value.',
      );
    }

    final weight = token['weight'];
    if (weight is! num) {
      throw StateError(
          'Invalid weight at "typography.$name.weight": "$weight". Expected numeric value like 400 or 700.');
    }

    final color = token['color'];
    if (color is! String || color.isEmpty) {
      throw StateError('Invalid color reference at "typography.$name.color": "$color"');
    }
    if (!availableColorKeys.contains(color)) {
      throw StateError(
        'Unknown color reference at "typography.$name.color": "$color". '
        'Add this key under themes.light.colors.',
      );
    }
  }
}

void _validateElevationAliases(
  Map<String, dynamic> data, {
  required Map<String, dynamic> elevations,
}) {
  if (!data.containsKey('elevationAliases')) {
    return;
  }

  final aliases = _map(data['elevationAliases'], 'Invalid "elevationAliases" in tokens.json');
  for (final entry in aliases.entries) {
    final alias = entry.key;
    _validateTokenName('elevationAliases', alias);

    if (elevations.containsKey(alias)) {
      throw StateError(
        'Elevation alias "elevationAliases.$alias" conflicts with base elevation token "$alias".',
      );
    }

    final target = entry.value;
    if (target is! String || target.isEmpty) {
      throw StateError(
        'Invalid alias target at "elevationAliases.$alias": "$target". Expected elevation key string.',
      );
    }

    if (!elevations.containsKey(target)) {
      throw StateError(
        'Unknown elevation alias target at "elevationAliases.$alias": "$target". '
        'Target must exist in "elevations".',
      );
    }
  }
}

void _requireNum(dynamic value, String path) {
  if (value is! num) {
    throw StateError('Invalid numeric value at "$path": "$value"');
  }
}

void _validateThemeGradients(Map<String, dynamic> themes) {
  final lightTheme = _map(themes['light'], 'Invalid theme definition for "light"');
  final hasLightGradients = lightTheme.containsKey('gradients');
  final themeEntries = _orderedEntries(themes);

  if (!hasLightGradients) {
    for (final entry in themeEntries) {
      final theme = _map(entry.value, 'Invalid theme definition for "${entry.key}"');
      if (theme.containsKey('gradients')) {
        throw StateError(
          'Theme "${entry.key}" defines gradients but "light" does not. '
          'Either define gradients for all themes or remove gradients entirely.',
        );
      }
    }
    return;
  }

  final lightGradients = _map(
    lightTheme['gradients'],
    'Invalid "themes.light.gradients" in tokens.json',
  );
  if (lightGradients.isEmpty) {
    throw StateError('"themes.light.gradients" must not be empty when provided');
  }

  final baselineKeys = <String>{};
  final lightColorKeys = _map(
    lightTheme['colors'],
    'Missing "themes.light.colors" in tokens.json',
  ).keys.cast<String>().toSet();
  for (final entry in lightGradients.entries) {
    final key = entry.key;
    _validateTokenName('themes.light.gradients', key);
    _validateGradientToken(
      entry.value,
      'themes.light.gradients.$key',
      availableColorKeys: lightColorKeys,
    );
    baselineKeys.add(key);
  }

  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    final theme = _map(themeEntry.value, 'Invalid theme definition for "$themeName"');
    if (!theme.containsKey('gradients')) {
      throw StateError(
        'Theme "$themeName" is missing "gradients". '
        'All themes must define gradients when light has gradients.',
      );
    }

    final gradients = _map(
      theme['gradients'],
      'Invalid "themes.$themeName.gradients" in tokens.json',
    );
    final themeColorKeys = _map(
      theme['colors'],
      'Missing "themes.$themeName.colors" in tokens.json',
    ).keys.cast<String>().toSet();

    final keys = gradients.keys.cast<String>().toSet();
    final missingKeys = baselineKeys.difference(keys);
    final extraKeys = keys.difference(baselineKeys);
    if (missingKeys.isNotEmpty || extraKeys.isNotEmpty) {
      throw StateError(
        'Theme "$themeName" gradient keys must match "light" exactly. '
        'Missing: ${missingKeys.join(', ')}. Extra: ${extraKeys.join(', ')}.',
      );
    }

    for (final gradientEntry in gradients.entries) {
      final gradientKey = gradientEntry.key;
      _validateTokenName('themes.$themeName.gradients', gradientKey);
      _validateGradientToken(
        gradientEntry.value,
        'themes.$themeName.gradients.$gradientKey',
        availableColorKeys: themeColorKeys,
      );
    }
  }
}

void _validateThemeShadows(Map<String, dynamic> themes) {
  final lightTheme = _map(themes['light'], 'Invalid theme definition for "light"');
  final hasLightShadows = lightTheme.containsKey('shadows');
  final themeEntries = _orderedEntries(themes);

  if (!hasLightShadows) {
    for (final entry in themeEntries) {
      final theme = _map(entry.value, 'Invalid theme definition for "${entry.key}"');
      if (theme.containsKey('shadows')) {
        throw StateError(
          'Theme "${entry.key}" defines shadows but "light" does not. '
          'Either define shadows for all themes or remove shadows entirely.',
        );
      }
    }
    return;
  }

  final lightShadows = _map(
    lightTheme['shadows'],
    'Invalid "themes.light.shadows" in tokens.json',
  );
  if (lightShadows.isEmpty) {
    throw StateError('"themes.light.shadows" must not be empty when provided');
  }

  final lightColorKeys = _map(
    lightTheme['colors'],
    'Missing "themes.light.colors" in tokens.json',
  ).keys.cast<String>().toSet();

  final baselineKeys = <String>{};
  for (final entry in lightShadows.entries) {
    final key = entry.key;
    _validateTokenName('themes.light.shadows', key);
    _validateShadowToken(
      entry.value,
      'themes.light.shadows.$key',
      availableColorKeys: lightColorKeys,
    );
    baselineKeys.add(key);
  }

  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    final theme = _map(themeEntry.value, 'Invalid theme definition for "$themeName"');
    if (!theme.containsKey('shadows')) {
      throw StateError(
        'Theme "$themeName" is missing "shadows". '
        'All themes must define shadows when light has shadows.',
      );
    }

    final shadows = _map(
      theme['shadows'],
      'Invalid "themes.$themeName.shadows" in tokens.json',
    );
    final themeColorKeys = _map(
      theme['colors'],
      'Missing "themes.$themeName.colors" in tokens.json',
    ).keys.cast<String>().toSet();

    final keys = shadows.keys.cast<String>().toSet();
    final missingKeys = baselineKeys.difference(keys);
    final extraKeys = keys.difference(baselineKeys);
    if (missingKeys.isNotEmpty || extraKeys.isNotEmpty) {
      throw StateError(
        'Theme "$themeName" shadow keys must match "light" exactly. '
        'Missing: ${missingKeys.join(', ')}. Extra: ${extraKeys.join(', ')}.',
      );
    }

    for (final shadowEntry in shadows.entries) {
      final shadowKey = shadowEntry.key;
      _validateTokenName('themes.$themeName.shadows', shadowKey);
      _validateShadowToken(
        shadowEntry.value,
        'themes.$themeName.shadows.$shadowKey',
        availableColorKeys: themeColorKeys,
      );
    }
  }
}

void _validateShadowToken(
  dynamic value,
  String path, {
  required Set<String> availableColorKeys,
}) {
  final token = _map(value, 'Invalid shadow token at "$path"');
  final layers = token['layers'];
  if (layers is! List || layers.isEmpty) {
    throw StateError('Shadow "$path" must define a non-empty "layers" list.');
  }

  for (var i = 0; i < layers.length; i++) {
    final layer = _map(layers[i], 'Invalid shadow layer at "$path.layers[$i]"');
    _requireNum(layer['x'], '$path.layers[$i].x');
    _requireNum(layer['y'], '$path.layers[$i].y');
    _requireNum(layer['blur'], '$path.layers[$i].blur');
    _requireNum(layer['spread'], '$path.layers[$i].spread');
    _validateGradientColorValue(
      layer['color'],
      '$path.layers[$i].color',
      availableColorKeys: availableColorKeys,
    );

    final opacity = layer['opacity'];
    if (opacity != null) {
      if (opacity is! num || opacity < 0 || opacity > 1) {
        throw StateError('Shadow opacity "$path.layers[$i].opacity" must be between 0 and 1.');
      }
    }
  }
}

void _validateGradientToken(
  dynamic value,
  String path, {
  required Set<String> availableColorKeys,
}) {
  final token = _map(value, 'Invalid gradient token at "$path"');
  final type = token['type'];
  const allowedTypes = {'linear', 'radial', 'sweep'};
  if (type is! String || !allowedTypes.contains(type)) {
    throw StateError(
      'Invalid gradient type at "$path.type": "$type". Allowed: linear, radial, sweep.',
    );
  }

  final colors = token['colors'];
  if (colors is! List || colors.length < 2) {
    throw StateError('Gradient "$path" must define at least two colors.');
  }
  for (var i = 0; i < colors.length; i++) {
    _validateGradientColorValue(
      colors[i],
      '$path.colors[$i]',
      availableColorKeys: availableColorKeys,
    );
  }

  final stops = token['stops'];
  if (stops != null) {
    if (stops is! List || stops.length != colors.length) {
      throw StateError(
        'Gradient "$path.stops" must be a list with the same length as colors.',
      );
    }
    for (var i = 0; i < stops.length; i++) {
      final stop = stops[i];
      if (stop is! num || stop < 0 || stop > 1) {
        throw StateError('Gradient stop "$path.stops[$i]" must be a number between 0 and 1.');
      }
      if (i > 0 && stop < (stops[i - 1] as num)) {
        throw StateError('Gradient stops at "$path.stops" must be in ascending order.');
      }
    }
  }

  if (type == 'linear') {
    final begin = token['begin'];
    final end = token['end'];
    if (begin is! String || !_isAllowedAlignment(begin)) {
      throw StateError('Invalid linear gradient begin at "$path.begin": "$begin"');
    }
    if (end is! String || !_isAllowedAlignment(end)) {
      throw StateError('Invalid linear gradient end at "$path.end": "$end"');
    }
  }

  if (type == 'radial') {
    final center = token['center'];
    if (center != null && (center is! String || !_isAllowedAlignment(center))) {
      throw StateError('Invalid radial gradient center at "$path.center": "$center"');
    }
    final radius = token['radius'];
    if (radius is! num || radius <= 0) {
      throw StateError('Invalid radial gradient radius at "$path.radius": "$radius"');
    }
  }

  if (type == 'sweep') {
    final center = token['center'];
    if (center != null && (center is! String || !_isAllowedAlignment(center))) {
      throw StateError('Invalid sweep gradient center at "$path.center": "$center"');
    }
    final startAngle = token['startAngle'];
    final endAngle = token['endAngle'];
    if (startAngle != null && startAngle is! num) {
      throw StateError('Invalid sweep gradient startAngle at "$path.startAngle": "$startAngle"');
    }
    if (endAngle != null && endAngle is! num) {
      throw StateError('Invalid sweep gradient endAngle at "$path.endAngle": "$endAngle"');
    }
  }
}

void _validateGradientColorValue(
  dynamic value,
  String path, {
  required Set<String> availableColorKeys,
}) {
  if (value is! String || value.isEmpty) {
    throw StateError('Invalid gradient color at "$path": "$value"');
  }

  if (_hexColorRegex.hasMatch(value)) {
    return;
  }

  if (!availableColorKeys.contains(value)) {
    throw StateError(
      'Unknown gradient color reference at "$path": "$value". '
      'Use #RRGGBB or one of: ${availableColorKeys.join(', ')}',
    );
  }
}

bool _isAllowedAlignment(String value) {
  const allowed = {
    'topLeft',
    'topCenter',
    'topRight',
    'centerLeft',
    'center',
    'centerRight',
    'bottomLeft',
    'bottomCenter',
    'bottomRight',
  };
  return allowed.contains(value);
}

// ---------------- COLORS ----------------

void generateColors(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final themeEntries = _orderedEntries(themes);
  if (themeEntries.isEmpty) {
    throw StateError('tokens.json must define at least one theme');
  }

  final allColorKeys = <String>{};
  for (final themeEntry in themeEntries) {
    final theme = _map(themeEntry.value, 'Invalid theme definition for "${themeEntry.key}"');
    final colors =
        _map(theme['colors'], 'Missing "themes.${themeEntry.key}.colors" in tokens.json');
    allColorKeys.addAll(colors.keys.cast<String>());
  }

  final sortedColorKeys = allColorKeys.toList();

  final buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();
  buffer.writeln('abstract class ${_themeBaseClassName()} {');
  buffer.writeln('  const ${_themeBaseClassName()}();');
  for (final key in sortedColorKeys) {
    buffer.writeln('  Color get $key;');
  }
  buffer.writeln('}');
  buffer.writeln();

  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    final colors = _map(
      _map(themeEntry.value, 'Invalid theme definition for "$themeName"')['colors'],
      'Missing "themes.$themeName.colors" in tokens.json',
    );
    final className = _themeClassName(themeName);
    buffer.writeln('class $className extends ${_themeBaseClassName()} {');
    buffer.writeln('  const $className();');
    for (final key in sortedColorKeys) {
      final value = colors[key];
      if (value == null) {
        throw StateError('Missing "themes.$themeName.colors.$key" in tokens.json');
      }
      buffer.writeln('  @override');
      buffer.writeln('  Color get $key => const Color(0xff${value.toString().substring(1)});');
    }
    buffer.writeln('}');
    if (themeEntry != themeEntries.last) {
      buffer.writeln();
    }
  }

  writeFile('generated_color_tokens.dart', buffer.toString());
}

// ---------------- GRADIENTS ----------------

void generateGradients(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final themeEntries = _orderedEntries(themes);
  if (themeEntries.isEmpty) {
    throw StateError('tokens.json must define at least one theme');
  }

  final lightTheme = _map(themes['light'], 'Missing "themes.light" in tokens.json');
  final hasGradients = lightTheme.containsKey('gradients');
  final gradientKeys = <String>[];

  if (hasGradients) {
    final lightGradients = _map(
      lightTheme['gradients'],
      'Missing "themes.light.gradients" in tokens.json',
    );
    gradientKeys.addAll(lightGradients.keys.cast<String>());
  }

  final buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();
  buffer.writeln("import '../theme/app_theme_extension.dart';");
  buffer.writeln();
  buffer.writeln('abstract class ${_themeGradientBaseClassName()} {');
  buffer.writeln('  const ${_themeGradientBaseClassName()}();');
  for (final key in gradientKeys) {
    buffer.writeln('  Gradient $key(context);');
  }
  buffer.writeln('}');
  buffer.writeln();

  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    final theme = _map(themeEntry.value, 'Invalid theme definition for "$themeName"');
    final gradients = hasGradients
        ? _map(theme['gradients'], 'Missing "themes.$themeName.gradients" in tokens.json')
        : <String, dynamic>{};

    final className = _themeGradientClassName(themeName);
    buffer.writeln('class $className extends ${_themeGradientBaseClassName()} {');
    buffer.writeln('  const $className();');

    for (final key in gradientKeys) {
      final token = _map(
        gradients[key],
        'Missing "themes.$themeName.gradients.$key" in tokens.json',
      );
      buffer.writeln('  @override');
      buffer.writeln('  Gradient $key(context) {');
      buffer.writeln('    return ${_gradientExpression(token)};');
      buffer.writeln('  }');
    }

    buffer.writeln('}');
    if (themeEntry != themeEntries.last) {
      buffer.writeln();
    }
  }

  writeFile('generated_gradient_tokens.dart', buffer.toString());
}

String _gradientExpression(Map<String, dynamic> token) {
  final type = token['type'] as String;
  final colorValues = (token['colors'] as List).cast<dynamic>();
  final colorsExpr = _gradientColorsExpression(colorValues);
  final stops = token['stops'] as List?;
  final stopsExpr = stops == null ? null : _constNumListExpression(stops.cast<num>());

  if (type == 'linear') {
    final begin = _alignmentExpression(token['begin'] as String);
    final end = _alignmentExpression(token['end'] as String);
    return 'LinearGradient(begin: $begin, end: $end, colors: $colorsExpr${stopsExpr == null ? '' : ', stops: $stopsExpr'})';
  }

  if (type == 'radial') {
    final centerValue = token['center'] as String?;
    final center = _alignmentExpression(centerValue ?? 'center');
    final radius = token['radius'] as num;
    return 'RadialGradient(center: $center, radius: ${radius.toDouble()}, colors: $colorsExpr${stopsExpr == null ? '' : ', stops: $stopsExpr'})';
  }

  final centerValue = token['center'] as String?;
  final center = _alignmentExpression(centerValue ?? 'center');
  final startAngle = token['startAngle'] as num?;
  final endAngle = token['endAngle'] as num?;
  final startAnglePart = startAngle == null ? '' : ', startAngle: ${startAngle.toDouble()}';
  final endAnglePart = endAngle == null ? '' : ', endAngle: ${endAngle.toDouble()}';
  return 'SweepGradient(center: $center, colors: $colorsExpr${stopsExpr == null ? '' : ', stops: $stopsExpr'}$startAnglePart$endAnglePart)';
}

String _gradientColorsExpression(List<dynamic> values) {
  final resolved = values.map(_gradientColorExpression).join(', ');
  return '[$resolved]';
}

String _gradientColorExpression(dynamic value) {
  if (value is! String || value.isEmpty) {
    throw StateError('Invalid gradient color value "$value"');
  }

  if (_hexColorRegex.hasMatch(value)) {
    return 'const Color(0xff${value.substring(1)})';
  }

  return 'Theme.of(context).extension<AppThemeExtension>()!.colors.$value';
}

String _constNumListExpression(List<num> values) {
  final list = values.map((v) => v.toDouble().toString()).join(', ');
  return 'const [$list]';
}

String _alignmentExpression(String value) {
  switch (value) {
    case 'topLeft':
      return 'Alignment.topLeft';
    case 'topCenter':
      return 'Alignment.topCenter';
    case 'topRight':
      return 'Alignment.topRight';
    case 'centerLeft':
      return 'Alignment.centerLeft';
    case 'center':
      return 'Alignment.center';
    case 'centerRight':
      return 'Alignment.centerRight';
    case 'bottomLeft':
      return 'Alignment.bottomLeft';
    case 'bottomCenter':
      return 'Alignment.bottomCenter';
    case 'bottomRight':
      return 'Alignment.bottomRight';
    default:
      throw StateError('Unsupported alignment token "$value"');
  }
}

// ---------------- SHADOWS ----------------

void generateShadows(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final themeEntries = _orderedEntries(themes);
  if (themeEntries.isEmpty) {
    throw StateError('tokens.json must define at least one theme');
  }

  final lightTheme = _map(themes['light'], 'Missing "themes.light" in tokens.json');
  final hasShadows = lightTheme.containsKey('shadows');
  final shadowKeys = <String>[];

  if (hasShadows) {
    final lightShadows = _map(
      lightTheme['shadows'],
      'Missing "themes.light.shadows" in tokens.json',
    );
    shadowKeys.addAll(lightShadows.keys.cast<String>());
  }

  final buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();
  buffer.writeln("import '../theme/app_theme_extension.dart';");
  buffer.writeln();
  buffer.writeln('abstract class ${_themeShadowBaseClassName()} {');
  buffer.writeln('  const ${_themeShadowBaseClassName()}();');
  for (final key in shadowKeys) {
    buffer.writeln('  List<BoxShadow> $key(context);');
  }
  buffer.writeln('}');
  buffer.writeln();

  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    final theme = _map(themeEntry.value, 'Invalid theme definition for "$themeName"');
    final shadows = hasShadows
        ? _map(theme['shadows'], 'Missing "themes.$themeName.shadows" in tokens.json')
        : <String, dynamic>{};

    final className = _themeShadowClassName(themeName);
    buffer.writeln('class $className extends ${_themeShadowBaseClassName()} {');
    buffer.writeln('  const $className();');

    for (final key in shadowKeys) {
      final token = _map(
        shadows[key],
        'Missing "themes.$themeName.shadows.$key" in tokens.json',
      );
      final layers = token['layers'] as List;
      buffer.writeln('  @override');
      buffer.writeln('  List<BoxShadow> $key(context) {');
      buffer.writeln('    return ${_shadowLayersExpression(layers)};');
      buffer.writeln('  }');
    }

    buffer.writeln('}');
    if (themeEntry != themeEntries.last) {
      buffer.writeln();
    }
  }

  writeFile('generated_shadow_tokens.dart', buffer.toString());
}

String _shadowLayersExpression(List<dynamic> layers) {
  final values = layers
      .map((layer) => _shadowLayerExpression(_map(layer, 'Invalid shadow layer in tokens.json')))
      .join(', ');
  return '[$values]';
}

String _shadowLayerExpression(Map<String, dynamic> layer) {
  final x = (layer['x'] as num).toDouble();
  final y = (layer['y'] as num).toDouble();
  final blur = (layer['blur'] as num).toDouble();
  final spread = (layer['spread'] as num).toDouble();
  final opacity = layer['opacity'] as num?;
  final colorExpr = _shadowColorExpression(layer['color'], opacity);

  return 'BoxShadow(color: $colorExpr, offset: Offset($x, $y), blurRadius: $blur, spreadRadius: $spread)';
}

String _shadowColorExpression(dynamic value, num? opacity) {
  final base = _gradientColorExpression(value);
  if (opacity == null) {
    return base;
  }
  return '$base.withValues(alpha: ${opacity.toDouble()})';
}

// ---------------- ELEVATIONS ----------------

void generateElevations(Map<String, dynamic> data) {
  final elevations = _map(data['elevations'], 'Missing "elevations" in tokens.json');
  final elevationAliases = data.containsKey('elevationAliases')
      ? _map(data['elevationAliases'], 'Invalid "elevationAliases" in tokens.json')
      : <String, dynamic>{};

  final aliasBuffer = StringBuffer();
  for (final entry in elevationAliases.entries) {
    final alias = entry.key;
    final target = entry.value as String;
    aliasBuffer.writeln('''
  double $alias(context) {
    return $target(context);
  }
''');
  }

  final output = '''
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedElevationTokens {
  const GeneratedElevationTokens();

${generateResponsiveDouble(elevations, sectionName: 'elevations')}
${aliasBuffer.toString()}
}
''';

  writeFile('generated_elevation_tokens.dart', output);
}

// ---------------- SPACING ----------------

void generateSpacing(Map<String, dynamic> data) {
  final spacing = _map(data['spacing'], 'Missing "spacing" in tokens.json');

  final output = '''
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedSpacingTokens {
  const GeneratedSpacingTokens();

${generateResponsiveDouble(spacing, sectionName: 'spacing')}
}
''';

  writeFile('generated_spacing_tokens.dart', output);
}

String generateResponsiveDouble(
  Map<String, dynamic> values, {
  required String sectionName,
}) {
  final buffer = StringBuffer();
  final memberNames = _tokenMemberMap(values.keys, sectionName);

  for (final entry in values.entries) {
    final key = memberNames[entry.key] ?? entry.key;
    final token = _map(entry.value, 'Invalid responsive token for "$key"');
    buffer.writeln('''
  double $key(context) {
    return ResponsiveValue<double>(
      mobile: ${token['mobile']},
      tablet: ${token['tablet']},
      desktop: ${token['desktop']},
    ).resolve(context).r;
  }
''');
  }

  return buffer.toString();
}

// ---------------- RADIUS ----------------

void generateRadius(Map<String, dynamic> data) {
  final radius = _map(data['radius'], 'Missing "radius" in tokens.json');

  final output = '''
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedRadiusTokens {
  const GeneratedRadiusTokens();

${generateResponsiveDouble(radius, sectionName: 'radius')}
}
''';

  writeFile('generated_radius_tokens.dart', output);
}

// ---------------- TYPOGRAPHY ----------------

void generateTypography(Map<String, dynamic> data) {
  final typography = _map(data['typography'], 'Missing "typography" in tokens.json');

  final output = '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';
import '../theme/app_theme_extension.dart';

class GeneratedTypographyTokens {
  const GeneratedTypographyTokens();

${generateTextStyles(typography)}
}
''';

  writeFile('generated_typography_tokens.dart', output);
}

String generateTextStyles(Map<String, dynamic> values) {
  final buffer = StringBuffer();
  final memberNames = _tokenMemberMap(values.keys, 'typography');

  for (final entry in values.entries) {
    final name = memberNames[entry.key] ?? entry.key;
    final token = _map(entry.value, 'Invalid typography token for "$name"');
    final size = _map(token['size'], 'Missing typography size for "$name"');
    final lineHeight = token['lineHeight'] == null
        ? null
        : _map(token['lineHeight'], 'Invalid typography lineHeight for "$name"');
    final colorName = token['color'] as String?;

    if (colorName == null) {
      throw StateError('Missing typography color for "$name"');
    }

    final fontSizeExpr = '''ResponsiveValue<double>(
      mobile: ${size['mobile']},
      tablet: ${size['tablet']},
      desktop: ${size['desktop']},
    ).resolve(context).sp''';

    final lineHeightBlock = lineHeight == null
        ? ''
        : '''
    final lineHeight = ResponsiveValue<double>(
      mobile: ${lineHeight['mobile']},
      tablet: ${lineHeight['tablet']},
      desktop: ${lineHeight['desktop']},
    ).resolve(context).sp;
''';

    final lineHeightStyle = lineHeight == null ? '' : '\n      height: lineHeight / fontSize,';

    final letterSpacing = token['letterSpacing'];
    final letterSpacingStyle =
        letterSpacing == null ? '' : '\n      letterSpacing: ${letterSpacing.toString()}.sp,';

    buffer.writeln('''
  TextStyle $name(context) {
    final fontSize = $fontSizeExpr;
$lineHeightBlock
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w${token['weight']},
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.$colorName,$lineHeightStyle$letterSpacingStyle
    );
  }
''');
  }

  return buffer.toString();
}

// ---------------- DIMENSIONS ----------------

void generateDimensions(Map<String, dynamic> data) {
  final dimensions = _map(data['dimensions'], 'Missing "dimensions" in tokens.json');

  final output = '''
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedDimensionTokens {
  const GeneratedDimensionTokens();

${generateDimensionsCode(dimensions)}
}
''';

  writeFile('generated_dimension_tokens.dart', output);
}

String generateDimensionsCode(Map<String, dynamic> values) {
  final buffer = StringBuffer();
  final memberNames = _tokenMemberMap(values.keys, 'dimensions');

  for (final entry in values.entries) {
    final name = memberNames[entry.key] ?? entry.key;
    final token = _map(entry.value, 'Invalid dimension token for "$name"');
    final type = token['type'] as String?;

    final unit = switch (type) {
      'width' => '.w',
      'height' => '.h',
      _ => '.r',
    };

    buffer.writeln('''
  double $name(context) {
    return ResponsiveValue<double>(
      mobile: ${token['mobile']},
      tablet: ${token['tablet']},
      desktop: ${token['desktop']},
    ).resolve(context)$unit;
  }
''');
  }

  return buffer.toString();
}

// ---------------- WRAPPERS ----------------

void updateTokenWrappers(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final themeEntries = _orderedEntries(themes);
  if (themeEntries.isEmpty) {
    throw StateError('tokens.json must define at least one theme');
  }

  final lightThemeExists = themeEntries.any(
    (entry) => entry.key.toLowerCase() == 'light',
  );
  if (!lightThemeExists) {
    throw StateError('tokens.json must define a "light" theme for LightColorTokens');
  }

  final lightTheme = _map(themes['light'], 'Missing "themes.light" in tokens.json');
  final lightColors = _map(
    lightTheme['colors'],
    'Missing "themes.light.colors" in tokens.json',
  );
  final lightGradients = lightTheme.containsKey('gradients')
      ? _map(lightTheme['gradients'], 'Invalid "themes.light.gradients" in tokens.json')
      : <String, dynamic>{};
  final lightShadows = lightTheme.containsKey('shadows')
      ? _map(lightTheme['shadows'], 'Invalid "themes.light.shadows" in tokens.json')
      : <String, dynamic>{};

  final spacing = _map(data['spacing'], 'Missing "spacing" in tokens.json');
  final elevations = _map(data['elevations'], 'Missing "elevations" in tokens.json');
  final elevationAliases = data.containsKey('elevationAliases')
      ? _map(data['elevationAliases'], 'Invalid "elevationAliases" in tokens.json')
      : <String, dynamic>{};
  final radius = _map(data['radius'], 'Missing "radius" in tokens.json');
  final typography = _map(data['typography'], 'Missing "typography" in tokens.json');
  final dimensions = _map(data['dimensions'], 'Missing "dimensions" in tokens.json');

  final spacingMethodNames = _tokenMemberMap(spacing.keys, 'spacing').values;
  final radiusMethodNames = _tokenMemberMap(radius.keys, 'radius').values;
  final typographyMethodNames = _tokenMemberMap(typography.keys, 'typography').values;
  final dimensionMethodNames = _tokenMemberMap(dimensions.keys, 'dimensions').values;
  final elevationMethodNames = _tokenMemberMap(elevations.keys, 'elevations').values;
  final elevationAliasMethodNames =
      _tokenMemberMap(elevationAliases.keys, 'elevationAliases').values;

  final colorExtraClasses = <Map<String, dynamic>>[];
  final gradientExtraClasses = <Map<String, dynamic>>[];
  final shadowExtraClasses = <Map<String, dynamic>>[];
  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    if (themeName.toLowerCase() == 'light') {
      continue;
    }
    colorExtraClasses.add({
      'className': _tokenThemeClassName(themeName),
      'extends': _themeClassName(themeName),
      'themeKey': themeName,
    });
    gradientExtraClasses.add({
      'className': _tokenGradientThemeClassName(themeName),
      'extends': _themeGradientClassName(themeName),
      'themeKey': themeName,
    });
    shadowExtraClasses.add({
      'className': _tokenShadowThemeClassName(themeName),
      'extends': _themeShadowClassName(themeName),
      'themeKey': themeName,
    });
  }

  final configs = {
    'color_tokens.dart': {
      'className': 'LightColorTokens',
      'extends': _themeClassName('light'),
      'imports': [
        '../generated/generated_color_tokens.dart',
        'package:flutter/material.dart',
      ],
      'extraClasses': colorExtraClasses,
    },
    'spacing_tokens.dart': {
      'className': 'SpacingTokens',
      'extends': 'GeneratedSpacingTokens',
      'imports': ['../generated/generated_spacing_tokens.dart'],
    },
    'gradient_tokens.dart': {
      'className': 'LightGradientTokens',
      'extends': _themeGradientClassName('light'),
      'imports': [
        '../generated/generated_gradient_tokens.dart',
      ],
      'extraClasses': gradientExtraClasses,
    },
    'shadow_tokens.dart': {
      'className': 'LightShadowTokens',
      'extends': _themeShadowClassName('light'),
      'imports': [
        '../generated/generated_shadow_tokens.dart',
      ],
      'extraClasses': shadowExtraClasses,
    },
    'radius_tokens.dart': {
      'className': 'RadiusTokens',
      'extends': 'GeneratedRadiusTokens',
      'imports': ['../generated/generated_radius_tokens.dart'],
    },
    'typography_tokens.dart': {
      'className': 'TypographyTokens',
      'extends': 'GeneratedTypographyTokens',
      'imports': ['../generated/generated_typography_tokens.dart'],
    },
    'dimension_tokens.dart': {
      'className': 'DimensionTokens',
      'extends': 'GeneratedDimensionTokens',
      'imports': ['../generated/generated_dimension_tokens.dart'],
    },
    'elevation_tokens.dart': {
      'className': 'ElevationTokens',
      'extends': 'GeneratedElevationTokens',
      'imports': ['../generated/generated_elevation_tokens.dart'],
    },
  };

  for (final entry in configs.entries) {
    final fileName = entry.key;
    final config = entry.value as Map<String, dynamic>;
    final file = File('lib/core/design_system/tokens/$fileName');
    final imports = (config['imports'] as List).cast<String>();
    final className = config['className'] as String;
    final extendsName = config['extends'] as String;
    final extraClasses =
        (config['extraClasses'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

    String content;

    if (file.existsSync()) {
      content = file.readAsStringSync();
    } else {
      content = '';
    }

    if (fileName == 'color_tokens.dart') {
      content = _cleanupCorruptColorBlock(content);
    } else if (fileName == 'gradient_tokens.dart') {
      content = content.replaceAll("import 'package:flutter/material.dart';\n", '');
    } else if (fileName == 'shadow_tokens.dart') {
      content = content.replaceAll("import 'package:flutter/material.dart';\n", '');
    }

    for (final importLine in imports) {
      final importStatement = "import '$importLine';";
      if (!content.contains(importStatement)) {
        content = '$importStatement\n$content';
      }
    }

    content = _ensureClass(content, className, extendsName);
    if (fileName == 'color_tokens.dart') {
      content = _ensureColorBaseClass(content);
      content = _ensureImplements(content, className, _tokenThemeBaseClassName());
    } else if (fileName == 'gradient_tokens.dart') {
      content = _ensureGradientBaseClass(content);
      content = _ensureImplements(content, className, _tokenGradientThemeBaseClassName());
    } else if (fileName == 'shadow_tokens.dart') {
      content = _ensureShadowBaseClass(content);
      content = _ensureImplements(content, className, _tokenShadowThemeBaseClassName());
    }

    for (final extraClass in extraClasses) {
      final extraName = extraClass['className'] as String;
      final extraExtends = extraClass['extends'] as String;
      content = _ensureClass(content, extraName, extraExtends);
      if (fileName == 'color_tokens.dart') {
        content = _ensureImplements(content, extraName, _tokenThemeBaseClassName());
      } else if (fileName == 'gradient_tokens.dart') {
        content = _ensureImplements(content, extraName, _tokenGradientThemeBaseClassName());
      } else if (fileName == 'shadow_tokens.dart') {
        content = _ensureImplements(content, extraName, _tokenShadowThemeBaseClassName());
      }
    }

    if (fileName == 'color_tokens.dart') {
      content = _ensureGetterOverrides(content, 'LightColorTokens', lightColors.keys);
      content = _removeStaleGetterOverrides(content, 'LightColorTokens', lightColors.keys);

      for (final extraClass in extraClasses) {
        final themeKey = extraClass['themeKey'] as String?;
        final classForTheme = extraClass['className'] as String;
        if (themeKey == null) {
          continue;
        }
        final theme = _map(themes[themeKey], 'Missing "themes.$themeKey" in tokens.json');
        final colors = _map(theme['colors'], 'Missing "themes.$themeKey.colors" in tokens.json');
        // For non-light theme wrappers, do not auto-inject properties.
        // Only add @override when a getter already exists in that class.
        content = _ensureGetterOverrides(content, classForTheme, colors.keys);
        content = _removeStaleGetterOverrides(content, classForTheme, colors.keys);
      }
    } else if (fileName == 'gradient_tokens.dart') {
      content = _ensureMethodOverrides(
        content,
        'LightGradientTokens',
        lightGradients.keys,
        'Gradient',
      );
      content = _removeStaleMethodOverrides(content, 'LightGradientTokens', lightGradients.keys);

      for (final extraClass in extraClasses) {
        final themeKey = extraClass['themeKey'] as String?;
        final classForTheme = extraClass['className'] as String;
        if (themeKey == null) {
          continue;
        }
        final theme = _map(themes[themeKey], 'Missing "themes.$themeKey" in tokens.json');
        final gradients = theme.containsKey('gradients')
            ? _map(theme['gradients'], 'Missing "themes.$themeKey.gradients" in tokens.json')
            : <String, dynamic>{};
        content = _ensureMethodOverrides(
          content,
          classForTheme,
          gradients.keys,
          'Gradient',
        );
        content = _removeStaleMethodOverrides(content, classForTheme, gradients.keys);
      }
    } else if (fileName == 'shadow_tokens.dart') {
      content = _ensureMethodOverrides(
        content,
        'LightShadowTokens',
        lightShadows.keys,
        'List<BoxShadow>',
      );
      content = _removeStaleMethodOverrides(content, 'LightShadowTokens', lightShadows.keys);

      for (final extraClass in extraClasses) {
        final themeKey = extraClass['themeKey'] as String?;
        final classForTheme = extraClass['className'] as String;
        if (themeKey == null) {
          continue;
        }
        final theme = _map(themes[themeKey], 'Missing "themes.$themeKey" in tokens.json');
        final shadows = theme.containsKey('shadows')
            ? _map(theme['shadows'], 'Missing "themes.$themeKey.shadows" in tokens.json')
            : <String, dynamic>{};
        content = _ensureMethodOverrides(
          content,
          classForTheme,
          shadows.keys,
          'List<BoxShadow>',
        );
        content = _removeStaleMethodOverrides(content, classForTheme, shadows.keys);
      }
    } else if (fileName == 'spacing_tokens.dart') {
      content = _ensureMethodOverrides(content, 'SpacingTokens', spacingMethodNames, 'double');
      content = _removeStaleMethodOverrides(content, 'SpacingTokens', spacingMethodNames);
    } else if (fileName == 'elevation_tokens.dart') {
      final allElevationNames = [...elevationMethodNames, ...elevationAliasMethodNames];
      content = _ensureMethodOverrides(
        content,
        'ElevationTokens',
        allElevationNames,
        'double',
      );
      content = _removeStaleMethodOverrides(content, 'ElevationTokens', allElevationNames);
    } else if (fileName == 'radius_tokens.dart') {
      content = _ensureMethodOverrides(content, 'RadiusTokens', radiusMethodNames, 'double');
      content = _removeStaleMethodOverrides(content, 'RadiusTokens', radiusMethodNames);
    } else if (fileName == 'typography_tokens.dart') {
      content = _ensureMethodOverrides(
        content,
        'TypographyTokens',
        typographyMethodNames,
        'TextStyle',
      );
      content = _removeStaleMethodOverrides(content, 'TypographyTokens', typographyMethodNames);
    } else if (fileName == 'dimension_tokens.dart') {
      content = _ensureMethodOverrides(content, 'DimensionTokens', dimensionMethodNames, 'double');
      content = _removeStaleMethodOverrides(content, 'DimensionTokens', dimensionMethodNames);
    }

    file.writeAsStringSync(content);
  }
}

String _ensureGetterOverrides(
  String content,
  String className,
  Iterable<dynamic> getterNames, {
  String returnType = 'Color',
}) {
  return _rewriteClassBody(content, className, (classBody) {
    var body = classBody;

    for (final nameValue in getterNames) {
      final name = nameValue.toString();
      final withOverride = RegExp(
        r'@override\s+' + returnType + r'\s+get\s+' + name + r'\s*=>',
        multiLine: true,
      );
      if (withOverride.hasMatch(body)) {
        continue;
      }

      final withoutOverride = RegExp(
        r'(^[ \t]*)' + returnType + r'\s+get\s+' + name + r'\s*=>',
        multiLine: true,
      );
      body = body.replaceFirstMapped(withoutOverride, (match) {
        final indent = match.group(1) ?? '  ';
        return '$indent@override\n${indent}$returnType get $name =>';
      });
    }

    return body;
  });
}

String _ensureMethodOverrides(
  String content,
  String className,
  Iterable<dynamic> methodNames,
  String returnType,
) {
  return _rewriteClassBody(content, className, (classBody) {
    var body = classBody;

    for (final nameValue in methodNames) {
      final name = nameValue.toString();
      final withOverride = RegExp(
        r'@override\s+' + returnType + r'\s+' + name + r'\s*\(context\)\s*\{',
        multiLine: true,
      );
      if (withOverride.hasMatch(body)) {
        continue;
      }

      final withoutOverride = RegExp(
        r'(^[ \t]*)' + returnType + r'\s+' + name + r'\s*\(context\)\s*\{',
        multiLine: true,
      );
      body = body.replaceFirstMapped(withoutOverride, (match) {
        final indent = match.group(1) ?? '  ';
        return '$indent@override\n$indent$returnType $name(context) {';
      });
    }

    return body;
  });
}

String _removeStaleGetterOverrides(
  String content,
  String className,
  Iterable<dynamic> validGetterNames,
) {
  final allowed = validGetterNames.map((e) => e.toString()).toSet();

  return _rewriteClassBody(content, className, (classBody) {
    final pattern = RegExp(
      r'(^[ \t]*)@override\s*\n\1([A-Za-z0-9_<>,? ]+)\s+get\s+([A-Za-z_][A-Za-z0-9_]*)\s*=>',
      multiLine: true,
    );

    return classBody.replaceAllMapped(pattern, (match) {
      final indent = match.group(1) ?? '  ';
      final returnType = (match.group(2) ?? '').trim();
      final getterName = match.group(3) ?? '';

      if (allowed.contains(getterName)) {
        return match.group(0)!;
      }

      return '$indent$returnType get $getterName =>';
    });
  });
}

String _removeStaleMethodOverrides(
  String content,
  String className,
  Iterable<dynamic> validMethodNames,
) {
  final allowed = validMethodNames.map((e) => e.toString()).toSet();

  return _rewriteClassBody(content, className, (classBody) {
    final pattern = RegExp(
      r'(^[ \t]*)@override\s*\n\1([A-Za-z0-9_<>,? ]+)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(context\)\s*\{',
      multiLine: true,
    );

    return classBody.replaceAllMapped(pattern, (match) {
      final indent = match.group(1) ?? '  ';
      final returnType = (match.group(2) ?? '').trim();
      final methodName = match.group(3) ?? '';

      if (allowed.contains(methodName)) {
        return match.group(0)!;
      }

      return '$indent$returnType $methodName(context) {';
    });
  });
}

String _rewriteClassBody(
  String content,
  String className,
  String Function(String classBody) rewrite,
) {
  final classMatch = RegExp(
    r'class\s+' + className + r'\b\s+extends\s+\w+(?:\s+implements\s+[^\{]+)?\s*\{',
  ).firstMatch(content);

  if (classMatch == null) {
    return content;
  }

  final openBraceIndex = classMatch.end - 1;
  int depth = 0;
  int closeBraceIndex = -1;

  for (int i = openBraceIndex; i < content.length; i++) {
    final char = content[i];
    if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
      if (depth == 0) {
        closeBraceIndex = i;
        break;
      }
    }
  }

  if (closeBraceIndex == -1) {
    return content;
  }

  final classBody = content.substring(openBraceIndex + 1, closeBraceIndex);
  final newBody = rewrite(classBody);

  return content.substring(0, openBraceIndex + 1) + newBody + content.substring(closeBraceIndex);
}

String _ensureColorBaseClass(String content) {
  const decl = 'abstract class ColorTokensBase extends GeneratedThemeColorTokens';
  if (content.contains(decl)) {
    return content;
  }

  final classBlock = StringBuffer()
    ..writeln('abstract class ${_tokenThemeBaseClassName()} extends GeneratedThemeColorTokens {')
    ..writeln('  const ${_tokenThemeBaseClassName()}();')
    ..writeln('}')
    ..writeln();

  final importRegex = RegExp(r'^(import\s+[\s\S]*?;\n)+', multiLine: true);
  final match = importRegex.firstMatch(content);
  if (match == null) {
    return '${classBlock.toString()}$content';
  }

  final importsBlock = content.substring(0, match.end);
  final remaining = content.substring(match.end);
  return '$importsBlock\n${classBlock.toString()}$remaining';
}

String _ensureGradientBaseClass(String content) {
  const decl = 'abstract class GradientTokensBase extends GeneratedThemeGradientTokens';
  if (content.contains(decl)) {
    return content;
  }

  final classBlock = StringBuffer()
    ..writeln(
        'abstract class ${_tokenGradientThemeBaseClassName()} extends GeneratedThemeGradientTokens {')
    ..writeln('  const ${_tokenGradientThemeBaseClassName()}();')
    ..writeln('}')
    ..writeln();

  final importRegex = RegExp(r'^(import\s+[\s\S]*?;\n)+', multiLine: true);
  final match = importRegex.firstMatch(content);
  if (match == null) {
    return '${classBlock.toString()}$content';
  }

  final importsBlock = content.substring(0, match.end);
  final remaining = content.substring(match.end);
  return '$importsBlock\n${classBlock.toString()}$remaining';
}

String _ensureShadowBaseClass(String content) {
  const decl = 'abstract class ShadowTokensBase extends GeneratedThemeShadowTokens';
  if (content.contains(decl)) {
    return content;
  }

  final classBlock = StringBuffer()
    ..writeln(
        'abstract class ${_tokenShadowThemeBaseClassName()} extends GeneratedThemeShadowTokens {')
    ..writeln('  const ${_tokenShadowThemeBaseClassName()}();')
    ..writeln('}')
    ..writeln();

  final importRegex = RegExp(r'^(import\s+[\s\S]*?;\n)+', multiLine: true);
  final match = importRegex.firstMatch(content);
  if (match == null) {
    return '${classBlock.toString()}$content';
  }

  final importsBlock = content.substring(0, match.end);
  final remaining = content.substring(match.end);
  return '$importsBlock\n${classBlock.toString()}$remaining';
}

String _ensureImplements(String content, String className, String interfaceName) {
  final pattern = RegExp(
    r'class\s+' + className + r'\b\s+extends\s+(\w+)(?:\s+implements\s+([^\{]+))?\s*\{',
  );

  return content.replaceFirstMapped(pattern, (match) {
    final extendsName = match.group(1)!;
    final existingImplements = match.group(2)?.trim();

    if (existingImplements != null && existingImplements.contains(interfaceName)) {
      return match.group(0)!;
    }

    if (existingImplements == null || existingImplements.isEmpty) {
      return 'class $className extends $extendsName implements $interfaceName {';
    }

    return 'class $className extends $extendsName implements $existingImplements, $interfaceName {';
  });
}

String _ensureClass(String content, String className, String extendsName) {
  final classPattern = RegExp(
    r'class\s+' + className + r'\b(?:\s+extends\s+\w+)?(?:\s+implements\s+[^\{]+)?',
  );
  final classReplacement = 'class $className extends $extendsName';

  if (classPattern.hasMatch(content)) {
    return content.replaceFirst(classPattern, classReplacement);
  }

  final buffer = StringBuffer(content);
  if (buffer.isNotEmpty && !buffer.toString().endsWith('\n')) {
    buffer.writeln();
  }
  buffer.writeln();
  buffer.writeln('$classReplacement {');
  buffer.writeln('  const $className();');
  buffer.writeln('}');
  return buffer.toString();
}

String _cleanupCorruptColorBlock(String content) {
  final corruptBlock = RegExp(
    r'abstract class ColorTokens extends GeneratedLightColorTokensBase extends GeneratedThemeColorTokens \{[\s\S]*?\}\s*',
  );
  final renamedLegacyClass = RegExp(
    r'class\s+ColorTokens\s+extends\s+GeneratedLightColorTokens\s+implements\s+ColorTokensBase\s*\{',
  );
  return content.replaceAll(corruptBlock, '').replaceAll(
        renamedLegacyClass,
        'class LightColorTokens extends GeneratedLightColorTokens implements ColorTokensBase {',
      );
}

void updateTokensBarrel() {
  final file = File('lib/core/design_system/tokens/tokens.dart');
  final exports = [
    'color_tokens.dart',
    'dimension_tokens.dart',
    'elevation_tokens.dart',
    'gradient_tokens.dart',
    'radius_tokens.dart',
    'shadow_tokens.dart',
    'spacing_tokens.dart',
    'typography_tokens.dart',
  ];

  String content = file.existsSync() ? file.readAsStringSync() : '';

  for (final exportLine in exports) {
    final statement = "export '$exportLine';";
    if (!content.contains(statement)) {
      if (content.isNotEmpty && !content.endsWith('\n')) {
        content += '\n';
      }
      content = '$statement\n$content';
    }
  }

  file.writeAsStringSync(content);
}

// ---------------- THEME FILES ----------------

void updateAppThemeExtension(Map<String, dynamic> data) {
  final output = '''
import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final ${_tokenThemeBaseClassName()} colors;
  final ${_tokenGradientThemeBaseClassName()} gradients;
  final ${_tokenShadowThemeBaseClassName()} shadows;
  final SpacingTokens spacing;
  final RadiusTokens radius;
  final TypographyTokens typography;
  final DimensionTokens dimensions;
  final ElevationTokens elevations;

  const AppThemeExtension({
    required this.colors,
    required this.gradients,
    required this.shadows,
    required this.spacing,
    required this.radius,
    required this.typography,
    required this.dimensions,
    required this.elevations,
  });

  @override
  AppThemeExtension copyWith({
    ${_tokenThemeBaseClassName()}? colors,
    ${_tokenGradientThemeBaseClassName()}? gradients,
    ${_tokenShadowThemeBaseClassName()}? shadows,
    SpacingTokens? spacing,
    RadiusTokens? radius,
    TypographyTokens? typography,
    DimensionTokens? dimensions,
    ElevationTokens? elevations,
  }) {
    return AppThemeExtension(
      colors: colors ?? this.colors,
      gradients: gradients ?? this.gradients,
      shadows: shadows ?? this.shadows,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      typography: typography ?? this.typography,
      dimensions: dimensions ?? this.dimensions,
      elevations: elevations ?? this.elevations,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return t < 0.5 ? this : other;
  }
}
''';

  writeIfChanged('lib/core/design_system/theme/app_theme_extension.dart', output);
}

void updateAppTheme(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final themeEntries = _orderedEntries(themes);
  if (themeEntries.isEmpty) {
    throw StateError('tokens.json must define at least one theme');
  }

  final designSizes = data.containsKey('designSizes')
      ? _map(data['designSizes'], 'Invalid "designSizes" in tokens.json')
      : {
          'mobile': {'width': 390, 'height': 844},
          'tablet': {'width': 834, 'height': 1194},
          'desktop': {'width': 1440, 'height': 1024},
        };

  final themeFields = <String>[];
  final themeMapEntries = <String>[];

  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    final fieldName = _camelCase(themeName);
    final className = _tokenThemeClassName(themeName);
    final brightness =
        themeName.toLowerCase().contains('dark') ? 'Brightness.dark' : 'Brightness.light';

    themeFields.add('''
  static final ThemeData $fieldName = _buildTheme(
    colors: const $className(),
    gradients: const ${_tokenGradientThemeClassName(themeName)}(),
    shadows: const ${_tokenShadowThemeClassName(themeName)}(),
    brightness: $brightness,
  );
''');

    themeMapEntries.add("    '$themeName': $fieldName,");
  }

  final output = '''
import 'package:flutter/material.dart';

import '../responsive/responsive_value.dart';
import '../tokens/tokens.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static const SpacingTokens spacing = SpacingTokens();
  static const RadiusTokens radius = RadiusTokens();
  static const TypographyTokens typography = TypographyTokens();
  static const DimensionTokens dimensions = DimensionTokens();
  static const ElevationTokens elevations = ElevationTokens();

  static const Size mobileDesignSize = Size(${designSizes['mobile']['width']}, ${designSizes['mobile']['height']});
  static const Size tabletDesignSize = Size(${designSizes['tablet']['width']}, ${designSizes['tablet']['height']});
  static const Size desktopDesignSize = Size(${designSizes['desktop']['width']}, ${designSizes['desktop']['height']});

${themeFields.join('\n')}
  static final Map<String, ThemeData> themes = {
${themeMapEntries.join('\n')}
  };

  static ThemeData theme(String themeName) => themes[themeName] ?? themes.values.first;

  static Size designSize(BuildContext context) {
    return ResponsiveValue<Size>(
      mobile: mobileDesignSize,
      tablet: tabletDesignSize,
      desktop: desktopDesignSize,
    ).resolve(context);
  }

  static ThemeData _buildTheme({
    required ${_tokenThemeBaseClassName()} colors,
    required ${_tokenGradientThemeBaseClassName()} gradients,
    required ${_tokenShadowThemeBaseClassName()} shadows,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: brightness == Brightness.dark
          ? ColorScheme.dark(
              primary: colors.primary,
              surface: colors.surface,
              error: colors.error,
            )
          : ColorScheme.light(
              primary: colors.primary,
              surface: colors.surface,
              error: colors.error,
            ),
      extensions: [
        AppThemeExtension(
          colors: colors,
          gradients: gradients,
          shadows: shadows,
          spacing: spacing,
          radius: radius,
          typography: typography,
          dimensions: dimensions,
          elevations: elevations,
        ),
      ],
    );
  }
}
''';

  writeIfChanged('lib/core/design_system/theme/app_theme.dart', output);
}

void updateContextExtension(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final spacing = _map(data['spacing'], 'Missing "spacing" in tokens.json');
  final radius = _map(data['radius'], 'Missing "radius" in tokens.json');
  final typography = _map(data['typography'], 'Missing "typography" in tokens.json');
  final dimensions = _map(data['dimensions'], 'Missing "dimensions" in tokens.json');
  final elevations = _map(data['elevations'], 'Missing "elevations" in tokens.json');
  final elevationAliases = data.containsKey('elevationAliases')
      ? _map(data['elevationAliases'], 'Invalid "elevationAliases" in tokens.json')
      : <String, dynamic>{};
  final lightTheme = _map(themes['light'], 'Missing "themes.light" in tokens.json');
  final lightGradients = lightTheme.containsKey('gradients')
      ? _map(lightTheme['gradients'], 'Invalid "themes.light.gradients" in tokens.json')
      : <String, dynamic>{};
  final lightShadows = lightTheme.containsKey('shadows')
      ? _map(lightTheme['shadows'], 'Invalid "themes.light.shadows" in tokens.json')
      : <String, dynamic>{};
  final gradientGetterBuffer = StringBuffer();
  for (final gradientName in lightGradients.keys) {
    gradientGetterBuffer.writeln(
      '  Gradient get $gradientName => context.appTheme.gradients.$gradientName(context);',
    );
    gradientGetterBuffer.writeln();
  }
  final shadowGetterBuffer = StringBuffer();
  for (final shadowName in lightShadows.keys) {
    shadowGetterBuffer.writeln(
      '  List<BoxShadow> get $shadowName => context.appTheme.shadows.$shadowName(context);',
    );
    shadowGetterBuffer.writeln();
  }
  final elevationGetterBuffer = StringBuffer();
  final elevationMemberMap = _tokenMemberMap(elevations.keys, 'elevations');
  for (final elevationName in elevationMemberMap.values) {
    elevationGetterBuffer.writeln(
      '  double get $elevationName => context.appTheme.elevations.$elevationName(context);',
    );
    elevationGetterBuffer.writeln();
  }
  final elevationAliasMemberMap = _tokenMemberMap(elevationAliases.keys, 'elevationAliases');
  for (final aliasName in elevationAliasMemberMap.values) {
    elevationGetterBuffer.writeln(
      '  double get $aliasName => context.appTheme.elevations.$aliasName(context);',
    );
    elevationGetterBuffer.writeln();
  }

  final spacingGetterBuffer = StringBuffer();
  final spacingMemberMap = _tokenMemberMap(spacing.keys, 'spacing');
  final spacingMethodNames = <String>{...spacingMemberMap.values};
  spacingMethodNames.addAll(
    _collectWrapperMethods('lib/core/design_system/tokens/spacing_tokens.dart', 'double'),
  );
  final orderedSpacingMethods = spacingMethodNames.toList()..sort();
  for (final spacingName in orderedSpacingMethods) {
    spacingGetterBuffer.writeln(
      '  double get $spacingName => context.appTheme.spacing.$spacingName(context);',
    );
    spacingGetterBuffer.writeln();
  }

  final radiusGetterBuffer = StringBuffer();
  final radiusMemberMap = _tokenMemberMap(radius.keys, 'radius');
  final radiusMethodNames = <String>{...radiusMemberMap.values};
  radiusMethodNames.addAll(
    _collectWrapperMethods('lib/core/design_system/tokens/radius_tokens.dart', 'double'),
  );
  final orderedRadiusMethods = radiusMethodNames.toList()..sort();
  for (final radiusName in orderedRadiusMethods) {
    radiusGetterBuffer.writeln(
      '  double get $radiusName => context.appTheme.radius.$radiusName(context);',
    );
    radiusGetterBuffer.writeln();
  }

  final typographyGetterBuffer = StringBuffer();
  final typographyMemberMap = _tokenMemberMap(typography.keys, 'typography');
  final typographyMethodNames = <String>{...typographyMemberMap.values};
  final manualTypographyMethods = _collectWrapperMethods(
    'lib/core/design_system/tokens/typography_tokens.dart',
    'TextStyle',
  );
  typographyMethodNames.addAll(manualTypographyMethods);

  final orderedTypographyMethods = typographyMethodNames.toList()..sort();
  for (final typoName in orderedTypographyMethods) {
    typographyGetterBuffer.writeln(
      '  TextStyle get $typoName => context.appTheme.typography.$typoName(context);',
    );
    typographyGetterBuffer.writeln();
  }

  final dimensionGetterBuffer = StringBuffer();
  final dimensionMemberMap = _tokenMemberMap(dimensions.keys, 'dimensions');
  final dimensionMethodNames = <String>{...dimensionMemberMap.values};
  dimensionMethodNames.addAll(
    _collectWrapperMethods('lib/core/design_system/tokens/dimension_tokens.dart', 'double'),
  );
  final orderedDimensionMethods = dimensionMethodNames.toList()..sort();
  for (final dimName in orderedDimensionMethods) {
    dimensionGetterBuffer.writeln(
      '  double get $dimName => context.appTheme.dimensions.$dimName(context);',
    );
    dimensionGetterBuffer.writeln();
  }

  final elevationMethodNames = <String>{
    ...elevationMemberMap.values,
    ...elevationAliasMemberMap.values,
  };
  elevationMethodNames.addAll(
    _collectWrapperMethods('lib/core/design_system/tokens/elevation_tokens.dart', 'double'),
  );
  final orderedElevationMethods = elevationMethodNames.toList()..sort();
  elevationGetterBuffer.clear();
  for (final elevationName in orderedElevationMethods) {
    elevationGetterBuffer.writeln(
      '  double get $elevationName => context.appTheme.elevations.$elevationName(context);',
    );
    elevationGetterBuffer.writeln();
  }

  final output = '''
import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../tokens/color_tokens.dart';

extension ContextExtension on BuildContext {
  AppThemeExtension get appTheme => Theme.of(this).extension<AppThemeExtension>()!;

  ${_tokenThemeBaseClassName()} get colors => appTheme.colors;

  GradientExtension get gradients => GradientExtension(this);

  ShadowExtension get shadows => ShadowExtension(this);

  SpaceExtension get space => SpaceExtension(this);

  RadiusExtension get radius => RadiusExtension(this);

  TypographyExtension get typo => TypographyExtension(this);

  DimensionExtension get dimensions => DimensionExtension(this);

  ElevationExtension get elevation => ElevationExtension(this);
}

class GradientExtension {
  final BuildContext context;

  GradientExtension(this.context);

${gradientGetterBuffer.toString()}}

class ShadowExtension {
  final BuildContext context;

  ShadowExtension(this.context);

${shadowGetterBuffer.toString()}}

class SpaceExtension {
  final BuildContext context;

  SpaceExtension(this.context);

${spacingGetterBuffer.toString()}}

class RadiusExtension {
  final BuildContext context;

  RadiusExtension(this.context);

${radiusGetterBuffer.toString()}}

class TypographyExtension {
  final BuildContext context;

  TypographyExtension(this.context);

${typographyGetterBuffer.toString()}}

class DimensionExtension {
  final BuildContext context;

  DimensionExtension(this.context);

${dimensionGetterBuffer.toString()}}

class ElevationExtension {
  final BuildContext context;

  ElevationExtension(this.context);

${elevationGetterBuffer.toString()}}
''';

  writeIfChanged('lib/core/design_system/extensions/context_extension.dart', output);
}

// ---------------- RESPONSIVE ----------------

void ensureResponsiveFiles() {
  writeIfChanged('lib/core/design_system/responsive/responsive.dart', '''
import 'package:flutter/widgets.dart';

class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1200;
}
''');

  writeIfChanged('lib/core/design_system/responsive/responsive_value.dart', '''
import 'package:flutter/widgets.dart';

class ResponsiveValue<T> {
  final T mobile;
  final T tablet;
  final T desktop;

  const ResponsiveValue({
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  T resolve(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 600) return mobile;
    if (width < 1200) return tablet;
    return desktop;
  }
}
''');
}

// ---------------- FILE HELPERS ----------------

void writeIfChanged(String path, String content) {
  final file = File(path);
  file.parent.createSync(recursive: true);

  if (file.existsSync()) {
    final existing = file.readAsStringSync();
    if (existing == content) {
      return;
    }
  }

  file.writeAsStringSync(content);
}

void writeFile(String name, String content) {
  final directory = Directory('lib/core/design_system/generated');

  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final file = File('${directory.path}/$name');
  file.writeAsStringSync(content);
}
