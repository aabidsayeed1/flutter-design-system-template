import 'package:flutter/widgets.dart';

class Responsive {
 static bool isMobile(BuildContext context) =>
  MediaQuery.sizeOf(context).width < 600;

 static bool isTablet(BuildContext context) =>
  MediaQuery.sizeOf(context).width >= 600 &&
  MediaQuery.sizeOf(context).width < 1200;
}
