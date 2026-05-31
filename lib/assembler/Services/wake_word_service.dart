import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Listens for "Hey Vox" (and common misrecognitions) then triggers voice recording.
/// Mirrors web `useWakeWord.ts`: continuous listen, 6s cooldown, auto-restart on end/error.
class WakeWordService {
  WakeWordService();

  static const List<String> wakePhrases = [
    'hey vox',
    'hey box',
    'hey fox',
    'hey volks',
    'a vox',
    'hey voks',
  ];

  static const int cooldownMs = 6000;
  static const int restartDelayMs = 200;
  static const int autoStartDelayMs = 400;

  final SpeechToText _speech = SpeechToText();

  bool _active = false;
  bool _paused = false;
  bool _cooldown = false;
  bool _available = false;
  bool _handlingTrigger = false;
  Timer? _restartTimer;
  Timer? _cooldownTimer;

  /// Fired after the wake phrase is heard and the STT mic is released.
  VoidCallback? onTriggered;

  bool get isAvailable => _available;
  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (kDebugMode) {
        debugPrint('WakeWordService: microphone permission denied');
      }
      return false;
    }

    _available = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
      debugLogging: kDebugMode,
    );

    if (kDebugMode) {
      debugPrint('WakeWordService: available=$_available');
    }
    return _available;
  }

  void start() {
    if (!_available) {
      return;
    }
    _active = true;
    _paused = false;
    _scheduleRestart(immediate: true);
  }

  /// Stops wake-word recognition so [VoiceRecorder] can use the microphone.
  Future<void> pause() async {
    _paused = true;
    _restartTimer?.cancel();
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  void resume() {
    if (!_available || !_active) {
      return;
    }
    _paused = false;
    if (!_cooldown && !_handlingTrigger) {
      _scheduleRestart(immediate: true);
    }
  }

  void dispose() {
    _active = false;
    _paused = true;
    _restartTimer?.cancel();
    _cooldownTimer?.cancel();
    _speech.stop();
  }

  static String normalizeTranscript(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool containsWakePhrase(String raw) {
    final normalized = normalizeTranscript(raw);
    if (normalized.isEmpty) {
      return false;
    }
    return wakePhrases.any(normalized.contains);
  }

  void _scheduleRestart({bool immediate = false}) {
    if (!_active || _paused || _cooldown || _handlingTrigger) {
      return;
    }
    _restartTimer?.cancel();
    _restartTimer = Timer(
      Duration(milliseconds: immediate ? 0 : restartDelayMs),
      _tryStart,
    );
  }

  Future<void> _tryStart() async {
    if (!_active || _paused || _cooldown || _handlingTrigger || !_available) {
      return;
    }
    if (_speech.isListening) {
      return;
    }

    try {
      await _speech.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          localeId: 'en_US',
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          listenFor: const Duration(minutes: 30),
          pauseFor: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WakeWordService: listen failed: $e');
      }
      _scheduleRestart();
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (_cooldown || _handlingTrigger || _paused) {
      return;
    }

    final transcript = result.recognizedWords;
    if (!containsWakePhrase(transcript)) {
      return;
    }

    unawaited(_handleWakePhraseDetected());
  }

  Future<void> _handleWakePhraseDetected() async {
    if (_cooldown || _handlingTrigger || !_active) {
      return;
    }

    _handlingTrigger = true;
    _cooldown = true;
    _restartTimer?.cancel();

    await pause();

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(milliseconds: cooldownMs), () {
      _cooldown = false;
      _handlingTrigger = false;
      if (_active && !_paused) {
        _scheduleRestart(immediate: true);
      }
    });

    await Future<void>.delayed(
      const Duration(milliseconds: autoStartDelayMs),
    );

    if (_active) {
      onTriggered?.call();
    }

    _handlingTrigger = false;
  }

  void _onStatus(String status) {
    if (!_active || _paused || _cooldown || _handlingTrigger) {
      return;
    }
    if (status == 'done' ||
        status == SpeechToText.notListeningStatus ||
        status == SpeechToText.doneStatus) {
      _scheduleRestart();
    }
  }

  void _onError(SpeechRecognitionError error) {
    final msg = error.errorMsg.toLowerCase();
    if (msg.contains('error_permission') ||
        msg.contains('not-allowed') ||
        msg.contains('permission') ||
        msg.contains('service-not-allowed') ||
        msg.contains('recognizer_disabled')) {
      return;
    }
    if (_active && !_paused && !_cooldown && !_handlingTrigger) {
      _scheduleRestart();
    }
  }
}
