import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
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
  UpdateRegistrationForm( {required this.babyId,super.key,});

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
  void initState()  {
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
          style: TextStyle(fontSize: 14,color: kWhite),
        ),
        backgroundColor: kprimary,
      ),
      bottomNavigationBar: Obx(
            () => updateRegistrationFormController.isLoading.value
            ? Center(
            child: const CircularProgressIndicator())
            : SizedBox(
          width: mQ.width * 0.85,
          height: mQ.height * 0.065,
          child: PrimaryButton(
            onPressed: () {
              updateRegistrationFormController
                  .UpdateChildFunction(context,widget.babyId);
            },
            label: "Update",
            elevation: 3,
            bgColor: kprimary,
            labelStyle: kTextPrimaryButton.copyWith(
                fontWeight: FontWeight.w500),
            borderRadius:
            BorderRadius.circular(2.0),
          ),
        ),
      ),

      body:
        SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 15),
                      child: Form(
                        key: updateRegistrationFormController.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: mQ.height * 0.03,
                            ),
                             imageloading
                                ? Container(
                                width: mQ.width * 0.4,
                                height: mQ.height * 0.2,
                                child: Center(
                                    child:
                                    CircularProgressIndicator()))
                                : Container(
                                width: mQ.width * 0.4,
                                height: mQ.height * 0.2,
                                child: Image.network(
                                  imageUrl!
                                )),
                            IconButton(
                              icon: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text('Upload Image'),
                                    Icon(Icons.camera_alt_outlined,
                                        size: 30),
                                  ]),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 3),
                              onPressed: () async {_imageActionSheet(context, 'Student',mQ);},
                            )
                          ,
                            Text('Basic Information:', style: TextStyle(fontWeight: FontWeight.bold),),
                            CustomTextField(controller: updateRegistrationFormController.childFullName, inputType: TextInputType.text, labelText: "Full name of child", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                            CustomTextField(controller: updateRegistrationFormController.nameUsuallyKnownBy, inputType: TextInputType.text, labelText: "Name usually known by", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                            Row(
                              children: [
                                Expanded(child: Text('Mother’s Details:', style: TextStyle(fontWeight: FontWeight.bold),)),
                              ],
                            ),
                            CustomTextField(controller: updateRegistrationFormController.mothersName, inputType: TextInputType.text, labelText: "Mother’s name", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                            CustomTextField(controller: updateRegistrationFormController.mothersmobilePhoneNo, inputType: TextInputType.text, labelText: "Mobile Phone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                            CustomTextField(controller: updateRegistrationFormController.mothersEmailAddress, inputType: TextInputType.text, labelText: "Email Address", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                            Row(
                              children: [
                                Expanded(child: Text('Father’s Details:', style: TextStyle(fontWeight: FontWeight.bold),)),
                              ],
                            ),
                            CustomTextField(controller: updateRegistrationFormController.fathersName, inputType: TextInputType.text, labelText: "Father’s name", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                            CustomTextField(controller: updateRegistrationFormController.fathersMobileNo, inputType: TextInputType.text, labelText: "Mobile Phone No", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                            CustomTextField(controller: updateRegistrationFormController.fathersEmail, inputType: TextInputType.text, labelText: "Email Address", validators: (String? value) {if (value!.isEmpty) {return 'Required';}return null;},),
                          Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children:[
                            updateRegistrationFormController.selectDate("Registration Date",context),
                            (updateRegistrationFormController.datechanged)? Text('${updateRegistrationFormController.getCurrentDate()}') : Text('${updateRegistrationFormController.newdate}') ]),
                          ],
                        ),
                      ),
                    ),
                  ),
      // ),
    );
  }
bool isChecked = true;

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
              duration: 1,  backgroundRadius: 5,
              //gravity: Toast.top,
            );

          });

          break;
      }
    });
  }

  Future<void> _imageActionSheet(BuildContext context, String title,mQ) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return
          Column(
              mainAxisSize: MainAxisSize.min,      children: [
            Text("Take ${title} Picture"),
            Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
              // Image.asset('assets/staff.jpg',width: mQ.width*0.9,height: mQ.height*0.7,),
              Expanded(
                child: ListTile(titleAlignment: ListTileTitleAlignment.center,
                  title:
                  Text('Camera',style: TextStyle(fontSize: 10),textAlign: TextAlign.center),
                  leading:  Icon(Icons.camera_alt_outlined, color: Colors.purple,size: 20,),
                  onTap: () async {_imageActionSheet2(context, title);Navigator.pop(context);},
                ),
              ),
              Expanded(
                child: ListTile(titleAlignment: ListTileTitleAlignment.center,
                  title:
                  Text('Gallery',style: TextStyle(fontSize: 10),),
                  leading:  Icon(Icons.image, color: Colors.cyan, size: 20),
                  onTap: () async {_pickFile();Navigator.pop(context);},
                ),
              ),
            ]),
          ]);
      },
    );
  }
  Future<void> _imageActionSheet2(BuildContext context,
      String title,) async {
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
          return WillPopScope( onWillPop:() async {
            _controller.dispose();
            return true;
          },
              child:
              Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(0),
                  child:
                  Container(padding: EdgeInsets.all(0),
                      width: double.infinity,
                      // height: mQ.height*0.45,
                      height: double.infinity,
                      // color: grey100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.transparent
                      ),
                      child:  Column(children: [
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
                              final image =
                              await _controller.takePicture();
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
                      ])
                  ))
          );
        },
      );
    }
  }
  Future<void> fetchdataintoformChildFunction(BuildContext context,babyId) async {
    updateRegistrationFormController.isLoading.value = true;
    try {  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection(BabyData).doc(babyId).get();
    if (snapshot.exists) {
      setState(() {

    // doc(babyId).update({
          updateRegistrationFormController.  childFullName.text=snapshot.get("childFullName");
          imageUrl =snapshot.get("picture");
          updateRegistrationFormController.  fathersName.text=snapshot.get("fathersName");
          updateRegistrationFormController.  fathersEmail.text=snapshot.get("fathersEmail");
          updateRegistrationFormController.nameUsuallyKnownBy.text = snapshot.get('nameusuallyknownby');
          updateRegistrationFormController.  dateofBirth.value =snapshot.get("dateofBirth");
          // updateRegistrationFormController.   gender.text=snapshot.get("gender");
          // updateRegistrationFormController.  address.text=snapshot.get("address");
          // updateRegistrationFormController.  postCode.text=snapshot.get("postCode");
          updateRegistrationFormController.  homePhone.text=snapshot.get("homePhone");
          updateRegistrationFormController.  mothersName.text=snapshot.get("mothersName");
          // updateRegistrationFormController.  mothersoccupation.text=snapshot.get("mothersoccupation");
          // updateRegistrationFormController.  mothersemployer.text=snapshot.get("mothersemployer");
          updateRegistrationFormController.  mothersworkPhoneNo.text=snapshot.get("mothersworkPhoneNo");
          updateRegistrationFormController.  mothersmobilePhoneNo.text=snapshot.get("mothersmobilePhoneNo");
          updateRegistrationFormController.  mothersEmailAddress.text=snapshot.get("mothersEmailAddress");
          // updateRegistrationFormController.  mothersAddress.text=snapshot.get("mothersAddress");
          // updateRegistrationFormController.  mothersPostCode.text=snapshot.get("mothersPostCode");
          // updateRegistrationFormController.  bmothersparentalResponsibility=snapshot.get("mothersparentalResponsibility");
          // updateRegistrationFormController.  motherscontactrestrictions.text=snapshot.get("motherscontactrestrictions");
          // updateRegistrationFormController.  fathersOccupation.text=snapshot.get("fathersOccupation");
          // updateRegistrationFormController.  fathersEmployer.text=snapshot.get("fathersEmployer");
          updateRegistrationFormController.  fathersWorkPhoneNo.text=snapshot.get("fathersWorkPhoneNo");
          updateRegistrationFormController.  fathersMobileNo.text=snapshot.get("fathersMobileNo");
          // updateRegistrationFormController.  fathersAddress.text=snapshot.get("fathersAddress");
          // updateRegistrationFormController.  fathersPostCode.text=snapshot.get("fathersPostCode");
          // updateRegistrationFormController.  bfathersparentalResponsibility=snapshot.get("fathersparentalResponsibility");
          // updateRegistrationFormController.  fatherscontactrestrictions.text=snapshot.get("fatherscontactrestrictions");
          // updateRegistrationFormController.  otherEmergencyContactsName1.text=snapshot.get("otherEmergencyContactsName1");
          // updateRegistrationFormController.  otherEmergencyContactsTelephoneNo1.text=snapshot.get("otherEmergencyContactsTelephoneNo1");
          // updateRegistrationFormController.  otherEmergencyContactsRelationshiptoChild1.text=snapshot.get("otherEmergencyContactsRelationshiptoChild1");
          // updateRegistrationFormController.  otherEmergencyContactsName2.text=snapshot.get("otherEmergencyContactsName2");
          // updateRegistrationFormController.  otherEmergencyContactsTelephoneNo2.text=snapshot.get("otherEmergencyContactsTelephoneNo2");
          // updateRegistrationFormController.  otherEmergencyContactsRelationshiptoChild2.text=snapshot.get("otherEmergencyContactsRelationshiptoChild2");
          // updateRegistrationFormController.  MondayMorningFrom.text=snapshot.get("MondayMorningFrom");
          // updateRegistrationFormController.  MondayMorningTo.text=snapshot.get("MondayMorningTo");
          // updateRegistrationFormController.  MondayEveneingFrom.text=snapshot.get("MondayEveneingFrom");
          // updateRegistrationFormController.  MondayEveneingTo.text=snapshot.get("MondayEveneingTo");
          // updateRegistrationFormController.  bMondayFullDay=snapshot.get("MondayFullDay");
          // updateRegistrationFormController.  TuesdayMorningFrom.text=snapshot.get("TuesdayMorningFrom");
          // updateRegistrationFormController.  TuesdayMorningTo.text=snapshot.get("TuesdayMorningTo");
          // updateRegistrationFormController.  TuesdayEveningFrom.text=snapshot.get("TuesdayEveningFrom");
          // updateRegistrationFormController.  TuesdayEveneingTo.text=snapshot.get("TuesdayEveneingTo");
          // updateRegistrationFormController.  bTuesedayFullDay=snapshot.get("TuesdayFullDay");
          // updateRegistrationFormController.  WednesdayMorningFrom.text=snapshot.get("WednesdayMorningFrom");
          // updateRegistrationFormController.  WednesdayMorningTo.text=snapshot.get("WednesdayMorningTo");
          // updateRegistrationFormController.  WednesdayEveneingFrom.text=snapshot.get("WednesdayEveneingFrom");
          // updateRegistrationFormController.  WednesdayEveneingTo.text=snapshot.get("WednesdayEveneingTo");
          // updateRegistrationFormController.  bWednesdayFullDay=snapshot.get("WednesdayFullDay");
          // updateRegistrationFormController.  ThursdayMorningFrom.text=snapshot.get("ThursdayMorningFrom");
          // updateRegistrationFormController.  ThursdayMorningTo.text=snapshot.get("ThursdayMorningTo");
          // updateRegistrationFormController.  ThursdayEveneingFrom.text=snapshot.get("ThursdayEveneingFrom");
          // updateRegistrationFormController.  ThursdayEveneingTo.text=snapshot.get("ThursdayEveneingTo");
          // updateRegistrationFormController.  bThursdayFullDay=snapshot.get("ThursdayFullDay");
          // updateRegistrationFormController.  FridayMorningFrom.text=snapshot.get("FridayMorningFrom");
          // updateRegistrationFormController.  FridayMorningTo.text=snapshot.get("FridayMorningTo");
          // updateRegistrationFormController.  FridayEveneingFrom.text=snapshot.get("FridayEveneingFrom");
          // updateRegistrationFormController.  FridayEveneingTo.text=snapshot.get("FridayEveneingTo");
          // updateRegistrationFormController.  bFridayFullDay=snapshot.get("FridayFullDay");
          // updateRegistrationFormController.  SaturdayMorningFrom.text=snapshot.get("SaturdayMorningFrom");
          // updateRegistrationFormController.  SaturdayMorningTo.text=snapshot.get("SaturdayMorningTo");
          // updateRegistrationFormController.  SaturdayEveneingFrom.text=snapshot.get("SaturdayEveneingFrom");
          // updateRegistrationFormController.  SaturdayEveneingTo.text=snapshot.get("SaturdayEveneingTo");
          // updateRegistrationFormController.  bSaturdayFullDay=snapshot.get("SaturdayFullDay");
          // updateRegistrationFormController.  doctorsName.text=snapshot.get("doctorsName");
          // updateRegistrationFormController.  doctorsAddress.text=snapshot.get("doctorsAddress");
          // updateRegistrationFormController.  doctorsPostCode.text=snapshot.get("doctorsPostCode");
          // updateRegistrationFormController.  doctorsPhoneNo.text=snapshot.get("doctorsPhoneNo");
          // updateRegistrationFormController.  medicalproblemsdetail.text=snapshot.get("medicalproblemsdetail");
          // updateRegistrationFormController.  allergies.text=snapshot.get("allergies");
          // updateRegistrationFormController.  longTermMedication.text=snapshot.get("longTermMedication");
          // updateRegistrationFormController.  specialDietaryRequirements.text=snapshot.get("specialDietaryRequirements");
          // updateRegistrationFormController.  permissiontotakephotographsforfiles.text=snapshot.get("permissiontotakephotographsforfiles");
          // updateRegistrationFormController.  permissiontotakephotographsforpromotions.text=snapshot.get("permissiontotakephotographsforpromotions");
          // updateRegistrationFormController.  permissiontobabywipes_teethinggel_sudocrem.text=snapshot.get("permissiontobabywipes_teethinggel_sudocrem");
          // updateRegistrationFormController.  permissiontoadministerfirstaid.text=snapshot.get("permissiontoadministerfirstaid");
          // updateRegistrationFormController.  permissiontooutingstolocalshops.text=snapshot.get("permissiontooutingstolocalshops");
          // updateRegistrationFormController.  permissiontoadministerparacetamol.text=snapshot.get("permissiontoadministerparacetamol");
          updateRegistrationFormController.  RegistrationDate.text=snapshot.get("RegistrationDate");
          // updateRegistrationFormController.  authorisedtocollectName1.text=snapshot.get('authorisedtocollectName1');
          // updateRegistrationFormController.  authorisedtocollectRelationship1.text=snapshot.get("authorisedtocollectRelationship1");
          // updateRegistrationFormController.  authorisedtocollectName2.text=snapshot.get("authorisedtocollectName2");
          // updateRegistrationFormController.  authorisedtocollectRelationship2.text=snapshot.get("authorisedtocollectRelationship2");
          // updateRegistrationFormController.  authorisedtocollectName3.text=snapshot.get("authorisedtocollectName3");
          // updateRegistrationFormController.  authorisedtocollectRelationship3.text=snapshot.get("authorisedtocollectRelationship3");
          // updateRegistrationFormController.  collectionPassword.text=snapshot.get("collectionPassword");
          // updateRegistrationFormController.  childsReligion.text=snapshot.get("childsReligion");
          // updateRegistrationFormController.  childsEthnicGroup.text=snapshot.get("childsEthnicGroup");
          // updateRegistrationFormController.  firstLanguagespoken.text=snapshot.get("firstLanguagespoken");
          // updateRegistrationFormController.  otherlanguagespoken.text=snapshot.get("otherlanguagespoken");
          // updateRegistrationFormController. admissionDate.value=snapshot.get("admission_date");
      });
    }
    } catch (e) {
      print('Error fetching data: $e');
    }
    updateRegistrationFormController.isLoading.value = false;
  }

}
