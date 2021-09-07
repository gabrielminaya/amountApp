import 'package:consent_amount/modules/concepts/user_interface/pages/concept_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/di.dart';
import '../cubits/splash_cubit/splash_cubit.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<SplashCubit>()..loadDB(),
      child: SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        switch (state) {
          case SplashState.databaseSuccess:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ConceptPage()),
            );
            break;
          case SplashState.initial:
            break;
          case SplashState.error:
            break;
        }
      },
      child: Scaffold(
        body: SizedBox(
          width: screenSize.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flutter_dash_rounded,
                color: Theme.of(context).accentColor,
                size: screenSize.width * .2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: screenSize.width * .2,
                child: const LinearProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
