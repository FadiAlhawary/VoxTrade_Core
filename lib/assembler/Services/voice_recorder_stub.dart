import 'dart:typed_data';

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
  bool get isRecording => false;

  Stream<VoiceAudioLevel>? get audioLevelStream => null;

  Future<void> start() async {
    throw UnsupportedError(
      'Voice recording is not available on this platform in the current build.',
    );
  }

  Future<RecordedAudio> stop() async {
    throw UnsupportedError(
      'Voice recording is not available on this platform in the current build.',
    );
  }

  void dispose() {}
}
