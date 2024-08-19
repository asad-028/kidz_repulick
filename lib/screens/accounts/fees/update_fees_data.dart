import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import  'package:kids_republik/screens/accounts/fees/fees_form.dart';
import 'package:kids_republik/screens/accounts/manager_accounts_home.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:snackbar/snackbar.dart';
import 'package:toast/toast.dart';

import '../../../main.dart';

class FeesDataUpdateScreen2 extends StatefulWidget {
  final String babyId;

  const FeesDataUpdateScreen2({Key? key, required this.babyId}) : super(key: key);

  @override
  State<FeesDataUpdateScreen2> createState() => _FeesDataUpdateScreen2State();
}

class _FeesDataUpdateScreen2State extends State<FeesDataUpdateScreen2> {
    final collectionReferenceAccounts = FirebaseFirestore.instance.collection(accounts);
    final collectionReferenceBabyData = FirebaseFirestore.instance.collection(BabyData);
  final TextEditingController childFullName = TextEditingController();
    String imageUrl ='';
    TextEditingController nameUsuallyKnownBy = TextEditingController();
    TextEditingController fathersName = TextEditingController();
    TextEditingController fathersMobileNo = TextEditingController();
    final TextEditingController RegistrationNumber = TextEditingController();
  final TextEditingController RegistrationFees = TextEditingController();
  final TextEditingController SecurityFees = TextEditingController();
  final TextEditingController AnnualRecourceFees = TextEditingController();
  final TextEditingController UniformFees = TextEditingController();
  final TextEditingController AdmissionFormFees = TextEditingController();
  final TextEditingController TuitionFees = TextEditingController();
  final TextEditingController MealsFees = TextEditingController();
  final TextEditingController LateSatFees = TextEditingController();
  final TextEditingController FieldTripsFees = TextEditingController();
  final TextEditingController AfterSchoolFees = TextEditingController();
  final TextEditingController DropIncareFees = TextEditingController();
  final TextEditingController MiscFees = TextEditingController();
  final TextEditingController fathersEmail = TextEditingController();
    bool imageloading = false;

  bool isLoading = false; // Use for showing loading indicator

  String selectedclass_ = ""; // Assuming you have a selected class variable

  // Function to fetch data from Firestore
  Future<Map<String, dynamic>> fetchData(String babyId) async {
      isLoading = true;
      // imageloading = true;
      final documentSnapshot = await collectionReferenceAccounts.doc(babyId).get();
        DocumentSnapshot babyDataSnapshot = await FirebaseFirestore.instance.collection(BabyData).doc(babyId).get();
          imageUrl = babyDataSnapshot.get("picture");
          childFullName.text = babyDataSnapshot.get("childFullName");
          fathersName.text = babyDataSnapshot.get("fathersName");
          fathersEmail.text = babyDataSnapshot.get("fathersEmail");
          nameUsuallyKnownBy.text = babyDataSnapshot.get("nameusuallyknownby");
          fathersMobileNo.text = babyDataSnapshot.get("fathersMobileNo");
          selectedclass_ = babyDataSnapshot.get("class_");
      // imageloading = false;

    if (documentSnapshot.exists) {
      try {
      var data =
      // documentSnapshot.data!.data() as Map<String, dynamic>;
        documentSnapshot.data()! as Map<String, dynamic>;
                        childFullName.text = data['childFullName'] ?? '';
                        RegistrationFees.text = data['Registration'].toString() ?? '';
                        SecurityFees.text = data['Security'].toString() ?? '';
                        AnnualRecourceFees.text = data['AnnualRecource'].toString() ?? '';
                        UniformFees.text = data['Uniform'].toString() ?? '';
                        AdmissionFormFees. text = data['AdmissionForm'].toString() ?? '';
                        TuitionFees.text = data['Tuition'].toString() ?? '';
                        MealsFees.text = data['Meals'].toString() ?? '';
                        LateSatFees.text = data['Late_Sat'].toString() ?? '';
                        FieldTripsFees.text = data['FieldTrips'].toString() ?? '';
                        AfterSchoolFees.text = data['AfterSchool'].toString() ?? '';
                        DropIncareFees.text = data['DropIncare'].toString() ?? '';
                        MiscFees.text = data['Misc'].toString() ?? '' ;
                        fathersEmail.text = data['fathersEmail'] ?? '';
          RegistrationNumber.text = babyDataSnapshot.get("RegistrationNumber");

        // Check if babyId exists in "accounts" collection
        isLoading = false;
        setState(() {

        });
      return data ;
      } catch (e) {
        snack('Error fetching data: $e');
        // isLoading = false;
      return {};
      } finally {
        // Always set isLoading to false to prevent UI glitches
        isLoading = false;
      }

    } else {
      await confirm(context,title: Text('Record not found'),content: Text("Do you want to Add Fees Record?"),textOK: Text('Yes'),textCancel: Text("No"))?

      // AlertDialog(semanticLabel: 'No Fees record found for this child');
      // Handle the case where the document doesn't exist
      Get.to(FeesEntryForm(babyId: babyId)):Get.back();
          // isLoading = false;

      return {

      };
    }
  }

  // Function to build the UI based on fetched data
  Widget buildEditForm(BuildContext context, String babyId) {
    final mQ = MediaQuery.of(context).size;

    // return
    //   FutureBuilder<Map<String, dynamic>>(
    //     future: fetchData(babyId),
    // builder: (context, snapshot) {
    // if (snapshot.hasError) {
    // return Center(child: Text('Error: ${snapshot.error}'));
    // }
    //
    // if (!snapshot.hasData) {
    // return Center(child: CircularProgressIndicator());
    // }
    //
    // final data = snapshot.data!;
    //
    // // Use the fetched data to populate the UI
    return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
    children: [
      Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageloading
              ? Container(
              width: mQ.width * 0.30,
              height: mQ.height * 0.15,
              child:
              Center(child: CircularProgressIndicator()))
              : Container(
              width: mQ.width * 0.3,
              height: mQ.height * 0.15,
              child: (widget.babyId == 'No Baby Selected')
                  ? Icon(
                Icons.photo,
                size: 100,
                color: Colors.blue,
              )
                  : CachedNetworkImage(
                imageUrl: imageUrl!,
              )),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text('Name: ${childFullName.text} - (${nameUsuallyKnownBy.text})',style: TextStyle(fontSize: 12),),
                Text("Father's Name: ${fathersName.text}",style: TextStyle(fontSize: 12)),
                Text("Mobile No: ${fathersMobileNo.text}",style: TextStyle(fontSize: 12)),
                Text("Email: ${fathersEmail.text}",style: TextStyle(fontSize: 12)),
                Text("Reg#: ${RegistrationNumber.text}",style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      TextField(
    controller: RegistrationNumber,
    keyboardType: TextInputType.number,
    style: TextStyle(fontSize: 12),
    decoration: InputDecoration(labelText: "Registration Number",),
    // onChanged: (value) => value!.isEmpty ? 'Required' : null,
    ),
      TextField(
    controller: RegistrationFees,
    keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 12),
    decoration: InputDecoration(labelText: "Registration Fees"),
    onChanged: (value) => value.isEmpty ? 'Required' : null,
    ),
      StreamBuilder(
    stream: collectionReferenceAccounts
        .where('type', isEqualTo: 'New Package')
        .where('className', isEqualTo: selectedclass_)
        .snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
    return CircularProgressIndicator();
    }
    List<DropdownMenuItem<String>> packageItems = [];
    for (var doc in snapshot.data!.docs) {
    String packageName = doc['packageName'];
    String amount = doc['amount'].toString();
    packageItems.add(DropdownMenuItem(
    child: Text(
    '$packageName - ${doc['startTime']} to ${doc['endTime']} - ${doc['packageType']}: ${doc['currency']}.${doc['amount']}',
    style: TextStyle(fontSize: 12,color: Colors.black) ,
    ),
    value: amount,
    ));
    }
    return DropdownButtonFormField<String>(
    // itemHeight: 00.0,
    items: packageItems,
    onChanged: (selectedValue) {
    TuitionFees.text = selectedValue!;
    },
      style: TextStyle(fontSize: 12),
      decoration: InputDecoration (labelText: "Select Package", border: InputBorder.none,),
    );
    },
    ),
      TextField(
        controller: TuitionFees,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(labelText: "Tuition Fees"),
        onChanged: (value) => value.isEmpty ? 'Required' : null,
      ),
      StreamBuilder(
        stream: collectionReferenceAccounts
            .where('type', isEqualTo: 'Meals')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          List<DropdownMenuItem<String>> packageItems =
          [];
          for (var doc in snapshot.data!.docs) {
            String packageName = doc['mealName'];
            String amount = doc['mealPrice'].toString();
            packageItems.add(DropdownMenuItem(
              child: Text('$packageName - ${doc['mealFor']}: ${doc['currency']}.${doc['mealPrice']}', style: TextStyle(fontSize: 12,color: Colors.black),),
              // Text(packageName),
              value: amount,
            ));
          }
          return DropdownButtonFormField<String>(
            items: packageItems,
            onChanged: (selectedValue) {
              MealsFees.text = selectedValue!;
            },
            style: TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: "Select Meal",
              border: InputBorder.none,
            ),
          );
        },
      ),
      TextField(
        controller: MealsFees,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(labelText: "Meals"),
        onChanged: (value) => value.isEmpty ? 'Required' : null,
      ),
      TextField(
        controller: LateSatFees,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(labelText: "Late/Sat"),
        onChanged: (value) => value.isEmpty ? 'Required' : null,
      ),
      TextField(
        controller: FieldTripsFees,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(labelText: "Field Trips"),
        onChanged: (value) => value.isEmpty ? 'Required' : null,
      ),
      TextField(
        controller: AfterSchoolFees,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(labelText: "After School"),
        onChanged: (value) => value.isEmpty ? 'Required' : null,
      ),
      TextField(
        controller: DropIncareFees,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(labelText: "Drop-in Care"),
        onChanged: (value) => value.isEmpty ? 'Required' : null,
      ),
      TextField(
        controller: AnnualRecourceFees,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(labelText: "Annual" ),
        onChanged: (value) => value.isEmpty ? 'Required' : null,
      ),
      TextField(
        controller: MiscFees,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(labelText: "Misc"),
        onChanged: (value) => value.isEmpty ? 'Required' : null,
      ),
      TextField(
        controller: fathersEmail,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(labelText: "Father's Email"),
        onChanged: (value) => value.isEmpty ? 'Required' : null,
      ),
      ElevatedButton(
          style: ButtonStyle( backgroundColor: MaterialStatePropertyAll(Colors.teal)),
          onPressed: () =>
              updateFeesEntryForm(widget.babyId),
          child:
          Text('Save',style: TextStyle(color: Colors.white),)),
      // ),
    ],
    ),
    );
    // },
    // );
  }
  // Widget buildEditForm(BuildContext context, String babyId) {
  //   final mQ = MediaQuery.of(context).size;
  //
  //   return FutureBuilder<Map<String, dynamic>>(
  //       future: fetchData(babyId),
  //   builder: (context, snapshot) {
  //   if (snapshot.hasError) {
  //   return Center(child: Text('Error: ${snapshot.error}'));
  //   }
  //
  //   if (!snapshot.hasData) {
  //   return Center(child: CircularProgressIndicator());
  //   }
  //
  //   final data = snapshot.data!;
  //
  //   // Use the fetched data to populate the UI
  //   return Padding(
  //   padding: const EdgeInsets.all(10.0),
  //   child: Column(
  //   children: [
  //     Row(
  //       // crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         imageloading
  //             ? Container(
  //             width: mQ.width * 0.30,
  //             height: mQ.height * 0.15,
  //             child:
  //             Center(child: CircularProgressIndicator()))
  //             : Container(
  //             width: mQ.width * 0.3,
  //             height: mQ.height * 0.15,
  //             child: (widget.babyId == 'No Baby Selected')
  //                 ? Icon(
  //               Icons.photo,
  //               size: 100,
  //               color: Colors.blue,
  //             )
  //                 : CachedNetworkImage(
  //               imageUrl: imageUrl!,
  //             )),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //
  //               Text('Name: ${childFullName.text} - (${nameUsuallyKnownBy.text})',style: TextStyle(fontSize: 12),),
  //               Text("Father's Name: ${fathersName.text}",style: TextStyle(fontSize: 12)),
  //               Text("Mobile No: ${fathersMobileNo.text}",style: TextStyle(fontSize: 12)),
  //               Text("Email: ${fathersEmail.text}",style: TextStyle(fontSize: 12)),
  //               Text("Reg#: ${RegistrationNumber.text}",style: TextStyle(fontSize: 12)),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //     TextField(
  //   controller: RegistrationNumber,
  //   keyboardType: TextInputType.number,
  //   style: TextStyle(fontSize: 12),
  //   decoration: InputDecoration(labelText: "Registration Number",),
  //   // onChanged: (value) => value!.isEmpty ? 'Required' : null,
  //   ),
  //     TextField(
  //   controller: RegistrationFees,
  //   keyboardType: TextInputType.number,
  //     style: TextStyle(fontSize: 12),
  //   decoration: InputDecoration(labelText: "Registration Fees"),
  //   onChanged: (value) => value.isEmpty ? 'Required' : null,
  //   ),
  //     StreamBuilder(
  //   stream: collectionReferenceAccounts
  //       .where('type', isEqualTo: 'New Package')
  //       .where('className', isEqualTo: selectedclass_)
  //       .snapshots(),
  //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //   if (!snapshot.hasData) {
  //   return CircularProgressIndicator();
  //   }
  //   List<DropdownMenuItem<String>> packageItems = [];
  //   for (var doc in snapshot.data!.docs) {
  //   String packageName = doc['packageName'];
  //   String amount = doc['amount'].toString();
  //   packageItems.add(DropdownMenuItem(
  //   child: Text(
  //   '$packageName - ${doc['startTime']} to ${doc['endTime']} - ${doc['packageType']}: ${doc['currency']}.${doc['amount']}',
  //   style: TextStyle(fontSize: 12,color: Colors.black) ,
  //   ),
  //   value: amount,
  //   ));
  //   }
  //   return DropdownButtonFormField<String>(
  //   // itemHeight: 00.0,
  //   items: packageItems,
  //   onChanged: (selectedValue) {
  //   TuitionFees.text = selectedValue!;
  //   },
  //     style: TextStyle(fontSize: 12),
  //     decoration: InputDecoration (labelText: "Select Package", border: InputBorder.none,),
  //   );
  //   },
  //   ),
  //     TextField(
  //       controller: TuitionFees,
  //       keyboardType: TextInputType.number,
  //       style: TextStyle(fontSize: 12),
  //       decoration: InputDecoration(labelText: "Tuition Fees"),
  //       onChanged: (value) => value.isEmpty ? 'Required' : null,
  //     ),
  //     StreamBuilder(
  //       stream: collectionReferenceAccounts
  //           .where('type', isEqualTo: 'Meals')
  //           .snapshots(),
  //       builder: (context,
  //           AsyncSnapshot<QuerySnapshot> snapshot) {
  //         if (!snapshot.hasData) {
  //           return CircularProgressIndicator();
  //         }
  //         List<DropdownMenuItem<String>> packageItems =
  //         [];
  //         for (var doc in snapshot.data!.docs) {
  //           String packageName = doc['mealName'];
  //           String amount = doc['mealPrice'].toString();
  //           packageItems.add(DropdownMenuItem(
  //             child: Text('$packageName - ${doc['mealFor']}: ${doc['currency']}.${doc['mealPrice']}', style: TextStyle(fontSize: 12,color: Colors.black),),
  //             // Text(packageName),
  //             value: amount,
  //           ));
  //         }
  //         return DropdownButtonFormField<String>(
  //           items: packageItems,
  //           onChanged: (selectedValue) {
  //             MealsFees.text = selectedValue!;
  //           },
  //           style: TextStyle(fontSize: 12),
  //           decoration: InputDecoration(
  //             labelText: "Select Meal",
  //             border: InputBorder.none,
  //           ),
  //         );
  //       },
  //     ),
  //     TextField(
  //       controller: MealsFees,
  //       keyboardType: TextInputType.number,
  //       style: TextStyle(fontSize: 12),
  //       decoration: InputDecoration(labelText: "Meals"),
  //       onChanged: (value) => value.isEmpty ? 'Required' : null,
  //     ),
  //     TextField(
  //       controller: LateSatFees,
  //       keyboardType: TextInputType.number,
  //       style: TextStyle(fontSize: 12),
  //       decoration: InputDecoration(labelText: "Late/Sat"),
  //       onChanged: (value) => value.isEmpty ? 'Required' : null,
  //     ),
  //     TextField(
  //       controller: FieldTripsFees,
  //       keyboardType: TextInputType.number,
  //       style: TextStyle(fontSize: 12),
  //       decoration: InputDecoration(labelText: "Field Trips"),
  //       onChanged: (value) => value.isEmpty ? 'Required' : null,
  //     ),
  //     TextField(
  //       controller: AfterSchoolFees,
  //       keyboardType: TextInputType.number,
  //       style: TextStyle(fontSize: 12),
  //       decoration: InputDecoration(labelText: "After School"),
  //       onChanged: (value) => value.isEmpty ? 'Required' : null,
  //     ),
  //     TextField(
  //       controller: DropIncareFees,
  //       keyboardType: TextInputType.number,
  //       style: TextStyle(fontSize: 12),
  //       decoration: InputDecoration(labelText: "Drop-in Care"),
  //       onChanged: (value) => value.isEmpty ? 'Required' : null,
  //     ),
  //     TextField(
  //       controller: MiscFees,
  //       keyboardType: TextInputType.number,
  //       style: TextStyle(fontSize: 12),
  //       decoration: InputDecoration(labelText: "Misc"),
  //       onChanged: (value) => value.isEmpty ? 'Required' : null,
  //     ),
  //     TextField(
  //       controller: fathersEmail,
  //       keyboardType: TextInputType.emailAddress,
  //       style: TextStyle(fontSize: 12),
  //       decoration: InputDecoration(labelText: "Father's Email"),
  //       onChanged: (value) => value.isEmpty ? 'Required' : null,
  //     ),
  //     ElevatedButton(
  //                               style: ButtonStyle( backgroundColor: MaterialStatePropertyAll(Colors.teal)),
  //                               onPressed: () =>
  //                                   updateFeesEntryForm(widget.babyId),
  //                               child:
  //     // Obx(() => isLoading.value
  //                                   // ? CircularProgressIndicator(
  //                                   //     color: Colors.white)
  //                                   // :
  //                               Text('Save',style: TextStyle(color: Colors.white),)),
  //                             // ),
  //   ],
  //   ),
  //   );
  //   },
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    if(widget.babyId != 'No Baby Selected') fetchData(widget.babyId);
    // fetchdataintoformChildFunction( widget.babyId);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kprimary,
        foregroundColor: kWhite,
        title: Text('Update Fees Data',style: TextStyle(fontSize: 14),),
      ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildEditForm(context, widget.babyId),
            ],
          ),
        ));
  }
    // Future<void> fetchdataintoformChildFunction(
    //      String babyId) async {
    //   isLoading.value = true;
    //
    //   try {
    //     // Check if babyId exists in "accounts" collection
    //     DocumentSnapshot babyDataSnapshot = await FirebaseFirestore.instance.collection(BabyData).doc(babyId).get();
    //
    //     if (babyDataSnapshot.exists) {
    //       childFullName.text = babyDataSnapshot.get("childFullName");
    //       imageUrl = babyDataSnapshot.get("picture");
    //       fathersName.text = babyDataSnapshot.get("fathersName");
    //       fathersEmail.text = babyDataSnapshot.get("fathersEmail");
    //       nameUsuallyKnownBy.text = babyDataSnapshot.get("nameusuallyknownby");
    //       fathersMobileNo.text = babyDataSnapshot.get("fathersMobileNo");
    //       RegistrationNumber.text = babyDataSnapshot.get("RegistrationNumber");
    //       // ... (other data fields you need)
    //     } else {
    //       // Handle case where babyId doesn't exist in either collection
    //       snack('Baby data not found for ID: $babyId');
    //     }
    //   } catch (e) {
    //     snack('Error fetching data: $e');
    //   } finally {
    //     // Always set isLoading to false to prevent UI glitches
    //     isLoading.value = false;
    //   }
    //
    //   // setState(() {});
    // }

    void updateFeesEntryForm( String babyId) {
      isLoading = true;
      collectionReferenceBabyData.doc(babyId).update({
        "RegistrationNumber": RegistrationNumber.text,
      });
      collectionReferenceBabyData.doc(babyId).get().then((docSnapshot) {
        if (docSnapshot.exists) {
          collectionReferenceAccounts.doc(babyId).set({
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
            isLoading = false;
            ToastContext().init(context);
            Toast.show(
              'Fees details updated successfully',
              backgroundRadius: 5,
            );
            Get.to(ManagerAccountsHomeScreen());
          }).catchError((err) {
            isLoading = false;
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
        isLoading = false;
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

    void showErrorDialog(BuildContext context, dynamic err) {
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
    }

}
