import 'package:voxtrade_core/Components/ModelDto/CandleDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/PlaceOrderRequestDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/PlaceOrderResponseDTO.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<PlaceOrderResponseDTO>> placeOrder(PlaceOrderRequestDTO request) {
  return sendHttpPostRequest<List<PlaceOrderResponseDTO>>(
    "/api/Market/PlaceOrder",
    body: request.toJson(),
    fromJson: (json) {
      if (json is List) {
        return json
            .map(
              (e) => PlaceOrderResponseDTO.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      if (json is Map<String, dynamic>) {
        return [PlaceOrderResponseDTO.fromJson(json)];
      }
      throw Exception(
        'Unexpected PlaceOrder response type: ${json.runtimeType}',
      );
    },
  );
}

Future<List<CandleDTO>> getHistoricalCandles(
  String symbol,
  String resolution,
  int from,
  int to,
) {
  return sendHttpRequest<List<CandleDTO>>(
    "/api/FinnHub/HistoricalCandles",
    param: {'symbol': symbol, 'resolution': resolution, 'from': from, 'to': to},
    fromJson: (json) {
      List<CandleDTO> parseList(List<dynamic> list) {
        return list
            .whereType<Map>()
            .map((e) => CandleDTO.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      List<CandleDTO> parseFinnhubArrays(Map<String, dynamic> map) {
        final times = (map['t'] as List?) ?? const [];
        final opens = (map['o'] as List?) ?? const [];
        final highs = (map['h'] as List?) ?? const [];
        final lows = (map['l'] as List?) ?? const [];
        final closes = (map['c'] as List?) ?? const [];

        final count = [
          times.length,
          opens.length,
          highs.length,
          lows.length,
          closes.length,
        ].reduce((a, b) => a < b ? a : b);

        if (count == 0) return const [];

        return List.generate(count, (i) {
          return CandleDTO.fromJson({
            'time': times[i],
            'open': opens[i],
            'high': highs[i],
            'low': lows[i],
            'close': closes[i],
          });
        });
      }

      if (json is List) {
        return parseList(json);
      }
      if (json is Map<String, dynamic>) {
        // Case: single candle object.
        if (json.containsKey('time') || json.containsKey('t')) {
          final t = json['t'];
          if (t is List) {
            return parseFinnhubArrays(json);
          }
          return [CandleDTO.fromJson(json)];
        }

        // Case: wrapped responses (e.g. { data: [...] } / { result: [...] }).
        for (final key in const ['data', 'result', 'results', 'candles']) {
          final nested = json[key];
          if (nested is List) {
            return parseList(nested);
          }
          if (nested is Map<String, dynamic>) {
            if (nested['t'] is List) {
              return parseFinnhubArrays(nested);
            }
            if (nested.containsKey('time') || nested.containsKey('t')) {
              return [CandleDTO.fromJson(nested)];
            }
          }
        }
      }
      throw Exception('Unexpected Candle response type: ${json.runtimeType}');
    },
  );
}
