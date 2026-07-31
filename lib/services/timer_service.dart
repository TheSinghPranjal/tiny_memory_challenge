import 'dart:async';

/// Pausable countdown timer that reports remaining milliseconds.
///
/// Uses wall-clock anchors so pause/resume preserves exact remaining time
/// without drift from Timer.periodic jitter.
class TimerService {
  Timer? _ticker;
  DateTime? _deadline;
  int _remainingMs = 0;
  bool _running = false;
  bool _paused = false;

  void Function(int remainingMs)? onTick;
  void Function()? onExpired;

  int get remainingMs => _remainingMs;
  bool get isRunning => _running && !_paused;
  bool get isPaused => _paused;

  void start({
    required int durationMs,
    void Function(int remainingMs)? onTick,
    void Function()? onExpired,
  }) {
    cancel();
    this.onTick = onTick;
    this.onExpired = onExpired;
    _remainingMs = durationMs.clamp(0, durationMs);
    _running = true;
    _paused = false;
    _deadline = DateTime.now().add(Duration(milliseconds: _remainingMs));
    _schedule();
  }

  void pause() {
    if (!_running || _paused) return;
    _paused = true;
    _ticker?.cancel();
    _ticker = null;
    if (_deadline != null) {
      _remainingMs =
          _deadline!.difference(DateTime.now()).inMilliseconds.clamp(0, 1 << 30);
    }
  }

  void resume() {
    if (!_running || !_paused) return;
    if (_remainingMs <= 0) {
      _expire();
      return;
    }
    _paused = false;
    _deadline = DateTime.now().add(Duration(milliseconds: _remainingMs));
    _schedule();
  }

  void cancel() {
    _ticker?.cancel();
    _ticker = null;
    _running = false;
    _paused = false;
    _deadline = null;
    _remainingMs = 0;
  }

  void _schedule() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_paused || !_running || _deadline == null) return;
      final left =
          _deadline!.difference(DateTime.now()).inMilliseconds.clamp(0, 1 << 30);
      _remainingMs = left;
      onTick?.call(_remainingMs);
      if (_remainingMs <= 0) {
        _expire();
      }
    });
  }

  void _expire() {
    _ticker?.cancel();
    _ticker = null;
    _running = false;
    _paused = false;
    _remainingMs = 0;
    onExpired?.call();
  }

  void dispose() => cancel();
}
