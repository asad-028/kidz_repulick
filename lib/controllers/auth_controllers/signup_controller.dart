import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/main_tabs.dart';
import 'package:toast/toast.dart';

class SignUpController extends GetxController {
  RxBool isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReferenceUser =
  FirebaseFirestore.instance.collection('users');
  TextEditingController nameController = TextEditingController();
  TextEditingController invitationCodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void signupUser(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        // Validate invitation code
        final isValidCode =
        await validateInvitationCode(invitationCodeController.text);
        if (!isValidCode) {
          Get.snackbar('Error', 'Invalid invitation code');
          isLoading.value = false;
          return;
        }

        final result = await firebaseAuth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        List<String> splitList = nameController.text.split(' ');
        List<String> indexList = [];

        for (int i = 0; i < splitList.length; i++) {
          for (int j = 1; j < splitList[i].length + 1; j++) {
            indexList.add(splitList[i].substring(0, j).toLowerCase());
          }
        }

        await collectionReferenceUser.doc(result.user!.email).set({
          "id": emailController.text,
          "status": '',
          "role": '',
          // "class": '',
          "email": emailController.text,
          "password": passwordController.text,
          "full_name": nameController.text,
          "invitation_code": invitationCodeController.text,
          "contact_number": phoneController.text,
          "userImage": "https://firebasestorage.googleapis.com/v0/b/kids-republik-e8265.appspot.com/o/images%2Fnullpicturenew.png?alt=media&token=a723ae08-0bd8-45a1-9b44-e5b51f7d647e",
          "searchIndex": indexList,
        });

        isLoading.value = false;
        ToastContext().init(context);

        Toast.show(
          'Account Created Successfully',
          // context,
          backgroundRadius: 5,
        );


        Get.off(MainTabs());
      } catch (err) {
        isLoading.value = false;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text('Oops'),
              ),
              content: Text(err.toString()),
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
          },
        );
      }
    }
  }

  Future<bool> validateInvitationCode(String code) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('invitation_codes')
          .where('invitation_code', isEqualTo: code)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error validating invitation code: $e');
      return false;
    }
  }
}
