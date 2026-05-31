class AddFundsRequestDto {
  final int adminUserId;
  final int targetUserId;
  final double amount;
  final String? description;

  AddFundsRequestDto({
    required this.adminUserId,
    required this.targetUserId,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'adminUserId': adminUserId,
    'targetUserId': targetUserId,
    'amount': amount,
    if (description != null && description!.isNotEmpty)
      'description': description,
  };
}

class AddFundsResponseDto {
  final bool success;
  final String message;
  final int? targetUserId;
  final double? amount;
  final double? balanceBefore;
  final double? balanceAfter;
  final double? availableBefore;
  final double? availableAfter;

  AddFundsResponseDto({
    required this.success,
    required this.message,
    this.targetUserId,
    this.amount,
    this.balanceBefore,
    this.balanceAfter,
    this.availableBefore,
    this.availableAfter,
  });

  factory AddFundsResponseDto.fromJson(Map<String, dynamic> json) {
    return AddFundsResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      targetUserId: json['targetUserId'] as int?,
      amount: (json['amount'] as num?)?.toDouble(),
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble(),
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      availableBefore: (json['availableBefore'] as num?)?.toDouble(),
      availableAfter: (json['availableAfter'] as num?)?.toDouble(),
    );
  }
}
