import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/InstrumentDTO.dart';
import 'package:voxtrade_core/Components/ModelDto/LookupItemDto.dart';
import 'package:voxtrade_core/assembler/Services/Instrument_Services.dart';

class InstrumentController extends GetxController {
  RxList<InstrumentDTO> instruments = <InstrumentDTO>[].obs;
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  RxString errorMessage = ''.obs;
  RxList<LookupItemDto> instrumentTypes = <LookupItemDto>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInstruments().whenComplete(() {
      fetchInstrumentTypes();
    });
  }
  
  InstrumentDTO getInstrumentById(int instrumentId) {
    return instruments.firstWhere((instrument) => instrument.id == instrumentId);
  }

  /// Prefer a Bitcoin pair for trade entry; falls back to the first instrument.
  int resolveDefaultTradeInstrumentId() {
    if (instruments.isEmpty) return 0;
    for (final InstrumentDTO i in instruments) {
      if (matchesBitcoinInstrument(i)) return i.id;
    }
    return instruments.first.id;
  }

  /// True if this instrument is treated as the primary Bitcoin market.
  static bool matchesBitcoinInstrument(InstrumentDTO i) {
    final String sym = i.symbol.toUpperCase();
    final String name = i.name.toUpperCase();
    final String short = i.shortName.toUpperCase();
    if (sym == 'BTC' || short == 'BTC') return true;
    if (name.contains('BITCOIN')) return true;
    if (sym.contains('BTCUSDT') ||
        sym.contains('BTC_USDT') ||
        sym.contains('BTCUSD') ||
        sym.contains('BTC_USD')) {
      return true;
    }
    if (sym.startsWith('BTC') && sym.length <= 12) return true;
    return false;
  }
  Future<void> fetchInstruments({bool activeOnly = true}) async {
    try {
      isLoading.value = true;
      var data = await getInstruments(activeOnly: activeOnly);
      instruments.value = data;
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInstrumentTypes() async {
    try {
      isLoading.value = true;
      var data = await getInstrumentTypes();
      instrumentTypes.value = data;
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
