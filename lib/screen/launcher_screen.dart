import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_project/bloc/launcher_bloc.dart';
import 'package:interview_project/bloc/launcher_event.dart';
import 'package:interview_project/bloc/launcher_state.dart';
import 'package:interview_project/core/app_constants.dart';
import 'package:interview_project/core/di/app_dependencies.dart';
import 'package:interview_project/core/utils/debouncer.dart';
import 'package:interview_project/models/grid_image_item.dart';
import 'package:interview_project/widgets/launcher_app_bar_actions.dart';
import 'package:interview_project/widgets/launcher_paged_grid.dart';
import 'package:interview_project/widgets/photo_gallery_dialog.dart';

class LauncherScreen extends StatefulWidget {
  const LauncherScreen({super.key});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  late final PageController _pageController;
  late final LauncherBloc _bloc;
  late final Debouncer _reloadDebouncer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _bloc = AppDependencies.instance<LauncherBloc>();
    _reloadDebouncer = Debouncer(delay: const Duration(milliseconds: 450));
    _bloc.add(const ReloadAllRequested());
  }

  @override
  void dispose() {
    _reloadDebouncer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _syncPage(LauncherState state) {
    if (!_pageController.hasClients || state.items.isEmpty) return;

    if (state.update == LauncherUpdate.reloaded) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
      return;
    }

    if (state.update == LauncherUpdate.added) {
      final int lastIndex = state.items.length - 1;
      final int targetPage = lastIndex ~/ AppConstants.pageSize;
      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _openGallery({
    required List<GridImageItem> items,
    required int initialIndex,
  }) async {
    final PageController galleryController = PageController(
      initialPage: initialIndex,
    );
    int currentIndex = initialIndex;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        return PhotoGalleryDialog(
          items: items,
          pageController: galleryController,
          onPageChanged: (index) => currentIndex = index,
        );
      },
    );

    if (!mounted || !_pageController.hasClients) return;

    final int targetPage = currentIndex ~/ AppConstants.pageSize;
    await _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: const Text(
          'Grid Launcher',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          LauncherAppBarActions(bloc: _bloc, reloadDebouncer: _reloadDebouncer),
        ],
      ),
      body: BlocListener<LauncherBloc, LauncherState>(
        bloc: _bloc,
        listenWhen: (prev, curr) =>
            prev.items != curr.items && curr.update != LauncherUpdate.none,
        listener: (context, state) => _syncPage(state),
        child: BlocBuilder<LauncherBloc, LauncherState>(
          bloc: _bloc,
          builder: (context, state) {
            if (state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return LauncherPagedGrid(
              pageController: _pageController,
              items: state.items,
              onImageTap: (absoluteIndex) => _openGallery(
                items: state.items,
                initialIndex: absoluteIndex,
              ),
            );
          },
        ),
      ),
    );
  }
}
