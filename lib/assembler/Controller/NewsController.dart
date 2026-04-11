import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Models/FinnHubModels/News_Model.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

import '../Services/FinnHub_Services.dart';

class NewsController extends GetxController {
  RxList<News> marketNews = <News>[].obs;
  RxList<News> companyNews = <News>[].obs;
  RxBool isMarketNewsLoading = false.obs;
  RxBool isCompanyNewsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMarketNews();
    fetchCompanyNews(symbol: "AAPL", from: "2025-01-01", to: "2025-12-31");
  }

  Future<void> fetchCompanyNews({
    required String symbol,
    required String from,
    required String to,
  }) async {
    try {
      isCompanyNewsLoading.value = true;
      var data = await getCompanyNews(symbol: symbol, from: from, to: to);
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
