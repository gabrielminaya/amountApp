import 'package:bloc/bloc.dart';

enum brightnessModeState { lightMode, darkMode }

class BrightnessModeCubit extends Cubit<brightnessModeState> {
  BrightnessModeCubit() : super(brightnessModeState.lightMode);

  void changeMode() {
    switch (state) {
      case brightnessModeState.lightMode:
        emit(brightnessModeState.darkMode);
        break;
      case brightnessModeState.darkMode:
        emit(brightnessModeState.lightMode);
        break;
    }
  }
}
