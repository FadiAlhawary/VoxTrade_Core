import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voxtrade_core/assembler/Services/Voice_Nlp_Service.dart';
import 'package:voxtrade_core/assembler/Services/voice_recorder.dart';

class VoiceTradingPage extends StatefulWidget {
  const VoiceTradingPage({super.key});

  @override
  State<VoiceTradingPage> createState() => _VoiceTradingPageState();
}

class _VoiceTradingPageState extends State<VoiceTradingPage> {
  final VoiceRecorder _recorder = VoiceRecorder();
  final VoiceNlpService _voiceNlpService = VoiceNlpService();

  bool _isRecording = false;
  bool _isProcessing = false;
  String _statusMessage = 'Tap the microphone to start recording.';
  String _errorMessage = '';
  String _transcript = '';
  String _transcriptAr = '';
  String _sttModelUsed = '';
  String _sttModelRequested = 'gpt-4o-transcribe';
  Map<String, dynamic>? _response;
  Timer? _autoStopTimer;

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _onMicPressed() async {
    if (_isProcessing) {
      return;
    }

    if (_isRecording) {
      await _stopAndProcess();
      return;
    }

    await _startRecording();
  }

  Future<void> _startRecording() async {
    setState(() {
      _errorMessage = '';
      _response = null;
      _transcript = '';
      _transcriptAr = '';
      _sttModelUsed = '';
      _statusMessage = 'Listening... speak now.';
    });

    try {
      await _recorder.start();
      if (!mounted) {
        return;
      }

      setState(() {
        _isRecording = true;
      });

      _autoStopTimer?.cancel();
      _autoStopTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && _isRecording) {
          _stopAndProcess();
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _friendlyMicError(error);
        _statusMessage = 'Microphone access failed.';
      });
    }
  }

  Future<void> _stopAndProcess() async {
    _autoStopTimer?.cancel();

    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _errorMessage = '';
      _statusMessage = 'Processing your voice command...';
    });

    try {
      final recordedAudio = await _recorder.stop();
      final response = await _voiceNlpService.processVoiceCommand(
        audio: recordedAudio,
        sttModel: _sttModelRequested,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _response = response;
        _transcript =
            (response['transcript'] ??
                    response['text'] ??
                    response['raw_text'] ??
                    '')
                .toString();
        _transcriptAr = (response['transcript_ar'] ?? '').toString();
        _sttModelUsed =
            (response['stt_model'] ?? _sttModelRequested).toString();
        _statusMessage =
            _transcript.isEmpty
                ? 'Audio processed with no transcript text.'
                : 'Voice command parsed successfully.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final raw = error.toString();
      final message = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
      setState(() {
        _errorMessage =
            '$message Make sure the voice NLP service is running on port 8000.';
        _statusMessage = 'Voice processing failed.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _friendlyMicError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('notallowederror') || message.contains('permission')) {
      return 'Microphone permission is blocked. Allow microphone access and try again.';
    }
    if (message.contains('notfounderror')) {
      return 'No microphone was detected on this device.';
    }
    if (message.contains('notreadableerror')) {
      return 'Microphone is busy. Close other apps using it and retry.';
    }

    return 'Unable to access microphone in this browser. Use Chrome/Edge and grant mic permission.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canInteract = !_isProcessing;

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Trading')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record Voice Command',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _sttModelRequested,
                    decoration: const InputDecoration(
                      labelText: 'STT Model',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'gpt-4o-transcribe',
                        child: Text('Strong (gpt-4o-transcribe)'),
                      ),
                      DropdownMenuItem(
                        value: 'whisper-1',
                        child: Text('Classic (whisper-1)'),
                      ),
                    ],
                    onChanged:
                        canInteract
                            ? (value) {
                              if (value == null) return;
                              setState(() {
                                _sttModelRequested = value;
                              });
                            }
                            : null,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: FilledButton.icon(
                      onPressed: canInteract ? _onMicPressed : null,
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                      label: Text(
                        _isRecording
                            ? 'Stop and Process'
                            : _isProcessing
                            ? 'Processing...'
                            : 'Start Recording (5s)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_statusMessage, style: theme.textTheme.bodyMedium),
                  if (_sttModelUsed.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Model used: $_sttModelUsed',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_transcript.isNotEmpty || _transcriptAr.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transcript',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_transcript.isNotEmpty)
                      Text(_transcript, style: theme.textTheme.bodyLarge),
                    if (_transcriptAr.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _transcriptAr,
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (_response != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parsed Output',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _kv('Intent', _response!['intent']),
                    _kv('Order Type', _response!['order_type']),
                    _kv('Asset', _response!['asset']),
                    _kv('Quantity', _response!['quantity']),
                    _kv('Price', _response!['price']),
                    _kv('Confidence', _response!['confidence']),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _kv(String label, Object? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: (value ?? '-').toString()),
          ],
        ),
      ),
    );
  }
}
