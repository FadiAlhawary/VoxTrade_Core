import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/common/News/NewsCard.dart';
import 'package:voxtrade_core/Components/common/TabBar/CustomeTabBar.dart';
import 'package:voxtrade_core/assembler/Controller/NewsController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final newsController = Get.find<NewsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                CustomTabBar(
                  tabs: [Tab(text: "Market News"), Tab(text: "Company News")],
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      NewsCard(
                        type: NewsType.market,
                        newsController: newsController,
                      ),
                      NewsCard(
                        type: NewsType.company,
                        newsController: newsController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
