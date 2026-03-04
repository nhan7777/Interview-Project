import 'package:get_it/get_it.dart';
import 'modules/bloc_module.dart';
import 'modules/repository_module.dart';

class AppDependencies {
  AppDependencies._();

  static final GetIt instance = GetIt.instance;

  static Future<void> setup() async {
    registerRepositoryModule(instance);
    registerBlocModule(instance);
  }
}
