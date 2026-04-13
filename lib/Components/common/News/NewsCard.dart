import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:voxtrade_core/Components/Loader.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/Components/common/News/NewFliter.dart';
import 'package:voxtrade_core/assembler/Controller/NewsController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class NewsCard extends StatefulWidget {
  final NewsType type;
  final NewsController newsController;
  const NewsCard({super.key, required this.type, required this.newsController});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> with TickerProviderStateMixin {
  static const _scrollThreshold = 8.0;
  static const _filterAnimDuration = Duration(milliseconds: 280);

  ScrollController? _scrollController;
  AnimationController? _filterAnimCtrl;
  Animation<double>? _filterSizeFactor;
  Animation<double>? _filterOpacity;

  bool _filterVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    if (widget.type == NewsType.company) {
      _scrollController = ScrollController();
      _scrollController!.addListener(_onCompanyScroll);

      _filterAnimCtrl = AnimationController(
        vsync: this,
        duration: _filterAnimDuration,
      );
      final curved = CurvedAnimation(
        parent: _filterAnimCtrl!,
        curve: Curves.fastOutSlowIn,
      );
      _filterSizeFactor = Tween<double>(begin: 1, end: 0).animate(curved);
      _filterOpacity = Tween<double>(begin: 1, end: 0).animate(curved);
    }
  }

  void _onCompanyScroll() {
    final controller = _scrollController;
    final anim = _filterAnimCtrl;
    if (controller == null || anim == null || !controller.hasClients) return;

    final current = controller.offset;
    final delta = current - _lastScrollOffset;

    if (current <= 0) {
      if (!_filterVisible) {
        _filterVisible = true;
        anim.reverse();
      }
    } else if (delta > _scrollThreshold) {
      if (_filterVisible) {
        _filterVisible = false;
        anim.forward();
      }
    } else if (delta < -_scrollThreshold) {
      if (!_filterVisible) {
        _filterVisible = true;
        anim.reverse();
      }
    }

    _lastScrollOffset = current;
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onCompanyScroll);
    _scrollController?.dispose();
    _filterAnimCtrl?.dispose();
    super.dispose();
  }

  Future<void> fetchData({String? symbol, String? from, String? to}) async {
    if (widget.type == NewsType.market) {
      await widget.newsController.fetchMarketNews();
    } else {
      final now = DateTime.now();
      final oneYearAgo = now.subtract(const Duration(days: 365));

      String formatDate(DateTime date) {
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }

      await widget.newsController.fetchCompanyNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.type == NewsType.company &&
            _filterAnimCtrl != null &&
            _filterSizeFactor != null &&
            _filterOpacity != null)
          SizeTransition(
            sizeFactor: _filterSizeFactor!,
            axis: Axis.vertical,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: _filterOpacity!,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(child: Newfliter()),
              ),
            ),
          ),

        Expanded(
          child: Obx(() {
            if (widget.type == NewsType.market) {
              if (widget.newsController.isMarketNewsLoading.value) {
                return const Center(child: Loader());
              }
            } else {
              if (widget.newsController.isCompanyNewsLoading.value) {
                return const Center(child: Loader());
              }
            }
            if (widget.type == NewsType.market) {
              if (widget.newsController.marketNews.isEmpty) {
                return const Center(child: Text("No Market news available"));
              }
            } else {
              if (widget.newsController.companyNews.isEmpty) {
                return const Center(child: Text("No Company news available"));
              }
            }

            return RefreshIndicator(
              onRefresh: () async {
                await fetchData();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    widget.type == NewsType.market
                        ? widget.newsController.marketNews.length
                        : widget.newsController.companyNews.length,
                itemBuilder: (context, ind) {
                  final news =
                      widget.type == NewsType.market
                          ? widget.newsController.marketNews[ind]
                          : widget.newsController.companyNews[ind];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 1,
                      horizontal: 10,
                    ),
                    child: Card(
                      elevation: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey.shade900,
                          child: Column(
                            children: [
                              Text(news.headline),
                              const SizedBox(height: 10),
                              Image.network(news.image),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
