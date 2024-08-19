import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/utils/const.dart';

import '../../auth/login.dart';

class EmptyBackground extends StatelessWidget {
  final String title;
  const EmptyBackground({
    super.key,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    final mQ = MediaQuery.of(context).size;
    return
      Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        SizedBox(
          height: mQ.height * 0.05,
        ),
        Center(
          child: Image.asset(
            'assets/${table_}empty_2.png',
            height: mQ.height * 0.2,
            width: mQ.width * 0.9,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(
          height: 17,
        ),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: kprimary.withOpacity(0.6),
              //fontSize: 16,
            ),
          ),
        ),
        (role_=='')?CupertinoDialogAction(
          isDefaultAction: false,
          child: Column(
            children: const <Widget>[
              Text('LogOut'),
            ],
          ),
          onPressed: () {
            try {
               firebaseAuth.signOut();
              // Navigate to the login screen or any other screen you desire
              Get.offAll(LoginScreen());
            } catch (e) {
              print("Error logging out: $e");
            }
          },
        ):Container(),

      ],
    );
  }
}
