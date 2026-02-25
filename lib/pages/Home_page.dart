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
        SizedBox(height: 50,),
        Button(
          purpose: ButtonPurpose.secondary,
          isLoading: false,
          label: "Load News",
          onPress: () async {
            await marketNewsController.fetchNews();
            SnackBarComp.show(
              "Successfully fetched market News",
              title: 'Success',
            );
          },
        ),
        SizedBox(height: 50,),
        Expanded(
          child: Obx(() {
            // if (marketNewsController.isLoading.value) {
            //   return Center(child: CircularProgressIndicator());
            // }
          
            if (marketNewsController.marketNews.isEmpty) {
              return Center(child: Text("No news available"));
            }
          
            return  RefreshIndicator(
              onRefresh: () async {
                await marketNewsController.fetchNews(); // reload data
              },
              child: ListView.builder(
                  itemCount: marketNewsController.marketNews.length,
                  itemBuilder: (context, ind) {
                    final news = marketNewsController.marketNews[ind];
                    return ListTile(title: Text(news.headline));
                  },
                ),
            );
            
          }),
        ),
      ],
    );
  }
}
