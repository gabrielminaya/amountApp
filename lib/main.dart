import 'package:flutter/material.dart';

import 'core/app_widget.dart';
import 'core/di/di.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DependecyInjection.configure();
  runApp(AppWidget());
}
