
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/splash_controller.dart';
import 'package:kids_republik/screens/splash.dart';

import '../../main.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReferenceUser =
      FirebaseFirestore.instance.collection('users');
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final SplashController controller = Get.put(SplashController());

  void signInUser(BuildContext context) {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      firebaseAuth
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((res) async {
        DocumentSnapshot userSnapshot =
            await collectionReferenceUser.doc(res.user!.email).get();
            // await collectionReferenceUser.doc(res.user?.email).get();
        if (userSnapshot.exists) {

          role_ = userSnapshot['role'] ;
          (userSnapshot['role'] != 'Teacher') ? teachersClass_ = '' : teachersClass_ = userSnapshot['class'];
          controller.name.value = userSnapshot['full_name'] ?? '';
          controller.email.value = userSnapshot['email'] ?? '';
          isLoading.value = false;
          isloadingPage.value = true;
        }

        Get.off(SplashScreen());
      }).catchError((err) {
        isLoading.value = false;

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text('Oops'),
                ),
                content: Text(err.message),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: false,
                    child: const Column(
                      children: <Widget>[
                        Text('Cancel'),
                      ],
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            });
      });
    }
  }
}
