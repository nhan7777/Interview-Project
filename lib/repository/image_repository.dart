import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/grid_image_item.dart';

class ImageRepository {
  List<GridImageItem> buildImages({
    required int startId,
    required int count,
    required int reloadRound,
  }) {
    return List.generate(count, (index) {
      final int id = startId + index;
      return GridImageItem(id: id, url: buildImageUrl(id, reloadRound));
    }, growable: false);
  }

  GridImageItem buildSingleImage({required int id, required int reloadRound}) {
    return GridImageItem(id: id, url: buildImageUrl(id, reloadRound));
  }

  String buildImageUrl(int id, int reloadRound) =>
      'https://picsum.photos/200/200?random=$id&rt=$reloadRound';

  String buildBrokenImageUrl(int id, int reloadRound) =>
      'https://picsum.photos/invalid/$id?rt=$reloadRound';

  Future<void> clearAllCaches() async {
    await DefaultCacheManager().emptyCache();
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
