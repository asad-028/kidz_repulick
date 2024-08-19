
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/accounts/fees/update_fees_data.dart';
import 'package:kids_republik/screens/widgets/primary_button.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:snackbar/snackbar.dart';
import 'package:toast/toast.dart';

import '../../kids/widgets/custom_textfield.dart';
import '../manager_accounts_home.dart';

final classes_ = <String>['Infant', 'Toddler', 'Kinder Garten - I', 'Kinder Garten - II', 'Play Group - I'];
bool imageloading = false;
String selectedclass_ = 'Infant';

final RxBool isLoading = RxBool(false); // Use for showing loading indicator

ScrollController scrollController = ScrollController();
final collectionReferenceBabyData = FirebaseFirestore.instance.collection(BabyData);
final collectionReferenceAccounts = FirebaseFirestore.instance.collection(accounts);

class FeesEntryForm extends StatefulWidget {
  String babyId;
  FeesEntryForm({required this.babyId, super.key});

  @override
  State<FeesEntryForm> createState() => _FeesEntryFormState();
}

class _FeesEntryFormState extends State<FeesEntryForm> {
final TextEditingController childFullName = TextEditingController();
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
  bool imagedownloading = false;

  // UpdateFeesEntryFormController updateFeesEntryFormController = Get.put(UpdateFeesEntryFormController());

  @override
  void dispose() {
    super.dispose();
    imageUrl = "";
    imageloading = false;
    childFullName.dispose();
    RegistrationFees.dispose();
    SecurityFees.dispose();
    AnnualRecourceFees.dispose();
    UniformFees.dispose();
    AdmissionFormFees.dispose();
    TuitionFees.dispose();
    MealsFees.dispose();
    LateSatFees.dispose();
    FieldTripsFees.dispose();
    AfterSchoolFees.dispose();
    DropIncareFees.dispose();
    MiscFees.dispose();
    fathersEmail.dispose();
  }
@override
  void initState() {
    // TODO: implement initState
  if (widget.babyId != 'No Baby Selected') fetchdataintoformChildFunction(widget.babyId);
  super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: kWhite,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kWhite),
        title: Text(
          'Fees Entry Form',
          style: TextStyle(fontSize: 14, color: kWhite),
        ),
        backgroundColor: kprimary,
      ),
      bottomNavigationBar: Obx(
            () => isLoading.value
            ? Center(child: const CircularProgressIndicator())
            : SizedBox(

          width: mQ.width * 0.85,
          height: mQ.height * 0.065,
          child: PrimaryButton(

            onPressed: () {
              (widget.babyId== 'No Baby Selected')?Get.back():
              updateFeesEntryForm( widget.babyId);
            },
            label: (widget.babyId== 'No Baby Selected')?"Close":"Save",
            elevation: 3,
            bgColor: kprimary,
            labelStyle: kTextPrimaryButton.copyWith(fontWeight: FontWeight.w500),
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
          child: Form(
            // key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                (widget.babyId == 'No Baby Selected')
                    ?
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: mQ.height * 0.03,),
                      // (widget.babyId == 'No Baby Selected')
                      //     ?
                      Column(
                        children: [
                          Text('Tab on Kid to select'),
                          classwisestudents('Infant'),
                          SizedBox(height: mQ.height * 0.01,),
                          classwisestudents('Toddler'),
                          SizedBox(height: mQ.height * 0.01,),
                          classwisestudents('Play Group - I'),
                          SizedBox(height: mQ.height * 0.01,),
                          classwisestudents('Kinder Garten - I'),
                          SizedBox(height: mQ.height * 0.01,),
                          classwisestudents('Kinder Garten - II'),
                        ],
                      )
                    ],
                  ),
                )

                    :
                (widget.babyId != 'No Baby Selected')
                    ? Column(
                  children: [
                    Row(
                      children: [
                        imageloading
                            ? Container(
                            width: mQ.width * 0.30,
                            height: mQ.height * 0.15,
                            child: Center(child: CircularProgressIndicator()))
                            : Container(
                            width: mQ.width * 0.3,
                            height: mQ.height * 0.15,
                            child: (widget.babyId == 'No Baby Selected')
                                ? Icon(Icons.photo)
                                : CachedNetworkImage(imageUrl: imageUrl!)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${childFullName.text} - (${nameUsuallyKnownBy.text})',style: TextStyle(fontSize: 12),),
                              Text("Father's Name: ${fathersName.text}",style: TextStyle(fontSize: 12),),
                              // Text("Mobile No: ${fathersMobileNo.text}",style: TextStyle(fontSize: 12),),
                              // Text("Email: ${fathersEmail.text}",style: TextStyle(fontSize: 12),),
                              Text("Reg #: ${RegistrationNumber.text}",style: TextStyle(fontSize: 12),),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Text(
                          'Enter Fees Amount (s)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900],fontSize: 12),
                        ),
                      ],
                    ),
                    CustomTextField(
                      controller: RegistrationNumber,
                      inputType: TextInputType.number,
                      labelText: "Registration Number",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: RegistrationFees,
                      inputType: TextInputType.number,
                      labelText: "Registration Fees",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: SecurityFees,
                      inputType: TextInputType.number,
                      labelText: "Security",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: AnnualRecourceFees,
                      inputType: TextInputType.number,
                      labelText: "Annual Recource",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: UniformFees,
                      inputType: TextInputType.number,
                      labelText: "Uniform",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: AdmissionFormFees,
                      inputType: TextInputType.number,
                      labelText: "Admission Form",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    StreamBuilder(
                      stream: collectionReferenceAccounts.where('type', isEqualTo: 'New Package').where('className', isEqualTo: selectedclass_).snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        List<DropdownMenuItem<String>> packageItems = [];
                        for (var doc in snapshot.data!.docs) {
                          String packageName = doc['packageName'];
                          String amount = doc['amount'].toString();
                          packageItems.add(DropdownMenuItem(
                            value: amount,
                            child:
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$packageName - ${doc['startTime']} to ${doc['endTime']} - ${doc['packageType']}: ${doc['currency']}.${doc['amount']}',style: TextStyle(fontSize: 12),),
                              ] ,
                            ),
                          ));
                        }
                        return DropdownButtonFormField<String>(
                          // itemHeight: 00.0,
                          items: packageItems,
                          onChanged: (selectedValue) {
                            TuitionFees.text = selectedValue!;
                          },
                          decoration: InputDecoration(labelText: "Select Package",     border: InputBorder.none,),
                        );
                      },
                    ),
                    SizedBox(height: 20,),
                    CustomTextField(
                      controller: TuitionFees,
                      inputType: TextInputType.text,
                      labelText: "Tuition",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    StreamBuilder(
                      stream: collectionReferenceAccounts.where('type', isEqualTo: 'Meals').snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        List<DropdownMenuItem<String>> packageItems = [];
                        for (var doc in snapshot.data!.docs) {
                          String packageName = doc['mealName'];
                          String amount = doc['mealPrice'].toString();
                          packageItems.add(DropdownMenuItem(
                            child:
                            Text('$packageName - ${doc['mealFor']}: ${doc['currency']}.${doc['mealPrice']}' ,style: TextStyle(fontSize: 12),),
                            // Text(packageName),
                            value: amount,
                          ));
                        }
                        return DropdownButtonFormField<String>(
                          items: packageItems,
                          onChanged: (selectedValue) {
                            MealsFees.text = selectedValue!;
                          },
                          decoration: InputDecoration(labelText: "Select Meal",     border: InputBorder.none,),
                        );
                      },
                    ),
                    CustomTextField(
                      controller: MealsFees,
                      inputType: TextInputType.text,
                      labelText: "Meals",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: LateSatFees,
                      inputType: TextInputType.text,
                      labelText: "Late Sitting",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: FieldTripsFees,
                      inputType: TextInputType.text,
                      labelText: "Field Trips",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: AfterSchoolFees,
                      inputType: TextInputType.text,
                      labelText: "After School",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: DropIncareFees,
                      inputType: TextInputType.text,
                      labelText: "Drop in care",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: MiscFees,
                      inputType: TextInputType.text,
                      labelText: "Misc.",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                  ],
                )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget classwisestudents(classname){
    final mQ = MediaQuery.of(context).size;
    selectedclass_ = classname;
    // if (classname =='Kinder Garten - I') {
      isLoading.value = false;

    // }
    return
      Padding(
        padding:
        EdgeInsets.symmetric(vertical: 0.0, horizontal: mQ.width*0.02),
        child: StreamBuilder<QuerySnapshot>(
          stream: (role_ == 'Parent') ? collectionReferenceBabyData.where('class_', isEqualTo: classname).where('fathersEmail', isEqualTo: useremail).snapshots():collectionReferenceBabyData.where('class_', isEqualTo: classname).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {return Center(child: Padding(padding: EdgeInsets.only(top: mQ.height*0.01),child: CircularProgressIndicator(),),); }
            if (snapshot.hasError) {return Center(child: Text('Error: ${snapshot.error}'));}
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {return Center(child: Text('',style: TextStyle(color: Colors.grey),));}
            return Column(
              children: <Widget>[
                Container(width: mQ.width,color: Colors.green[50] ,height: mQ.height*0.022,child: Text(classname,textAlign: TextAlign.center,style: TextStyle(color: Colors.teal),)),
                Container(alignment: Alignment.center,
                  color: Colors.transparent,
                  height: mQ.height * 0.098,
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, position) {
                      final childData = snapshot.data!.docs[position].data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () async {
                          try {
                            DocumentSnapshot accountSnapshot = await FirebaseFirestore
                                .instance
                                .collection(accounts)
                                .doc(snapshot.data!.docs[position].id)
                                .get();

                            if (accountSnapshot.exists) {
                              await
                              confirm(context,title: Text('Record exists'),content: Text("Do you want to Update Fees Record?"),textOK: Text('Yes'),textCancel: Text("No"))?
                              // snack('Fees record already exists. Please edit from Update Section.',);
                              Get.to(() => FeesDataUpdateScreen2(babyId: snapshot.data!.docs[position].id)):null;
                            }

else
  await fetchdataintoformChildFunction(
                              snapshot.data!.docs[position].id,);
                            widget.babyId = snapshot.data!.docs[position].id;
                          } catch(e)
                          {print(e.toString());}
            },
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: mQ.width * 0.1,
                              height: mQ.height * 0.042,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(alignment: FractionalOffset.topCenter,
                                    image:
                                    CachedNetworkImageProvider(childData['picture']),
                                    fit: BoxFit.fitHeight),
                              ),
                            ),
                            Text(" ${childData['childFullName']} ",
                                style: TextStyle(
                                    fontSize: 10,
                                    // fontFamily: 'Comic Sans MS',
                                    fontWeight: FontWeight.normal,
                                    color: Colors.blue)),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      );

  }
  Future<void> fetchdataintoformChildFunction( String babyId) async {

    isLoading.value = true;
    RegistrationNumber.text = '';
try {
 {
    // If babyId doesn't exist in "accounts", proceed with fetching data from "BabyData"
    DocumentSnapshot babyDataSnapshot = await FirebaseFirestore.instance
        .collection(BabyData)
        .doc(babyId)
        .get();

    if (babyDataSnapshot.exists) {
      childFullName.text = babyDataSnapshot.get("childFullName");
      imageUrl = babyDataSnapshot.get("picture");
      fathersName.text = babyDataSnapshot.get("fathersName");
      fathersEmail.text = babyDataSnapshot.get("fathersEmail");
      nameUsuallyKnownBy.text = babyDataSnapshot.get("nameusuallyknownby");
      fathersMobileNo.text = babyDataSnapshot.get("fathersMobileNo");
      RegistrationNumber.text =
          babyDataSnapshot.get("RegistrationNumber") ?? '';
        } else {
          // Handle case where babyId doesn't exist in either collection
          snack('Baby data not found for ID: $babyId');
        }}
    }
       catch (e) {
      print('Error fetching data: $e');
    } finally {
      // Always set isLoading to false to prevent UI glitches
      isLoading.value = false;
    }
    setState(() {});

  }
  void updateFeesEntryForm( String babyId) {
    isLoading.value = true;
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
          isLoading.value = false;
          ToastContext().init(context);
          Toast.show(
            'Fees details updated successfully',
            backgroundRadius: 5,
          );
          Get.to(ManagerAccountsHomeScreen());
          // Get.back();
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
}

