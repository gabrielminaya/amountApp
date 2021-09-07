import 'package:bloc/bloc.dart';
import 'package:consent_amount/core/database/database.dart';

enum SplashState { initial, databaseSuccess, error }

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState.initial);

  Future<void> loadDB() async {
    try {
      await AppDatabase.instance.database;

      emit(SplashState.databaseSuccess);
    } catch (_) {
      emit(SplashState.error);
    }
  }
}
