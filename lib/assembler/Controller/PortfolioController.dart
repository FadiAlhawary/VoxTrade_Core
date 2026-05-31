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
  final RxString lastPortfolioError = ''.obs;

  int? get _userId => userController.user.value?.id;

  @override
  void onInit() {
    super.onInit();
    ever(userController.user, (_) {
      if (_userId != null) fetchPortfolio();
    });
  }

  Future<void> fetchProfitLossChart(DateTime from, DateTime to) async {
    final userId = _userId;
    if (userId == null) return;

    isLoadingProfitLossChart.value = true;
    try {
      var data = await getProfitLossChart(userId, from, to).timeout(
        const Duration(seconds: 15),
      );
      profitLossChart.value = data;
    } on TimeoutException {
      SnackBarComp.show(
        'Profit/loss request timed out. Please try again.',
        title: 'Chart unavailable',
        status: SnackBarCompStatus.danger,
      );
    } catch (e) {
      SnackBarComp.showError(e, title: 'Chart unavailable');
    } finally {
      isLoadingProfitLossChart.value = false;
    }
  }

  Future<void> fetchPortfolio() async {
    final userId = _userId;
    if (userId == null) return;

    isLoading.value = true;
    lastPortfolioError.value = '';
    try {
      var data = await getPortfolio(userId);
      portfolio.value = data;
    } catch (e) {
      lastPortfolioError.value = e.toString();
      SnackBarComp.showError(e, title: 'Portfolio unavailable');
    } finally {
      isLoading.value = false;
    }
  }
}
