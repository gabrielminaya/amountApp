import 'package:get_it/get_it.dart';

import '../../modules/auth/cubits/splash_cubit/splash_cubit.dart';
import '../../modules/concepts/business_logic/brightness_mode_cubit/brightness_mode_cubit.dart';
import '../../modules/concepts/business_logic/concept_cubit/concept_cubit.dart';
import '../../modules/concepts/business_logic/export_cubit/export_cubit.dart';
import '../../modules/concepts/data_access/repositories/concept_repository.dart';

final di = GetIt.instance;

class DependecyInjection {
  DependecyInjection._();

  static Future<void> configure() async {
    final _conceptRepository = ConceptRepository();

    di.registerFactory(() => SplashCubit());
    di.registerFactory(() => BrightnessModeCubit());
    di.registerFactory(() => ExportCubit());
    di.registerFactory(() => ConceptCubit(_conceptRepository));
  }
}
