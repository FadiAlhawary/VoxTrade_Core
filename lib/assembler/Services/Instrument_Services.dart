import 'package:voxtrade_core/Components/ModelDto/InstrumentDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/LookupItemDto.dart';
import 'package:voxtrade_core/assembler/common/globalAJAXService.dart';

Future<List<InstrumentDTO>> getOrderStatuses({bool activeOnly = true}) {
  return sendHttpRequest<List<InstrumentDTO>>(
    "/api/Instrument/GetAllInstrument",
    param: {'activeOnly': activeOnly},
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => InstrumentDTO.fromJson(e)).toList();
    },
  );
}

Future<List<LookupItemDto>> getInstrumentTypes() {
  return sendHttpRequest<List<LookupItemDto>>(
    "/api/Instrument/GetInstrumentTypes",
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => LookupItemDto.fromJson(e)).toList();
    },
  );
}

Future<List<LookupItemDto>> getInstrumentStatuses() {
  return sendHttpRequest<List<LookupItemDto>>(
    "/api/Instrument/GetInstrumentStatuses",
    fromJson: (json) {
      final list = json as List;
      return list.map((e) => LookupItemDto.fromJson(e)).toList();
    },
  );
}
