import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();

  void forgotPassword(BuildContext context) {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      firebaseAuth
          .sendPasswordResetEmail(email: emailController.text)
          .then((result) async {
        isLoading.value = false;

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text('Successfull'),
                ),
                content: const Text(
                    'Please check your email for password resset link'),
                actions: [
                  CupertinoDialogAction(
                      isDefaultAction: false,
                      child: const Column(
                        children: <Widget>[
                          Text('Okay'),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }),
                ],
              );
            });
      }).catchError((err) {
        isLoading.value = false;

        print(err.message);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text(err.message),
                actions: [
                  TextButton(
                    child: const Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      });
    }
  }
}
