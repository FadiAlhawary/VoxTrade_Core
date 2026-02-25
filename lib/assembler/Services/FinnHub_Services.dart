


import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

import '../../Models/FinnHubModels/MarketNews_Model.dart';

Future<List<MarketNews>> getMarketNews({String category = "general"}) {
  print("APi called");
  return sendHttpRequest<List<MarketNews>>(
    "/api/FinnHub/MarketNews",
    param: {'category': category},
    fromJson: (json) {
      final list = json as List;
      return list
          .map((e) => MarketNews.fromJson(e))
          .toList();
    },
  );
}