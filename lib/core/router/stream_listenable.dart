import 'dart:async';

import 'package:flutter/foundation.dart';

/// Lets `GoRouter(refreshListenable: StreamListenable(authCubit.stream))`
/// re-run `redirect` whenever the auth state changes.
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
