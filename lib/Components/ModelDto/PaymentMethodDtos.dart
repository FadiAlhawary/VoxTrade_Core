class PaymentMethodTypeDto {
  final int id;
  final String methodName;
  final String methodType;
  final bool isActive;

  PaymentMethodTypeDto({
    required this.id,
    required this.methodName,
    required this.methodType,
    this.isActive = true,
  });

  factory PaymentMethodTypeDto.fromJson(Map<String, dynamic> json) {
    return PaymentMethodTypeDto(
      id: json['id'] as int? ?? 0,
      methodName:
          (json['methodName'] ?? json['mehtodName'] ?? json['mehtod_name'] ?? '')
              .toString(),
      methodType: (json['methodType'] ?? json['method_type'] ?? '').toString(),
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
    );
  }
}

class UserPaymentMethodDto {
  final int id;
  final int userId;
  final int paymentMethodId;
  final String methodName;
  final String methodType;
  final String attributeValue1;
  final String? attributeValue2;
  final DateTime? createdAt;

  UserPaymentMethodDto({
    required this.id,
    required this.userId,
    required this.paymentMethodId,
    required this.methodName,
    required this.methodType,
    required this.attributeValue1,
    this.attributeValue2,
    this.createdAt,
  });

  factory UserPaymentMethodDto.fromJson(Map<String, dynamic> json) {
    return UserPaymentMethodDto(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? json['user_id'] as int? ?? 0,
      paymentMethodId:
          json['paymentMethodId'] as int? ??
          json['payment_method_id'] as int? ??
          0,
      methodName: (json['methodName'] ?? json['method_name'] ?? '').toString(),
      methodType: (json['methodType'] ?? json['method_type'] ?? '').toString(),
      attributeValue1:
          (json['attributeValue1'] ?? json['attribute_value_1'] ?? '')
              .toString(),
      attributeValue2:
          (json['attributeValue2'] ?? json['attribute_value_2'])?.toString(),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  String get displayLabel {
    final secondary =
        attributeValue2 != null && attributeValue2!.trim().isNotEmpty
            ? attributeValue2!.trim()
            : attributeValue1.trim();
    return secondary;
  }

  String get displaySubtitle {
    if (attributeValue2 != null && attributeValue2!.trim().isNotEmpty) {
      return attributeValue1.trim();
    }
    return methodName;
  }
}

class AddPaymentMethodRequestDto {
  final int paymentMethodId;
  final String attributeValue1;
  final String? attributeValue2;

  AddPaymentMethodRequestDto({
    required this.paymentMethodId,
    required this.attributeValue1,
    this.attributeValue2,
  });

  Map<String, dynamic> toJson() => {
    'paymentMethodId': paymentMethodId,
    'attributeValue1': attributeValue1,
    if (attributeValue2 != null && attributeValue2!.trim().isNotEmpty)
      'attributeValue2': attributeValue2!.trim(),
  };
}

class AddPaymentMethodResponseDto {
  final bool success;
  final String message;
  final int? id;
  final UserPaymentMethodDto? paymentMethod;

  AddPaymentMethodResponseDto({
    required this.success,
    required this.message,
    this.id,
    this.paymentMethod,
  });

  factory AddPaymentMethodResponseDto.fromJson(Map<String, dynamic> json) {
    final nested = json['paymentMethod'];
    final id = json['id'] as int?;
    final paymentMethod =
        nested is Map<String, dynamic>
            ? UserPaymentMethodDto.fromJson(nested)
            : null;
    return AddPaymentMethodResponseDto(
      success:
          json['success'] as bool? ??
          id != null ||
          paymentMethod != null,
      message: (json['message'] ?? '').toString(),
      id: id,
      paymentMethod: paymentMethod,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

List<T> parseDtoList<T>(
  dynamic json,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (json is List) {
    return json
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  if (json is Map<String, dynamic>) {
    for (final key in ['items', 'data', 'paymentMethods', 'types']) {
      final nested = json[key];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((e) => fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
  }
  return [];
}
