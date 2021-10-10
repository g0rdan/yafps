library yafps;

import 'dart:async';
import 'dart:math';

import 'package:flutter/scheduler.dart';

class FpsService {
  final double timeInterval;
  final int maxFps;
  final _fpsEventSubject = StreamController<FpsEntity>.broadcast();
  double _ticks = 0;
  double _fps = 0;
  int _lastCalcTime = 0;
  bool _enabled = false;

  bool get enabled => _enabled;
  int get nowMs => DateTime.now().millisecondsSinceEpoch;
  double get intervalTimeMs => timeInterval * 1000;
  double get fps => _fps;
  Stream<FpsEntity> get fpsStream => _fpsEventSubject.stream;
  late Ticker _ticker;

  /// The service allow us to track frames per second for the app.
  ///
  /// [timeInterval] - interval in seconds in which we take FPS. Meaning,
  /// in each [timeInterval] we take a FPS number.
  /// [maxFps] - FPS limit that we track. Depend on a device it could be 60, 120, 240, etc.
  FpsService({
    required this.timeInterval,
    required this.maxFps,
  }) {
    _fps = maxFps.toDouble();
    _ticker = Ticker(_handleTick);
  }

  void start() {
    _enabled = true;
    _ticker.start();
    _lastCalcTime = nowMs;
  }

  void stop() {
    _enabled = false;
    _ticker.stop();
  }

  void dispose() {
    if (_enabled) {
      stop();
    }
    _ticker.dispose();
    _fpsEventSubject.close();
  }

  void _handleTick(Duration _) {
    if (!enabled) {
      _lastCalcTime = nowMs;
      return;
    }

    _ticks++;
    if (nowMs - _lastCalcTime > intervalTimeMs) {
      final remainder = (nowMs - _lastCalcTime - intervalTimeMs).round();
      _lastCalcTime = nowMs - remainder;
      _fps = min(
        (_ticks * 1000 / intervalTimeMs).roundToDouble(),
        maxFps.toDouble(),
      );
      _ticks = 0;
      _fpsEventSubject.add(FpsEntity(
        _lastCalcTime,
        _fps,
      ));
    }
  }
}

class FpsEntity {
  final double fps;
  final int time;

  const FpsEntity(
    this.time,
    this.fps,
  );
}
