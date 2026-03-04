import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/launcher_bloc.dart';
import '../bloc/launcher_event.dart';
import '../bloc/launcher_state.dart';
import '../core/utils/debouncer.dart';

class LauncherAppBarActions extends StatelessWidget {
  const LauncherAppBarActions({
    required this.bloc,
    required this.reloadDebouncer,
    super.key,
  });

  final LauncherBloc bloc;
  final Debouncer reloadDebouncer;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            tooltip: 'Add image',
            onPressed: () => bloc.add(const AddImageRequested()),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
          BlocBuilder<LauncherBloc, LauncherState>(
            bloc: bloc,
            buildWhen: (prev, curr) => prev.reloading != curr.reloading,
            builder: (context, state) {
              return FilledButton.tonalIcon(
                onPressed: state.reloading
                    ? null
                    : () => reloadDebouncer.run(
                        () => bloc.add(const ReloadAllRequested()),
                      ),
                icon: state.reloading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(state.reloading ? 'Reloading' : 'Reload'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(0, 40),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
