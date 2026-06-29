import 'dart:convert';
import 'dart:io';

// ❯ dart run lib/core/design_system/generator/generate_tokens.dart
void main() {
  final file = File('lib/core/design_system/generator/tokens.json');
  final data = jsonDecode(file.readAsStringSync());

  generateColors(data);

  generateSpacing(data);

  generateRadius(data);

  generateTypography(data);

  generateDimensions(data);

  updateTokenFiles();

  print("All tokens generated");
}

// ---------------- COLORS ----------------

void generateColors(Map data) {
  final light = data["themes"]["light"]["colors"];

  final dark = data["themes"]["dark"]["colors"];

  final output = """

import 'package:flutter/material.dart';


${generateColorClass("GeneratedLightColorTokens", light)}



${generateColorClass("GeneratedDarkColorTokens", dark)}

""";

  writeFile("generated_color_tokens.dart", output);
}

String generateColorClass(String name, Map values) {
  final buffer = StringBuffer();

  buffer.writeln("class $name {");

  buffer.writeln("const $name();");

  values.forEach((key, value) {
    buffer.writeln("""
Color get $key =>
const Color(0xff${value.substring(1)});
""");
  });

  buffer.writeln("}");

  return buffer.toString();
}

// ---------------- SPACING ----------------

void generateSpacing(Map data) {
  final spacing = data["spacing"];

  final output = """

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';


class GeneratedSpacingTokens {


const GeneratedSpacingTokens();


${generateResponsiveDouble(spacing)}

}

""";

  writeFile("generated_spacing_tokens.dart", output);
}

String generateResponsiveDouble(Map values) {
  final buffer = StringBuffer();

  values.forEach((key, value) {
    buffer.writeln("""

double $key(context){

return ResponsiveValue<double>(

mobile:${value["mobile"]},

tablet:${value["tablet"]},

desktop:${value["desktop"]}

)
.resolve(context)
.r;

}

""");
  });

  return buffer.toString();
}

// ---------------- RADIUS ----------------

void generateRadius(Map data) {
  final radius = data["radius"];

  final output = """

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';


class GeneratedRadiusTokens {


const GeneratedRadiusTokens();


${generateResponsiveDouble(radius)}

}

""";

  writeFile("generated_radius_tokens.dart", output);
}

// ---------------- TYPOGRAPHY ----------------

void generateTypography(Map data) {
  final typography = data["typography"];

  final output = """

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';


class GeneratedTypographyTokens {


const GeneratedTypographyTokens();



${generateTextStyles(typography)}

}

""";

  writeFile("generated_typography_tokens.dart", output);
}

String generateTextStyles(Map values) {
  final buffer = StringBuffer();

  values.forEach((name, value) {
    buffer.writeln("""

TextStyle $name(context){


return TextStyle(

fontSize:

ResponsiveValue<double>(

mobile:${value["size"]["mobile"]},

tablet:${value["size"]["tablet"]},

desktop:${value["size"]["desktop"]}

)
.resolve(context)
.sp,


fontWeight:
FontWeight.w${value["weight"]},


);

}


""");
  });

  return buffer.toString();
}

// ---------------- DIMENSIONS ----------------

void generateDimensions(Map data) {
  final dimensions = data["dimensions"];

  final output = """

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';


class GeneratedDimensionTokens {


const GeneratedDimensionTokens();



${generateDimensionsCode(dimensions)}

}

""";

  writeFile("generated_dimension_tokens.dart", output);
}

String generateDimensionsCode(Map values) {
  final buffer = StringBuffer();

  values.forEach((name, value) {
    String unit;

    switch (value["type"]) {
      case "width":
        unit = ".w";
        break;

      case "height":
        unit = ".h";
        break;

      default:
        unit = ".r";
    }

    buffer.writeln("""

double $name(context){

return ResponsiveValue<double>(

mobile:${value["mobile"]},

tablet:${value["tablet"]},

desktop:${value["desktop"]}

)
.resolve(context)
$unit;

}

""");
  });

  return buffer.toString();
}

void updateTokenFiles() {
  final configs = {
    "color_tokens.dart": {
      "className": "ColorTokens",
      "extends": "GeneratedLightColorTokens",
      "dark": true,
      "imports": [
        "../generated/generated_color_tokens.dart",
      ],
    },
    "spacing_tokens.dart": {
      "className": "SpacingTokens",
      "extends": "GeneratedSpacingTokens",
      "imports": [
        "../generated/generated_spacing_tokens.dart",
      ],
    },
    "radius_tokens.dart": {
      "className": "RadiusTokens",
      "extends": "GeneratedRadiusTokens",
      "imports": [
        "../generated/generated_radius_tokens.dart",
      ],
    },
    "typography_tokens.dart": {
      "className": "TypographyTokens",
      "extends": "GeneratedTypographyTokens",
      "imports": [
        "../generated/generated_typography_tokens.dart",
      ],
    },
    "dimension_tokens.dart": {
      "className": "DimensionTokens",
      "extends": "GeneratedDimensionTokens",
      "imports": [
        "../generated/generated_dimension_tokens.dart",
      ],
    },
  };

  configs.forEach((fileName, config) {
    final path = 'lib/core/design_system/tokens/$fileName';

    final file = File(path);

    if (!file.existsSync()) {
      return;
    }

    String content = file.readAsStringSync();

    // add missing imports
    final imports = config["imports"] as List<String>;

    final importBlock = imports.map((e) => "import '$e';").join("\n");

    if (!content.contains(importBlock)) {
      content = "$importBlock\n\n$content";
    }

    final String className = config["className"] as String;

    final String extendsName = config["extends"] as String;

    // update only class declaration
    content = content.replaceFirst(
      RegExp(
        r'class\s+' + className!,
      ),
      'class $className extends $extendsName',
    );

    // add dark class if color token
    if (config["dark"] == true && !content.contains("DarkColorTokens")) {
      content += """



class DarkColorTokens extends GeneratedDarkColorTokens {

  const DarkColorTokens();

}

""";
    }

    file.writeAsStringSync(content);
  });
}

void writeFile(
  String name,
  String content,
) {
  final directory = Directory('lib/core/design_system/generated');

  if (!directory.existsSync()) {
    directory.createSync(
      recursive: true,
    );
  }

  final file = File('${directory.path}/$name');

  file.writeAsStringSync(content);
}
