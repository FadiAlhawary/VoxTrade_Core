import 'package:voxtrade_core/Components/ModelDto/AuthResponseDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/RegisterDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/UserDTO.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<UserDTO> getUserProfileData(int userId) {
  return sendHttpRequest<UserDTO>(
    "/api/User/GetUserProfileById",
    param: {'userId': userId},
    fromJson: (json) {
      return UserDTO.fromJson(json);
    },
  );
}

Future<AuthResponseDTO> login(String userName, String password) {
  return sendHttpPostRequest<AuthResponseDTO>(
    "/api/Auth/login",
    body: {'username': userName, 'password': password},
    fromJson: (json) {
      return AuthResponseDTO.fromJson(json);
    },
  );
}

Future<AuthResponseDTO> register(RegisterDTO registerDTO) {
  return sendHttpPostRequest<AuthResponseDTO>(
    "/api/Auth/register",
    body: registerDTO.toJson(),
    fromJson: (json) {
      return AuthResponseDTO.fromJson(json);
    },
  );
}
