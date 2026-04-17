class VoiceCommandModel {
  final int id;
  final String? rawText;
  final double? confidenceScore;
  final DateTime? recognizedAt;

  VoiceCommandModel({
    required this.id,
    this.rawText,
    this.confidenceScore,
    this.recognizedAt,
  });

  factory VoiceCommandModel.fromJson(Map<String, dynamic> json) {
    return VoiceCommandModel(
      id: json['id'] as int,
      rawText: json['rawText'] as String?,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      recognizedAt: json['recognizedAt'] != null ? DateTime.parse(json['recognizedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawText': rawText,
      'confidenceScore': confidenceScore,
      'recognizedAt': recognizedAt?.toIso8601String(),
    };
  }
}