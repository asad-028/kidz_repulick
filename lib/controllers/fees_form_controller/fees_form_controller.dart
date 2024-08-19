import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';

import '../../main.dart';

class UpdateFeesEntryFormController extends GetxController {
  String? newdate;
  RxString admissionDate = ''.obs;
  RxString dateofBirth = ''.obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingInitial = true.obs;
  final formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReferenceBabyData = FirebaseFirestore.instance.collection(BabyData);
  CollectionReference collectionReferenceAccount = FirebaseFirestore.instance.collection(accounts);

  TextEditingController childFullName = TextEditingController();
  TextEditingController nameUsuallyKnownBy = TextEditingController();
  TextEditingController mothersName = TextEditingController();
  TextEditingController mothersmobilePhoneNo = TextEditingController();
  TextEditingController mothersEmailAddress = TextEditingController();
  TextEditingController fathersName = TextEditingController();
  TextEditingController fathersMobileNo = TextEditingController();
  TextEditingController fathersEmail = TextEditingController();
  // Fees
  TextEditingController RegistrationNumber = TextEditingController();
  TextEditingController RegistrationFees = TextEditingController();
  TextEditingController SecurityFees = TextEditingController();
  TextEditingController AnnualRecourceFees = TextEditingController();
  TextEditingController UniformFees = TextEditingController();
  TextEditingController AdmissionFormFees = TextEditingController();
  TextEditingController TuitionFees = TextEditingController();
  TextEditingController MealsFees = TextEditingController();
  TextEditingController LateSatFees = TextEditingController();
  TextEditingController FieldTripsFees = TextEditingController();
  TextEditingController AfterSchoolFees = TextEditingController();
  TextEditingController DropIncareFees = TextEditingController();
  TextEditingController MiscFees = TextEditingController();
  RxList<DocumentSnapshot> dropdownItems = <DocumentSnapshot>[].obs;
  DocumentSnapshot? selectedItem;

  void updateFeesEntryForm(BuildContext context, String babyId) {
    isLoading.value = true;
        collectionReferenceBabyData.doc(babyId).update({
          "RegistrationNumber": RegistrationNumber.text,
        });
    collectionReferenceBabyData.doc(babyId).get().then((docSnapshot) {
      if (docSnapshot.exists) {
        collectionReferenceAccount.doc(babyId).set({
          "childFullName": childFullName.text,
          "child_": babyId,
          "Registration": int.parse(RegistrationFees.text),
          "Security": int.parse(SecurityFees.text),
          "AnnualRecource": int.parse(AnnualRecourceFees.text),
          "Uniform": int.parse(UniformFees.text),
          "AdmissionForm": int.parse(AdmissionFormFees.text),
          "Tuition": int.parse(TuitionFees.text),
          "Meals": int.parse(MealsFees.text),
          "Late_Sat": int.parse(LateSatFees.text),
          "FieldTrips": int.parse(FieldTripsFees.text),
          "AfterSchool": int.parse(AfterSchoolFees.text),
          "DropIncare": int.parse(DropIncareFees.text),
          "Misc": int.parse(MiscFees.text),
          "fathersEmail": fathersEmail.text,
        }).then((res) async {
          isLoading.value = false;
          ToastContext().init(context);
          Toast.show(
            'Fees details updated successfully',
            backgroundRadius: 5,
          );
          Get.back();
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
            },
          );
        });
      }

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
        },
      );
    });
  }



  @override
  void onInit() {
    // TODO: implement onInit
    newdate=  '${now.day.toString().padLeft(2, '0')} / ${now.month.toString().padLeft(2, '0')} / ${now.year.toString()}';
    super.onInit();
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

  bool datechanged = false;
  DateTime now =DateTime.now();
  selectDate(title, context) {
    now = DateTime.now();
    return TextButton(onPressed: () async {

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year, now.month,
            now.day), // Set lastDate to the end of the current year
      );

      if (picked != null && picked != now) {
        now = picked;
        datechanged = true;
      }
      final day =
      now.day.toString().padLeft(2, '0'); // Add leading zero if needed
      final month = now.month.toString().padLeft(2, '0'); // Add leading zero if needed
      final year = now.year.toString();
      newdate = '$day / $month / $year ';
    }, child: Text('$title', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),),);

  }
}
