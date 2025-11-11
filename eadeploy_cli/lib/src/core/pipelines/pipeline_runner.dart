import 'pipeline.dart';

// the param corresponds to _forceStop
typedef EventListenerCallback = void Function(bool);

abstract class PipelineRunner<T, R extends Object?> {
  Pipeline? parent;
  bool _forceStop = false;

  final List<EventListenerCallback> _eventListeners = <EventListenerCallback>[];

  bool get mustForceEvent => _forceStop;

  void stop() {
    _forceStop = true;
    end();
  }

  void registerListener(EventListenerCallback callback) =>
      _eventListeners.add(callback);
  void removeListener(EventListenerCallback callback) =>
      _eventListeners.remove(callback);

  /// Ends the current runner and notifies to the listeners
  /// avoid it
  void end() {
    for (EventListenerCallback p in _eventListeners) {
      p(_forceStop);
    }

    if (autoCleanListeners) _eventListeners.clear();
  }

  String get identifier;
  bool get autoCleanListeners => true;

  /// The phase of the current runner
  ///
  /// We use [phase] tipically to know
  /// at what point the commands were
  /// executed, to start [revert]
  int get phase;

  /// Revert all the changes as possible
  bool revert(R param);

  /// Runs the runner
  T run(R param);
}
