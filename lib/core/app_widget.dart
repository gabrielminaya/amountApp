import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../modules/auth/presentation/splash_page.dart';
import '../modules/concepts/business_logic/brightness_mode_cubit/brightness_mode_cubit.dart';
import 'di/di.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<BrightnessModeCubit>(),
      child: Builder(builder: (context) {
        final brightnessMode = context.watch<BrightnessModeCubit>();

        switch (brightnessMode.state) {
          case brightnessModeState.lightMode:
            return PageTransitionSwitcher(
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  child: MaterialApp(
                    theme: ThemeData.light().copyWith(
                      primaryColor: Colors.indigo,
                      accentColor: Colors.indigo.shade600,
                    ),
                    home: child,
                  ),
                );
              },
              child: SplashPage(),
            );

          case brightnessModeState.darkMode:
            return PageTransitionSwitcher(
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  child: MaterialApp(
                    theme: ThemeData.dark(),
                    home: child,
                  ),
                );
              },
              child: SplashPage(),
            );
        }
      }),
    );
  }
}
