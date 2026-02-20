import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/kids_controller/registation_form_controller.dart';
import 'package:kids_republik/screens/kids/widgets/custom_textfield.dart';
import 'package:kids_republik/screens/widgets/primary_button.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

import '../../main.dart';

var image;
CameraDescription? firstCamera;
bool imageloading = false;
double? progress;
bool takepicture = false;
FilePicker? imagefile;
PlatformFile? file;
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

  RegistrationFormController registrationFormController =
      Get.put(RegistrationFormController());

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
                  onPressed: () async {
                    await uploadimagetocloudstorage(image);

                    registrationFormController.addChildFunction(context);
                  },
                  label: "Register",
                  elevation: 3,
                  bgColor: kprimary,
                  labelStyle:
                      kTextPrimaryButton.copyWith(fontWeight: FontWeight.w500),
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
                    ? Container(
                        width: mQ.width * 0.4,
                        height: mQ.height * 0.2,
                        child: Center(child: CircularProgressIndicator()))
                    : Container(
                        width: mQ.width * 0.4,
                        height: mQ.height * 0.2,
                        child: Image.file(
                          File(imagefilepath),
                          fit: BoxFit.fill,
                        )),
                IconButton(
                  icon: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Upload Image'),
                        Icon(Icons.camera_alt_outlined, size: 30),
                      ]),
                  constraints: const BoxConstraints(),
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
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
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      'Mother’s Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
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
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      'Father’s Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
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
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      registrationFormController.selectDate(
                          "Registration Date", context),
                      (registrationFormController.datechanged)
                          ? Text(
                              '${registrationFormController.getCurrentDate()}')
                          : Text('${registrationFormController.newdate}')
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

  // void _pickFile() async {
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: false);
  //   setState(() {
  //     imageloading = true;
  //   });
  //   pickAndUploadImage(result);
  //   if (result == null) return;
  //
  //   final file = result.files.first;
  //   imagefilepath = result.files.first.path!;
  //
  //   uploadimagetocloudstorage(file);
  //   // Upload to API
  //   File imageFile = File(file.path!);
  //   await uploadImageToApi(imageFile);
  //   // _openFile(file);
  //   setState(() {
  //     imageloading = false;
  //   });
  // }
  // Future<void> uploadImageToApi(File imageFile) async {
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('https://app.kidzrepublik.com.pk/api/publik/api/upload'),
  //   );
  //
  //   // Add the file to the request
  //   request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
  //
  //   // Send the request to the server
  //   var response = await request.send();
  //
  //   // Get the response from the server
  //   if (response.statusCode == 200) {
  //     // Handle success
  //     print('Image uploaded successfully to API.');
  //   } else {
  //     // Handle error
  //     print('Image upload to API failed.');
  //   }
  // }

  // Future<void> pickAndUploadImage(pickedFile) async {
  //   // final picker = ImagePicker();
  //   // final pickedFile = await picker.getImage(source: ImageSource.camera);
  //
  //   if (pickedFile != null) {
  //     File imageFile = File(pickedFile.path);
  //     await uploadImageToApi(imageFile);
  //   } else {
  //     print('No image selected.');
  //   }
  // }

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

  // Future<void> uploadImage(File imageFile) async {
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('https://app.kidzrepublik.com.pk/api/publik/api/upload'),
  //   );
  //
  //   // Add the file to the request
  //   request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
  //
  //   // Send the request to the server
  //   var response = await request.send();
  //
  //   // Get the response from the server
  //   if (response.statusCode == 200) {
  //     // Handle success
  //     print('Image uploaded successfully.');
  //   } else {
  //     // Handle error
  //     print('Image upload failed.');
  //   }
  // }
  // uploadimagetocloudstorage(imagefile) async {
  //   final storageRef = FirebaseStorage.instance.ref();
  //   final file = File(imagefile.path);
  //   final metadata = SettableMetadata(contentType: "image/jpeg");
  //   final filename = "images/${table_ == 'tsn_' ? 'tsn_' : 'krdc'}/${registrationFormController.childFullName.text}${DateTime.now()}";
  //   final uploadTask = storageRef.child(filename).putFile(file, metadata);
  //   uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
  //     switch (taskSnapshot.state) {
  //       case TaskState.running:
  //             100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
  //         break;
  //       case TaskState.paused:
  //         print("Upload is paused.");
  //         break;
  //       case TaskState.canceled:
  //         print("Upload was canceled");
  //         break;
  //       case TaskState.error:
  //       // Handle unsuccessful uploads
  //         break;
  //       case TaskState.success:
  //       // Handle successful uploads on complete
  //       // ...
  //         setState(() async {
  //           imageUrl = await storageRef.child(filename).getDownloadURL();
  //           imageloading = false;
  //           imagedownloading = true;
  //         });
  //
  //         break;
  //     }
  //     ToastContext().init(context);
  //     Toast.show(
  //       'Photo uploaded successfully',
  //       // Get.context,
  //       duration: 10,  backgroundRadius: 5,
  //       //gravity: Toast.top,
  //     );
  //   });
  //   // await apiService.uploadimage(file);
  //
  // }
  Future<void> _imageActionSheet(BuildContext context, String title, mQ) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Take ${title} Picture"),
          Row(children: [
            // Image.asset('assets/staff.jpg',width: mQ.width*0.9,height: mQ.height*0.7,),
            Expanded(
              child: IconButton(
                // title:
                // Text('',style: TextStyle(fontSize: mQ.height*0.016),),
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.purple,
                  size: 28,
                ),
                onPressed: () async {
                  _imageActionSheet2(context, title);
                  Navigator.pop(context);
                },
                // contentPadding: EdgeInsets.symmetric(horizontal: 50)
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.image, color: Colors.cyan, size: 28),
                onPressed: () async {
                  _pickFile();
                  Navigator.pop(context);
                },
                // contentPadding: EdgeInsets.symmetric(horizontal: 50)
              ),
            ),
          ]),
        ]);
      },
    );
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    setState(() {
      imageloading = true;
    });

    if (result == null) return;

    final file = result.files.first;
    imagefilepath = result.files.first.path!;

    // _openFile(file);
    setState(() {
      image = file;
      // savepicture = true;
      imageloading = false;
    });
  }

  // Future<void> _imageActionSheet(BuildContext context, String title,mQ) async {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return
  //         Column(
  //             mainAxisSize: MainAxisSize.min,      children: [
  //           Text("Take ${title} Picture"),
  //           Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
  //             // Image.asset('assets/staff.jpg',width: mQ.width*0.9,height: mQ.height*0.7,),
  //             Expanded(
  //               child: ListTile(titleAlignment: ListTileTitleAlignment.center,
  //                 title:
  //                 Text('Camera',style: TextStyle(fontSize: 10),textAlign: TextAlign.center),
  //                 leading:  Icon(Icons.camera_alt_outlined, color: Colors.purple,size: 20,),
  //                 onTap: () async {_imageActionSheet2(context, title);Navigator.pop(context);},
  //               ),
  //             ),
  //             Expanded(
  //               child: ListTile(titleAlignment: ListTileTitleAlignment.center,
  //                 title:
  //                 Text('Gallery',style: TextStyle(fontSize: 10),),
  //                 leading:  Icon(Icons.image, color: Colors.cyan, size: 20),
  //                 onTap: () async {_pickFile();Navigator.pop(context);},
  //               ),
  //             ),
  //           ]),
  //         ]);
  //     },
  //   );
  // }
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
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.transparent),
                      child: Column(children: [
                        FutureBuilder<void>(
                          future: _initializeControllerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return CameraPreview(_controller);
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                        FloatingActionButton(
                          onPressed: () async {
                            try {
                              await _initializeControllerFuture;
                              image = await _controller.takePicture();
                              if (!mounted) return;
                              imagefilepath = image.path;
                              imageloading = true;
                              await GallerySaver.saveImage(imagefilepath);
                              await loadimagefunction(imagefilepath);

                              // await uploadimagetocloudstorage(image);
                              _controller.dispose();
                              // savepicture = true;
                              Navigator.pop(context);
                              setState(() {});
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

                        // FloatingActionButton(
                        //   onPressed: () async {
                        //     try {
                        //       await _initializeControllerFuture;
                        //       final image =
                        //       await _controller.takePicture();
                        //       if (!mounted) return;
                        //       imagefilepath = image.path;
                        //       imageloading = true;
                        //       await GallerySaver.saveImage(imagefilepath);
                        //       await loadimagefunction(imagefilepath);
                        //       _controller.dispose();
                        //       Navigator.pop(context);
                        //     } catch (e) {
                        //       print(e);
                        //     }
                        //   },
                        //
                        //   child: Icon(
                        //     Icons.camera_alt_outlined,
                        //     color: Colors.purple,
                        //     size: 20,
                        //   ),
                        // ),
                      ]))));
        },
      );
    }
  }

// Function to compress the image
  Future<Uint8List?> compressImage(File file, int targetSizeInBytes) async {
    int quality = 100;
    Uint8List? result;

    do {
      result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        minWidth: 1920,
        minHeight: 1080,
      );
      quality -= 10;
    } while (
        result != null && result.length > targetSizeInBytes && quality > 0);

    return result;
  }

  uploadimagetocloudstorage(imagefile) async {
    final storageRef = FirebaseStorage.instance.ref();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: CircularProgressIndicator(
          color: kprimary,
          backgroundColor: Colors.blue[50],
          value: progress ?? 0.1, // Adjust the value to control the progress
        ),
      ),
    );
    Uint8List? compressedImage =
        await compressImage(File(imagefile.path), 1 * 1024 * 1024);
    // Check if compression returned null, if so, use the original file bytes
    if (compressedImage == null) {
      print("Compression failed, using original image.");
      compressedImage = await File(imagefile.path).readAsBytes();
    }

    // Convert compressed image to file
    final compressedFile = File('${imagefile.path}_compressed.jpg');
    await compressedFile.writeAsBytes(compressedImage);

    // final metadata = SettableMetadata(contentType: "image/jpeg");
    // final filename = "${table_}images/${DateTime.now()}";

    final file = File(imagefile.path);
    final metadata = SettableMetadata(contentType: "image/jpeg");
    final filename =
        "${table_}images/studentsprofile/${registrationFormController.childFullName.text}${DateTime.now()}";

    final uploadTask =
        storageRef.child(filename).putFile(compressedFile, metadata);
    // final uploadTask = storageRef.child(filename).putFile(file, metadata);
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
          setState(() async {
            imageUrl = await storageRef.child(filename).getDownloadURL();
            imageloading = false;
            imagedownloading = true;
          });

          ToastContext().init(context);
          Toast.show(
            'Photo uploaded successfully',
            duration: 10,
            backgroundRadius: 5,
          );
          break;
      }
    });
  }

  // void _pickFile() async {
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: false);
  //   setState(() {
  //     imageloading = true;
  //   });
  //   if (result == null) return;
  //
  //   file = result.files.first;
  //   imagefilepath = result.files.first.path!;
  //
  //
  //   // Upload to API and get the uploaded image URL
  //   // File imageFile = File(file.path!);
  //   await uploadimagetocloudstorage(file);
  //   // String? imageUrl = await uploadImageToApi(imageFile);
  //
  //   // Save the image URL in Firebase Firestore
  //   // if (imageUrl != null) {
  //   //   await saveImageLinkToFirestore(imageUrl);
  //   // }
  //
  //   // Optionally, upload to Firebase Storage as well
  //   // uploadimagetocloudstorage(file);
  //
  //   setState(() {
  //     imageloading = false;
  //   });
  // }

  Future<String?> uploadImageToApi(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://app.kidzrepublik.com.pk/api/public/api/upload'),
    );

    // Add the file to the request
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    // Send the request to the server
    var response = await request.send();

    if (response.statusCode == 200) {
      // Construct the URL of the uploaded image
      imageUrl =
          "https://app.kidzrepublik.com.pk/storage/uploads/${imageFile.path.split('/').last}";
      print('Image uploaded successfully to API. URL: $imageUrl');
      return imageUrl;
    } else {
      print('Image upload to API failed.');
      return null;
    }
  }

  // Future<void> saveImageLinkToFirestore(String imageUrl) async {
  //   // Replace 'your-collection' with your actual collection name
  //   CollectionReference collectionRef = FirebaseFirestore.instance.collection('your-collection');
  //
  //   // Add the image URL to the Firestore document
  //   await collectionRef.add({
  //     'imageUrl': imageUrl,
  //     'timestamp': Timestamp.now(),
  //   });
  //
  //   print('Image URL saved to Firestore: $imageUrl');
  // }
}
