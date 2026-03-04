import 'package:equatable/equatable.dart';

class GridImageItem extends Equatable {
  const GridImageItem({required this.id, required this.url});

  final int id;
  final String url;

  @override
  List<Object?> get props => [id, url];
}
