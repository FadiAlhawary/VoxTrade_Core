 ContactInfo({
    required this.id,
    this.userId,
    required this.primaryEmail,
    this.altEmail,
    required this.primaryPhoneNumber,
    this.altPhoneNumber,
    this.isPrimaryEmailActive,
    this.isAltEmailActive,
    this.isPrimaryPhoneActive,
    this.isAltPhoneActive,
    this.fax,
    this.isFaxActive,
    this.createdAt,
    this.isDeleted,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      id: json['id'],
      userId: json['user_id'],
      primaryEmail: json['primary_email'] ?? '',
      altEmail: json['alt_email'],
      primaryPhoneNumber: json['primary_phone_number'] ?? '',
      altPhoneNumber: json['alt_phone_number'],
      isPrimaryEmailActive: json['is_primary_email_active'],
      isAltEmailActive: json['is_alt_email_active'],
      isPrimaryPhoneActive: json['is_primary_phone_number_active'],
      isAltPhoneActive: json['is_alt_phone_number_active'],
      fax: json['fax'],
      isFaxActive: json['is_fax_active'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      isDeleted: json['is_deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'primary_email': primaryEmail,
      'alt_email': altEmail,
      'primary_phone_number': primaryPhoneNumber,
      'alt_phone_number': altPhoneNumber,
      'is_primary_email_active': isPrimaryEmailActive,
      'is_alt_email_active': isAltEmailActive,
      'is_primary_phone_number_active': isPrimaryPhoneActive,
      'is_alt_phone_number_active': isAltPhoneActive,
      'fax': fax,
      'is_fax_active': isFaxActive,
      'created_at': createdAt?.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }
}