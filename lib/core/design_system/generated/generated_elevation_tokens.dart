import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedElevationTokens {
  const GeneratedElevationTokens();

  double level1(context) {
    return ResponsiveValue<double>(
      mobile: 1,
      tablet: 1,
      desktop: 1,
    ).resolve(context).r;
  }

  double level2(context) {
    return ResponsiveValue<double>(
      mobile: 2,
      tablet: 2,
      desktop: 2,
    ).resolve(context).r;
  }

  double level3(context) {
    return ResponsiveValue<double>(
      mobile: 4,
      tablet: 4,
      desktop: 4,
    ).resolve(context).r;
  }


  double surface(context) {
    return level1(context);
  }

  double card(context) {
    return level1(context);
  }

  double popover(context) {
    return level2(context);
  }

  double dialog(context) {
    return level3(context);
  }


}
