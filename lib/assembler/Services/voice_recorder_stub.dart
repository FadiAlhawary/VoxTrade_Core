import 'dart:typed_data';

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
