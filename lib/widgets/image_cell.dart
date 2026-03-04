import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import '../models/grid_image_item.dart';

class ImageCell extends StatefulWidget {
  const ImageCell({required this.item, required this.onTap, super.key});

  final GridImageItem item;
  final VoidCallback onTap;

  @override
  State<ImageCell> createState() => _ImageCellState();
}

class _ImageCellState extends State<ImageCell> {
  int _retryVersion = 0;

  Future<void> _retryLoad() async {
    await CachedNetworkImage.evictFromCache(widget.item.url);

    if (!mounted) return;
    setState(() {
      _retryVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radius),
      child: Material(
        color: Colors.grey.shade200,
        child: InkWell(
          onTap: widget.onTap,
          child: RepaintBoundary(
            child: CachedNetworkImage(
              key: ValueKey('${widget.item.id}-$_retryVersion'),
              imageUrl: widget.item.url,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              fadeInDuration: const Duration(milliseconds: 120),
              placeholder: (context, url) => const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: InkWell(
                  onTap: _retryLoad,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 18),
                        SizedBox(height: 2),
                        Text('Retry', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
