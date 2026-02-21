class VoiceCommandAudit {
  final int id;
  final int? voiceCommandId;
  final String? step;
  final String? details;
  final DateTime? createdAt;

  VoiceCommandAudit({
    required this.id,
    this.voiceCommandId,
    this.step,
    this.details,
    this.createdAt,
  });

  factory VoiceCommandAudit.fromJson(Map<String, dynamic> json) {
    return VoiceCommandAudit(
      id: json['id'],
      voiceCommandId: json['voice_command_id'],
      step: json['step'],
      details: json['details'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'voice_command_id': voiceCommandId,
        'step': step,
        'details': details,
        'created_at': createdAt?.toIso8601String(),
      };
}