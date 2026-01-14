import 'package:flutter/material.dart';

import '../assembler/Services/roles_Services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final result = await GetAllRoles();
              print('name:=========================');
              print(result.first.role_name_en);
            },
            child: Text("Press Me"
              //,style: TextStyle(color: Colors.green),
            ),
            // style: ElevatedButton.styleFrom(
            //   backgroundColor: Colors.black26,
            //   textStyle: TextStyle(
            //     color: Colors.green
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}
