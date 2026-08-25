import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/design_system/theme/app_theme.dart';
import 'home_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  static const String brandThemeName = 'aurora';

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: AppTheme.designSize(context),
      builder: (_, child) {
        return MaterialApp(
          theme: AppTheme.theme(brandThemeName),
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: child,
        );
      },
      child: const HomePage(),
    );
  }
}
