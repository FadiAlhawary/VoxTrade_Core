// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
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
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  final List<html.Blob> _chunks = [];
  Completer<RecordedAudio>? _stopCompleter;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Stream<VoiceAudioLevel>? get audioLevelStream => null;

  Future<void> start() async {
    if (_isRecording) {
      return;
    }

    final mediaDevices = html.window.navigator.mediaDevices;
    if (mediaDevices == null) {
      throw StateError('Microphone access is not supported in this browser.');
    }

    final stream = await mediaDevices.getUserMedia({'audio': true});
    final preferredMimeType = _pickMimeType();

    final recorder =
        preferredMimeType == null
            ? html.MediaRecorder(stream)
            : html.MediaRecorder(stream, {'mimeType': preferredMimeType});

    _mediaStream = stream;
    _mediaRecorder = recorder;
    _chunks.clear();
    _stopCompleter = Completer<RecordedAudio>();

    recorder.addEventListener('dataavailable', (event) {
      final data = (event as dynamic).data as html.Blob?;
      if (data != null && data.size > 0) {
        _chunks.add(data);
      }
    });

    recorder.addEventListener('stop', (_) async {
      try {
        final recorderMimeType = recorder.mimeType ?? '';
        final chunkMimeType = _chunks.isNotEmpty ? _chunks.first.type : '';
        final mimeType =
            recorderMimeType.isNotEmpty
                ? recorderMimeType
                : (chunkMimeType.isNotEmpty ? chunkMimeType : 'audio/webm');

        final blob = html.Blob(_chunks, mimeType);
        final bytes = await _blobToBytes(blob);
        _stopCompleter?.complete(
          RecordedAudio(
            bytes: bytes,
            mimeType: mimeType,
            extension: _extensionFromMimeType(mimeType),
          ),
        );
      } catch (error, stackTrace) {
        _stopCompleter?.completeError(error, stackTrace);
      } finally {
        _cleanupMediaStream();
        _isRecording = false;
      }
    });

    recorder.start();
    _isRecording = true;
  }

  Future<RecordedAudio> stop() async {
    final recorder = _mediaRecorder;
    final stopCompleter = _stopCompleter;

    if (!_isRecording || recorder == null || stopCompleter == null) {
      throw StateError('No active recording to stop.');
    }

    recorder.stop();
    final output = await stopCompleter.future.timeout(
      const Duration(seconds: 12),
      onTimeout:
          () => throw TimeoutException('Audio recording stop timed out.'),
    );

    _mediaRecorder = null;
    _stopCompleter = null;
    _chunks.clear();

    return output;
  }

  void dispose() {
    if (_isRecording) {
      _mediaRecorder?.stop();
    }
    _cleanupMediaStream();
    _mediaRecorder = null;
    _stopCompleter = null;
    _chunks.clear();
    _isRecording = false;
  }

  void _cleanupMediaStream() {
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
  }

  String? _pickMimeType() {
    const candidates = <String>[
      'audio/webm;codecs=opus',
      'audio/webm',
      'audio/ogg;codecs=opus',
      'audio/mp4',
    ];

    for (final candidate in candidates) {
      if (html.MediaRecorder.isTypeSupported(candidate)) {
        return candidate;
      }
    }

    return null;
  }

  String _extensionFromMimeType(String mimeType) {
    final normalized = mimeType.toLowerCase();
    if (normalized.contains('ogg')) {
      return 'ogg';
    }
    if (normalized.contains('mp4') || normalized.contains('m4a')) {
      return 'm4a';
    }
    if (normalized.contains('wav')) {
      return 'wav';
    }
    return 'webm';
  }

  Future<Uint8List> _blobToBytes(html.Blob blob) {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();

    reader.onError.listen((_) {
      completer.completeError(
        StateError('Failed to read recorded audio data from browser blob.'),
      );
    });

    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is ByteBuffer) {
        completer.complete(Uint8List.view(result));
        return;
      }

      if (result is Uint8List) {
        completer.complete(result);
        return;
      }

      if (result is ByteData) {
        completer.complete(result.buffer.asUint8List());
        return;
      }

      if (result is List<int>) {
        completer.complete(Uint8List.fromList(result));
        return;
      }

      // Some browser/runtime combos expose a non-Dart arraybuffer shape.
      // Fallback to data URL decoding for maximum compatibility.
      _blobToBytesFromDataUrl(blob).then(completer.complete).catchError((_) {
        completer.completeError(
          StateError('Unexpected browser audio blob format.'),
        );
      });
    });

    reader.readAsArrayBuffer(blob);
    return completer.future;
  }

  Future<Uint8List> _blobToBytesFromDataUrl(html.Blob blob) {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();

    reader.onError.listen((_) {
      completer.completeError(
        StateError('Failed to decode browser audio blob as data URL.'),
      );
    });

    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is String && result.contains(',')) {
        final base64Part = result.split(',').last;
        completer.complete(Uint8List.fromList(base64Decode(base64Part)));
        return;
      }

      completer.completeError(
        StateError('Unexpected browser audio data URL format.'),
      );
    });

    reader.readAsDataUrl(blob);
    return completer.future;
  }
}
