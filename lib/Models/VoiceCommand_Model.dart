class VoiceCommand {
  final int id;
  final int? userId;
  final String rawText;
  final int? languageId;
  final int? language2Id;
  final bool? isMultiLanguage;
  final double? confidenceScore;
  final DateTime? recognizedAt;

  VoiceCommand({
    required this.id,
    this.userId,
    required this.rawText,
    this.languageId,
    this.language2Id,
    this.isMultiLanguage,
    this.confidenceScore,
    this.recognizedAt,
  });

  factory VoiceCommand.fromJson(Map<String, dynamic> json) {
    return VoiceCommand(
      id: json['id'],
      userId: json['user_id'],
      rawText: json['raw_text'] ?? '',
      languageId: json['language_id'],
      language2Id: json['language_2_id'],
      isMultiLanguage: json['is_multi_language'],
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      recognizedAt: json['recognized_at'] != null ? DateTime.parse(json['recognized_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'raw_text': rawText,
        'language_id': languageId,
        'language_2_id': language2Id,
        'is_multi_language': isMultiLanguage,
        'confidence_score': confidenceScore,
        'recognized_at': recognizedAt?.toIso8601String(),
      };
}
