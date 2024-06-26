import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';

class AddNewConsentController extends GetxController {
  RxString currentDate = ''.obs;
  RxString currentTime = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingInitial = true.obs;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReferenceConsent = FirebaseFirestore.instance
      .collection('Consent');


  TextEditingController title_ = TextEditingController();
  TextEditingController description_ = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  // Class Activity
  RxList<DocumentSnapshot> dropdownItemsClassActivity = <DocumentSnapshot>[]
      .obs;
  DocumentSnapshot? selectedItemClassActivity;
  RxString classActivityName = ''.obs;
  RxString classActivitySubject = ''.obs;
  RxString classActivityDescription = ''.obs;

  Future<void> fetchInitialActivity() async {
    isLoadingInitial.value = true;
    try {
      DocumentSnapshot documentSnapshot = await collectionReferenceConsent
          .doc('%')
          .get();

      Map<String, dynamic> data =
      documentSnapshot.data() as Map<String, dynamic>;

      classActivitySubject.value = data['activity_subject'];
      classActivityName.value = data['activity_name'];
      classActivityDescription.value = data['activity_description'];
      // currentDate.value = getCurrentDate();

    } catch (error) {
      print('Error fetching data: $error');
    }
    isLoadingInitial.value = false;
  }

  addActivityfunction(BuildContext context) {
    isLoading.value = true;
    try {
      collectionReferenceConsent.add(
          {
            'child_': ' ',
            'title_': title_.text,
            'description_': description_.text,
            'date_': currentDate.value,
            'result_': 'Waiting',
            'category_': 'Consent',
            'parentid_': ''
          });
    } catch (error) {
      print('Error fetching data: $error');
    }
    isLoading.value = false;
    Toast.show('Record added successfully',backgroundColor: Colors.black12,duration: 10 );
    Get.back();
  }
  addclasswiseActivityfunction(BuildContext context,subject_,classofBiweekly) {
      try {
        collectionReferenceConsent.add(
            {'child_': ' ',
              'subject_': subject_,
              'title_': title_.text,
              'description_': description_.text,
              'date_': currentDate.value,
              'result_': ' ',
              'class_': classofBiweekly,
              'parentid_': ' ',
              'category_': 'BiWeekly'
            });
      } catch (error) {
        print('Error fetching data: $error');
      }

      ToastContext().init(context);

      Toast.show(
        'Activity added Successfully',
        // Get.context,
        backgroundRadius: 5,
        //gravity: Toast.top,
      );
  Get.back();
    }


    String getCurrentDate() {
      final now = DateTime.now();
      final day = now.day.toString().padLeft(2, '0'); // Add leading zero if needed
      final month = now.month.toString().padLeft(2, '0'); // Add leading zero if needed
      final year = now.year.toString();
      isLoadingInitial = false.obs;
      return '$day-$month-$year';
    }

    selectTime(context) async {
      TimeOfDay? pickedTime = await showTimePicker(
        initialTime: TimeOfDay.now(),
        cancelText: 'Cancel',
        confirmText: 'Select',
        context: context,);
      if (pickedTime != null) {
        final hours = pickedTime.hour.toString().padLeft(2, '0');
        final minutes = pickedTime.minute.toString().padLeft(2, '0');
        return '$hours:$minutes';

      }
    }
  }

