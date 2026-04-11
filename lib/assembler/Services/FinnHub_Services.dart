import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

import '../../Models/FinnHubModels/News_Model.dart';

Future<List<News>> getMarketNews({String category = "general"}) {
  return sendHttpRequest<List<News>>(
    "/api/FinnHub/MarketNews",
    param: {'category': category},
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => News.fromJson(e)).toList();
    },
  );
}

Future<List<News>> getCompanyNews({
  required String symbol,
  required String from,
  required String to,
}) {
  return sendHttpRequest<List<News>>(
    "/api/FinnHub/CompanyNews",
    param: {'symbol': symbol, 'from': from, 'to': to},
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => News.fromJson(e)).toList();
    },
  );
}
