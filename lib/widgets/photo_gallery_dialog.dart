import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/grid_image_item.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoGalleryDialog extends StatelessWidget {
  const PhotoGalleryDialog({
    required this.items,
    required this.pageController,
    required this.onPageChanged,
    super.key,
  });

  final List<GridImageItem> items;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: pageController,
            itemCount: items.length,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            onPageChanged: onPageChanged,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(items[index].url),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'grid-image-${items[index].id}',
                ),
              );
            },
            loadingBuilder: (context, event) =>
                const Center(child: CircularProgressIndicator()),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: IconButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
