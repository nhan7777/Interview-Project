import 'package:get_it/get_it.dart';
import '../../../bloc/launcher_bloc.dart';
import '../../../repository/image_repository.dart';

void registerBlocModule(GetIt getIt) {
  if (!getIt.isRegistered<LauncherBloc>()) {
    getIt.registerLazySingleton<LauncherBloc>(
      () => LauncherBloc(imageRepository: getIt<ImageRepository>()),
    );
  }
}
