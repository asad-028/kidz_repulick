import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController currentcontroller = TextEditingController();

  final TextEditingController newpasswordcontroller = TextEditingController();
  final TextEditingController confirmpasswordcontroller =
      TextEditingController();

  RxBool isLoading = false.obs;

  changePassword() async {
    if (currentcontroller.text.isEmpty ||
        newpasswordcontroller.text.isEmpty ||
        confirmpasswordcontroller.text.isEmpty) {
      Get.snackbar(
          backgroundColor: Colors.white, 'Error', 'Please fill in all fields');
    } else {
      isLoading.value = true;
      AuthCredential credential = EmailAuthProvider.credential(
          email: FirebaseAuth.instance.currentUser!.email!,
          password: currentcontroller.text);

      try {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithCredential(credential);
        if (newpasswordcontroller.text == confirmpasswordcontroller.text) {
          FirebaseAuth.instance.currentUser!.updatePassword(
            newpasswordcontroller.text,
          );
          // FirebaseFirestore.instance
          //     .collection(users)
          //     .doc(FirebaseAuth.instance.currentUser!.uid)
          //     .set({
          //   'password': newpasswordcontroller.text,
          // }, SetOptions(merge: true));
             // Get.back();

          Get.snackbar(
              backgroundColor: Colors.white,
              'Success',
              'Password changed successfully');
        } else {
          Get.snackbar(
              backgroundColor: Colors.white,
              'Error',
              'Something Went Wrong Try Again Later');
        }
        isLoading.value = false;
      } catch (e) {
        isLoading.value = false;

        Get.snackbar(
            backgroundColor: Colors.white,
            'Error',
            'Old password is incorrect');
      }
    }
  }
}
