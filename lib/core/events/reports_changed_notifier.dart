import 'dart:async';

/// Shared event notifier used to signal across shell tabs (Home, Explore)
/// that reports have changed (e.g. created, updated, or marked recovered),
/// so tabs can refresh their feeds in memory without needing a manual pull.
class ReportsChangedNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  void dispose() {
    _controller.close();
  }
}
