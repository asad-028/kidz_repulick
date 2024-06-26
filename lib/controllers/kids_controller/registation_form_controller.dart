import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:toast/toast.dart';

class RegistrationFormController extends GetxController {
String? newdate;
bool bmothersparentalResponsibility = false;
bool bfathersparentalResponsibility = false;
bool bMondayFullDay = false;
bool bTuesedayFullDay = false;
bool bWednesdayFullDay = false;
bool bThursdayFullDay = false;
bool bFridayFullDay = false;
bool bSaturdayFullDay = false;
  RxString admissionDate = ''.obs;
  RxString dateofBirth = ''.obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingInitial = true.obs;
  final formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReference =
  FirebaseFirestore.instance.collection('BabyData');

  TextEditingController childFullName = TextEditingController();
  TextEditingController nameUsuallyKnownBy = TextEditingController();
  TextEditingController childFullName3 = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController postCode = TextEditingController();
  TextEditingController homePhone = TextEditingController();
  TextEditingController mothersName = TextEditingController();
  TextEditingController mothersoccupation = TextEditingController();
  TextEditingController mothersemployer = TextEditingController();
  TextEditingController mothersworkPhoneNo = TextEditingController();
  TextEditingController mothersmobilePhoneNo = TextEditingController();
  TextEditingController mothersEmailAddress = TextEditingController();
  TextEditingController mothersAddress = TextEditingController();
  TextEditingController mothersPostCode = TextEditingController();
  TextEditingController motherscontactrestrictions = TextEditingController();
  TextEditingController fathersName = TextEditingController();
  TextEditingController fathersOccupation = TextEditingController();
  TextEditingController fathersEmployer = TextEditingController();
  TextEditingController fathersWorkPhoneNo = TextEditingController();
  TextEditingController fathersMobileNo = TextEditingController();
  TextEditingController fathersEmail = TextEditingController();
  TextEditingController fathersAddress = TextEditingController();
  TextEditingController fathersPostCode = TextEditingController();
  TextEditingController fatherscontactrestrictions = TextEditingController();
  TextEditingController otherEmergencyContactsName1 = TextEditingController();
  TextEditingController otherEmergencyContactsTelephoneNo1 = TextEditingController();
  TextEditingController otherEmergencyContactsRelationshiptoChild1 = TextEditingController();
  TextEditingController otherEmergencyContactsName2 = TextEditingController();
  TextEditingController otherEmergencyContactsTelephoneNo2 = TextEditingController();
  TextEditingController otherEmergencyContactsRelationshiptoChild2 = TextEditingController();
  TextEditingController MondayMorningFrom = TextEditingController();
  TextEditingController MondayMorningTo = TextEditingController();
  TextEditingController MondayEveneingFrom = TextEditingController();
  TextEditingController MondayEveneingTo = TextEditingController();
  TextEditingController TuesdayMorningFrom = TextEditingController();
  TextEditingController TuesdayMorningTo = TextEditingController();
  TextEditingController TuesdayEveningFrom = TextEditingController();
  TextEditingController TuesdayEveneingTo = TextEditingController();
  TextEditingController WednesdayMorningFrom = TextEditingController();
  TextEditingController WednesdayMorningTo = TextEditingController();
  TextEditingController WednesdayEveneingFrom = TextEditingController();
  TextEditingController WednesdayEveneingTo = TextEditingController();
  TextEditingController ThursdayMorningFrom = TextEditingController();
  TextEditingController ThursdayMorningTo = TextEditingController();
  TextEditingController ThursdayEveneingFrom = TextEditingController();
  TextEditingController ThursdayEveneingTo = TextEditingController();
  TextEditingController FridayMorningFrom = TextEditingController();
  TextEditingController FridayMorningTo = TextEditingController();
  TextEditingController FridayEveneingFrom = TextEditingController();
  TextEditingController FridayEveneingTo = TextEditingController();
  TextEditingController SaturdayMorningFrom = TextEditingController();
  TextEditingController SaturdayMorningTo = TextEditingController();
  TextEditingController SaturdayEveneingFrom = TextEditingController();
  TextEditingController SaturdayEveneingTo = TextEditingController();
  TextEditingController doctorsName = TextEditingController();
  TextEditingController doctorsAddress = TextEditingController();
  TextEditingController doctorsPostCode = TextEditingController();
  TextEditingController doctorsPhoneNo = TextEditingController();
  TextEditingController medicalproblemsdetail = TextEditingController();
  TextEditingController allergies = TextEditingController();
  TextEditingController longTermMedication = TextEditingController();
  TextEditingController specialDietaryRequirements = TextEditingController();
  TextEditingController permissiontotakephotographsforfiles = TextEditingController();
  TextEditingController permissiontotakephotographsforpromotions = TextEditingController();
  TextEditingController permissiontobabywipes_teethinggel_sudocrem = TextEditingController();
  TextEditingController permissiontoadministerfirstaid = TextEditingController();
  TextEditingController permissiontooutingstolocalshops = TextEditingController();
  TextEditingController permissiontoadministerparacetamol = TextEditingController();
  TextEditingController RegistrationDate = TextEditingController();
  TextEditingController authorisedtocollectName1 = TextEditingController();
  TextEditingController authorisedtocollectRelationship1 = TextEditingController();
  TextEditingController authorisedtocollectName2 = TextEditingController();
  TextEditingController authorisedtocollectRelationship2 = TextEditingController();
  TextEditingController authorisedtocollectName3 = TextEditingController();
  TextEditingController authorisedtocollectRelationship3 = TextEditingController();
  TextEditingController collectionPassword = TextEditingController();
  TextEditingController childsReligion = TextEditingController();
  TextEditingController childsEthnicGroup = TextEditingController();
  TextEditingController firstLanguagespoken = TextEditingController();
  TextEditingController otherlanguagespoken = TextEditingController();
  TextEditingController childFullName84 = TextEditingController();
  TextEditingController childFullName85 = TextEditingController();
  TextEditingController childFullName86 = TextEditingController();
  TextEditingController childFullName87 = TextEditingController();
  // User? user = FirebaseAuth.instance.currentUser;
  RxList<DocumentSnapshot> dropdownItems = <DocumentSnapshot>[].obs;
  DocumentSnapshot? selectedItem;

  void addChildFunction(BuildContext context) {
        isLoading.value = true;
        collectionReference.add({
        "childFullName"
            :  childFullName.text,
        "nameusuallyknownby"
            : nameUsuallyKnownBy.text,
        // "dateofBirth"
        //     :  dateofBirth.value,
        // "gender"
        //     :   gender.text,
        // "address"
        //     :  address.text,
        // "postCode"
        //     :  postCode.text,
        // "homePhone"
        //     :  homePhone.text,
        "mothersName"
            :  mothersName.text,
        // "mothersoccupation"
        //     :  mothersoccupation.text,
        // "mothersemployer"
        //     :  mothersemployer.text,
        // "mothersworkPhoneNo"
        //     :  mothersworkPhoneNo.text,
        "mothersmobilePhoneNo"
            :  mothersmobilePhoneNo.text,
        "mothersEmailAddress"
            :  mothersEmailAddress.text,
        // "mothersAddress"
        //     :  mothersAddress.text,
        // "mothersPostCode"
        //     :  mothersPostCode.text,
        // "mothersparentalResponsibility"
        //     :  bmothersparentalResponsibility,
        // "motherscontactrestrictions"
        //     :  motherscontactrestrictions.text,
        "fathersName"
            :  fathersName.text,
        // "fathersOccupation"
        //     :  fathersOccupation.text,
        // "fathersEmployer"
        //     :  fathersEmployer.text,
        // "fathersWorkPhoneNo"
        //     :  fathersWorkPhoneNo.text,
        "fathersMobileNo"
            :  fathersMobileNo.text,
        "fathersEmail"
            :  fathersEmail.text,
        // "fathersAddress"
        //     :  fathersAddress.text,
        // "fathersPostCode"
        //     :  fathersPostCode.text,
        // "fathersparentalResponsibility"
        //     :  bfathersparentalResponsibility,
        // "fatherscontactrestrictions"
        //     :  fatherscontactrestrictions.text,
        // "otherEmergencyContactsName1"
        //     :  otherEmergencyContactsName1.text,
        // "otherEmergencyContactsTelephoneNo1"
        //     :  otherEmergencyContactsTelephoneNo1.text,
        // "otherEmergencyContactsRelationshiptoChild1"
        //     :  otherEmergencyContactsRelationshiptoChild1.text,
        // "otherEmergencyContactsName2"
        //     :  otherEmergencyContactsName2.text,
        // "otherEmergencyContactsTelephoneNo2"
        //     :  otherEmergencyContactsTelephoneNo2.text,
        // "otherEmergencyContactsRelationshiptoChild2"
        //     :  otherEmergencyContactsRelationshiptoChild2.text,
        // "MondayMorningFrom"
        //     :  MondayMorningFrom.text,
        // "MondayMorningTo"
        //     :  MondayMorningTo.text,
        // "MondayEveneingFrom"
        //     :  MondayEveneingFrom.text,
        // "MondayEveneingTo"
        //     :  MondayEveneingTo.text,
        // "MondayFullDay"
        //     :  bMondayFullDay,
        // "TuesdayMorningFrom"
        //     :  TuesdayMorningFrom.text,
        // "TuesdayMorningTo"
        //     :  TuesdayMorningTo.text,
        // "TuesdayEveningFrom"
        //     :  TuesdayEveningFrom.text,
        // "TuesdayEveneingTo"
        //     :  TuesdayEveneingTo.text,
        // "TuesdayFullDay"
        //     :  bTuesedayFullDay,
        // "WednesdayMorningFrom"
        //     :  WednesdayMorningFrom.text,
        // "WednesdayMorningTo"
        //     :  WednesdayMorningTo.text,
        // "WednesdayEveneingFrom"
        //     :  WednesdayEveneingFrom.text,
        // "WednesdayEveneingTo"
        //     :  WednesdayEveneingTo.text,
        // "WednesdayFullDay"
        //     :  bWednesdayFullDay,
        // "ThursdayMorningFrom"
        //     :  ThursdayMorningFrom.text,
        // "ThursdayMorningTo"
        //     :  ThursdayMorningTo.text,
        // "ThursdayEveneingFrom"
        //     :  ThursdayEveneingFrom.text,
        // "ThursdayEveneingTo"
        //     :  ThursdayEveneingTo.text,
        // "ThursdayFullDay"
        //     :  bThursdayFullDay,
        // "FridayMorningFrom"
        //     :  FridayMorningFrom.text,
        // "FridayMorningTo"
        //     :  FridayMorningTo.text,
        // "FridayEveneingFrom"
        //     :  FridayEveneingFrom.text,
        // "FridayEveneingTo"
        //     :  FridayEveneingTo.text,
        // "FridayFullDay"
        //     :  bFridayFullDay,
        //   "SaturdayMorningFrom"
        //     :  SaturdayMorningFrom.text,
        //       "SaturdayMorningTo"
        //     :  SaturdayMorningTo.text,
        //       "SaturdayEveneingFrom"
        //     :  SaturdayEveneingFrom.text,
        //       "SaturdayEveneingTo"
        //     :  SaturdayEveneingTo.text,
        // "SaturdayFullDay"
        //     :  bSaturdayFullDay,
        //       "doctorsName"
        //     :  doctorsName.text,
        //       "doctorsAddress"
        //     :  doctorsAddress.text,
        //       "doctorsPostCode"
        //     :  doctorsPostCode.text,
        //       "doctorsPhoneNo"
        //     :  doctorsPhoneNo.text,
        //       "medicalproblemsdetail"
        //     :  medicalproblemsdetail.text,
        //       "allergies"
        //     :  allergies.text,
        //   "longTermMedication"
        //     :  longTermMedication.text,
        //   "specialDietaryRequirements"
        //     :  specialDietaryRequirements.text,
        //   "permissiontotakephotographsforfiles"
        //     :  permissiontotakephotographsforfiles.text,
        //   "permissiontotakephotographsforpromotions"
        //     :  permissiontotakephotographsforpromotions.text,
        //   "permissiontobabywipes_teethinggel_sudocrem"
        //     :  permissiontobabywipes_teethinggel_sudocrem.text,
        //   "permissiontoadministerfirstaid"
        //     :  permissiontoadministerfirstaid.text,
        //   "permissiontooutingstolocalshops"
        //     :  permissiontooutingstolocalshops.text,
        //   "permissiontoadministerparacetamol"
        //     :  permissiontoadministerparacetamol.text,
        //   "RegistrationDate"
        //     :  RegistrationDate.text,
        //   'authorisedtocollectName1'
        //     :  authorisedtocollectName1.text,
        //   "authorisedtocollectRelationship1"
        //     :  authorisedtocollectRelationship1.text,
        //   "authorisedtocollectName2"
        //     :  authorisedtocollectName2.text,
        //   "authorisedtocollectRelationship2"
        //     :  authorisedtocollectRelationship2.text,
        //   "authorisedtocollectName3"
        //     :  authorisedtocollectName3.text,
        //   "authorisedtocollectRelationship3"
        //     :  authorisedtocollectRelationship3.text,
        //   "collectionPassword"
        //     :  collectionPassword.text,
        //   "childsReligion"
        //     :  childsReligion.text,
        //   "childsEthnicGroup"
        //     :  childsEthnicGroup.text,
        //   "firstLanguagespoken"
        //     :  firstLanguagespoken.text,
        //   "otherlanguagespoken"
        //     :  otherlanguagespoken.text,
        //   "Undertaking" : "I understand and acknowledge that the fee due for my child’s care centre / preschool is to be paid per calendar month and paid in one month advance, directly into the bank on receipt of the fee voucher and is non refundable in case of absence.I further agree to give one month’s notice or payment in lieu of notice if I wish to withdraw my child from the childcare / preschool. I understand that failure to pay said fees may result in loss of provision of childcare continuation of education in preschool.",
          "class_" : 'NewAdmission',
          "admission_date": admissionDate.value,
        "picture": imageUrl??"",
          // "age": ageValue,
        // "child_gender": ChildGender.text,
        // "childFullName": childFullName.text,
        // "ChildAgeYears": ChildAgeYears.text,
        // "ChildAgeMonths": ChildAgeMonths.text,
        // "ChildAgeDays": ChildAgeDays.text,
        // "ChildGender": ChildGender.text,
        // "address1": address1.text,
        // "address2": address2.text,
        // "fathersName": fathersName.text,
        // "fathersOccupation": fathersOccupation.text,
        // "employer": employer.text,
        // "fathersEmail": fathersEmail.text,
        // "fMobileNo": fMobileNo.text,
        // "workPhoneNo": workPhoneNo.text,
        }).then((res) async {
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
    }, child: Text('${title} ', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),),);

    }
  }
