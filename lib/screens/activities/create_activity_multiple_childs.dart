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
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[50], // Soft background
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kWhite),
        title: Text(
          'Create Activity',
          style: const TextStyle(
              fontSize: 18, color: kWhite, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kprimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                DateFormat('MMM dd, yyyy').format(DateTime.now()),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => createActivityScreenController.isLoading.value
                ? const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kprimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      if (widget.selectedBabies.isNotEmpty) {
                        if (savepicture) {
                          await uploadimagetocloudstorage(image);
                        } else {
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
                                : createActivityScreenController
                                    .description_.text,
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
                    child: const Text(
                      'Create Activity',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Info Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              decoration: BoxDecoration(
                color: kprimary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  ImageSlideShowfunction(context),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          subject ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Obx(
              () => createActivityScreenController.isLoadingInitial.value
                  ? const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time Picker Card (if applicable)
                          if (!(subject == 'Mood' ||
                              subject == 'Activity' ||
                              subject == 'Notes' ||
                              subject == 'BiWeekly'))
                            _buildCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.access_time_filled,
                                    color: kprimary),
                                title: const Text('Activity Time',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(selectedTime?.format(context) ??
                                    'Select Time'),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 14),
                                onTap: () async {
                                  final TimeOfDay? time = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        selectedTime ?? TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      selectedTime = time;
                                      sleeptime_ = selectedTime.format(context);
                                      timeupdated = true;
                                    });
                                  }
                                },
                              ),
                            ),

                          if (!(subject == 'Mood' ||
                              subject == 'Activity' ||
                              subject == 'Notes' ||
                              subject == 'BiWeekly'))
                            const SizedBox(height: 16),

                          // Activity Content Card
                          _buildCard(
                            title: 'Activity Details',
                            child: Column(
                              children: [
                                if (widget.selectedsubject_ == 'BiWeekly')
                                  BiWeeklyDropDown(mQ)
                                else if (widget.selectedsubject_ ==
                                        'Activity' ||
                                    widget.selectedsubject_ == 'Notes')
                                  CustomTextField(
                                    enabled: true,
                                    controller: createActivityScreenController
                                        .activity_,
                                    inputType: TextInputType.multiline,
                                    labelText: "Heading",
                                    validators: (String? value) =>
                                        value == null || value.isEmpty ? 'Required' : null,
                                  )
                                else if (widget.selectedsubject_ != 'Mood')
                                  DropdownSearch<String>(
                                    popupProps: PopupProps.menu(
                                      showSelectedItems: true,
                                      disabledItemFn: (s) => s.startsWith('I'),
                                    ),
                                    items: list,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText:
                                            'Select ${widget.selectedsubject_} Remarks',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        dropdownValue = value!;
                                      });
                                    },
                                    selectedItem: dropdownValue,
                                  ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  enabled: true,
                                  controller: createActivityScreenController
                                      .description_,
                                  inputType: TextInputType.multiline,
                                  labelText: "Type Remarks (optional)",
                                  validators: (String? value) =>
                                      value == null || value.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Special Inputs (Mood, Fluids, etc.)
                          if (subject == 'Health' ||
                              subject == 'Toilet' ||
                              subject == 'Fluids' ||
                              subject == 'Mood' ||
                              subject == 'Sleep')
                            _buildCard(
                              title: subject == 'Mood'
                                  ? 'Current Mood'
                                  : 'Additional Info',
                              child: _buildSpecialInputs(),
                            ),

                          if (subject == 'Health' ||
                              subject == 'Toilet' ||
                              subject == 'Fluids' ||
                              subject == 'Mood' ||
                              subject == 'Sleep')
                            const SizedBox(height: 16),

                          // Media Section
                          _buildCard(
                            title: 'Attachments',
                            child: Column(
                              children: [
                                if (takepicture) ...[
                                  if (imageloading)
                                    const CircularProgressIndicator()
                                  else if (imagefilepath.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(imagefilepath),
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () => _imageActionSheet(
                                        context, subject!, mQ),
                                    icon: const Icon(Icons.camera_alt),
                                    label: Text(imagefilepath.isEmpty
                                        ? 'Upload Photo'
                                        : 'Change Photo'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: kprimary,
                                      side: BorderSide(color: kprimary),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ] else
                                  const Text(
                                      'No photo attachment required for this activity.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildSpecialInputs() {
    if (subject == 'Health') {
      return checkboxfunction(context, 'Recommended to consult the Dr.');
    } else if (subject == 'Toilet') {
      if (teachersClass_ == 'Infant' ||
          teachersClass_ == 'Toddler' ||
          teachersClass_ == 'Play Group - I') {
        return checkboxfunction(context, 'Diaper Changed.');
      } else {
        return toiletfunction(context);
      }
    } else if (subject == 'Sleep') {
      return sleepFuntion(context);
    } else if (subject == 'Fluids') {
      return fluidsfunction(context);
    } else if (subject == 'Mood') {
      return moodfunction(context);
    }
    return Container();
  }

  // Adding a missing toilet function to improve the Toilet subject selection
  Widget toiletfunction(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Toilet Activity',
            style: TextStyle(
                color: kprimary, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Pee', 'Potty', 'Used Toilet'].map((type) {
            final isSel = dropdownValue == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSel,
              onSelected: (val) {
                setState(() {
                  dropdownValue = type;
                });
              },
              selectedColor: kprimary.withOpacity(0.2),
              labelStyle: TextStyle(color: isSel ? kprimary : Colors.black87),
            );
          }).toList(),
        ),
      ],
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
      await camerainitialize();

      _controller = CameraController(
        firstCamera!,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller.initialize();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopScope(
              canPop: false,
              onPopInvoked: (didPop) async {
                if (didPop) return;
                await _controller.dispose();
                Navigator.of(context).pop();
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
    if (result == null) {
      if (mounted) {
        setState(() {
          imageloading = false;
        });
      }
      return;
    }

    final file = result.files.first;
    imagefilepath = result.files.first.path!;

    // _openFile(file);
    if (mounted) {
      setState(() {
        image = file;
        savepicture = true;
        imageloading = false;
      });
    }
  }

  loadimagefunction(result) async {
    if (mounted) {
      setState(() {
        imageloading = false;
      });
    }
    if (context.mounted) {
      ToastContext().init(context);
      Toast.show(
        'Click on Create Activity to proceed!',
        duration: 5,
        backgroundRadius: 2,
        backgroundColor: Colors.lightBlueAccent,
      );
    }
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
          if (!mounted) return;
          progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          ToastContext().init(context);
          Toast.show(
            'Photo is uploading,  ${progress?.toStringAsFixed(2)}%',
            duration: 5, backgroundRadius: 2,
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
          if (!mounted) return;
          imageUrl = await storageRef.child(filename).getDownloadURL();
          if (mounted) {
            setState(() {
              imageloading = false;
              imagedownloading = true;
              ToastContext().init(context);
              Toast.show('Photo Uploaded Successfully',
                  duration: 5,
                  backgroundRadius: 5,
                  backgroundColor: kprimary);
            });
          }
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

  Widget sleepFuntion(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sleep Activity',
            style: TextStyle(
                color: kprimary, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionChip(
                label: 'Nap Start',
                icon: Icons.bedtime,
                color: Colors.indigo,
                isSelected: dropdownValue == 'Nap Start',
                onTap: () {
                  setState(() {
                    descriptionplus =
                        createActivityScreenController.description_.text;
                    dropdownValue = 'Nap Start';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionChip(
                label: 'Wake up',
                icon: Icons.wb_sunny,
                color: Colors.orange,
                isSelected: dropdownValue == 'Wake up',
                onTap: () {
                  setState(() {
                    descriptionplus =
                        createActivityScreenController.description_.text;
                    dropdownValue = 'Wake up';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[600], size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isChecked = false;
  Widget checkboxfunction(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: kprimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        value: isChecked,
        activeColor: kprimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onChanged: (bool? value) {
          setState(() {
            isChecked = value!;
            descriptionplus = isChecked ? title : "";
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget fluidsfunction(BuildContext context) {
    final quantities = ["All", "Most", "Some", "None", "NA"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quantity Drunk',
            style: TextStyle(
                color: kprimary, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: quantities.map((q) {
            final isSel = descriptionplus == "Quantity: $q" ||
                (q == 'NA' && _groupValue == 4);
            return ChoiceChip(
              label: Text(q),
              selected: isSel,
              onSelected: (val) {
                setState(() {
                  if (q == 'NA') {
                    _groupValue = 4;
                    descriptionplus = "";
                  } else {
                    _groupValue = quantities.indexOf(q);
                    descriptionplus = "Quantity: $q";
                  }
                });
              },
              selectedColor: kprimary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSel ? kprimary : Colors.black87,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget moodfunction(BuildContext context) {
    final moods = [
      {'label': 'Happy', 'emoji': '😁', 'color': Colors.amber},
      {'label': 'Sleep', 'emoji': '😴', 'color': Colors.indigo},
      {'label': 'Grumpy', 'emoji': '😣', 'color': Colors.red},
      {'label': 'Sick', 'emoji': '🤢', 'color': Colors.green},
      {'label': 'Sad', 'emoji': '🥺', 'color': Colors.blue},
      {'label': 'Shy', 'emoji': '😊', 'color': Colors.pink},
      {'label': 'Playful', 'emoji': '😂', 'color': Colors.orange},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        final isSelected =
            descriptionplus == "${mood['label']} ${mood['emoji']}";
        return InkWell(
          onTap: () {
            setState(() {
              descriptionplus = "${mood['label']} ${mood['emoji']}";
              _groupValue = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? (mood['color'] as Color).withOpacity(0.15)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? (mood['color'] as Color) : Colors.grey[200]!,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(mood['emoji'] as String,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  mood['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? (mood['color'] as Color)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                    if (value == null || value.isEmpty) {
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
                    if (value == null || value.isEmpty) {
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
