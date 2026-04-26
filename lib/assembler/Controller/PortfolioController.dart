import 'package:get/get.dart';
import 'dart:async';
import 'package:voxtrade_core/Components/ModelDto/PortfolioPositionDto.dart';
import 'package:voxtrade_core/Components/ModelDto/PortfolioProfitLossPointDto.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Portfolio_Services.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class PortfolioController extends GetxController {
  final userController = Get.find<UserController>();
  RxList<PortfolioPositionDto> portfolio = <PortfolioPositionDto>[].obs;
  RxList<PortfolioProfitLossPointDto> profitLossChart =
      <PortfolioProfitLossPointDto>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingProfitLossChart = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPortfolio();
  }

  Future<void> fetchProfitLossChart(DateTime from, DateTime to) async {
    isLoadingProfitLossChart.value = true;
    try {
      var data = await getProfitLossChart(
        userController.user.value!.id,
        from,
        to,
      ).timeout(const Duration(seconds: 15));
      profitLossChart.value = data;
    } on TimeoutException {
      SnackBarComp.show(
        "Profit/loss request timed out. Please try again.",
        title: "Timeout while fetching profit loss chart",
        status: SnackBarCompStatus.danger,
      );
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: "Error while fetching profit loss chart",
        status: SnackBarCompStatus.danger,
      );
    } finally {
      isLoadingProfitLossChart.value = false;
    }
  }

  Future<void> fetchPortfolio() async {
    isLoading.value = true;
    try {
      var data = await getPortfolio(userController.user.value!.id);
      portfolio.value = data;
    } catch (e) {
      SnackBarComp.show(
        e.toString(),
        title: "Error while fetching portfolio",
        status: SnackBarCompStatus.danger,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
