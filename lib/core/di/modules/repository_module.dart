import 'package:get_it/get_it.dart';
import '../../../repository/image_repository.dart';

void registerRepositoryModule(GetIt getIt) {
  if (!getIt.isRegistered<ImageRepository>()) {
    getIt.registerLazySingleton<ImageRepository>(ImageRepository.new);
  }
}
