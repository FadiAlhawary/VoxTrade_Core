class AdminActionResponseDto {
  final bool success;
  final String message;
  final int? id;

  AdminActionResponseDto({
    required this.success,
    required this.message,
    this.id,
  });

  factory AdminActionResponseDto.fromJson(Map<String, dynamic> json) {
    return AdminActionResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      id: json['id'] as int?,
    );
  }
}

class AdminDashboardDto {
  final int totalUsers;
  final int activeUsers;
  final int lockedUsers;
  final int totalInstruments;
  final int activeInstruments;
  final int totalOrders;
  final int pendingOrders;
  final int filledOrders;
  final int cancelledOrders;
  final int totalTrades;
  final double totalWalletBalance;
  final double totalAvailableBalance;
  final double totalReservedBalance;

  AdminDashboardDto({
    required this.totalUsers,
    required this.activeUsers,
    required this.lockedUsers,
    required this.totalInstruments,
    required this.activeInstruments,
    required this.totalOrders,
    required this.pendingOrders,
    required this.filledOrders,
    required this.cancelledOrders,
    required this.totalTrades,
    required this.totalWalletBalance,
    required this.totalAvailableBalance,
    required this.totalReservedBalance,
  });

  factory AdminDashboardDto.fromJson(Map<String, dynamic> json) {
    return AdminDashboardDto(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      lockedUsers: json['lockedUsers'] ?? 0,
      totalInstruments: json['totalInstruments'] ?? 0,
      activeInstruments: json['activeInstruments'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      filledOrders: json['filledOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
      totalTrades: json['totalTrades'] ?? 0,
      totalWalletBalance: (json['totalWalletBalance'] as num?)?.toDouble() ?? 0,
      totalAvailableBalance:
          (json['totalAvailableBalance'] as num?)?.toDouble() ?? 0,
      totalReservedBalance:
          (json['totalReservedBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AdminUserDto {
  final int id;
  final String username;
  final String firstNameEn;
  final String lastNameEn;
  final String? firstNameAr;
  final String? lastNameAr;
  final int roleId;
  final String roleName;
  final bool isDeleted;
  final bool isLocked;
  final String? lockReason;
  final bool isLoggedIn;
  final bool is2FaEnabled;
  final int? primaryCurrencyId;
  final DateTime? createdAt;
  final DateTime? lastLoginDate;

  AdminUserDto({
    required this.id,
    required this.username,
    required this.firstNameEn,
    required this.lastNameEn,
    this.firstNameAr,
    this.lastNameAr,
    required this.roleId,
    required this.roleName,
    required this.isDeleted,
    required this.isLocked,
    this.lockReason,
    required this.isLoggedIn,
    required this.is2FaEnabled,
    this.primaryCurrencyId,
    this.createdAt,
    this.lastLoginDate,
  });

  String get displayName {
    final en = '$firstNameEn $lastNameEn'.trim();
    return en.isNotEmpty ? en : username;
  }

  bool matchesSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (id.toString().contains(q)) return true;
    if (username.toLowerCase().contains(q)) return true;
    if (displayName.toLowerCase().contains(q)) return true;
    if (roleName.toLowerCase().contains(q)) return true;
    if (roleId.toString() == q) return true;
    final ar = '${firstNameAr ?? ''} ${lastNameAr ?? ''}'.trim().toLowerCase();
    if (ar.isNotEmpty && ar.contains(q)) return true;
    return false;
  }

  factory AdminUserDto.fromJson(Map<String, dynamic> json) {
    return AdminUserDto(
      id: json['id'] as int,
      username: json['username'] ?? '',
      firstNameEn: json['firstNameEn'] ?? '',
      lastNameEn: json['lastNameEn'] ?? '',
      firstNameAr: json['firstNameAr'] as String?,
      lastNameAr: json['lastNameAr'] as String?,
      roleId: json['roleId'] ?? 0,
      roleName: json['roleName'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      isLocked: json['isLocked'] ?? false,
      lockReason: json['lockReason'] as String?,
      isLoggedIn: json['isLoggedIn'] ?? false,
      is2FaEnabled: json['is2FaEnabled'] ?? false,
      primaryCurrencyId: json['primaryCurrencyId'] as int?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      lastLoginDate:
          json['lastLoginDate'] != null
              ? DateTime.tryParse(json['lastLoginDate'].toString())
              : null,
    );
  }
}

class UpdateUserAdminRequestDto {
  final String? firstNameEn;
  final String? lastNameEn;
  final String? firstNameAr;
  final String? lastNameAr;
  final String? username;
  final int? roleId;
  final int? primaryCurrencyId;
  final bool? is2FaEnabled;

  UpdateUserAdminRequestDto({
    this.firstNameEn,
    this.lastNameEn,
    this.firstNameAr,
    this.lastNameAr,
    this.username,
    this.roleId,
    this.primaryCurrencyId,
    this.is2FaEnabled,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstNameEn != null) map['firstNameEn'] = firstNameEn;
    if (lastNameEn != null) map['lastNameEn'] = lastNameEn;
    if (firstNameAr != null) map['firstNameAr'] = firstNameAr;
    if (lastNameAr != null) map['lastNameAr'] = lastNameAr;
    if (username != null) map['username'] = username;
    if (roleId != null) map['roleId'] = roleId;
    if (primaryCurrencyId != null) map['primaryCurrencyId'] = primaryCurrencyId;
    if (is2FaEnabled != null) map['is2FaEnabled'] = is2FaEnabled;
    return map;
  }
}

class AdminWalletDto {
  final int id;
  final int userId;
  final String username;
  final int currencyId;
  final String currencySymbol;
  final double balance;
  final double availableBalance;
  final double reservedBalance;
  final bool status;
  final String? freezeReason;
  final DateTime? updatedAt;

  AdminWalletDto({
    required this.id,
    required this.userId,
    required this.username,
    required this.currencyId,
    required this.currencySymbol,
    required this.balance,
    required this.availableBalance,
    required this.reservedBalance,
    required this.status,
    this.freezeReason,
    this.updatedAt,
  });

  bool get isFrozen => !status;

  bool matchesSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (userId.toString().contains(q)) return true;
    if (id.toString().contains(q)) return true;
    if (username.toLowerCase().contains(q)) return true;
    if (currencySymbol.toLowerCase().contains(q)) return true;
    if (currencyId.toString() == q) return true;
    return false;
  }

  factory AdminWalletDto.fromJson(Map<String, dynamic> json) {
    return AdminWalletDto(
      id: json['id'] as int,
      userId: json['userId'] as int,
      username: json['username'] ?? '',
      currencyId: json['currencyId'] ?? 0,
      currencySymbol: json['currencySymbol'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
      reservedBalance: (json['reservedBalance'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? true,
      freezeReason: json['freezeReason'] as String?,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null,
    );
  }
}

class AdjustWalletRequestDto {
  final int adminUserId;
  final int targetUserId;
  final double amount;
  final String? description;

  AdjustWalletRequestDto({
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

class AdminInstrumentDto {
  final int id;
  final String symbol;
  final String shortName;
  final String name;
  final double tickSize;
  final double minQuantity;
  final String instrumentType;
  final String status;
  final bool isDeleted;
  final DateTime? createdAt;

  AdminInstrumentDto({
    required this.id,
    required this.symbol,
    required this.shortName,
    required this.name,
    required this.tickSize,
    required this.minQuantity,
    required this.instrumentType,
    required this.status,
    required this.isDeleted,
    this.createdAt,
  });

  factory AdminInstrumentDto.fromJson(Map<String, dynamic> json) {
    return AdminInstrumentDto(
      id: json['id'] as int,
      symbol: json['symbol'] ?? '',
      shortName: json['shortName'] ?? '',
      name: json['name'] ?? '',
      tickSize: (json['tickSize'] as num?)?.toDouble() ?? 0,
      minQuantity: (json['minQuantity'] as num?)?.toDouble() ?? 0,
      instrumentType: json['instrumentType'] ?? '',
      status: json['status'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
    );
  }
}

class AdminOrderDto {
  final int id;
  final int userId;
  final String username;
  final int instrumentId;
  final String symbol;
  final String side;
  final double quantity;
  final double? limitPrice;
  final double? executionPrice;
  final double filledQuantity;
  final double remainingQuantity;
  final String status;
  final String orderType;
  final DateTime? createdAt;

  AdminOrderDto({
    required this.id,
    required this.userId,
    required this.username,
    required this.instrumentId,
    required this.symbol,
    required this.side,
    required this.quantity,
    this.limitPrice,
    this.executionPrice,
    required this.filledQuantity,
    required this.remainingQuantity,
    required this.status,
    required this.orderType,
    this.createdAt,
  });

  factory AdminOrderDto.fromJson(Map<String, dynamic> json) {
    return AdminOrderDto(
      id: json['id'] as int,
      userId: json['userId'] as int,
      username: json['username'] ?? '',
      instrumentId: json['instrumentId'] ?? 0,
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      limitPrice: (json['limitPrice'] as num?)?.toDouble(),
      executionPrice: (json['executionPrice'] as num?)?.toDouble(),
      filledQuantity: (json['filledQuantity'] as num?)?.toDouble() ?? 0,
      remainingQuantity: (json['remainingQuantity'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? '',
      orderType: json['orderType'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
    );
  }
}

class AdminTradeDto {
  final int id;
  final int orderId;
  final int userId;
  final String username;
  final int instrumentId;
  final String symbol;
  final String side;
  final double price;
  final double quantity;
  final double tradeValue;
  final DateTime? executedAt;

  AdminTradeDto({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.username,
    required this.instrumentId,
    required this.symbol,
    required this.side,
    required this.price,
    required this.quantity,
    required this.tradeValue,
    this.executedAt,
  });

  factory AdminTradeDto.fromJson(Map<String, dynamic> json) {
    return AdminTradeDto(
      id: json['id'] as int,
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] as int,
      username: json['username'] ?? '',
      instrumentId: json['instrumentId'] ?? 0,
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      tradeValue: (json['tradeValue'] as num?)?.toDouble() ?? 0,
      executedAt:
          json['executedAt'] != null
              ? DateTime.tryParse(json['executedAt'].toString())
              : null,
    );
  }
}

class AdminRoleDto {
  final int id;
  final String roleNameEn;
  final String roleNameAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final bool allowDelete;
  final bool allowCreate;
  final bool allowEdit;
  final bool allowSuperView;
  final bool lockAllUser;
  final bool isDeleted;

  AdminRoleDto({
    required this.id,
    required this.roleNameEn,
    required this.roleNameAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.allowDelete,
    required this.allowCreate,
    required this.allowEdit,
    required this.allowSuperView,
    required this.lockAllUser,
    required this.isDeleted,
  });

  factory AdminRoleDto.fromJson(Map<String, dynamic> json) {
    return AdminRoleDto(
      id: json['id'] as int,
      roleNameEn: json['roleNameEn'] ?? '',
      roleNameAr: json['roleNameAr'] ?? '',
      descriptionEn: json['descriptionEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      allowDelete: json['allowDelete'] ?? false,
      allowCreate: json['allowCreate'] ?? false,
      allowEdit: json['allowEdit'] ?? false,
      allowSuperView: json['allowSuperView'] ?? false,
      lockAllUser: json['lockAllUser'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

class AdminCurrencyDto {
  final int id;
  final String nameEn;
  final String nameAr;
  final String symbol;
  final double usdRate;
  final bool isDeleted;

  AdminCurrencyDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.symbol,
    required this.usdRate,
    required this.isDeleted,
  });

  factory AdminCurrencyDto.fromJson(Map<String, dynamic> json) {
    return AdminCurrencyDto(
      id: json['id'] as int,
      nameEn: json['nameEn'] ?? '',
      nameAr: json['nameAr'] ?? '',
      symbol: json['symbol'] ?? '',
      usdRate: (json['usdRate'] as num?)?.toDouble() ?? 0,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

class AdminAuditLogDto {
  final int id;
  final int? userId;
  final String? username;
  final String entity;
  final int? entityId;
  final String actionCode;
  final String? description;
  final DateTime? createdAt;

  AdminAuditLogDto({
    required this.id,
    this.userId,
    this.username,
    required this.entity,
    this.entityId,
    required this.actionCode,
    this.description,
    this.createdAt,
  });

  factory AdminAuditLogDto.fromJson(Map<String, dynamic> json) {
    return AdminAuditLogDto(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      entity: json['entity'] ?? '',
      entityId: json['entityId'] as int?,
      actionCode: json['actionCode'] ?? '',
      description: json['description'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
    );
  }
}
