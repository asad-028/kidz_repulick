import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/auth/invitation_codes.dart';

import '../../utils/const.dart';
import '../home/home_user_management.dart';

class SelectUserOrInvitation extends StatefulWidget {
  const SelectUserOrInvitation({super.key});

  @override
  State<SelectUserOrInvitation> createState() => _SelectUserOrInvitationState();
}

class _SelectUserOrInvitationState extends State<SelectUserOrInvitation> {
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return
      Scaffold(
          appBar: AppBar(title: Text('User Management',style: TextStyle(fontSize: 14),),backgroundColor: kprimary,foregroundColor: Colors.white,),

          body:
          Center(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: mQ.width*0.75,
                  height: 50, // Adjust the height as needed
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(UserManagementScreen()); // Navigation action for 'User Management' button
                    },
                    child: Text('Users',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.teal[100], // Vibrant purple color
                    ),
                  ),
                ),
                SizedBox(height: 10), // Spacing between buttons
                Container(
                  width: mQ.width*0.75,
                  height: 50, // Adjust the height as needed
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(InvitationCodesScreen()); // Navigation action for 'Invitation Codes' button
                    },
                    child: Text('Invitation Codes',style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.teal[100], // Vibrant orange color
                    ),
                  ),
                ),
              ],
            ),
          )


      );
  }
}
