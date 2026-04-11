import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/assembler/Controller/MarketNewsController.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final MarketNewsController marketNewsController = Get.put(
    MarketNewsController(),
  );

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final nameRx = ''.obs;
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            // if (marketNewsController.isLoading.value) {
            //   return Center(child: CircularProgressIndicator());
            // }

            if (marketNewsController.marketNews.isEmpty) {
              return Center(child: Text("No news available"));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await marketNewsController.fetchNews(); // reload data
              },
              child: ListView.builder(
                itemCount: marketNewsController.marketNews.length,
                itemBuilder: (context, ind) {
                  final news = marketNewsController.marketNews[ind];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),

                    child: Card(
                      elevation: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          padding: EdgeInsets.all(5),

                          color: Colors.grey.shade900,
                          child: Column(
                          spacing: 10,

                            children: [
                              Text(news.headline),
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
