import 'package:voxtrade_core/Components/ModelDto/PortfolioPositionDto.dart';
import 'package:voxtrade_core/Components/ModelDto/PortfolioProfitLossPointDto.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<PortfolioPositionDto>> getPortfolio(int userId) {
  return sendHttpRequest<List<PortfolioPositionDto>>(
    "/api/Portfolio/GetPortfolio",
    param: {'userId': userId},
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => PortfolioPositionDto.fromJson(e)).toList();
    },
  );
}
Future<List<PortfolioProfitLossPointDto>> getProfitLossChart(int userId, DateTime from, DateTime to) {
  return sendHttpRequest<List<PortfolioProfitLossPointDto>>(
    "/api/Portfolio/GetProfitLossChart",
    param: {'userId': userId, 'from': from, 'to': to},
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => PortfolioProfitLossPointDto.fromJson(e)).toList();
    },
  );
}
