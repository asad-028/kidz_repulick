import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:toast/toast.dart';

class UpdateRegistrationFormController extends GetxController {
String? newdate;
  RxString admissionDate = ''.obs;
  RxString dateofBirth = ''.obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingInitial = true.obs;
  final formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReference = FirebaseFirestore.instance.collection(BabyData);

  TextEditingController childFullName = TextEditingController();
  TextEditingController nameUsuallyKnownBy = TextEditingController();
  TextEditingController childFullName3 = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController homePhone = TextEditingController();
  TextEditingController mothersName = TextEditingController();
  TextEditingController mothersworkPhoneNo = TextEditingController();
  TextEditingController mothersmobilePhoneNo = TextEditingController();
  TextEditingController mothersEmailAddress = TextEditingController();
  TextEditingController fathersName = TextEditingController();
  TextEditingController fathersWorkPhoneNo = TextEditingController();
  TextEditingController fathersMobileNo = TextEditingController();
  TextEditingController fathersEmail = TextEditingController();
  TextEditingController RegistrationDate = TextEditingController();
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

  void UpdateChildFunction(BuildContext context,babyId) {
        isLoading.value = true;
        collectionReference.doc(babyId).update({
        "childFullName"
            :  childFullName.text,
        "nameusuallyknownby"
            : nameUsuallyKnownBy.text,
          "mothersName"
            :  mothersName.text,
        "mothersmobilePhoneNo"
            :  mothersmobilePhoneNo.text,
        "mothersEmailAddress"
            :  mothersEmailAddress.text,
        "fathersName"
            :  fathersName.text,
        "fathersMobileNo"
            :  fathersMobileNo.text,
        "fathersEmail"
            :  fathersEmail.text,
        "RegistrationDate"
            :  admissionDate.value,
        "picture": imageUrl,
          }).then((res) async {
          isLoading.value = false;

          ToastContext().init(context);

          Toast.show('Child Registered Successfully', backgroundRadius: 5,);

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
     newdate=  '${now.day.toString().padLeft(2, '0')} / ${now.month.toString().padLeft(2, '0')} / ${now.year.toString()}';
    super.onInit();
    admissionDate.value
    = getCurrentDate();
    dateofBirth.value
    = getCurrentDate();
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
    }, child: Text('$title ', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),),);
    }
  }
