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
    fetchInstruments();
    fetchInstrumentTypes();
  }
  
  InstrumentDTO getInstrumentById(int instrumentId) {
    return instruments.firstWhere((instrument) => instrument.id == instrumentId);
  }
  Future<void> fetchInstruments({bool activeOnly = true}) async {
    try {
      isLoading.value = true;
      var data = await getInstruments(activeOnly: activeOnly);
      instruments.value = data;
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
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
    }
  }
}
