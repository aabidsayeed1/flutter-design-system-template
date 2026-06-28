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

  if(width < 600) return mobile;
  if(width < 1200) return tablet;
  return desktop;
 }
}
