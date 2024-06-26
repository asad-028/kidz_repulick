import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';

class AddChildController extends GetxController {
  RxString selectedChildAge = 'Years'.obs;
  List<String> childAgeOptions = ['Years', 'Months', 'Days'];
  RxString currentDate = ''.obs;
  // RxString seedName = ''.obs;
  // RxString seedVariety = ''.obs;
  // RxString seedUnitPrice = ''.obs;
  // RxInt seedInStock = 0.obs;
  // RxInt seedInStockOriginalValue = 0.obs;
  // RxString seedUnitValuePrice = ''.obs;
  // RxString seedDocumentID = ''.obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingInitial = true.obs;
  final formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('BabyData');

  TextEditingController childFullName = TextEditingController();
  TextEditingController ChildAgeYears = TextEditingController();
  TextEditingController ChildAgeMonths = TextEditingController();
  TextEditingController ChildAgeDays = TextEditingController();
  TextEditingController ChildGender = TextEditingController();
  TextEditingController fathersName = TextEditingController();
  TextEditingController fMobileNo = TextEditingController();
  TextEditingController fathersEmail = TextEditingController();
  TextEditingController fathersOccupation = TextEditingController();
  TextEditingController workPhoneNo = TextEditingController();
  TextEditingController employer = TextEditingController();
  TextEditingController address1 = TextEditingController();
  TextEditingController address2 = TextEditingController();
  TextEditingController picture = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  RxList<DocumentSnapshot> dropdownItems = <DocumentSnapshot>[].obs;
  DocumentSnapshot? selectedItem;

  void addChildFunction(BuildContext context) {
    if (formKey.currentState!.validate()) {
      if (ChildAgeYears.text.isEmpty &&
          ChildAgeMonths.text.isEmpty &&
          ChildAgeDays.text.isEmpty) {
        ToastContext().init(context);

        Toast.show(
          'In Age atleast one field must be filled ',
          // Get.context,
          backgroundRadius: 5,
          duration: 3,
          //gravity: Toast.top,
        );
      } else {
        isLoading.value = true;
        var ageValue = '';
        if (ChildAgeYears.text.isNotEmpty &&
            ChildAgeMonths.text.isNotEmpty &&
            ChildAgeDays.text.isNotEmpty) {
          ageValue =
              "${ChildAgeYears.text} Years, ${ChildAgeMonths.text} Months, ${ChildAgeDays.text} Days";
        } else if (ChildAgeYears.text.isEmpty &&
            ChildAgeMonths.text.isNotEmpty &&
            ChildAgeDays.text.isNotEmpty) {
          ageValue =
              "${ChildAgeMonths.text} Months, ${ChildAgeDays.text} Days";
        } else if (ChildAgeYears.text.isEmpty &&
            ChildAgeMonths.text.isEmpty &&
            ChildAgeDays.text.isNotEmpty) {
          ageValue = "${ChildAgeDays.text} Days";
        } else if (ChildAgeYears.text.isNotEmpty &&
            ChildAgeMonths.text.isEmpty &&
            ChildAgeDays.text.isEmpty) {
          ageValue = "${ChildAgeYears.text} Years";
        } else if (ChildAgeYears.text.isNotEmpty &&
            ChildAgeMonths.text.isEmpty &&
            ChildAgeDays.text.isNotEmpty) {
          ageValue =
              "${ChildAgeYears.text} Years, ${ChildAgeDays.text} Days";
        } else if (ChildAgeYears.text.isEmpty &&
            ChildAgeMonths.text.isNotEmpty &&
            ChildAgeDays.text.isEmpty) {
          ageValue = "${ChildAgeMonths.text} Months";
        } else if (ChildAgeYears.text.isNotEmpty &&
            ChildAgeMonths.text.isNotEmpty &&
            ChildAgeDays.text.isEmpty) {
          ageValue =
              "${ChildAgeYears.text} Years, ${ChildAgeMonths.text} Months";
        }

        collectionReference.add({

          "class_": 'NewAdmission',
          "age": ageValue,
          "admission_date": currentDate.value,
          "child_gender": ChildGender.text,
          "childFullName": childFullName.text,
          "ChildAgeYears": ChildAgeYears.text,
          "ChildAgeMonths": ChildAgeMonths.text,
          "ChildAgeDays": ChildAgeDays.text,
          "ChildGender": ChildGender.text,
          "picture": picture.text,
          "address1": address1.text,
          "address2": address2.text,
          "fathersName": fathersName.text,
          "fathersOccupation": fathersOccupation.text,
          "employer": employer.text,
          "fathersEmail": fathersEmail.text,
          "fMobileNo": fMobileNo.text,
          "workPhoneNo": workPhoneNo.text,

        }).then((res) async {
          // collectionReference
          //     .doc(user!.uid)
          //     .collection('stored_crops')
          //     .doc(seedDocumentID.value)
          //     .set({
          //   "in_stock": seedInStock.value.toString(),
          // }, SetOptions(merge: true));

          isLoading.value = false;

          ToastContext().init(context);

          Toast.show(
            'Child Registered Successfully',
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
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    currentDate.value = getCurrentDate();
    //fetchData();
  }

  Future<void> fetchData() async {
    List<DocumentSnapshot> data = await getCollectionData();


    dropdownItems.value = data;

    // Set the initial selected item to the first item in the list, if it's not empty
    if (dropdownItems.isNotEmpty) {
      selectedItem = dropdownItems[0];
      // seedVariety.value = dropdownItems[0]['subtitle'];
      // seedUnitPrice.value = dropdownItems[0]['price_per_kg'];
      // seedName.value = dropdownItems[0]['name'];
      // seedInStock.value = int.parse(dropdownItems[0]['in_stock']);
      // seedInStockOriginalValue.value = int.parse(dropdownItems[0]['in_stock']);
      // seedDocumentID.value = dropdownItems[0].id.toString();
      // seedUnitValuePrice.value = dropdownItems[0]['currency'];
    }
    isLoadingInitial.value = false;
  }

  Future<List<DocumentSnapshot>> getCollectionData() async {
    QuerySnapshot querySnapshot = await collectionReference
        .doc(user!.uid)
        .collection('stored_crops')
        .where('type', isEqualTo: 'seed')
        .get();
    return querySnapshot.docs;
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
}
