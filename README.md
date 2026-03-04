# Interview Project – Flutter Grid Launcher

## Technical Decisions

### State management: `flutter_bloc`

- Event-driven flow with explicit transitions.
- Events:
  - `ReloadAllRequested`
  - `AddImageRequested`
- State tracks: `items`, `nextId`, `reloading`, `reloadRound`, `update`.

### Image loading: `cached_network_image`

- Simpler and maintainable widget-level loading/caching without a custom networking pipeline.
- Each cell handles placeholder/success/error UI.
- Failed cells expose **tap-to-retry** UX.

### Gallery: `photo_view` + `PhotoViewGallery`

- No separate gallery screen.
- Opened via fullscreen dialog using `PhotoViewGallery.builder`.
- Starts at tapped image index and supports swipe/zoom.
- On dismiss, main `PageView` syncs to page containing the last viewed image.

### Anti-spam reload: `Debouncer`

- `Reload All` is debounced to avoid rapid repeated trigger spam.
- Important: debouncing does **not** cancel in-flight network requests; it only reduces how often reload events are emitted.

### DI: `get_it`

- Keeps wiring clean and testable (`LauncherBloc`, `ImageRepository`).

## Architecture (BLoC)

```text
lib/
├─ main.dart
├─ core/
│  ├─ app_constants.dart
│  ├─ di/
│  │  ├─ app_dependencies.dart
│  │  └─ modules/
│  │     ├─ bloc_module.dart
│  │     └─ repository_module.dart
│  └─ utils/
│     └─ debouncer.dart
├─ bloc/
│  ├─ launcher_bloc.dart
│  ├─ launcher_event.dart
│  └─ launcher_state.dart
├─ repository/
│  └─ image_repository.dart
├─ models/
│  └─ grid_image_item.dart
├─ screen/
│  └─ launcher_screen.dart
└─ widgets/
   ├─ launcher_app_bar_actions.dart
   ├─ launcher_paged_grid.dart
   ├─ image_cell.dart
   └─ photo_gallery_dialog.dart
```

```text
User action (Add / Reload / Tap image)
    -> UI widget dispatches event
    -> LauncherBloc handles logic and emits LauncherState
    -> BlocBuilder rebuilds UI from state
    -> Repository is used by Bloc for data creation/cache clear
```

## Key Trade-offs

1. `**cached_network_image` with a simpler image pipeline**
  - **Pros:** less code, easier maintenance, built-in caching UX.
  - **Cons:** less low-level control over request lifecycle.
2. **Debouncer for reload-spam control**
  - **Pros:** simple and effective in reducing repeated `Reload All` events.
  - **Cons:** does not cancel transport-level requests already in flight.
3. **Per-cell retry UX**
  - **Pros:** localized recovery without reloading entire grid.
  - **Cons:** adds small state handling per cell.

## Implementation Notes

- **ID strategy (`nextId`)**
  - Each image item gets a monotonic increasing id.
  - `Reload All` generates a new block of ids from current `nextId`.
  - `Add Image` appends exactly one new id at the tail.
- **Initial batch size (`initialImageLoadCount = 140`)**
  - Full reload regenerates 140 items by design (2 pages x 70 items/page).
  - Keeps startup/reload behavior deterministic.
- **Reload versioning (`reloadRound`)**
  - Incremented on each reload.
  - Injected into image URL query (`rt`) to separate reload sessions and reduce stale visual reuse risk.
- **Reload event handling in BLoC**
  - `ReloadAllRequested` sets `reloading=true`, clears caches, rebuilds item list, then emits final state.
  - UI uses this flag to disable reload action and show loading feedback.
- **Rendering optimization (`RepaintBoundary`)**
  - Image cell painting is isolated to reduce repaint propagation during loading/fade/error transitions.
  - Helps scrolling/paging remain smoother under many concurrently updating cells.
- **Cell-level recovery**
  - Error state exposes tap-to-retry per cell.
  - Recovery is local, avoiding expensive full-grid reload for a single failed image.

