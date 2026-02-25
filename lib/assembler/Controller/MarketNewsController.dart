


import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Models/FinnHubModels/MarketNews_Model.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

import '../Services/FinnHub_Services.dart';

class MarketNewsController extends GetxController {
  RxList<MarketNews> marketNews = <MarketNews>[].obs;

  Future<void> fetchNews({String category = "general"}) async {
    try{
      var data = await getMarketNews(category: category);
      marketNews.value = data;
    }catch(e){
       SnackBarComp.show(
         e.toString(),
         title: "Error while Fetching Market News",
         status: SnackBarCompStatus.danger
       );
    }
 }
}