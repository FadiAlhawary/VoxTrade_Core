import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/common/News/NewFliter.dart';
import 'package:voxtrade_core/assembler/Controller/NewsController.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'dart:math' as math;

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
  static const _shimmerDuration = Duration(milliseconds: 900);

  ScrollController? _scrollController;
  AnimationController? _filterAnimCtrl;
  late final AnimationController _shimmerAnimCtrl;
  Animation<double>? _filterSizeFactor;
  Animation<double>? _filterOpacity;

  bool _filterVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _shimmerAnimCtrl = AnimationController(
      vsync: this,
      duration: _shimmerDuration,
    )..repeat();
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
    _shimmerAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchData({String? symbol, String? from, String? to}) async {
    if (widget.type == NewsType.market) {
      await widget.newsController.fetchMarketNews();
    } else {
      await widget.newsController.fetchCompanyNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

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
                return _buildNewsShimmer(themeController);
              }
            } else {
              if (widget.newsController.isCompanyNewsLoading.value) {
                return _buildNewsShimmer(themeController);
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
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: Card(
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color:
                              themeController.isDarkMode.value
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color:
                              themeController.isDarkMode.value
                                  ? Colors.grey.shade900
                                  : Colors.white,
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

  Widget _buildNewsShimmer(ThemeController themeController) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: AnimatedBuilder(
            animation: _shimmerAnimCtrl,
            builder: (context, child) {
              final shimmerValue = _shimmerAnimCtrl.value;
              final pulseOpacity =
                  0.88 +
                  (0.12 *
                      ((math.sin(shimmerValue * 2 * math.pi) + 1) / 2));
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment(-2.0 + (4.0 * shimmerValue), -0.2),
                    end: Alignment(-0.8 + (4.0 * shimmerValue), 0.2),
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                    stops: const [0.42, 0.5, 0.58],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Opacity(opacity: pulseOpacity, child: child),
              );
            },
            child: _buildShimmerCard(themeController),
          ),
        );
      },
    );
  }

  Widget _buildShimmerCard(ThemeController themeController) {
    final baseColor =
        themeController.isDarkMode.value
            ? Colors.grey.shade800
            : Colors.grey.shade300;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              themeController.isDarkMode.value
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(12),
        color:
            themeController.isDarkMode.value
                ? Colors.grey.shade900
                : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 14,
              width: 220,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
