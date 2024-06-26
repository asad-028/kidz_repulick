import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_republik/controllers/kids_controller/registation_form_controller.dart';
import 'package:kids_republik/screens/kids/widgets/custom_textfield.dart';
import 'package:kids_republik/screens/widgets/primary_button.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

import '../../main.dart';

CameraDescription? firstCamera;
bool imageloading = false;
double? progress;
bool takepicture = false;
FilePicker? imagefile;
String imagefilepath = '';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({
    super.key,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool imagedownloading = false;
  late File limagefile;
  camerainitialize() async {
    final cameras = await availableCameras();
    firstCamera = cameras.first;
  }

  RegistrationFormController registrationFormController = Get.put(RegistrationFormController());

  @override
  void dispose() {
    takepicture = false;
    progress = 0;
    imagefilepath = '';
    super.dispose();
    imageUrl = "";
    imageloading = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // registrationFormController.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Registration Form',
          style: TextStyle(color: kWhite),
        ),
        backgroundColor: kprimary,
      ),
      bottomNavigationBar: Obx(
        () => registrationFormController.isLoading.value
            ? Center(child: const CircularProgressIndicator())
            : SizedBox(
                width: mQ.width * 0.85,
                height: mQ.height * 0.065,
                child: PrimaryButton(
                  onPressed: () {
                    registrationFormController.addChildFunction(context);
                  },
                  label: "Register",
                  elevation: 3,
                  bgColor: kprimary,
                  labelStyle: kTextPrimaryButton.copyWith(fontWeight: FontWeight.w500),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15),
          child: Form(
            key: registrationFormController.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: mQ.height * 0.03,
                ),
                imageloading
                    ? Container(width: mQ.width * 0.4, height: mQ.height * 0.2, child: Center(child: CircularProgressIndicator()))
                    : Container(
                        width: mQ.width * 0.4,
                        height: mQ.height * 0.2,
                        child: Image.file(
                          File(imagefilepath),
                          fit: BoxFit.fill,
                        )),
                IconButton(
                  icon: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Upload Image'),
                    Icon(Icons.camera_alt_outlined, size: 30),
                  ]),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                  onPressed: () async {
                    _imageActionSheet(context, 'Student', mQ);
                    // _imageActionSheet(context, subject!);
                  },
                ),
                Text(
                  'Basic Information:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                CustomTextField(
                  controller: registrationFormController.childFullName,
                  inputType: TextInputType.text,
                  labelText: "Full name of child",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: registrationFormController.nameUsuallyKnownBy,
                  inputType: TextInputType.text,
                  labelText: "Name usually known by",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                // Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children:[
                //   Expanded(child: TextButton(onPressed: () async { registrationFormController.datechanged = !registrationFormController.datechanged;    DateTime today_ = DateTime.now();    final DateTime? picked = await showDatePicker(context: context,initialDate: today_??DateTime.now(),firstDate: DateTime(2000),lastDate: DateTime(today_.year, today_.month,today_.day),);today_ = picked!;final day =today_.day.toString().padLeft(2, '0');final month = today_.month.toString().padLeft(2, '0');final year = today_.year.toString();registrationFormController.dateofBirth.value = '$day/$month/$year';}, child: (registrationFormController.datechanged)? Text('Date of Birth ${registrationFormController.dateofBirth}', style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black)) :Text('Date of Birth ${registrationFormController.dateofBirth}', style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black)),)) ,
                //   Expanded(child: buildDropdownButton('Gender',['Boy', 'Girl'],'Boy'),)
                // ]),
                // CustomTextField(controller: registrationFormController.address, inputType: TextInputType.text, labelText: "Address", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.postCode, inputType: TextInputType.text, labelText: "Post Code", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.homePhone, inputType: TextInputType.text, labelText: "Home Phone", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      'Mother’s Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    // Expanded(child:checkboxfunction('bmothersparentalResponsibility',context, 'Parental Respensibility.'),)
                  ],
                ),
                CustomTextField(
                  controller: registrationFormController.mothersName,
                  inputType: TextInputType.text,
                  labelText: "Mother’s name",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                // CustomTextField(controller: registrationFormController.mothersoccupation, inputType: TextInputType.text, labelText: "Occupation", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.mothersemployer, inputType: TextInputType.text, labelText: "Employer", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.mothersworkPhoneNo, inputType: TextInputType.text, labelText: "Work Phone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                CustomTextField(
                  controller: registrationFormController.mothersmobilePhoneNo,
                  inputType: TextInputType.text,
                  labelText: "Mobile Phone No",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: registrationFormController.mothersEmailAddress,
                  inputType: TextInputType.text,
                  labelText: "Email Address",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                // CustomTextField(controller: registrationFormController.mothersAddress, inputType: TextInputType.text, labelText: "Address (if Different from Child)", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.mothersPostCode, inputType: TextInputType.text, labelText: "Post Code", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text('Are there any other contact restrictions (if yes please give details)', style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.motherscontactrestrictions, inputType: TextInputType.text, labelText: "Contact restriction details", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      'Father’s Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    // Expanded(child:checkboxfunction('bfathersparentalResponsibility', context, 'Parental Respensibility.'),)
                  ],
                ),
                CustomTextField(
                  controller: registrationFormController.fathersName,
                  inputType: TextInputType.text,
                  labelText: "Father’s name",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                // CustomTextField(controller: registrationFormController.fathersOccupation, inputType: TextInputType.text, labelText: "Occupation", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.fathersEmployer, inputType: TextInputType.text, labelText: "Employer", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.fathersWorkPhoneNo, inputType: TextInputType.text, labelText: "Work Phone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                CustomTextField(
                  controller: registrationFormController.fathersMobileNo,
                  inputType: TextInputType.text,
                  labelText: "Mobile Phone No",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: registrationFormController.fathersEmail,
                  inputType: TextInputType.text,
                  labelText: "Email Address",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                // CustomTextField(controller: registrationFormController.fathersAddress, inputType: TextInputType.text, labelText: "Address (if Different from Child)", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.fathersPostCode, inputType: TextInputType.text, labelText: "Post Code", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text('Are there any other contact restrictions (if yes please give details)', style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.fatherscontactrestrictions, inputType: TextInputType.text, labelText: "Contact restriction details ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text('Other emergency contacts:', style: TextStyle(fontWeight: FontWeight.bold),),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: registrationFormController.otherEmergencyContactsName1, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.otherEmergencyContactsTelephoneNo1, inputType: TextInputType.text, labelText: "Telephone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //     Expanded(child: CustomTextField(controller: registrationFormController.otherEmergencyContactsRelationshiptoChild1, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: registrationFormController.otherEmergencyContactsName2, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //     Expanded(child: CustomTextField(controller: registrationFormController.otherEmergencyContactsTelephoneNo2, inputType: TextInputType.text, labelText: "Telephone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //     Expanded(child: CustomTextField(controller: registrationFormController.otherEmergencyContactsRelationshiptoChild2, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //   ],
                // ),
                // Text('Days / Time:', style: TextStyle(fontWeight: FontWeight.bold),),
                // Row(
                //   children: [
                // Expanded(child: Text('Full Day', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // // Expanded(child: Text('Day', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // Expanded(child: Text('Morning', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // Expanded(child: Text('', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // Expanded(child: Text('Evening', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // Expanded(child: Text('', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                //
                //   ]),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bMondayFullDay', context, "Mon"),),
                //     Expanded(child: CustomTextField(controller: registrationFormController.MondayMorningFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.MondayMorningTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.MondayEveneingFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.MondayEveneingTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bTuesedayFullDay', context, "Tue"),),
                //     Expanded(child: CustomTextField(controller: registrationFormController.TuesdayMorningFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.TuesdayMorningTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.TuesdayEveningFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.TuesdayEveneingTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bWednesdayFullDay', context, "Wed"),),
                //     Expanded(child: CustomTextField(controller: registrationFormController.WednesdayMorningFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.WednesdayMorningTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.WednesdayEveneingFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.WednesdayEveneingTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bThursdayFullDay', context, "Thu"),),
                //     Expanded(child: CustomTextField(controller: registrationFormController.ThursdayMorningFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.ThursdayMorningTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.ThursdayEveneingFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.ThursdayEveneingTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bFridayFullDay', context, "Fri"),),
                //     Expanded(child: CustomTextField(controller: registrationFormController.FridayMorningFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.FridayMorningTo, inputType: TextInputType.text, labelText: "To", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.FridayEveneingFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.FridayEveneingTo, inputType: TextInputType.text, labelText: "To", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bSaturdayFullDay', context, "Sat"),),
                //     Expanded(child: CustomTextField(controller: registrationFormController.SaturdayMorningFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.SaturdayMorningTo, inputType: TextInputType.text, labelText: "To", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.SaturdayEveneingFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.SaturdayEveneingTo, inputType: TextInputType.text, labelText: "To", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     ],
                // ),
                // Text("Doctor's detail:", style: TextStyle(fontWeight: FontWeight.bold),),
                // CustomTextField(controller: registrationFormController.doctorsName, inputType: TextInputType.text, labelText: "Doctor's Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.doctorsAddress, inputType: TextInputType.text, labelText: "Doctor’s address ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.doctorsPostCode, inputType: TextInputType.text, labelText: "Post Code", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.doctorsPhoneNo, inputType: TextInputType.text, labelText: "Doctor’s phone no ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Medical Details:", style: TextStyle(fontWeight: FontWeight.bold),),
                // Text("Does your child have any medical problems that we should be made aware of? Please give details below", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.medicalproblemsdetail, inputType: TextInputType.text, labelText: "Medical Problems (if any) ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Does your child have any allergies that we should be made aware of? Please give details below.", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.allergies, inputType: TextInputType.text, labelText: "Allergies (if any) ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Is your child on any long term medication that we should be made aware of? Please give details below.", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.longTermMedication, inputType: TextInputType.text, labelText: "Long Term Medication (if any) ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Does your child have any special dietary requirements that we should be made aware of? Please give details below.", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.specialDietaryRequirements, inputType: TextInputType.text, labelText: "Special Dietary Requirements (if any) ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Permissions", style: TextStyle(fontWeight: FontWeight.bold),),
                // Text("Do you give Kidz Rebublik permission to take photographs of your child for development files?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.permissiontotakephotographsforfiles, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to take photographs of your child for promotions?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.permissiontotakephotographsforpromotions, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to babywipes / teething gel / sudocrem?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.permissiontobabywipes_teethinggel_sudocrem, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to administer first aid?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.permissiontoadministerfirstaid, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to take your child on outings to local shops etc?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.permissiontooutingstolocalshops, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to administer paracetamol suspension if needed?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.permissiontoadministerparacetamol, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Collection Arrangements", style: TextStyle(fontWeight: FontWeight.bold),),
                // Text("Any changes to this information should be made in writing to the administration.", style: TextStyle(fontSize: 12,color: Colors.red,fontWeight: FontWeight.bold),),
                // Text("Who is authorised to collect your child from the Kidz Republik other than the parents? Your child would only be allowed to leave the childcare centre with people listed here? ", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: registrationFormController.authorisedtocollectName1, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.authorisedtocollectRelationship1, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: registrationFormController.authorisedtocollectName2, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.authorisedtocollectRelationship2, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: registrationFormController.authorisedtocollectName3, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: registrationFormController.authorisedtocollectRelationship3, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Text("As an extra precaution you may use a password. Anyone collecting your child should be made aware of this.", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: registrationFormController.collectionPassword, inputType: TextInputType.text, labelText: "Password ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Child’s Background", style: TextStyle(fontWeight: FontWeight.bold),),
                // CustomTextField(controller: registrationFormController.childsReligion, inputType: TextInputType.text, labelText: "Child’s Religion ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.childsEthnicGroup, inputType: TextInputType.text, labelText: "Child’s EthnicGroup ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.firstLanguagespoken, inputType: TextInputType.text, labelText: "What is the first Language spoken at home?", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: registrationFormController.otherlanguagespoken, inputType: TextInputType.text, labelText: "Is there any other language spoken at home?", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("I understand and acknowledge that the fee due for my child’s care centre / preschool is to be paid per calendar month and paid in one month advance, directly into the bank on receipt of the fee voucher and is non refundable in case of absence.I further agree to give one month’s notice or payment in lieu of notice if I wish to withdraw my child from the childcare / preschool. I understand that failure to pay said fees may result in loss of provision of childcare continuation of education in preschool.", style: TextStyle(fontWeight: FontWeight.normal),),
                // SizedBox(height: mQ.height * 0.028,),
                Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                  registrationFormController.selectDate("Registration Date", context),
                  (registrationFormController.datechanged) ? Text('${registrationFormController.getCurrentDate()}') : Text('${registrationFormController.newdate}')
                ]),
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: Text(
                //     "Fathers Info",
                //     style: TextStyle(
                //         color: Colors.black87,
                //         fontWeight: FontWeight.w500),
                //   ),
                // ),
                // CustomTextField(
                //   controller:
                //       registrationFormController.fathersName,
                //   inputType: TextInputType.text,
                //   labelText:
                //       "Fathers Name",
                //   validators: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Required';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: mQ.height * 0.065,
                // ),
                // CustomTextField(
                //   controller:
                //       registrationFormController.fMobileNo,
                //   inputType: TextInputType.number,
                //   labelText:
                //       "Father's Mobile No",
                //   validators: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Required';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: mQ.height * 0.028,
                // ),
                // CustomTextField(
                //   controller:
                //       registrationFormController.fathersEmail,
                //   inputType: TextInputType.emailAddress,
                //   labelText:
                //       "Father Email",
                //   validators: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Required';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: mQ.height * 0.028,
                // ),
                // CustomTextField(
                //   controller:
                //   registrationFormController.fathersOccupation,
                //   inputType: TextInputType.text,
                //   labelText:
                //   "Father Occupation",
                //   validators: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Required';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: mQ.height * 0.028,
                // ),
                // CustomTextField(
                //   controller:
                //   registrationFormController.workPhoneNo,
                //   inputType: TextInputType.phone,
                //   labelText:
                //   "Work Phone No",
                //   validators: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Required';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: mQ.height * 0.028,
                // ),
                // CustomTextField(
                //   controller:
                //   registrationFormController.employer,
                //   inputType: TextInputType.text,
                //   labelText:
                //   "Employer",
                //   validators: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Required';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: mQ.height * 0.028,
                // ),
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: Text(
                //     "Contact Info",
                //     style: TextStyle(
                //         color: Colors.black87,
                //         fontWeight: FontWeight.w500),
                //   ),
                // ),
                // CustomTextField(
                //   controller:
                //       registrationFormController.address1,
                //   inputType: TextInputType.text,
                //   labelText:
                //       "Address 1",
                //   validators: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Required';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: mQ.height * 0.065,
                // ),
                // CustomTextField(
                //   controller:
                //       registrationFormController.address2,
                //   inputType: TextInputType.text,
                //   labelText:
                //       "Address 2",
                //   validators: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Required';
                //     }
                //     return null;
                //   },
                // ),
                // CustomTextField(
                //   controller:
                //       registrationFormController.picture,
                //   inputType: TextInputType.text,
                //   labelText:
                //       "Picture",
                //   validators: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Required';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: mQ.height * 0.065,
                // ),
              ],
            ),
          ),
        ),
      ),
      // ),
    );
  }

  bool isChecked = true;
  checkboxfunction(isCheckedcontroller, context, title) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue.shade100;
      }
      return Colors.blue.shade100;
      // return Colors.red;
    }

    return Row(children: [
      Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: (isCheckedcontroller == 'bmothersparentalResponsibility')
              ? registrationFormController.bmothersparentalResponsibility
              : (isCheckedcontroller == 'bfathersparentalResponsibility')
                  ? registrationFormController.bfathersparentalResponsibility
                  : (isCheckedcontroller == 'bMondayFullDay')
                      ? registrationFormController.bMondayFullDay
                      : (isCheckedcontroller == 'bTuesedayFullDay')
                          ? registrationFormController.bTuesedayFullDay
                          : (isCheckedcontroller == 'bWednesdayFullDay')
                              ? registrationFormController.bWednesdayFullDay
                              : (isCheckedcontroller == 'bThursdayFullDay')
                                  ? registrationFormController.bThursdayFullDay
                                  : (isCheckedcontroller == 'bFridayFullDay')
                                      ? registrationFormController.bFridayFullDay
                                      : (isCheckedcontroller == 'bSaturdayFullDay')
                                          ? registrationFormController.bSaturdayFullDay
                                          : false,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
              // (isChecked) ?
              //   controller = titlechecked             :  controller = titleunchecked;
              (isCheckedcontroller == 'bmothersparentalResponsibility')
                  ? registrationFormController.bmothersparentalResponsibility = isChecked
                  : (isCheckedcontroller == 'bfathersparentalResponsibility')
                      ? registrationFormController.bfathersparentalResponsibility = isChecked
                      : (isCheckedcontroller == 'bMondayFullDay')
                          ? registrationFormController.bMondayFullDay = isChecked
                          : (isCheckedcontroller == 'bTuesedayFullDay')
                              ? registrationFormController.bTuesedayFullDay = isChecked
                              : (isCheckedcontroller == 'bWednesdayFullDay')
                                  ? registrationFormController.bWednesdayFullDay = isChecked
                                  : (isCheckedcontroller == 'bThursdayFullDay')
                                      ? registrationFormController.bThursdayFullDay = isChecked
                                      : (isCheckedcontroller == 'bFridayFullDay')
                                          ? registrationFormController.bFridayFullDay = isChecked
                                          : (isCheckedcontroller == 'bSaturdayFullDay')
                                              ? registrationFormController.bSaturdayFullDay = isChecked
                                              : null;
            });
          }),
      Text(
        title,
        style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.normal),
      )
    ]);
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    setState(() {
      imageloading = true;
    });

    if (result == null) return;

    final file = result.files.first;
    imagefilepath = result.files.first.path!;
    uploadimagetocloudstorage(file);

    // _openFile(file);
    setState(() {
      imageloading = false;
    });
  }

  loadimagefunction(result) async {
    setState(() {
      imageloading = true;
    });
    if (result == null) return;
    imagefilepath = result;
    setState(() {
      imageloading = false;
    });
  }

  uploadimagetocloudstorage(imagefile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final file = File(imagefile.path);
    final metadata = SettableMetadata(contentType: "image/jpeg");
    final filename = "images/ ${registrationFormController.childFullName.text}${DateTime.now()}";
    final uploadTask = storageRef.child(filename).putFile(file, metadata);
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          break;
        case TaskState.success:
          // Handle successful uploads on complete
          // ...

          imageUrl = await storageRef.child(filename).getDownloadURL();
          imageloading = false;
          imagedownloading = true;

          break;
      }
      ToastContext().init(context);
      Toast.show(
        'Photo uploaded successfully',
        // Get.context,
        duration: 10, backgroundRadius: 5,
        //gravity: Toast.top,
      );
    });
  }

  Future<void> getProfileImageFromCameraAndUpdate(BuildContext context, {VoidCallback? onStart, VoidCallback? onSuccess}) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        String imagefile = image.path;
        await loadimagefunction(imagefile);
        await uploadimagetocloudstorage(image);
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        showPermissionDialog(context, 'Camera');
      }
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        showPermissionDialog(context, 'Camera');
      } else {
        print(e);
      }
    }
  }

  Future<void> getProfileImageFromStorageAndUpdate(BuildContext context, {VoidCallback? onStart, VoidCallback? onSuccess}) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        String imagefile = image.path;
        await loadimagefunction(imagefile);
        await uploadimagetocloudstorage(image);
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        showPermissionDialog(context, 'Gallery');
      }
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        showPermissionDialog(context, 'Gallery');
      } else {
        print(e);
      }
    }
  }

  void showPermissionDialog(BuildContext context, String permissionType) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Permission required'),
        content: Text('$permissionType permission is required. Please enable it in the app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }

  Future<void> _imageActionSheet(BuildContext context, String title, mQ) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Take ${title} Picture"),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Image.asset('assets/staff.jpg',width: mQ.width*0.9,height: mQ.height*0.7,),
            Expanded(
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                title: Text('Camera', style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.purple,
                  size: 20,
                ),
                onTap: () async {
                  getProfileImageFromCameraAndUpdate(context);
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                title: Text(
                  'Gallery',
                  style: TextStyle(fontSize: 10),
                ),
                leading: Icon(Icons.image, color: Colors.cyan, size: 20),
                onTap: () async {
                  getProfileImageFromCameraAndUpdate(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ]),
        ]);
      },
    );
  }

  Future<void> _imageActionSheet2(
    BuildContext context,
    String title,
  ) async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isGranted) {
      camerainitialize();

      _controller = CameraController(
        firstCamera!,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller.initialize();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async {
                _controller.dispose();
                return true;
              },
              child: Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(0),
                  child: Container(
                      padding: EdgeInsets.all(0),
                      width: double.infinity,
                      // height: mQ.height*0.45,
                      height: double.infinity,
                      // color: grey100,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.transparent),
                      child: Column(children: [
                        FutureBuilder<void>(
                          future: _initializeControllerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return CameraPreview(_controller);
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                        FloatingActionButton(
                          onPressed: () async {
                            try {
                              await _initializeControllerFuture;
                              final image = await _controller.takePicture();
                              if (!mounted) return;
                              imagefilepath = image.path;
                              imageloading = true;
                              await GallerySaver.saveImage(imagefilepath);
                              await loadimagefunction(imagefilepath);
                              await uploadimagetocloudstorage(image);
                              _controller.dispose();
                              Navigator.pop(context);
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.purple,
                            size: 20,
                          ),
                        ),
                      ]))));
        },
      );
    }
  }
}
