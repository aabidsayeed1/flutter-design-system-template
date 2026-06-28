import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {

 final Widget child;

 const AppCard({
  super.key,
  required this.child,
 });

 @override
 Widget build(BuildContext context) {
  return Card(
   child: child,
  );
 }
}
