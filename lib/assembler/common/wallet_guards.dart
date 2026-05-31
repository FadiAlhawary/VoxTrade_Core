import 'package:voxtrade_core/Components/ModelDto/WalletDTO.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

const String walletFrozenUserMessage =
    'Your wallet is frozen. You cannot buy, sell, receive, or send funds until an admin unfreezes it.';

const String walletFrozenTargetMessage =
    'This user\'s wallet is frozen. Credits and debits are blocked until it is unfrozen.';

extension WalletFrozenX on WalletDto {
  bool get isFrozen => !status;
}

/// Returns false when the wallet is frozen and an optional snackbar was shown.
bool ensureWalletCanTransact(
  WalletDto wallet, {
  bool showSnack = true,
  String? message,
}) {
  if (!wallet.isFrozen) return true;
  if (showSnack) {
    SnackBarComp.show(
      message ?? walletFrozenUserMessage,
      title: 'Wallet frozen',
      status: SnackBarCompStatus.warning,
    );
  }
  return false;
}
