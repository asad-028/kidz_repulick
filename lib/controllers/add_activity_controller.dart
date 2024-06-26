
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';

class AddActivityController extends GetxController {
  RxString currentDate = ''.obs;
  RxString currentTime = ''.obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingInitial = true.obs;
  final formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReferenceActivity =
  FirebaseFirestore.instance.collection('Activity');

  TextEditingController babyIDActivity_ = TextEditingController();
  TextEditingController activity_ = TextEditingController();
  TextEditingController description_ = TextEditingController();
  TextEditingController picture = TextEditingController();

  // User? user = FirebaseAuth.instance.currentUser;
  RxList<DocumentSnapshot> dropdownItems = <DocumentSnapshot>[].obs;

  // DocumentSnapshot? selectedItem;

  void addActivityFunction(BuildContext context) {
    collectionReferenceActivity
        .add({
      "id": babyIDActivity_.text,
      "Activity": activity_.text,
      "date_": DateTime.now(),
      "description": description_.text,
      "picture": picture.text
    }).then((res) async {
      isLoading.value = false;

      ToastContext().init(context);

      Toast.show(
        'Activity Registered Successfully',
        // Get.context,
        backgroundRadius: 5,
        //gravity: Toast.top,
      );

      Get.back();
    }).catchError((err) {
      print(err.toString());
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


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // currentDate.value = getCurrentDate();
    // currentTime.value = getCurrentTime();
    // babyIDActivity_.text = ;
    //fetchData();
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final day =
    now.day.toString().padLeft(2, '0'); // Add leading zero if needed
    final month =
    now.month.toString().padLeft(2, '0'); // Add leading zero if needed
    final year = now.year.toString();

    return '$day/$month/$year';
  }
  String getCurrentTime() {
    final now = TimeOfDay.now();
    final hours = now.hour.toString().padLeft(2, '0');
    final minutes = now.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month,
          now.day), // Set lastDate to the end of the current year
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      currentDate.value = '$day/$month/$year';
    }
  }

  Future selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(), context: context,);
    if (pickedTime != null) {
      final hours = pickedTime.hour.toString().padLeft(2, '0');
      final minutes = pickedTime.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
      // DateTime parsedTime = DateFormat.jm().parse(
      //     pickedTime.format(context).toString());
      // String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
      // currentTime.value = formattedTime; //set the value of text field.
    }
    }

}
