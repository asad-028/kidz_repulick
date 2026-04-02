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
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: kprimary),
        title: Text(
          'Registration Form',
          style: k16bold.copyWith(color: kprimary),
        ),
        backgroundColor: kWhite,
      ),
      bottomNavigationBar: Obx(
        () => registrationFormController.isLoading.value
            ? const SizedBox(
                height: 100, child: Center(child: CircularProgressIndicator()))
            : Container(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: PrimaryButton(
                  onPressed: () async {
                    if (registrationFormController.formKey.currentState!.validate()) {
                      if (image != null) {
                        await uploadimagetocloudstorage(image);
                      }
                      registrationFormController.addChildFunction(context);
                    }
                  },
                  label: "Register Student",
                  elevation: 5,
                  bgColor: kprimary,
                  labelStyle: kTextPrimaryButton.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(mQ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Form(
                key: registrationFormController.formKey,
                child: Column(
                  children: [
                    _buildImagePicker(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Basic Information"),
                    _buildSectionCard([
                      CustomTextField(
                        controller: registrationFormController.childFullName,
                        inputType: TextInputType.text,
                        labelText: "Full name of child",
                        validators: (String? value) {
                          if (value!.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                      CustomTextField(
                        controller:
                            registrationFormController.nameUsuallyKnownBy,
                        inputType: TextInputType.text,
                        labelText: "Name usually known by",
                        validators: (String? value) {
                          return null;
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionHeader("Mother's Details"),
                    _buildSectionCard([
                      CustomTextField(
                        controller: registrationFormController.mothersName,
                        inputType: TextInputType.text,
                        labelText: "Mother's name",
                        validators: (String? value) {
                          return null;
                        },
                      ),
                      CustomTextField(
                        controller:
                            registrationFormController.mothersmobilePhoneNo,
                        inputType: TextInputType.text,
                        labelText: "Mobile Phone No",
                        validators: (String? value) {
                          return null;
                        },
                      ),
                      CustomTextField(
                        controller:
                            registrationFormController.mothersEmailAddress,
                        inputType: TextInputType.text,
                        labelText: "Email Address",
                        validators: (String? value) {
                          if (value!.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionHeader("Father's Details"),
                    _buildSectionCard([
                      CustomTextField(
                        controller: registrationFormController.fathersName,
                        inputType: TextInputType.text,
                        labelText: "Father's name",
                        validators: (String? value) {
                          return null;
                        },
                      ),
                      CustomTextField(
                        controller: registrationFormController.fathersMobileNo,
                        inputType: TextInputType.text,
                        labelText: "Mobile Phone No",
                        validators: (String? value) {
                          return null;
                        },
                      ),
                      CustomTextField(
                        controller: registrationFormController.fathersEmail,
                        inputType: TextInputType.text,
                        labelText: "Email Address",
                        validators: (String? value) {
                          if (value!.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildRegistrationDateSection(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size mQ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: kprimary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            "Student Registration",
            style: kMediumTitle.copyWith(color: kprimary),
          ),
          const SizedBox(height: 4),
          Text(
            "Please fill in the details below to register a new student",
            style: kSubTitle.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: grey100,
              border: Border.all(color: kprimary.withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: ClipOval(
              child: imagefilepath.isEmpty
                  ? Icon(Icons.person, size: 60, color: kGreyColor)
                  : imageloading
                      ? const Center(child: CircularProgressIndicator())
                      : Image.file(
                          File(imagefilepath),
                          fit: BoxFit.cover,
                        ),
            ),
          ),
          InkWell(
            onTap: () => _imageActionSheet(
                context, 'Student', MediaQuery.of(context).size),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kprimary,
                shape: BoxShape.circle,
                border: Border.all(color: kWhite, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: kWhite, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: kprimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: k16bold.copyWith(color: kprimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      color: kWhite,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildRegistrationDateSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kprimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: kprimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Registration Date", style: k12500.copyWith(color: kGrey)),
                Text(
                  '${registrationFormController.datechanged ? registrationFormController.getCurrentDate() : registrationFormController.newdate}',
                  style: k14500.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          registrationFormController.selectDate("Change", context),
        ],
      ),
    );
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

  Future<void> _imageActionSheet2(
    BuildContext context,
    String title,
  ) async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isGranted) {
      await camerainitialize();

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
    // Guard against null or invalid image before starting upload
    if (imagefile == null || imagefile.path == null) {
      ToastContext().init(context);
      Toast.show(
        'Please select a valid image before uploading',
        duration: 3,
      );
      return;
    }

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
}
