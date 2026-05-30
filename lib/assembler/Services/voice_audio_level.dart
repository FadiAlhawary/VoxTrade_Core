/// Mic level sample from the recorder (dBFS; higher = louder).
class VoiceAudioLevel {
  const VoiceAudioLevel({
    required this.currentDb,
    required this.maxDb,
  });

  final double currentDb;
  final double maxDb;
}
