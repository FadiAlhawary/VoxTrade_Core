import 'package:flutter/material.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

import '../Components/Loader.dart';
import '../assembler/Services/roles_Services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          OutlinedButton(

              onPressed: (){}, child: Text("Sell")),
          FilledButton(
            onPressed: () async {
              final result = await GetAllRoles();
              print('name:=========================');
              print(result.first.role_name_en);
            },
            child: Loader(height: 20,width: 25,)
            // style: ElevatedButton.styleFrom(
            //   backgroundColor: Colors.black26,
            //   textStyle: TextStyle(
            //     color: Colors.green
            //   ),
            // ),
          ),
          Button(Purpose: ButtonPurpose.primary, IsLoading: false, Lable: "buy"),
          ElevatedButton(onPressed: (){}, child:Text("Delete"))

        ],
      ),
    );
  }
}
