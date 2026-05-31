import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Models/FinnHubModels/News_Model.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

import '../Services/FinnHub_Services.dart';

/// Finnhub / backend expect `from` and `to` as YYYY-MM-DD, not full ISO-8601.
String _companyNewsDateOnly(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class NewsController extends GetxController {
  RxList<News> marketNews = <News>[].obs;
  RxList<News> companyNews = <News>[].obs;
  RxBool isMarketNewsLoading = false.obs;
  RxBool isCompanyNewsLoading = false.obs;
  RxString selectedSymbol = 'AAPL'.obs;
  RxString selectedFromDate =
      _companyNewsDateOnly(
        DateTime.now().subtract(const Duration(days: 365)),
      ).obs;
  RxString selectedToDate = _companyNewsDateOnly(DateTime.now()).obs;

  @override
  void onInit() {
    super.onInit();
    // News loads when a screen requests it.
  }

  Future<void> ensureMarketNewsLoaded() async {
    if (marketNews.isNotEmpty || isMarketNewsLoading.value) return;
    await fetchMarketNews();
  }

  Future<void> ensureCompanyNewsLoaded() async {
    if (companyNews.isNotEmpty || isCompanyNewsLoading.value) return;
    await fetchCompanyNews();
  }

  Future<void> fetchCompanyNews() async {
    try {
      isCompanyNewsLoading.value = true;
      var data = await getCompanyNews(
        symbol: selectedSymbol.value,
        from: selectedFromDate.value,
        to: selectedToDate.value,
      );
      companyNews.value = data;
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: "Error while Fetching Company News",
        status: SnackBarCompStatus.danger,
      );
    } finally {
      isCompanyNewsLoading.value = false;
    }
  }

  Future<void> fetchMarketNews({String category = "general"}) async {
    try {
      isMarketNewsLoading.value = true;
      var data = await getMarketNews(category: category);
      marketNews.value = data;
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: "Error while Fetching Market News",
        status: SnackBarCompStatus.danger,
      );
    } finally {
      isMarketNewsLoading.value = false;
    }
  }
}
