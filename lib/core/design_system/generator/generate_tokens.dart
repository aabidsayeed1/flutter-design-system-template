import 'dart:convert';
import 'dart:io';

//dart run generator/generate_tokens.dart
void main() {
  final file = File('tokens.json');

  final data = jsonDecode(file.readAsStringSync());

  generateColors(data);

  generateSpacing(data);

  generateRadius(data);

  generateTypography(data);

  generateDimensions(data);

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

void writeFile(String name, String content) {
  final file = File('../generated/$name');

  file.createSync(recursive: true);

  file.writeAsStringSync(content);
}
