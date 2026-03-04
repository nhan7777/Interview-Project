import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import '../models/grid_image_item.dart';
import 'image_cell.dart';

class LauncherPagedGrid extends StatelessWidget {
  const LauncherPagedGrid({
    required this.pageController,
    required this.items,
    required this.onImageTap,
    super.key,
  });

  final PageController pageController;
  final List<GridImageItem> items;
  final ValueChanged<int> onImageTap;

  @override
  Widget build(BuildContext context) {
    final int pageCount = (items.length / AppConstants.pageSize).ceil();

    return PageView.builder(
      controller: pageController,
      itemCount: pageCount,
      itemBuilder: (context, pageIndex) {
        final int start = pageIndex * AppConstants.pageSize;
        final int end = (start + AppConstants.pageSize).clamp(0, items.length);
        final List<GridImageItem> pageItems = items.sublist(start, end);

        return Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppConstants.rows,
              mainAxisSpacing: AppConstants.spacing,
              crossAxisSpacing: AppConstants.spacing,
              childAspectRatio: 1,
            ),
            itemCount: pageItems.length,
            itemBuilder: (context, index) {
              final GridImageItem item = pageItems[index];
              final int absoluteIndex = start + index;

              return Hero(
                tag: 'grid-image-${item.id}',
                child: ImageCell(
                  item: item,
                  onTap: () => onImageTap(absoluteIndex),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
