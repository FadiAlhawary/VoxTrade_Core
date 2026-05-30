import 'dart:io';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:voxtrade_core/assembler/Services/voice_audio_level.dart';

class RecordedAudio {
  RecordedAudio({
    required this.bytes,
    required this.mimeType,
    required this.extension,
  });

  final Uint8List bytes;
  final String mimeType;
  final String extension;
}

class VoiceRecorder {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentFilePath;

  bool get isRecording => _isRecording;

  /// Mic levels while recording; used for speech (not noise) detection.
  Stream<VoiceAudioLevel>? get audioLevelStream {
    if (!_isRecording) {
      return null;
    }
    return _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .map(
          (amplitude) => VoiceAudioLevel(
            currentDb: amplitude.current.toDouble(),
            maxDb: amplitude.max.toDouble(),
          ),
        );
  }

  Future<void> start() async {
    if (_isRecording) {
      return;
    }

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      throw StateError(
        'Microphone permission denied. Open app settings and allow microphone access.',
      );
    }

    final filePath =
        '${Directory.systemTemp.path}/voxtrade_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );

    _currentFilePath = filePath;
    _isRecording = true;
  }

  Future<RecordedAudio> stop() async {
    if (!_isRecording) {
      throw StateError('No active recording to stop.');
    }

    final outputPath = await _audioRecorder.stop();
    _isRecording = false;

    final filePath = outputPath ?? _currentFilePath;
    _currentFilePath = null;

    if (filePath == null) {
      throw StateError('Recorded audio file path is missing.');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw StateError('Recorded audio file is missing.');
    }

    final bytes = await file.readAsBytes();
    try {
      await file.delete();
    } catch (_) {
      // Ignore cleanup failures for temporary files.
    }

    return RecordedAudio(bytes: bytes, mimeType: 'audio/mp4', extension: 'm4a');
  }

  void dispose() {
    _audioRecorder.dispose();
    _isRecording = false;
    _currentFilePath = null;
  }
}
