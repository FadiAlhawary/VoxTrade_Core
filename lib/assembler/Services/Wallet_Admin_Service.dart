import 'package:voxtrade_core/Components/ModelDto/UserSearchResultDto.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<UserSearchResultDto>> searchUsers(String query, {int limit = 20}) {
  return sendHttpRequest<List<UserSearchResultDto>>(
    '/api/User/SearchUsers',
    param: {'query': query, 'limit': limit},
    fromJson: (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => UserSearchResultDto.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
}

