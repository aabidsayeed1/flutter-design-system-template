import 'package:flutter/material.dart';
import 'package:flutter_design_system_template/core/design_system/extensions/context_extension.dart';
import 'package:flutter_design_system_template/core/design_system/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

T _firstAvailable<T>(List<T Function()> candidates, String label) {
  for (final candidate in candidates) {
    try {
      return candidate();
    } catch (_) {
      // Try next candidate getter.
    }
  }
  throw StateError('No $label getter was available on generated context extensions.');
}

void main() {
  testWidgets('context extension exposes usable design tokens', (tester) async {
    late Color primary;
    late Gradient brandGradient;
    late double sampleSpace;
    late double sampleRadius;
    late TextStyle sampleTextStyle;
    late double sampleDimension;
    late List<BoxShadow> cardShadow;
    late double sampleElevation;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) {
          return MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) {
                primary = context.colors.primary;
                brandGradient = context.gradients.brandLinear;
                sampleSpace = _firstAvailable<double>([
                  () => (context.space as dynamic).md as double,
                  () => (context.space as dynamic).sm as double,
                  () => (context.space as dynamic).xs as double,
                  () => (context.space as dynamic).lg as double,
                ], 'spacing');
                sampleRadius = _firstAvailable<double>([
                  () => (context.radius as dynamic).md as double,
                  () => (context.radius as dynamic).sm as double,
                  () => (context.radius as dynamic).xs as double,
                  () => (context.radius as dynamic).lg as double,
                  () => (context.radius as dynamic).full as double,
                ], 'radius');
                sampleTextStyle = _firstAvailable<TextStyle>([
                  () => (context.typo as dynamic).body as TextStyle,
                  () => (context.typo as dynamic).subtitle as TextStyle,
                  () => (context.typo as dynamic).h1 as TextStyle,
                  () => (context.typo as dynamic).display as TextStyle,
                  () => (context.typo as dynamic).caption as TextStyle,
                ], 'typography');
                sampleDimension = _firstAvailable<double>([
                  () => (context.dimensions as dynamic).buttonHeight as double,
                  () => (context.dimensions as dynamic).icon as double,
                  () => (context.dimensions as dynamic).avatar as double,
                ], 'dimension');
                cardShadow = context.shadows.card;
                sampleElevation = _firstAvailable<double>([
                  () => (context.elevation as dynamic).level2 as double,
                  () => (context.elevation as dynamic).level1 as double,
                  () => (context.elevation as dynamic).surface as double,
                  () => (context.elevation as dynamic).card as double,
                  () => (context.elevation as dynamic).dialog as double,
                ], 'elevation');
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );

    expect(primary.alpha, greaterThanOrEqualTo(0));
    expect(brandGradient, isA<Gradient>());
    expect(sampleSpace, greaterThan(0));
    expect(sampleRadius, greaterThan(0));
    expect(sampleTextStyle.fontSize, isNotNull);
    expect(sampleDimension, greaterThan(0));
    expect(cardShadow, isNotEmpty);
    expect(sampleElevation, greaterThan(0));
  });

  testWidgets('home screen renders with design-system themed app', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) {
          return MaterialApp(
            theme: AppTheme.aurora,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    'smoke',
                    style: context.typo.body,
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    expect(find.text('smoke'), findsOneWidget);
  });
}
