import 'package:voxtrade_core/Components/ModelDto/AddFundsDtos.dart';
import 'package:voxtrade_core/Components/ModelDto/AdminDtos.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

const _base = '/api/admin';

List<T> _parseList<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
  if (json is! List) return [];
  return json
      .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

T _mapJson<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
  return fromJson(Map<String, dynamic>.from(json as Map));
}

Future<AdminDashboardDto> adminGetDashboard() {
  return sendHttpRequest<AdminDashboardDto>(
    '$_base/dashboard',
    fromJson: (json) => _mapJson(json, AdminDashboardDto.fromJson),
  );
}

Future<List<AdminUserDto>> adminGetUsers() {
  return sendHttpRequest<List<AdminUserDto>>(
    '$_base/users',
    fromJson: (json) => _parseList(json, AdminUserDto.fromJson),
  );
}

Future<AdminUserDto> adminGetUser(int userId) {
  return sendHttpRequest<AdminUserDto>(
    '$_base/users/$userId',
    fromJson: (json) => _mapJson(json, AdminUserDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminUpdateUser(
  int targetUserId,
  int adminUserId,
  UpdateUserAdminRequestDto body,
) {
  return sendHttpPutRequest<AdminActionResponseDto>(
    '$_base/users/$targetUserId',
    queryParameters: {'adminUserId': adminUserId},
    body: body.toJson(),
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminAssignUserRole(
  int targetUserId,
  int roleId,
  int adminUserId,
) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/users/$targetUserId/role/$roleId',
    queryParameters: {'adminUserId': adminUserId},
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminRestoreUser(
  int targetUserId,
  int adminUserId,
) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/users/$targetUserId/restore',
    queryParameters: {'adminUserId': adminUserId},
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminLockUser(
  int targetUserId,
  int adminUserId, {
  String? reason,
}) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/users/$targetUserId/lock',
    queryParameters: {
      'adminUserId': adminUserId,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    },
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminUnlockUser(
  int targetUserId,
  int adminUserId,
) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/users/$targetUserId/unlock',
    queryParameters: {'adminUserId': adminUserId},
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<List<AdminWalletDto>> adminGetWallets() {
  return sendHttpRequest<List<AdminWalletDto>>(
    '$_base/wallets',
    fromJson: (json) => _parseList(json, AdminWalletDto.fromJson),
  );
}

Future<AdminWalletDto> adminGetUserWallet(int userId) {
  return sendHttpRequest<AdminWalletDto>(
    '$_base/users/$userId/wallet',
    fromJson: (json) => _mapJson(json, AdminWalletDto.fromJson),
  );
}

Future<AddFundsResponseDto> adminAddFunds(AdjustWalletRequestDto request) {
  return sendHttpPostRequest<AddFundsResponseDto>(
    '$_base/wallets/add-funds',
    body: request.toJson(),
    fromJson:
        (json) => AddFundsResponseDto.fromJson(json as Map<String, dynamic>),
  );
}

Future<AdminActionResponseDto> adminDeductFunds(
  AdjustWalletRequestDto request,
) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/wallets/deduct-funds',
    body: request.toJson(),
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminFreezeWallet(
  int targetUserId,
  int adminUserId, {
  String? reason,
}) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/users/$targetUserId/wallet/freeze',
    queryParameters: {
      'adminUserId': adminUserId,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    },
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminUnfreezeWallet(
  int targetUserId,
  int adminUserId,
) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/users/$targetUserId/wallet/unfreeze',
    queryParameters: {'adminUserId': adminUserId},
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<List<AdminInstrumentDto>> adminGetInstruments() {
  return sendHttpRequest<List<AdminInstrumentDto>>(
    '$_base/instruments',
    fromJson: (json) => _parseList(json, AdminInstrumentDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminDeactivateInstrument(
  int instrumentId,
  int adminUserId,
) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/instruments/$instrumentId/deactivate',
    queryParameters: {'adminUserId': adminUserId},
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminRestoreInstrument(int instrumentId) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/instruments/$instrumentId/restore',
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<List<AdminOrderDto>> adminGetOrders() {
  return sendHttpRequest<List<AdminOrderDto>>(
    '$_base/orders',
    fromJson: (json) => _parseList(json, AdminOrderDto.fromJson),
  );
}

Future<AdminActionResponseDto> adminCancelOrder(int orderId, int adminUserId) {
  return sendHttpPostRequest<AdminActionResponseDto>(
    '$_base/orders/$orderId/cancel',
    queryParameters: {'adminUserId': adminUserId},
    fromJson: (json) => _mapJson(json, AdminActionResponseDto.fromJson),
  );
}

Future<List<AdminTradeDto>> adminGetTrades() {
  return sendHttpRequest<List<AdminTradeDto>>(
    '$_base/trades',
    fromJson: (json) => _parseList(json, AdminTradeDto.fromJson),
  );
}

Future<List<AdminRoleDto>> adminGetRoles() {
  return sendHttpRequest<List<AdminRoleDto>>(
    '$_base/roles',
    fromJson: (json) => _parseList(json, AdminRoleDto.fromJson),
  );
}

Future<List<AdminCurrencyDto>> adminGetCurrencies() {
  return sendHttpRequest<List<AdminCurrencyDto>>(
    '$_base/currencies',
    fromJson: (json) => _parseList(json, AdminCurrencyDto.fromJson),
  );
}

Future<List<AdminAuditLogDto>> adminGetAuditLogs() {
  return sendHttpRequest<List<AdminAuditLogDto>>(
    '$_base/audit-logs',
    fromJson: (json) => _parseList(json, AdminAuditLogDto.fromJson),
  );
}
