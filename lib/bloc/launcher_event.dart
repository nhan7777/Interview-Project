sealed class LauncherEvent {
  const LauncherEvent();
}

final class ReloadAllRequested extends LauncherEvent {
  const ReloadAllRequested();
}

final class AddImageRequested extends LauncherEvent {
  const AddImageRequested();
}
