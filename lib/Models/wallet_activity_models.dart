import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/ModelDto/WalletHistoryDTO.dart';

enum WalletActivityKind { deposit, withdrawal, transfer }

extension WalletActivityKindX on WalletActivityKind {
  String get title => switch (this) {
        WalletActivityKind.deposit => 'Deposit',
        WalletActivityKind.withdrawal => 'Withdrawal',
        WalletActivityKind.transfer => 'Transfer',
      };

  IconData get icon => switch (this) {
        WalletActivityKind.deposit => Icons.south_west_rounded,
        WalletActivityKind.withdrawal => Icons.north_east_rounded,
        WalletActivityKind.transfer => Icons.swap_horiz_rounded,
      };
}

class WalletActivityTransaction {
  const WalletActivityTransaction({
    required this.kind,
    required this.occurredAt,
    required this.signedAmount,
  });

  final WalletActivityKind kind;
  final DateTime occurredAt;
  /// Positive = money in, negative = money out.
  final double signedAmount;

  String get displayTitle => kind.title;

  factory WalletActivityTransaction.fromDto(WalletHistoryDto dto) {
    return WalletActivityTransaction(
      kind: _kindFromTransactionType(dto.transactionType),
      occurredAt: dto.createdAt,
      signedAmount: dto.amount,
    );
  }
}

WalletActivityKind _kindFromTransactionType(String raw) {
  final s = raw.toLowerCase();
  if (s.contains('deposit') ||
      s.contains('credit') ||
      s.contains('fund') ||
      s.contains('inbound')) {
    return WalletActivityKind.deposit;
  }
  if (s.contains('withdraw') || s.contains('debit') || s.contains('outbound')) {
    return WalletActivityKind.withdrawal;
  }
  return WalletActivityKind.transfer;
}

String formatWalletActivityDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}
