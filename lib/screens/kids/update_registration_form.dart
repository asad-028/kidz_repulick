import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_republik/controllers/kids_controller/update_registation_form_controller.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/kids/widgets/custom_textfield.dart';
import 'package:kids_republik/screens/widgets/primary_button.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

CameraDescription? firstCamera;
bool imageloading = false;
double? progress;
bool takepicture = false;
FilePicker? imagefile;
String imagefilepath = '';

class UpdateRegistrationForm extends StatefulWidget {
  String babyId;
  UpdateRegistrationForm({
    required this.babyId,
    super.key,
  });

  @override
  State<UpdateRegistrationForm> createState() => _UpdateRegistrationFormState();
}

class _UpdateRegistrationFormState extends State<UpdateRegistrationForm> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool imagedownloading = false;
  late File limagefile;
  camerainitialize() async {
    final cameras = await availableCameras();
    firstCamera = cameras.first;
  }

  UpdateRegistrationFormController updateRegistrationFormController = Get.put(UpdateRegistrationFormController());

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
    fetchdataintoformChildFunction(context, widget.babyId);
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
          'Update Registration Form',
          style: TextStyle(fontSize: 14, color: kWhite),
        ),
        backgroundColor: kprimary,
      ),
      bottomNavigationBar: Obx(
        () => updateRegistrationFormController.isLoading.value
            ? Center(child: const CircularProgressIndicator())
            : SizedBox(
                width: mQ.width * 0.85,
                height: mQ.height * 0.065,
                child: PrimaryButton(
                  onPressed: () {
                    updateRegistrationFormController.UpdateChildFunction(context, widget.babyId);
                  },
                  label: "Update",
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
            key: updateRegistrationFormController.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: mQ.height * 0.03,
                ),
                imageloading
                    ? Container(width: mQ.width * 0.4, height: mQ.height * 0.2, child: Center(child: CircularProgressIndicator()))
                    : Container(width: mQ.width * 0.4, height: mQ.height * 0.2, child: Image.network(imageUrl!)),
                IconButton(
                  icon: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Upload Image'),
                    Icon(Icons.camera_alt_outlined, size: 30),
                  ]),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                  onPressed: () async {
                    _imageActionSheet(context, 'Student', mQ);
                  },
                ),
                Text(
                  'Basic Information:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                CustomTextField(
                  controller: updateRegistrationFormController.childFullName,
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
                  controller: updateRegistrationFormController.nameUsuallyKnownBy,
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
                //   Expanded(child: TextButton(onPressed: () async { updateRegistrationFormController.datechanged = !updateRegistrationFormController.datechanged;    DateTime today_ = DateTime.now();    final DateTime? picked = await showDatePicker(context: context,initialDate: today_??DateTime.now(),firstDate: DateTime(2000),lastDate: DateTime(today_.year, today_.month,today_.day),);today_ = picked!;final day =today_.day.toString().padLeft(2, '0');final month = today_.month.toString().padLeft(2, '0');final year = today_.year.toString();updateRegistrationFormController.dateofBirth.value = '$day/$month/$year';}, child: (updateRegistrationFormController.datechanged)? Text('Date of Birth ${updateRegistrationFormController.dateofBirth}', style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black)) :Text('Date of Birth ${updateRegistrationFormController.dateofBirth}', style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black)),)) ,
                //   Expanded(child: buildDropdownButton('Gender',['Boy', 'Girl'],'Boy'),)
                // ]),
                // CustomTextField(controller: updateRegistrationFormController.address, inputType: TextInputType.text, labelText: "Address", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.postCode, inputType: TextInputType.text, labelText: "Post Code", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.homePhone, inputType: TextInputType.text, labelText: "Home Phone", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
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
                  controller: updateRegistrationFormController.mothersName,
                  inputType: TextInputType.text,
                  labelText: "Mother’s name",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                // CustomTextField(controller: updateRegistrationFormController.mothersoccupation, inputType: TextInputType.text, labelText: "Occupation", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.mothersemployer, inputType: TextInputType.text, labelText: "Employer", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.mothersworkPhoneNo, inputType: TextInputType.text, labelText: "Work Phone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                CustomTextField(
                  controller: updateRegistrationFormController.mothersmobilePhoneNo,
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
                  controller: updateRegistrationFormController.mothersEmailAddress,
                  inputType: TextInputType.text,
                  labelText: "Email Address",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                // CustomTextField(controller: updateRegistrationFormController.mothersAddress, inputType: TextInputType.text, labelText: "Address (if Different from Child)", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.mothersPostCode, inputType: TextInputType.text, labelText: "Post Code", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text('Are there any other contact restrictions (if yes please give details)', style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.motherscontactrestrictions, inputType: TextInputType.text, labelText: "Contact restriction details", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
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
                  controller: updateRegistrationFormController.fathersName,
                  inputType: TextInputType.text,
                  labelText: "Father’s name",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                // CustomTextField(controller: updateRegistrationFormController.fathersOccupation, inputType: TextInputType.text, labelText: "Occupation", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.fathersEmployer, inputType: TextInputType.text, labelText: "Employer", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.fathersWorkPhoneNo, inputType: TextInputType.text, labelText: "Work Phone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                CustomTextField(
                  controller: updateRegistrationFormController.fathersMobileNo,
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
                  controller: updateRegistrationFormController.fathersEmail,
                  inputType: TextInputType.text,
                  labelText: "Email Address",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                // CustomTextField(controller: updateRegistrationFormController.fathersAddress, inputType: TextInputType.text, labelText: "Address (if Different from Child)", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.fathersPostCode, inputType: TextInputType.text, labelText: "Post Code", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text('Are there any other contact restrictions (if yes please give details)', style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.fatherscontactrestrictions, inputType: TextInputType.text, labelText: "Contact restriction details ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text('Other emergency contacts:', style: TextStyle(fontWeight: FontWeight.bold),),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.otherEmergencyContactsName1, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.otherEmergencyContactsTelephoneNo1, inputType: TextInputType.text, labelText: "Telephone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.otherEmergencyContactsRelationshiptoChild1, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.otherEmergencyContactsName2, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.otherEmergencyContactsTelephoneNo2, inputType: TextInputType.text, labelText: "Telephone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.otherEmergencyContactsRelationshiptoChild2, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),),
                //   ],
                // ),
                // Text('Days / Time:', style: TextStyle(fontWeight: FontWeight.bold),),
                // Row(
                //   children: [
                // Expanded(child: Text('Full Day', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // Expanded(child: Text('Day', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // Expanded(child: Text('Morning', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // Expanded(child: Text('', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // Expanded(child: Text('Evening', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                // Expanded(child: Text('', textAlign: TextAlign.center,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)),
                //
                //   ]),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bMondayFullDay', context, "Mon"),),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.MondayMorningFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.MondayMorningTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.MondayEveneingFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.MondayEveneingTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bTuesedayFullDay', context, "Tue"),),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.TuesdayMorningFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.TuesdayMorningTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.TuesdayEveningFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.TuesdayEveneingTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bWednesdayFullDay', context, "Wed"),),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.WednesdayMorningFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.WednesdayMorningTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.WednesdayEveneingFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.WednesdayEveneingTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bThursdayFullDay', context, "Thu"),),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.ThursdayMorningFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.ThursdayMorningTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.ThursdayEveneingFrom, inputType: TextInputType.text, labelText: "From ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.ThursdayEveneingTo, inputType: TextInputType.text, labelText: "To ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bFridayFullDay', context, "Fri"),),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.FridayMorningFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.FridayMorningTo, inputType: TextInputType.text, labelText: "To", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.FridayEveneingFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.FridayEveneingTo, inputType: TextInputType.text, labelText: "To", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: checkboxfunction('bSaturdayFullDay', context, "Sat"),),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.SaturdayMorningFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.SaturdayMorningTo, inputType: TextInputType.text, labelText: "To", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.SaturdayEveneingFrom, inputType: TextInputType.text, labelText: "From", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.SaturdayEveneingTo, inputType: TextInputType.text, labelText: "To", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     ],
                // ),
                // Text("Doctor's detail:", style: TextStyle(fontWeight: FontWeight.bold),),
                // CustomTextField(controller: updateRegistrationFormController.doctorsName, inputType: TextInputType.text, labelText: "Doctor's Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.doctorsAddress, inputType: TextInputType.text, labelText: "Doctor’s address ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.doctorsPostCode, inputType: TextInputType.text, labelText: "Post Code", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.doctorsPhoneNo, inputType: TextInputType.text, labelText: "Doctor’s phone no ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Medical Details:", style: TextStyle(fontWeight: FontWeight.bold),),
                // Text("Does your child have any medical problems that we should be made aware of? Please give details below", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.medicalproblemsdetail, inputType: TextInputType.text, labelText: "Medical Problems (if any) ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Does your child have any allergies that we should be made aware of? Please give details below.", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.allergies, inputType: TextInputType.text, labelText: "Allergies (if any) ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Is your child on any long term medication that we should be made aware of? Please give details below.", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.longTermMedication, inputType: TextInputType.text, labelText: "Long Term Medication (if any) ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Does your child have any special dietary requirements that we should be made aware of? Please give details below.", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.specialDietaryRequirements, inputType: TextInputType.text, labelText: "Special Dietary Requirements (if any) ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Permissions", style: TextStyle(fontWeight: FontWeight.bold),),
                // Text("Do you give Kidz Rebublik permission to take photographs of your child for development files?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.permissiontotakephotographsforfiles, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to take photographs of your child for promotions?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.permissiontotakephotographsforpromotions, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to babywipes / teething gel / sudocrem?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.permissiontobabywipes_teethinggel_sudocrem, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to administer first aid?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.permissiontoadministerfirstaid, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to take your child on outings to local shops etc?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.permissiontooutingstolocalshops, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Do you give Kidz Rebublik permission to administer paracetamol suspension if needed?", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.permissiontoadministerparacetamol, inputType: TextInputType.text, labelText: "Yes / No ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Collection Arrangements", style: TextStyle(fontWeight: FontWeight.bold),),
                // Text("Any changes to this information should be made in writing to the administration.", style: TextStyle(fontSize: 12,color: Colors.red,fontWeight: FontWeight.bold),),
                // Text("Who is authorised to collect your child from the Kidz Republik other than the parents? Your child would only be allowed to leave the childcare centre with people listed here? ", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.authorisedtocollectName1, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.authorisedtocollectRelationship1, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.authorisedtocollectName2, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.authorisedtocollectRelationship2, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.authorisedtocollectName3, inputType: TextInputType.text, labelText: "Name ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //     Expanded(child: CustomTextField(controller: updateRegistrationFormController.authorisedtocollectRelationship3, inputType: TextInputType.text, labelText: "Relationship to child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},)),
                //   ],
                // ),
                // Text("As an extra precaution you may use a password. Anyone collecting your child should be made aware of this.", style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                // CustomTextField(controller: updateRegistrationFormController.collectionPassword, inputType: TextInputType.text, labelText: "Password ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("Child’s Background", style: TextStyle(fontWeight: FontWeight.bold),),
                // CustomTextField(controller: updateRegistrationFormController.childsReligion, inputType: TextInputType.text, labelText: "Child’s Religion ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.childsEthnicGroup, inputType: TextInputType.text, labelText: "Child’s EthnicGroup ", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.firstLanguagespoken, inputType: TextInputType.text, labelText: "What is the first Language spoken at home?", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // CustomTextField(controller: updateRegistrationFormController.otherlanguagespoken, inputType: TextInputType.text, labelText: "Is there any other language spoken at home?", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                // Text("I understand and acknowledge that the fee due for my child’s care centre / preschool is to be paid per calendar month and paid in one month advance, directly into the bank on receipt of the fee voucher and is non refundable in case of absence.I further agree to give one month’s notice or payment in lieu of notice if I wish to withdraw my child from the childcare / preschool. I understand that failure to pay said fees may result in loss of provision of childcare continuation of education in preschool.", style: TextStyle(fontWeight: FontWeight.normal),),
                // SizedBox(height: mQ.height * 0.028,),
                Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                  updateRegistrationFormController.selectDate("Registration Date", context),
                  (updateRegistrationFormController.datechanged)
                      ? Text('${updateRegistrationFormController.getCurrentDate()}')
                      : Text('${updateRegistrationFormController.newdate}')
                ]),
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
              ? updateRegistrationFormController.bmothersparentalResponsibility
              : (isCheckedcontroller == 'bfathersparentalResponsibility')
                  ? updateRegistrationFormController.bfathersparentalResponsibility
                  : (isCheckedcontroller == 'bMondayFullDay')
                      ? updateRegistrationFormController.bMondayFullDay
                      : (isCheckedcontroller == 'bTuesedayFullDay')
                          ? updateRegistrationFormController.bTuesedayFullDay
                          : (isCheckedcontroller == 'bWednesdayFullDay')
                              ? updateRegistrationFormController.bWednesdayFullDay
                              : (isCheckedcontroller == 'bThursdayFullDay')
                                  ? updateRegistrationFormController.bThursdayFullDay
                                  : (isCheckedcontroller == 'bFridayFullDay')
                                      ? updateRegistrationFormController.bFridayFullDay
                                      : (isCheckedcontroller == 'bSaturdayFullDay')
                                          ? updateRegistrationFormController.bSaturdayFullDay
                                          : false,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
              // (isChecked) ?
              //   controller = titlechecked             :  controller = titleunchecked;
              (isCheckedcontroller == 'bmothersparentalResponsibility')
                  ? updateRegistrationFormController.bmothersparentalResponsibility = isChecked
                  : (isCheckedcontroller == 'bfathersparentalResponsibility')
                      ? updateRegistrationFormController.bfathersparentalResponsibility = isChecked
                      : (isCheckedcontroller == 'bMondayFullDay')
                          ? updateRegistrationFormController.bMondayFullDay = isChecked
                          : (isCheckedcontroller == 'bTuesedayFullDay')
                              ? updateRegistrationFormController.bTuesedayFullDay = isChecked
                              : (isCheckedcontroller == 'bWednesdayFullDay')
                                  ? updateRegistrationFormController.bWednesdayFullDay = isChecked
                                  : (isCheckedcontroller == 'bThursdayFullDay')
                                      ? updateRegistrationFormController.bThursdayFullDay = isChecked
                                      : (isCheckedcontroller == 'bFridayFullDay')
                                          ? updateRegistrationFormController.bFridayFullDay = isChecked
                                          : (isCheckedcontroller == 'bSaturdayFullDay')
                                              ? updateRegistrationFormController.bSaturdayFullDay = isChecked
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
    final filename = "images/ ${updateRegistrationFormController.childFullName.text}${DateTime.now()}";
    final uploadTask = storageRef.child(filename).putFile(file, metadata);
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
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
          setState(() async {
            imageUrl = await storageRef.child(filename).getDownloadURL();
            imageloading = false;
            imagedownloading = true;
            ToastContext().init(context);
            Toast.show(
              'Wait: Uploading photo',
              // Get.context,
              duration: 1, backgroundRadius: 5,
              //gravity: Toast.top,
            );
          });

          break;
      }
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
                  getProfileImageFromCameraAndUpdate(
                    context,
                  );
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
                  getProfileImageFromStorageAndUpdate(context);
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

  Future<void> fetchdataintoformChildFunction(BuildContext context, babyId) async {
    updateRegistrationFormController.isLoading.value = true;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('BabyData').doc(babyId).get();
      if (snapshot.exists) {
        setState(() {
          // doc(babyId).update({
          updateRegistrationFormController.childFullName.text = snapshot.get("childFullName");
          imageUrl = snapshot.get("picture");
          updateRegistrationFormController.fathersName.text = snapshot.get("fathersName");
          updateRegistrationFormController.fathersEmail.text = snapshot.get("fathersEmail");
          updateRegistrationFormController.nameUsuallyKnownBy.text = snapshot.get('nameusuallyknownby');
          updateRegistrationFormController.nameUsuallyKnownBy.text = snapshot.get("nameusuallyknownby");
          updateRegistrationFormController.dateofBirth.value = snapshot.get("dateofBirth");
          updateRegistrationFormController.gender.text = snapshot.get("gender");
          updateRegistrationFormController.address.text = snapshot.get("address");
          updateRegistrationFormController.postCode.text = snapshot.get("postCode");
          updateRegistrationFormController.homePhone.text = snapshot.get("homePhone");
          updateRegistrationFormController.mothersName.text = snapshot.get("mothersName");
          updateRegistrationFormController.mothersoccupation.text = snapshot.get("mothersoccupation");
          updateRegistrationFormController.mothersemployer.text = snapshot.get("mothersemployer");
          updateRegistrationFormController.mothersworkPhoneNo.text = snapshot.get("mothersworkPhoneNo");
          updateRegistrationFormController.mothersmobilePhoneNo.text = snapshot.get("mothersmobilePhoneNo");
          updateRegistrationFormController.mothersEmailAddress.text = snapshot.get("mothersEmailAddress");
          updateRegistrationFormController.mothersAddress.text = snapshot.get("mothersAddress");
          updateRegistrationFormController.mothersPostCode.text = snapshot.get("mothersPostCode");
          updateRegistrationFormController.bmothersparentalResponsibility = snapshot.get("mothersparentalResponsibility");
          updateRegistrationFormController.motherscontactrestrictions.text = snapshot.get("motherscontactrestrictions");
          updateRegistrationFormController.fathersOccupation.text = snapshot.get("fathersOccupation");
          updateRegistrationFormController.fathersEmployer.text = snapshot.get("fathersEmployer");
          updateRegistrationFormController.fathersWorkPhoneNo.text = snapshot.get("fathersWorkPhoneNo");
          updateRegistrationFormController.fathersMobileNo.text = snapshot.get("fathersMobileNo");
          updateRegistrationFormController.fathersAddress.text = snapshot.get("fathersAddress");
          updateRegistrationFormController.fathersPostCode.text = snapshot.get("fathersPostCode");
          updateRegistrationFormController.bfathersparentalResponsibility = snapshot.get("fathersparentalResponsibility");
          updateRegistrationFormController.fatherscontactrestrictions.text = snapshot.get("fatherscontactrestrictions");
          updateRegistrationFormController.otherEmergencyContactsName1.text = snapshot.get("otherEmergencyContactsName1");
          updateRegistrationFormController.otherEmergencyContactsTelephoneNo1.text = snapshot.get("otherEmergencyContactsTelephoneNo1");
          updateRegistrationFormController.otherEmergencyContactsRelationshiptoChild1.text = snapshot.get("otherEmergencyContactsRelationshiptoChild1");
          updateRegistrationFormController.otherEmergencyContactsName2.text = snapshot.get("otherEmergencyContactsName2");
          updateRegistrationFormController.otherEmergencyContactsTelephoneNo2.text = snapshot.get("otherEmergencyContactsTelephoneNo2");
          updateRegistrationFormController.otherEmergencyContactsRelationshiptoChild2.text = snapshot.get("otherEmergencyContactsRelationshiptoChild2");
          updateRegistrationFormController.MondayMorningFrom.text = snapshot.get("MondayMorningFrom");
          updateRegistrationFormController.MondayMorningTo.text = snapshot.get("MondayMorningTo");
          updateRegistrationFormController.MondayEveneingFrom.text = snapshot.get("MondayEveneingFrom");
          updateRegistrationFormController.MondayEveneingTo.text = snapshot.get("MondayEveneingTo");
          updateRegistrationFormController.bMondayFullDay = snapshot.get("MondayFullDay");
          updateRegistrationFormController.TuesdayMorningFrom.text = snapshot.get("TuesdayMorningFrom");
          updateRegistrationFormController.TuesdayMorningTo.text = snapshot.get("TuesdayMorningTo");
          updateRegistrationFormController.TuesdayEveningFrom.text = snapshot.get("TuesdayEveningFrom");
          updateRegistrationFormController.TuesdayEveneingTo.text = snapshot.get("TuesdayEveneingTo");
          updateRegistrationFormController.bTuesedayFullDay = snapshot.get("TuesdayFullDay");
          updateRegistrationFormController.WednesdayMorningFrom.text = snapshot.get("WednesdayMorningFrom");
          updateRegistrationFormController.WednesdayMorningTo.text = snapshot.get("WednesdayMorningTo");
          updateRegistrationFormController.WednesdayEveneingFrom.text = snapshot.get("WednesdayEveneingFrom");
          updateRegistrationFormController.WednesdayEveneingTo.text = snapshot.get("WednesdayEveneingTo");
          updateRegistrationFormController.bWednesdayFullDay = snapshot.get("WednesdayFullDay");
          updateRegistrationFormController.ThursdayMorningFrom.text = snapshot.get("ThursdayMorningFrom");
          updateRegistrationFormController.ThursdayMorningTo.text = snapshot.get("ThursdayMorningTo");
          updateRegistrationFormController.ThursdayEveneingFrom.text = snapshot.get("ThursdayEveneingFrom");
          updateRegistrationFormController.ThursdayEveneingTo.text = snapshot.get("ThursdayEveneingTo");
          updateRegistrationFormController.bThursdayFullDay = snapshot.get("ThursdayFullDay");
          updateRegistrationFormController.FridayMorningFrom.text = snapshot.get("FridayMorningFrom");
          updateRegistrationFormController.FridayMorningTo.text = snapshot.get("FridayMorningTo");
          updateRegistrationFormController.FridayEveneingFrom.text = snapshot.get("FridayEveneingFrom");
          updateRegistrationFormController.FridayEveneingTo.text = snapshot.get("FridayEveneingTo");
          updateRegistrationFormController.bFridayFullDay = snapshot.get("FridayFullDay");
          updateRegistrationFormController.SaturdayMorningFrom.text = snapshot.get("SaturdayMorningFrom");
          updateRegistrationFormController.SaturdayMorningTo.text = snapshot.get("SaturdayMorningTo");
          updateRegistrationFormController.SaturdayEveneingFrom.text = snapshot.get("SaturdayEveneingFrom");
          updateRegistrationFormController.SaturdayEveneingTo.text = snapshot.get("SaturdayEveneingTo");
          updateRegistrationFormController.bSaturdayFullDay = snapshot.get("SaturdayFullDay");
          updateRegistrationFormController.doctorsName.text = snapshot.get("doctorsName");
          updateRegistrationFormController.doctorsAddress.text = snapshot.get("doctorsAddress");
          updateRegistrationFormController.doctorsPostCode.text = snapshot.get("doctorsPostCode");
          updateRegistrationFormController.doctorsPhoneNo.text = snapshot.get("doctorsPhoneNo");
          updateRegistrationFormController.medicalproblemsdetail.text = snapshot.get("medicalproblemsdetail");
          updateRegistrationFormController.allergies.text = snapshot.get("allergies");
          updateRegistrationFormController.longTermMedication.text = snapshot.get("longTermMedication");
          updateRegistrationFormController.specialDietaryRequirements.text = snapshot.get("specialDietaryRequirements");
          updateRegistrationFormController.permissiontotakephotographsforfiles.text = snapshot.get("permissiontotakephotographsforfiles");
          updateRegistrationFormController.permissiontotakephotographsforpromotions.text = snapshot.get("permissiontotakephotographsforpromotions");
          updateRegistrationFormController.permissiontobabywipes_teethinggel_sudocrem.text = snapshot.get("permissiontobabywipes_teethinggel_sudocrem");
          updateRegistrationFormController.permissiontoadministerfirstaid.text = snapshot.get("permissiontoadministerfirstaid");
          updateRegistrationFormController.permissiontooutingstolocalshops.text = snapshot.get("permissiontooutingstolocalshops");
          updateRegistrationFormController.permissiontoadministerparacetamol.text = snapshot.get("permissiontoadministerparacetamol");
          updateRegistrationFormController.RegistrationDate.text = snapshot.get("RegistrationDate");
          updateRegistrationFormController.authorisedtocollectName1.text = snapshot.get('authorisedtocollectName1');
          updateRegistrationFormController.authorisedtocollectRelationship1.text = snapshot.get("authorisedtocollectRelationship1");
          updateRegistrationFormController.authorisedtocollectName2.text = snapshot.get("authorisedtocollectName2");
          updateRegistrationFormController.authorisedtocollectRelationship2.text = snapshot.get("authorisedtocollectRelationship2");
          updateRegistrationFormController.authorisedtocollectName3.text = snapshot.get("authorisedtocollectName3");
          updateRegistrationFormController.authorisedtocollectRelationship3.text = snapshot.get("authorisedtocollectRelationship3");
          updateRegistrationFormController.collectionPassword.text = snapshot.get("collectionPassword");
          updateRegistrationFormController.childsReligion.text = snapshot.get("childsReligion");
          updateRegistrationFormController.childsEthnicGroup.text = snapshot.get("childsEthnicGroup");
          updateRegistrationFormController.firstLanguagespoken.text = snapshot.get("firstLanguagespoken");
          updateRegistrationFormController.otherlanguagespoken.text = snapshot.get("otherlanguagespoken");
          updateRegistrationFormController.admissionDate.value = snapshot.get("admission_date");
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    updateRegistrationFormController.isLoading.value = false;
  }
}
