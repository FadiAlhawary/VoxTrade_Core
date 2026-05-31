class TransferMoneyRequestDto {
  final int fromUserId;
  final int toUserId;
  final double amount;
  final String? description;

  TransferMoneyRequestDto({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'amount': amount,
    if (description != null && description!.isNotEmpty) 'description': description,
  };
}

class TransferMoneyResponseDto {
  final bool success;
  final String message;
  final int? fromUserId;
  final int? toUserId;
  final double? amount;
  final double? senderBalanceAfter;
  final double? senderAvailableBalanceAfter;
  final double? receiverBalanceAfter;
  final double? receiverAvailableBalanceAfter;

  TransferMoneyResponseDto({
    required this.success,
    required this.message,
    this.fromUserId,
    this.toUserId,
    this.amount,
    this.senderBalanceAfter,
    this.senderAvailableBalanceAfter,
    this.receiverBalanceAfter,
    this.receiverAvailableBalanceAfter,
  });

  factory TransferMoneyResponseDto.fromJson(Map<String, dynamic> json) {
    return TransferMoneyResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      fromUserId: json['fromUserId'] as int?,
      toUserId: json['toUserId'] as int?,
      amount: (json['amount'] as num?)?.toDouble(),
      senderBalanceAfter: (json['senderBalanceAfter'] as num?)?.toDouble(),
      senderAvailableBalanceAfter:
          (json['senderAvailableBalanceAfter'] as num?)?.toDouble(),
      receiverBalanceAfter: (json['receiverBalanceAfter'] as num?)?.toDouble(),
      receiverAvailableBalanceAfter:
          (json['receiverAvailableBalanceAfter'] as num?)?.toDouble(),
    );
  }
}
