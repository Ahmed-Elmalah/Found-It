import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/core/router/stream_listenable.dart';

void main() {
  test('notifies once per stream event', () async {
    final controller = StreamController<int>.broadcast();
    final listenable = StreamListenable(controller.stream);
    var count = 0;
    listenable.addListener(() => count++);

    controller.add(1);
    await Future<void>.delayed(Duration.zero);
    expect(count, 1);

    controller
      ..add(2)
      ..add(3);
    await Future<void>.delayed(Duration.zero);
    expect(count, 3);

    listenable.dispose();
    await controller.close();
  });

  test('does not notify after dispose and cancels the subscription', () async {
    final controller = StreamController<int>.broadcast();
    final listenable = StreamListenable(controller.stream);
    var count = 0;
    listenable.addListener(() => count++);

    expect(controller.hasListener, isTrue);
    listenable.dispose();
    expect(controller.hasListener, isFalse);

    controller.add(1);
    await Future<void>.delayed(Duration.zero);
    expect(count, 0);

    await controller.close();
  });
}
