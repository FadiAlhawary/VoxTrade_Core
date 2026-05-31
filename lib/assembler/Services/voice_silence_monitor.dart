import 'dart:async';
import 'dart:math' as math;

import 'package:voxtrade_core/assembler/Services/voice_audio_level.dart';

/// Ends listening after the user stops speaking (not ambient noise), with a
/// visible countdown that resets if speech resumes.
class VoiceSilenceMonitor {
  VoiceSilenceMonitor({
    this.countdownDuration = const Duration(milliseconds: 3000),
    this.silenceBeforeCountdown = const Duration(milliseconds: 350),
    this.initialGrace = const Duration(milliseconds: 600),
    this.speechMarginDb = 14.0,
    this.minSpeechDynamicRangeDb = 6.0,
    this.minSpeechModulationDb = 2.0,
    this.maxSpeechModulationDb = 14.0,
    this.consecutiveSpeechFramesRequired = 4,
    this.levelWindowSize = 7,
  });

  final Duration countdownDuration;
  final Duration silenceBeforeCountdown;
  final Duration initialGrace;
  final double speechMarginDb;
  final double minSpeechDynamicRangeDb;
  final double minSpeechModulationDb;
  final double maxSpeechModulationDb;
  final int consecutiveSpeechFramesRequired;
  final int levelWindowSize;

  StreamSubscription<VoiceAudioLevel>? _subscription;
  Timer? _countdownTimer;
  DateTime? _listeningStartedAt;
  DateTime? _silenceSince;
  bool _hasDetectedSpeech = false;
  double? _countdownValue;
  DateTime? _countdownStartedAt;

  double _noiseFloorDb = -48.0;
  final List<double> _recentLevels = [];
  int _consecutiveSpeechFrames = 0;

  void Function(double secondsLeft)? onCountdownTick;
  void Function()? onCountdownCancelled;
  void Function()? onComplete;

  double? get countdownValue => _countdownValue;

  bool get isCountingDown => _countdownValue != null;

  void start(Stream<VoiceAudioLevel> levelStream) {
    stop();
    _listeningStartedAt = DateTime.now();
    _hasDetectedSpeech = false;
    _silenceSince = null;
    _countdownValue = null;
    _countdownStartedAt = null;
    _noiseFloorDb = -48.0;
    _recentLevels.clear();
    _consecutiveSpeechFrames = 0;
    _subscription = levelStream.listen(_onLevel);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _countdownValue = null;
    _countdownStartedAt = null;
    _silenceSince = null;
    _listeningStartedAt = null;
    _hasDetectedSpeech = false;
    _recentLevels.clear();
    _consecutiveSpeechFrames = 0;
  }

  void _onLevel(VoiceAudioLevel sample) {
    final level = sample.currentDb;
    _pushLevel(level);
    _updateNoiseFloor(level);

    final isSpeechLike = _isSpeechLike(sample);

    if (isSpeechLike) {
      _consecutiveSpeechFrames++;
    } else {
      _consecutiveSpeechFrames = 0;
    }

    final isSpeaking =
        _consecutiveSpeechFrames >= consecutiveSpeechFramesRequired;

    if (_countdownValue != null) {
      // Use a lower bar while counting down so pause → talk reliably cancels.
      if (_isResumingSpeech(sample)) {
        _consecutiveSpeechFrames++;
      } else {
        _consecutiveSpeechFrames = 0;
      }
      if (_consecutiveSpeechFrames >= 2) {
        _cancelCountdown();
        _hasDetectedSpeech = true;
      }
      return;
    }

    if (isSpeaking) {
      _hasDetectedSpeech = true;
      _silenceSince = null;
      return;
    }

    final now = DateTime.now();
    final startedAt = _listeningStartedAt;
    if (startedAt == null) {
      return;
    }

    if (!_hasDetectedSpeech && now.isBefore(startedAt.add(initialGrace))) {
      return;
    }

    _silenceSince ??= now;
    if (now.difference(_silenceSince!) >= silenceBeforeCountdown) {
      _beginCountdown();
    }
  }

  void _pushLevel(double level) {
    _recentLevels.add(level);
    while (_recentLevels.length > levelWindowSize) {
      _recentLevels.removeAt(0);
    }
  }

  void _updateNoiseFloor(double level) {
    final provisionalCeiling = _noiseFloorDb + speechMarginDb - 4;
    if (level <= provisionalCeiling) {
      _noiseFloorDb = (_noiseFloorDb * 0.88) + (level * 0.12);
    }
  }

  /// Loud enough to treat as "user started talking again" during the finish countdown.
  bool _isResumingSpeech(VoiceAudioLevel sample) {
    final peak = math.max(sample.currentDb, sample.maxDb);
    final aboveNoise = peak > _noiseFloorDb + 8.0;
    // Absolute floor so resume works even if the noise model drifted during a pause.
    const absoluteSpeechDb = -40.0;
    return aboveNoise || peak > absoluteSpeechDb;
  }

  bool _isSpeechLike(VoiceAudioLevel sample) {
    final level = sample.currentDb;
    final peak = math.max(level, sample.maxDb);
    final speechThreshold = _noiseFloorDb + speechMarginDb;

    if (peak <= speechThreshold) {
      return false;
    }

    if (_recentLevels.length < 3) {
      return peak > speechThreshold + 4;
    }

    final windowMin = _recentLevels.reduce(math.min);
    final windowMax = _recentLevels.reduce(math.max);
    final dynamicRange = windowMax - windowMin;

    if (dynamicRange < minSpeechDynamicRangeDb) {
      return false;
    }

    var modulationSum = 0.0;
    for (var i = 1; i < _recentLevels.length; i++) {
      modulationSum += (_recentLevels[i] - _recentLevels[i - 1]).abs();
    }
    final avgModulation = modulationSum / (_recentLevels.length - 1);

    if (avgModulation < minSpeechModulationDb ||
        avgModulation > maxSpeechModulationDb) {
      return false;
    }

    return level > speechThreshold;
  }

  void _beginCountdown() {
    if (_countdownValue != null) {
      return;
    }

    _countdownStartedAt = DateTime.now();
    _countdownValue = countdownDuration.inMilliseconds / 1000.0;
    onCountdownTick?.call(_countdownValue!);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final startedAt = _countdownStartedAt;
      if (startedAt == null) {
        timer.cancel();
        return;
      }

      final remaining = countdownDuration - DateTime.now().difference(startedAt);
      if (remaining <= Duration.zero) {
        timer.cancel();
        _countdownValue = null;
        _countdownStartedAt = null;
        onComplete?.call();
        return;
      }

      final secondsLeft = (remaining.inMilliseconds / 1000.0 * 10).ceil() / 10;
      if (_countdownValue != secondsLeft) {
        _countdownValue = secondsLeft;
        onCountdownTick?.call(secondsLeft);
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _countdownValue = null;
    _countdownStartedAt = null;
    _silenceSince = null;
    _consecutiveSpeechFrames = 0;
    onCountdownCancelled?.call();
  }
}
