import 'package:flutter_bloc/flutter_bloc.dart';
import 'launcher_event.dart';
import 'launcher_state.dart';
import '../core/app_constants.dart';
import '../models/grid_image_item.dart';
import '../repository/image_repository.dart';

class LauncherBloc extends Bloc<LauncherEvent, LauncherState> {
  LauncherBloc({required ImageRepository imageRepository})
    : _imageRepo = imageRepository,
      super(LauncherState.initial()) {
    on<ReloadAllRequested>(_onReloadAll);
    on<AddImageRequested>(_onAddImage);
  }

  final ImageRepository _imageRepo;

  Future<void> _onReloadAll(
    ReloadAllRequested event,
    Emitter<LauncherState> emit,
  ) async {
    final int nextRound = state.reloadRound + 1;
    emit(state.copyWith(reloading: true, reloadRound: nextRound));

    await _imageRepo.clearAllCaches();
    if (isClosed) return;

    final int startId = state.nextId;
    final List<GridImageItem> items = _imageRepo.buildImages(
      startId: startId,
      count: AppConstants.initialImageLoadCount,
      reloadRound: nextRound,
    );

    emit(
      state.copyWith(
        items: items,
        nextId: startId + AppConstants.initialImageLoadCount,
        update: LauncherUpdate.reloaded,
        reloading: false,
      ),
    );
  }

  void _onAddImage(AddImageRequested event, Emitter<LauncherState> emit) {
    final int id = state.nextId;
    final GridImageItem item = _imageRepo.buildSingleImage(
      id: id,
      reloadRound: state.reloadRound,
    );

    emit(
      state.copyWith(
        items: [...state.items, item],
        nextId: id + 1,
        update: LauncherUpdate.added,
      ),
    );
  }
}
