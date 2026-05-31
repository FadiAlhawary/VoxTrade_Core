import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/DashboardDtos.dart';
import 'package:voxtrade_core/Components/ModelDto/PortfolioPositionDto.dart';
import 'package:voxtrade_core/Components/ModelDto/UserSearchResultDto.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/User_&_Auth/User_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Dashboard_Service.dart';

class DashboardController extends GetxController {
  final userController = Get.find<UserController>();

  final Rx<UserDashboardSummaryDto?> summary = Rx<UserDashboardSummaryDto?>(
    null,
  );
  final Rx<DashboardWalletDto?> wallet = Rx<DashboardWalletDto?>(null);
  final Rx<DashboardOrdersSummaryDto?> ordersSummary =
      Rx<DashboardOrdersSummaryDto?>(null);
  final RxList<PortfolioPositionDto> positions = <PortfolioPositionDto>[].obs;
  final RxList<DashboardActivityItemDto> recentActivity =
      <DashboardActivityItemDto>[].obs;
  final RxList<DashboardMarketSnapshotItemDto> marketSnapshot =
      <DashboardMarketSnapshotItemDto>[].obs;

  final RxBool isLoadingSummary = false.obs;
  final RxBool isLoadingWallet = false.obs;
  final RxBool isLoadingOrders = false.obs;
  final RxBool isLoadingPositions = false.obs;
  final RxBool isLoadingActivity = false.obs;
  final RxBool isLoadingMarket = false.obs;
  final RxBool isSearchingRecipients = false.obs;

  int? get _userId => userController.user.value?.id;

  @override
  void onInit() {
    super.onInit();
    ever(userController.user, (_) {
      if (_userId != null) fetchSummary();
    });
  }

  Future<void> fetchSummary({int recentLimit = 10}) async {
    final userId = _userId;
    if (userId == null) return;

    isLoadingSummary.value = true;
    try {
      final data = await getDashboardSummary(userId, recentLimit: recentLimit);
      summary.value = data;
      wallet.value = data.wallet;
      ordersSummary.value = data.orders;
      recentActivity.assignAll(data.recentActivity);
    } catch (e) {
      SnackBarComp.showError(e, title: 'Dashboard unavailable');
    } finally {
      isLoadingSummary.value = false;
    }
  }

  Future<void> fetchWallet() async {
    final userId = _userId;
    if (userId == null) return;

    isLoadingWallet.value = true;
    try {
      wallet.value = await getDashboardWallet(userId);
    } catch (e) {
      SnackBarComp.showError(e, title: 'Wallet unavailable');
    } finally {
      isLoadingWallet.value = false;
    }
  }

  Future<void> fetchOrdersSummary() async {
    final userId = _userId;
    if (userId == null) return;

    isLoadingOrders.value = true;
    try {
      ordersSummary.value = await getDashboardOrdersSummary(userId);
    } catch (e) {
      SnackBarComp.showError(e, title: 'Orders unavailable');
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> fetchPositions() async {
    final userId = _userId;
    if (userId == null) return;

    isLoadingPositions.value = true;
    try {
      positions.assignAll(await getDashboardPositions(userId));
    } catch (e) {
      SnackBarComp.showError(e, title: 'Positions unavailable');
    } finally {
      isLoadingPositions.value = false;
    }
  }

  Future<void> fetchRecentActivity({int limit = 20}) async {
    final userId = _userId;
    if (userId == null) return;

    isLoadingActivity.value = true;
    try {
      recentActivity.assignAll(
        await getDashboardRecentActivity(userId, limit: limit),
      );
    } catch (e) {
      SnackBarComp.showError(e, title: 'Activity unavailable');
    } finally {
      isLoadingActivity.value = false;
    }
  }

  Future<void> fetchMarketSnapshot({int limit = 20}) async {
    isLoadingMarket.value = true;
    try {
      marketSnapshot.assignAll(
        await getDashboardMarketSnapshot(limit: limit),
      );
    } catch (e) {
      SnackBarComp.showError(e, title: 'Market snapshot unavailable');
    } finally {
      isLoadingMarket.value = false;
    }
  }

  Future<List<UserSearchResultDto>> searchTransferRecipients(
    String query, {
    int limit = 20,
  }) async {
    final userId = _userId;
    if (userId == null || query.trim().length < 2) return [];

    isSearchingRecipients.value = true;
    try {
      final results = await searchDashboardTransferRecipients(
        query: query.trim(),
        excludeUserId: userId,
        limit: limit,
      );
      return results
          .map(
            (r) => UserSearchResultDto(
              id: r.id,
              username: r.username,
              firstNameEn: r.firstNameEn,
              lastNameEn: r.lastNameEn,
              displayName: r.displayName,
              walletId: r.walletId,
            ),
          )
          .toList();
    } catch (e) {
      SnackBarComp.showError(e, title: 'Recipient search failed');
      return [];
    } finally {
      isSearchingRecipients.value = false;
    }
  }

  Future<void> refreshDashboard({int recentLimit = 10}) async {
    await fetchSummary(recentLimit: recentLimit);
  }
}
