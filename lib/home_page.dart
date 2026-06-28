import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'core/design_system/extensions/context_extension.dart';
import 'core/design_system/widgets/app_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(context.space.md),
        child: Column(
          children: [
            Text(
              'Design System Demo',
              style: context.typo.title,
            ),
            Gap(context.space.md),
            Container(
              padding: EdgeInsets.all(context.space.md),
              color: context.colors.surface,
              child: Text(
                'All values come from tokens',
                style: context.typo.body,
              ),
            ),
            Gap(context.space.lg),
            AppButton(
              text: 'Continue',
              onPressed: () {},
            ),
            Gap(context.space.lg),
            SizedBox(
              height: context.dimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Save"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
