import 'dart:async';
import 'dart:math' as math;

import 'package:voxtrade_core/assembler/Services/voice_audio_level.dart';

/// Ends listening after the user stops speaking (not ambient noise), with a
/// visible countdown that resets if speech resumes.
class VoiceSilenceMonitor {
  VoiceSilenceMonitor({
    this.countdownSeconds = 3,
    this.silenceBeforeCountdown = const Duration(milliseconds: 350),
    this.initialGrace = const Duration(milliseconds: 600),
    this.speechMarginDb = 14.0,
    this.minSpeechDynamicRangeDb = 6.0,
    this.minSpeechModulationDb = 2.0,
    this.maxSpeechModulationDb = 14.0,
    this.consecutiveSpeechFramesRequired = 4,
    this.levelWindowSize = 7,
  });

  final int countdownSeconds;
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
  int? _countdownValue;

  double _noiseFloorDb = -48.0;
  final List<double> _recentLevels = [];
  int _consecutiveSpeechFrames = 0;

  void Function(int secondsLeft)? onCountdownTick;
  void Function()? onCountdownCancelled;
  void Function()? onComplete;

  int? get countdownValue => _countdownValue;

  bool get isCountingDown => _countdownValue != null;

  void start(Stream<VoiceAudioLevel> levelStream) {
    stop();
    _listeningStartedAt = DateTime.now();
    _hasDetectedSpeech = false;
    _silenceSince = null;
    _countdownValue = null;
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
      if (isSpeaking) {
        _cancelCountdown();
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

    _countdownValue = countdownSeconds;
    onCountdownTick?.call(_countdownValue!);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = _countdownValue;
      if (current == null) {
        timer.cancel();
        return;
      }
      if (current <= 1) {
        timer.cancel();
        _countdownValue = null;
        onComplete?.call();
        return;
      }
      _countdownValue = current - 1;
      onCountdownTick?.call(_countdownValue!);
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _countdownValue = null;
    _silenceSince = null;
    onCountdownCancelled?.call();
  }
}
