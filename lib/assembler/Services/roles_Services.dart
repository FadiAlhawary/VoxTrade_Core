import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

import '../../Models/Roles_Model.dart';


Future<List<RolesModel>> GetAllRoles() {
  return sendHttpRequest<List<RolesModel>>(
    "/api/Roles/GetAllRoles",
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => RolesModel.fromJson(e)).toList();
    },
  );
}