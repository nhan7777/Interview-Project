import 'package:equatable/equatable.dart';
import '../models/grid_image_item.dart';

enum LauncherUpdate { none, reloaded, added }

class LauncherState extends Equatable {
  const LauncherState({
    required this.items,
    required this.nextId,
    required this.update,
    required this.reloading,
    required this.reloadRound,
  });

  final List<GridImageItem> items;
  final int nextId;
  final LauncherUpdate update;
  final bool reloading;
  final int reloadRound;

  factory LauncherState.initial() {
    return const LauncherState(
      items: <GridImageItem>[],
      nextId: 0,
      update: LauncherUpdate.none,
      reloading: false,
      reloadRound: 0,
    );
  }

  LauncherState copyWith({
    List<GridImageItem>? items,
    int? nextId,
    LauncherUpdate? update,
    bool? reloading,
    int? reloadRound,
  }) {
    return LauncherState(
      items: items ?? this.items,
      nextId: nextId ?? this.nextId,
      update: update ?? this.update,
      reloading: reloading ?? this.reloading,
      reloadRound: reloadRound ?? this.reloadRound,
    );
  }

  @override
  List<Object?> get props => [items, nextId, update, reloading, reloadRound];
}
