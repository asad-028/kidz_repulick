import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/controllers/bi_monthly_reports/bi_monthly_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/getdatefunction.dart';
import '../../utils/image_slide_show.dart';
import '../kids/widgets/custom_textfield.dart';

CameraDescription? firstCamera;
List<String> list = <String>[];
String? dropdownValue;
var image;
String descriptionplus = "";
double? progress;
bool timeupdated = false;
bool imageloading = false;
bool takepicture = false;
bool savepicture = false;
FilePicker? imagefile;
String imagefilepath = '';
var selectedTime;

class CreateActivityForMultipleChildsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedBabies;
  // final selectedbabyid_;
  final selectedsubject_;
// final babypicture_;
// final name_;
  CreateActivityForMultipleChildsScreen({
    required this.selectedBabies,
    super.key,
    required this.selectedsubject_,
  });

  @override
  State<CreateActivityForMultipleChildsScreen> createState() =>
      _CreateActivityForMultipleChildsScreenState();
}

class _CreateActivityForMultipleChildsScreenState
    extends State<CreateActivityForMultipleChildsScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  CreateActivityScreenController createActivityScreenController =
      Get.put(CreateActivityScreenController());
  String? babyid;
  String? subject;
  String? class_variable;
  bool imagedownloading = false;
  late File limagefile;
  camerainitialize() async {
    final cameras = await availableCameras();
    firstCamera = cameras.first;
  }

  @override
  void initState() {
    selectlist();

    super.initState();
    descriptionplus = '';
    subject = widget.selectedsubject_;
    // babyid = widget.selectedbabyid_;
    createActivityScreenController.currentDate.value =
        createActivityScreenController.getCurrentDate();
    selectedTime = TimeOfDay.now();
    (subject != 'BiWeekly')
        ? (subject != 'Mood')
            ? (subject != 'Activity')
                ? (subject != 'Notes')
                    ? dropdownValue = list.first
                    : null
                : null
            : null
        : null;
    // (subject == 'BiWeekly')? () {
    createActivityScreenController.subject_.text = '';
    createActivityScreenController.activity_.text = '';
    sleeptime_ = null;
    imageUrl = "";
    descriptionplus = "";
    imageloading = false;
  }

  @override
  void dispose() {
    takepicture = false;
    savepicture = false;
    progress = 0;
    imagefilepath = '';

    createActivityScreenController.description_.text = '';
    selectedTime = TimeOfDay.now();
    sleeptime_ = null;
    super.dispose();
    imageUrl = "";
    descriptionplus = "";
    imageloading = false;
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Create Activity' // '${widget.name_}'
                ,
                style: TextStyle(fontSize: 14, color: Colors.amberAccent),
              ),
            ],
          ),
          backgroundColor: kprimary,
        ),
        bottomNavigationBar: Obx(
          () => createActivityScreenController.isLoading.value
              ? Center(child: const CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: kprimary, // Set the text color
                    elevation: 3, // Set the elevation (shadow) of the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          18.0), // Set the button's border radius
                    ),
                    padding: EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    if (widget.selectedBabies.isNotEmpty) {
                      if (savepicture) {
                        // Wait for image upload to complete
                        await uploadimagetocloudstorage(image);
                      } else {
                        // After image upload is successful, call addActivityfunction
                        await createActivityScreenController
                            .addActivityfunction(
                          context,
                          widget.selectedBabies,
                          (widget.selectedsubject_ != 'BiWeekly')
                              ? widget.selectedsubject_
                              : createActivityScreenController.subject_.text,
                          (widget.selectedsubject_ == 'BiWeekly' ||
                                  widget.selectedsubject_ == 'Activity' ||
                                  widget.selectedsubject_ == 'Notes')
                              ? createActivityScreenController.activity_.text
                              : dropdownValue,
                          (widget.selectedsubject_ != 'BiWeekly')
                              ? '${createActivityScreenController.description_.text} ${descriptionplus}'
                              : '${createActivityScreenController.description_.text}',
                          imageUrl ?? "",
                          sleeptime_ ??
                              DateFormat('HH:mm').format(DateTime.now()),
                          (widget.selectedsubject_ != 'BiWeekly')
                              ? 'DailySheet'
                              : 'BiWeekly',
                        );
                      }
                    }
                  },
                  child: Text(
                    'Create Activity',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ImageSlideShowfunction(context),
              Container(
                height: mQ.height * 0.03,
                color: Colors.grey[50],
                width: mQ.width * 0.9,
                // padding:mQ ,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Expanded(child: SizedBox(width: mQ.width * 0.5,)),
                    Expanded(
                      child: Text(
                        '  ${subject}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.right,
                        ' ${getCurrentDateforattendance()}',
                        style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Comic Sans MS',
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ), // Activity name and date
              SizedBox(
                height: mQ.height * 0.002,
              ),

              Obx(
                () => createActivityScreenController.isLoadingInitial.value
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(left: 18, right: 18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [],
                              ),
                              (subject == 'Mood' ||
                                      subject == 'Activity' ||
                                      subject == 'Notes' ||
                                      subject == 'BiWeekly')
                                  ? Container()
                                  : Container(
                                      width: mQ.width * 0.9,
                                      alignment: Alignment.centerLeft,
                                      color: Colors.grey[50],
                                      child: TextButton(
                                        onPressed: () async {
                                          setState(() {
                                            timeupdated = true;
                                          });
                                          final TimeOfDay? time =
                                              await showTimePicker(
                                                  context: context,
                                                  initialTime: selectedTime ??
                                                      TimeOfDay.now(),
                                                  initialEntryMode:
                                                      TimePickerEntryMode.dial,
                                                  orientation:
                                                      Orientation.portrait,
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return MediaQuery(
                                                      data: MediaQuery.of(
                                                              context)
                                                          .copyWith(
                                                              alwaysUse24HourFormat:
                                                                  true),
                                                      child: child!,
                                                    );
                                                  });
                                          selectedTime = time!;
                                          sleeptime_ =
                                              selectedTime.format(context);
                                        },
                                        child: (timeupdated)
                                            ? Text(
                                                textAlign: TextAlign.left,
                                                'Select Time ${selectedTime.format(context)}',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'Comic Sans MS',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.blue),
                                              )
                                            : Text(
                                                'Select Time ${selectedTime.format(context)}',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'Comic Sans MS',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.blue),
                                              ),
                                      ),
                                    ),
                              SizedBox(
                                height: mQ.height * 0.006,
                              ),
                              (widget.selectedsubject_ == 'BiWeekly')
                                  ? Container(
                                      width: mQ.width * 0.9,
                                      child: BiWeeklyDropDown(mQ))
                                  : (widget.selectedsubject_ != 'Mood')
                                      ? (widget.selectedsubject_ ==
                                                  'Activity' ||
                                              widget.selectedsubject_ ==
                                                  'Notes')
                                          ?
                                          // Container()
                                          Container(
                                              width: mQ.width * 0.9,
                                              alignment: Alignment.centerLeft,
                                              color: Colors.grey[50],
                                              child: CustomTextField(
                                                enabled: true,
                                                controller:
                                                    createActivityScreenController
                                                        .activity_,
                                                inputType:
                                                    TextInputType.multiline,
                                                labelText: "Heading",
                                                validators: (String? value) {
                                                  if (value!.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            )
                                          : Container(
                                              width: mQ.width * 0.9,
                                              alignment: Alignment.centerLeft,
                                              color: Colors.grey[50],
                                              child: DropdownSearch<String>(
                                                popupProps: PopupProps.menu(
                                                  showSelectedItems: true,
                                                  disabledItemFn: (String s) =>
                                                      s.startsWith('I'),
                                                ),
                                                items: list,
                                                dropdownDecoratorProps:
                                                    DropDownDecoratorProps(
                                                  dropdownSearchDecoration:
                                                      InputDecoration(
                                                    labelText:
                                                        'Select ${widget.selectedsubject_} ${widget.selectedsubject_ == 'Toilet' || widget.selectedsubject_ == 'Sleep' || widget.selectedsubject_ == 'Health' ? 'remarks' : ''}',
                                                    // teacherAssignments[index][i],
                                                    hintText:
                                                        'Select ${widget.selectedsubject_} ${widget.selectedsubject_ == 'Toilet' || widget.selectedsubject_ == 'Sleep' || widget.selectedsubject_ == 'Health' ? 'remarks' : ''}',
                                                    // teacherAssignments[index][i],
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    dropdownValue = value!;
                                                  });
                                                },
                                                selectedItem: dropdownValue,
                                                // teacherAssignments[index][i],
                                              ),
                                            )
                                      : Container(),
                              SizedBox(
                                  height: mQ.height * 0.006,
                                  child: Container(
                                    color: Colors.white,
                                  )),
                              Container(
                                width: mQ.width * 0.9,
                                alignment: Alignment.centerLeft,
                                color: Colors.grey[50],
                                child: CustomTextField(
                                  enabled: true,
                                  controller: createActivityScreenController
                                      .description_,
                                  inputType: TextInputType.multiline,
                                  labelText: "Type Remarks (optional)",
                                  validators: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              (subject == 'Health')
                                  ? checkboxfunction(
                                      context, 'Recommended to consult the Dr.')
                                  : (subject == 'Toilet') &&
                                          (teachersClass_ == 'Infant' ||
                                              teachersClass_ == 'Toddler' ||
                                              teachersClass_ ==
                                                  'Play Group - I')
                                      ? checkboxfunction(
                                          context, 'Diaper Changed.')
                                      // : (subject == 'Sleep')
                                      // ? sleepFuntion(context)
                                      : (subject == 'Fluids')
                                          ? fluidsfunction(context)
                                          : (subject == 'Mood')
                                              ? moodfunction(context)
                                              : Container(),
                              SizedBox(
                                height: mQ.height * 0.01,
                              ),
                              SizedBox(
                                  height: mQ.height * 0.004,
                                  child: Container(
                                    color: Colors.white,
                                  )),
                              takepicture
                                  ? imageloading
                                      ? Container(
                                          width: mQ.width * 0.4,
                                          height: mQ.height * 0.2,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()))
                                      : Container(
                                          width: mQ.width * 0.4,
                                          height: mQ.height * 0.2,
                                          child: Image.file(
                                            File(imagefilepath),
                                            fit: BoxFit.fill,
                                          ))
                                  : Container(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  takepicture
                                      ? IconButton(
                                          icon: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('Upload Image'),
                                              Icon(Icons.camera_alt_outlined,
                                                  size: 30),
                                            ],
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3, horizontal: 3),
                                          onPressed: () async {
                                            await _imageActionSheet(
                                                context, subject!, mQ);
                                          },
                                        )
                                      : Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ));
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
                              savepicture = true;
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

  Future<void> getProfileImageFromCameraAndUpdate(BuildContext context,
      {VoidCallback? onStart, VoidCallback? onSuccess}) async {
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

  Future<void> getProfileImageFromStorageAndUpdate(BuildContext context,
      {VoidCallback? onStart, VoidCallback? onSuccess}) async {
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
        content: Text(
            '$permissionType permission is required. Please enable it in the app settings.'),
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
                  getProfileImageFromCameraAndUpdate(context);
                  Navigator.pop(context);
                },
                // contentPadding: EdgeInsets.symmetric(horizontal: 50)
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.image, color: Colors.cyan, size: 28),
                onPressed: () async {
                  getProfileImageFromStorageAndUpdate(context);
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
      savepicture = true;
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
    ToastContext().init(context);
    Toast.show(
      'Click on Create Activity to proceed!',
      // Get.context,
      duration: 5, backgroundRadius: 2,
      backgroundColor: Colors.lightBlueAccent,
      // gravity: Toast.top,
    );
  }

  uploadimagetocloudstorage(imagefile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final file = File(imagefile.path);
    final metadata = SettableMetadata(contentType: "image/jpeg");
    final filename = "images/ ${babyid}${DateTime.now()}";
    final uploadTask = storageRef.child(filename).putFile(file, metadata);
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          ToastContext().init(context);
          Toast.show(
            'Photo is uploading,  ${progress?.toStringAsFixed(2)}%',
            // Get.context,
            duration: 5, backgroundRadius: 2,
            //gravity: Toast.top,
          );
          break;
        case TaskState.paused:
          ToastContext().init(context);
          Toast.show(
            'Upload is Paused,  ${progress?.toStringAsFixed(2)}%',
            // Get.context,
            duration: 5, backgroundRadius: 2,
            backgroundColor: Colors.black26,
            //gravity: Toast.top,
          );
          // print("Upload is paused.");
          break;
        case TaskState.canceled:
          ToastContext().init(context);
          Toast.show('Upload was cancelled',
              // Get.context,
              duration: 5,
              backgroundRadius: 2,
              backgroundColor: Colors.redAccent
              //gravity: Toast.top,
              );
          print("Upload was canceled");
          break;
        case TaskState.error:
          ToastContext().init(context);
          Toast.show('Error uploading',
              // Get.context,
              duration: 10,
              backgroundRadius: 2,
              backgroundColor: Colors.redAccent
              //gravity: Toast.top,
              );
          // Handle unsuccessful uploads
          break;
        case TaskState.success:
          // Handle successful uploads on complete
          // ...
          imageUrl = await storageRef.child(filename).getDownloadURL();
          setState(() {
            imageloading = false;
            imagedownloading = true;
            ToastContext().init(context);
            Toast.show('Photo Uploaded Successfully',
                // Get.context,
                duration: 5,
                backgroundRadius: 5,
                backgroundColor: kprimary //gravity: Toast.top,
                );
          });
          await createActivityScreenController.addActivityfunction(
            context,
            widget.selectedBabies,
            (widget.selectedsubject_ != 'BiWeekly')
                ? widget.selectedsubject_
                : createActivityScreenController.subject_.text,
            (widget.selectedsubject_ == 'BiWeekly' ||
                    widget.selectedsubject_ == 'Activity' ||
                    widget.selectedsubject_ == 'Notes')
                ? createActivityScreenController.activity_.text
                : dropdownValue,
            (widget.selectedsubject_ != 'BiWeekly')
                ? '${createActivityScreenController.description_.text} ${descriptionplus}'
                : '${createActivityScreenController.description_.text}',
            imageUrl ?? "",
            sleeptime_ ?? DateFormat('HH:mm').format(DateTime.now()),
            (widget.selectedsubject_ != 'BiWeekly') ? 'DailySheet' : 'BiWeekly',
          );

          break;
      }
    });
  }

  int _groupValue = -1;
  Widget _myRadioButton({title, value, onChanged}) {
    return RadioListTile(
      contentPadding: EdgeInsets.all(0),
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(title),
    );
  }

  Widget _myRadioButtonMood({title, value, onChanged}) {
    return RadioListTile(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  sleepFuntion(context) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 20,
          ),
          InkWell(
            onTap: () {
              descriptionplus =
                  createActivityScreenController.description_.text;
              createActivityScreenController.description_.text = dropdownValue!;
              dropdownValue = "Nap Start";
            }, // Handle the click event
            child: Wrap(
              children: [
                Text('Nap Start'),
                Icon(
                  Icons.bedtime,
                  color: Colors.green[600],
                  size: 26,
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              descriptionplus =
                  createActivityScreenController.description_.text;
              createActivityScreenController.description_.text = dropdownValue!;
              dropdownValue = "Wake up";
            }, // Handle the click event
            child: Wrap(
              children: [
                Text('Wake up'),
                Icon(
                  Icons.sunny_snowing,
                  color: Colors.red[600],
                  size: 26,
                )
              ],
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ]);
  }

  bool isChecked = false;
  checkboxfunction(context, title) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.blue;
    }

    return Row(children: [
      Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith(getColor),
        value: isChecked,
        onChanged: (bool? value) {
          setState(() {
            isChecked = value!;
            (isChecked) ? descriptionplus = title : descriptionplus = "";
          });
        },
      ),
      Text(title)
    ]);
  }

  fluidsfunction(context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '   Select Quantitity',
            style: TextStyle(color: Colors.blue),
          ),
          Row(
            children: [
              Expanded(
                child: _myRadioButton(
                  title: "All.",
                  value: 0,
                  onChanged: (newValue) => setState(() => (
                        _groupValue = newValue,
                        descriptionplus = "Quantity: All"
                      )),
                ),
              ),
              Expanded(
                child: _myRadioButton(
                  title: "Most.",
                  value: 1,
                  onChanged: (newValue) => setState(() => (
                        _groupValue = newValue,
                        descriptionplus = "Quantity: Most"
                      )),
                ),
              ),
              Expanded(
                child: _myRadioButton(
                  title: "Some.",
                  value: 2,
                  onChanged: (newValue) => setState(() => (
                        _groupValue = newValue,
                        descriptionplus = "Quantity: Some"
                      )),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _myRadioButton(
                  title: "None.",
                  value: 3,
                  onChanged: (newValue) => setState(() => (
                        _groupValue = newValue,
                        descriptionplus = "Quantity: None"
                      )),
                ),
              ),
              Expanded(
                child: _myRadioButton(
                  title: "NA.",
                  value: 4,
                  onChanged: (newValue) =>
                      setState(() => (_groupValue = newValue)),
                ),
              ),
              Expanded(child: Text('')),
            ],
          ),
        ]);
  }

  moodfunction(context) {
    dropdownValue = ''; // descriptionplus = '';
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        // textBaseline: TextBaseline.ideographic,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(
              child: _myRadioButtonMood(
                title: "Happy 😁",
                value: 0,
                onChanged: (newValue) => setState(() =>
                    (_groupValue = newValue, descriptionplus = "Happy 😁")),
              ),
            ),
            Expanded(
              child: _myRadioButtonMood(
                title: "Sleep 😴",
                value: 1,
                onChanged: (newValue) => setState(() =>
                    (_groupValue = newValue, descriptionplus = "Sleep 😴")),
              ),
            ),
          ]),
          Row(children: [
            Expanded(
              child: _myRadioButtonMood(
                title: "Grupmy 😣",
                value: 2,
                onChanged: (newValue) => setState(() =>
                    (_groupValue = newValue, descriptionplus = "Grupmy 😣")),
              ),
            ),
            Expanded(
              child: _myRadioButtonMood(
                title: "Sick 🤢",
                value: 3,
                onChanged: (newValue) => setState(() =>
                    (_groupValue = newValue, descriptionplus = "Sick 🤢")),
              ),
            ),
          ]),
          Row(children: [
            Expanded(
              child: _myRadioButtonMood(
                title: "Sad 🥺",
                value: 4,
                onChanged: (newValue) => setState(
                    () => (_groupValue = newValue, descriptionplus = "Sad 🥺")),
              ),
            ),
            Expanded(
              child: _myRadioButtonMood(
                title: "Shy 😊",
                value: 5,
                onChanged: (newValue) => setState(
                    () => (_groupValue = newValue, descriptionplus = "Shy 😊")),
              ),
            ),
          ]),
          Row(
            children: [
              Expanded(
                child: _myRadioButtonMood(
                  title: "Playful 😂",
                  value: 6,
                  onChanged: (newValue) => setState(() => (
                        _groupValue = newValue,
                        descriptionplus = "Playfull 😂"
                      )),
                ),
              ),
            ],
          ),
        ]);
  }

  selectlist() {
    switch (widget.selectedsubject_) {
      case 'Activity':
        takepicture = true;
        // list = [
        //   // 'Select ${widget.selectedsubject_}',
        //   '',
        //   'Fun Time',
        //   'Play Time',
        //   'Study Time',
        //   'Games',
        //   'Observation',
        //   'Other'
        // ];
        break;
      case 'Health':
        takepicture = true;
        list = [
          // 'Select ${widget.selectedsubject_} remarks',
          '',
          'Baby was little disturbed today.',
          'Baby is having nappy rashes.',
          'Baby is having Fever.',
          'Baby is having Flu.',
          'Baby is having Cough.',
          'Baby is having Colic Pain.',
          'Baby is having stomach disturbance.',
          'Medicine.',
          'Other'
        ];
        break;
      case 'Fluids':
        takepicture = true;
        list = [
          // 'Select ${widget.selectedsubject_}',
          '',
          'Water',
          'Milk',
          'Juice',
          'Other'
        ];
        break;
      case 'Food':
        takepicture = true;
        list = [
          // 'Select ${widget.selectedsubject_}',
          '',
          'Break Fast',
          'Lunch',
          'Dinner',
          'Other'
        ];
        break;
      case 'Sleep':
        takepicture = false;
        list = [
          // 'Select ${widget.selectedsubject_} remarks',
          '',
          'Baby was having sound sleep',
          'Baby was having a short Nap',
          'Baby was having distributed',
          'Nap Start',
          'Wake up',
          'Other'
        ];
        break;
      case 'Toilet':
        takepicture = false;
        list = [
          // 'Select ${widget.selectedsubject_} remarks',
          '',
          'Used Toilet',
          'Pee',
          'Potty',
          'Other'
        ];
        break;
      case 'Supplies':
        takepicture = false;
        list = [
          // 'Select ${widget.selectedsubject_}',
          '',
          'Cloths',
          'Diapers',
          'Socks',
          'Towel',
          'Soap',
          'Shampoo',
          'Toys',
          'Anti Rashing Cream',
          'Feeder (Bottle)',
          'Stroller',
          'Baby Bib',
          'Feeding Cup',
          'Baby Spoon with Bowl',
          'Other'
        ];
        break;
      case 'Notes':
        takepicture = false;
      // list = [
      //   // 'Select ${widget.selectedsubject_} remarks',
      //   '',
      //   'Baby enjoyed his day.',
      //   "Baby's day was full of smiles.",
      //   'Had tons of fun with toys.',
      //   'Quite Comfortable.',
      //   'Baby was relaxed.',
      //   'Other'
      // ];
      // break;
    }
  }

  BiWeeklyDropDown(mQ) {
    CollectionReference collectionReferenceBiweekly =
        FirebaseFirestore.instance.collection('Consent');
    return Container(
      width: mQ.width * 0.9,
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
          stream: collectionReferenceBiweekly
              .where('category_', isEqualTo: 'BiWeekly')
              .where('class_', isEqualTo: teachersClass_)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: CircularProgressIndicator(),
                ),
              ); // Show loading indicator
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<DropdownMenuItem> biweekltitems = [];

            final biweeklys = snapshot.data!.docs.reversed.toList();

            for (var biweekly in biweeklys)
              biweekltitems.add(DropdownMenuItem(
                value: biweekly.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      '${biweekly['subject_']}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${biweekly['description_']}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    Divider(
                      // Add a separator line
                      color: Colors.grey[50],
                      height: 8, // Adjust the height as needed
                    ),
                  ],
                ),
              )
                  //   DropdownMenuItem(
                  //   value: biweekly.id,
                  //   child: Text('${biweekly['subject_']} - ${biweekly['title_']} - ${biweekly['description_']}',
                  //     textAlign:TextAlign.left ,
                  //     style: TextStyle(
                  //         fontSize: 10,
                  //         fontWeight: FontWeight.normal,
                  //         color: Colors.black),
                  //   ),
                  // ),
                  );
            return Column(children: [
              DropdownButtonFormField(
                  iconSize: mQ.height * 0.025,
                  items: biweekltitems,
                  hint: Text("Select BiWeekly Activity"),
                  // hint: biweekltitems.first,
                  onChanged: (biWeeklyvalue) async {
                    isloadingBiweekly = false;
                    final DocumentSnapshot _dataStream = await FirebaseFirestore
                        .instance
                        .collection('Consent')
                        .doc(biWeeklyvalue)
                        .get();
                    createActivityScreenController.description_.text =
                        _dataStream.get('description_');
                    createActivityScreenController.subject_.text =
                        _dataStream.get('subject_');
                    createActivityScreenController.activity_.text =
                        _dataStream.get('title_');

                    // showBiWeeklyDialog(biWeeklyvalue,context,selectedbabyid_);
                  }),
              Container(
                color: Colors.grey[200],
                child: CustomTextField(
                  enabled: false,
                  controller: createActivityScreenController.subject_,
                  inputType: TextInputType.text,
                  labelText: "Subject",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                color: Colors.grey[200],
                child: CustomTextField(
                  enabled: false,
                  controller: createActivityScreenController.activity_,
                  inputType: TextInputType.text,
                  labelText: "Topic / Title",
                  validators: (String? value) {
                    if (value!.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ]);
          }),
    );
  }
}
