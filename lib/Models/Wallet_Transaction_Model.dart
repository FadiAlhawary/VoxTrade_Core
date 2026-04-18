import 'package:voxtrade_core/Components/ModelDto/WalletHistoryDTO.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.walletId,
    required this.transactionType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.transactionTime,
  });

  final int walletId;
  final String transactionType;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime transactionTime;

  factory WalletTransaction.fromDto(WalletHistoryDto dto) {
    return WalletTransaction(
      walletId: dto.walletId,
      transactionType: dto.transactionType,
      amount: dto.amount,
      balanceBefore: dto.balanceBefore,
      balanceAfter: dto.balanceAfter,
      transactionTime: dto.createdAt,
    );
  }

  bool get isPositive => amount > 0;

  String get formattedAmount {
    final sign = isPositive ? '+' : amount < 0 ? '-' : '';
    return '$sign\$${amount.abs().toStringAsFixed(2)}';
  }

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[transactionTime.month - 1]} ${transactionTime.day}, ${transactionTime.year}';
  }
}
