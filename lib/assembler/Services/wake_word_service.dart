import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Listens for "Hey Vox" then triggers voice recording.
class WakeWordService {
  WakeWordService();

  static const List<String> wakePhrases = [
    'hey vox',
    'hey box',
    'hey fox',
    'hey volks',
    'hey voks',
    'hey bucks',
    'hey bocks',
    'hey locks',
    'hey rocks',
    'hey walks',
    'hey voice',
    'hay vox',
    'he vox',
    'a vox',
    'hey voc',
    'hey vax',
  ];

  static final RegExp _heyVoxPattern = RegExp(
    r'\b(hey|hay|he|a)\s+'
    r'(vox|voks|box|fox|volks|bucks|bocks|locks|docs|rocks|walks|voc|vax|voice|votes|boxed)\b',
    caseSensitive: false,
  );

  static const int cooldownMs = 3000;
  static const int autoStartDelayMs = 400;
  static const int micHandoffDelayMs = 500;
  static const int sessionRestartDelayMs = 500;
  static const int watchdogIntervalMs = 2500;
  static const int tailWordCount = 12;

  SpeechToText _speech = SpeechToText();

  bool _active = false;
  bool _suspended = false;
  bool _cooldown = false;
  bool _initialized = false;
  bool _startingListen = false;
  Timer? _restartTimer;
  Timer? _cooldownTimer;
  Timer? _watchdogTimer;
  Timer? _sessionEndTimer;

  VoidCallback? onTriggered;

  bool get isAvailable => _initialized;
  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (kDebugMode) {
        debugPrint('WakeWordService: microphone permission denied');
      }
      return false;
    }
    return _initSpeech();
  }

  Future<bool> _initSpeech() async {
    try {
      _initialized = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
        debugLogging: kDebugMode,
      );
    } catch (e) {
      _initialized = false;
      if (kDebugMode) {
        debugPrint('WakeWordService: init error $e');
      }
    }
    if (kDebugMode) {
      debugPrint('WakeWordService: initialized=$_initialized');
    }
    return _initialized;
  }

  void start() {
    if (!_initialized) {
      return;
    }
    _active = true;
    _suspended = false;
    _startWatchdog();
    _scheduleListen(immediate: true);
  }

  Future<void> pause() async {
    _suspended = true;
    _restartTimer?.cancel();
    _sessionEndTimer?.cancel();
    await _stopListening();
  }

  Future<void> resumeAfterVoice() async {
    if (!_active) {
      return;
    }

    _suspended = false;
    _cooldown = false;
    _cooldownTimer?.cancel();

    await Future<void>.delayed(
      const Duration(milliseconds: micHandoffDelayMs),
    );

    if (!_active || _suspended) {
      return;
    }

    await _resetSpeechEngine();
    _scheduleListen(immediate: true);
  }

  Future<void> _resetSpeechEngine() async {
    await _stopListening();
    _speech = SpeechToText();
    await _initSpeech();
  }

  void dispose() {
    _active = false;
    _suspended = true;
    _restartTimer?.cancel();
    _cooldownTimer?.cancel();
    _watchdogTimer?.cancel();
    _sessionEndTimer?.cancel();
    unawaited(_stopListening());
  }

  static String normalizeTranscript(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9\s]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _isHeyToken(String word) {
    return word == 'hey' || word == 'hay' || word == 'he' || word == 'a';
  }

  static bool _isVoxLikeToken(String word) {
    if (word.isEmpty) {
      return false;
    }
    const exact = {
      'vox', 'voks', 'box', 'fox', 'volks', 'bucks', 'bocks', 'locks',
      'docs', 'rocks', 'walks', 'voc', 'vax', 'voice', 'votes', 'boxed',
    };
    if (exact.contains(word)) {
      return true;
    }
    return word.startsWith('vox') ||
        word.startsWith('vok') ||
        word.startsWith('box') ||
        word.startsWith('fox');
  }

  static bool containsWakePhrase(String raw) {
    final normalized = normalizeTranscript(raw);
    if (normalized.isEmpty) {
      return false;
    }
    if (wakePhrases.any(normalized.contains)) {
      return true;
    }
    if (_heyVoxPattern.hasMatch(normalized)) {
      return true;
    }
    final words = normalized.split(' ');
    for (var i = 0; i < words.length - 1; i++) {
      if (_isHeyToken(words[i]) && _isVoxLikeToken(words[i + 1])) {
        return true;
      }
    }
    return false;
  }

  static bool containsWakePhraseInTail(String raw, {int maxWords = tailWordCount}) {
    final words = normalizeTranscript(raw).split(' ');
    if (words.isEmpty) {
      return false;
    }
    final tail =
        words.length <= maxWords
            ? words
            : words.sublist(words.length - maxWords);
    return containsWakePhrase(tail.join(' '));
  }

  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(
      const Duration(milliseconds: watchdogIntervalMs),
      (_) {
        if (!_active || _suspended || _cooldown || !_initialized) {
          return;
        }
        if (_speech.isListening || _startingListen) {
          return;
        }
        if (kDebugMode) {
          debugPrint('WakeWordService: watchdog restart');
        }
        _scheduleListen(immediate: true);
      },
    );
  }

  void _scheduleListen({bool immediate = false}) {
    if (!_active || _suspended || _cooldown || !_initialized) {
      return;
    }
    _restartTimer?.cancel();
    _restartTimer = Timer(
      Duration(milliseconds: immediate ? 0 : sessionRestartDelayMs),
      () => unawaited(_tryStart()),
    );
  }

  /// Android fires both status:done and error:no_match — debounce to one restart.
  void _scheduleListenAfterSessionEnd() {
    if (!_active || _suspended || _cooldown) {
      return;
    }
    _sessionEndTimer?.cancel();
    _sessionEndTimer = Timer(
      const Duration(milliseconds: sessionRestartDelayMs),
      () {
        if (!_active || _suspended || _cooldown || _speech.isListening) {
          return;
        }
        _scheduleListen(immediate: true);
      },
    );
  }

  Future<void> _stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}
  }

  Future<void> _tryStart() async {
    if (!_active || _suspended || _cooldown || !_initialized || _startingListen) {
      return;
    }
    if (_speech.isListening) {
      return;
    }

    _startingListen = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!_active || _suspended || _cooldown) {
        return;
      }

      // FREE_FORM model (dictation) — search/web mode returns empty for "hey vox".
      await _speech.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          localeId: 'en_US',
          listenMode: ListenMode.dictation,
          onDevice: false,
          cancelOnError: false,
          listenFor: const Duration(minutes: 30),
          pauseFor: const Duration(seconds: 5),
        ),
      );
      if (kDebugMode) {
        debugPrint('WakeWordService: listening (dictation/en_US)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WakeWordService: listen error $e');
      }
      _scheduleListenAfterSessionEnd();
    } finally {
      _startingListen = false;
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (_cooldown || _suspended) {
      return;
    }

    final transcripts = <String>{
      result.recognizedWords,
      for (final alt in result.alternates) alt.recognizedWords,
    };

    for (final transcript in transcripts) {
      final text = transcript.trim();
      if (text.isEmpty) {
        continue;
      }
      if (kDebugMode) {
        debugPrint('WakeWordService: heard "$text"');
      }
      if (containsWakePhrase(text) || containsWakePhraseInTail(text)) {
        if (kDebugMode) {
          debugPrint('WakeWordService: wake phrase matched');
        }
        unawaited(_handleWakePhraseDetected());
        return;
      }
    }
  }

  Future<void> _handleWakePhraseDetected() async {
    if (_cooldown || !_active) {
      return;
    }

    _cooldown = true;
    _restartTimer?.cancel();
    _sessionEndTimer?.cancel();
    await _stopListening();

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(milliseconds: cooldownMs), () {
      _cooldown = false;
      if (_active && !_suspended) {
        _scheduleListen(immediate: true);
      }
    });

    await Future<void>.delayed(
      const Duration(milliseconds: autoStartDelayMs),
    );

    if (_active) {
      onTriggered?.call();
    }
  }

  void _onStatus(String status) {
    if (!_active || _suspended || _cooldown) {
      return;
    }
    final s = status.toLowerCase();
    if (s.contains('done') || s.contains('notlistening')) {
      _scheduleListenAfterSessionEnd();
    }
  }

  void _onError(SpeechRecognitionError error) {
    if (kDebugMode) {
      debugPrint('WakeWordService: ${error.errorMsg}');
    }
    final msg = error.errorMsg.toLowerCase();
    if (msg.contains('permission') ||
        msg.contains('not-allowed') ||
        msg.contains('recognizer_disabled')) {
      return;
    }
    if (_active && !_suspended && !_cooldown) {
      _scheduleListenAfterSessionEnd();
    }
  }

  void onAppResumed() {
    if (!_active || _suspended || !_initialized) {
      return;
    }
    _scheduleListen(immediate: true);
  }
}
