import 'dart:async';
import 'dart:collection';

/// Limits concurrent HTTP calls so the app does not exhaust the API DB pool on launch.
class ApiRequestGate {
  ApiRequestGate._();

  static const int maxConcurrent = 4;
  static int _inFlight = 0;
  static final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  static Future<T> run<T>(Future<T> Function() action) async {
    await _acquire();
    try {
      return await action();
    } finally {
      _release();
    }
  }

  static Future<void> _acquire() async {
    if (_inFlight < maxConcurrent) {
      _inFlight++;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  static void _release() {
    if (_waitQueue.isNotEmpty) {
      _waitQueue.removeFirst().complete();
      return;
    }
    _inFlight--;
  }
}

/// Runs [tasks] one after another (used to stagger startup work).
Future<void> runSequential(Future<void> Function() task) => task();

Future<void> runStartupTasks(List<Future<void> Function()> tasks) async {
  for (final task in tasks) {
    await task();
  }
}
