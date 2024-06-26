// ignore_for_file: unnecessary_const

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kids_republik/controllers/splash_controller.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/auth/change_password.dart';
import 'package:kids_republik/screens/auth/data_deletion_page.dart';
import 'package:kids_republik/screens/auth/login.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

CameraDescription? firstCamera;
double? progress;
bool imageloading = false;
// FilePicker? imagefile;
String imagefilepath = '';

class BaseDrawer extends StatefulWidget {
  @override
  _BaseDrawerState createState() => _BaseDrawerState();
}

class _BaseDrawerState extends State<BaseDrawer> {
  final collectionReference = FirebaseFirestore.instance.collection('users');
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool imagedownloading = false;
  camerainitialize() async {
    final cameras = await availableCameras();
    firstCamera = cameras.first;
  }

  User? user = FirebaseAuth.instance.currentUser;
  final SplashController controller = Get.put(SplashController());

  bool logoutbool = false;

  Future<bool> _onLogoutPressed() async {
    messageAllert('Do you want to logout?', 'Logout!');
    return true;
  }

  messageAllert(String msg, String ttl) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return CupertinoAlertDialog(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(ttl),
              ),
              content: Text(msg),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: logoutbool
                      ? const CircularProgressIndicator()
                      : Column(
                          children: const <Widget>[
                            Text('Yes'),
                          ],
                        ),
                  onPressed: () {
                    setState(() {
                      logoutbool = true;
                    });

                    signOut();
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Column(
                    children: const <Widget>[
                      Text('No'),
                    ],
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            );
          });
        });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Navigate to the login screen or any other screen you desire
      Get.offAll(LoginScreen());
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    final Uri toLaunch = Uri(scheme: 'https', host: 'sites.google.com\\view', path: 'kidzrepublikprivacy');
    return Drawer(
        child: ListView(
      children: [
        UserAccountsDrawerHeader(
            accountName: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0),
              child: Text(
                controller.name.value,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: drawerkPrimaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            accountEmail: Text(
              controller.email.value,
            ),
            currentAccountPicture: IconButton(
              icon: CircleAvatar(
                radius: 63,
                backgroundColor: kprimary,
                backgroundImage: NetworkImage(userImage_!),
              ),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
              onPressed: () async {
                _imageActionSheet(context, controller.name.value, mQ);
              },
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            leading: const Icon(Iconsax.eye, color: Colors.blueGrey, size: 20),
            minLeadingWidth: 16,
            title: const Text(
              'Change Password',
              style: TextStyle(fontSize: 15),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Get.to(ChangePasswordScreen());
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
              leading: const Icon(Iconsax.people, color: Colors.blueGrey, size: 20),
              minLeadingWidth: 16,
              title: const Text('Privacy Policy', style: TextStyle(fontSize: 15)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                // _launchAsInAppWebViewWithCustomHeaders(toLaunch);
                _launchUrl();
              }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
              leading: const Icon(Iconsax.share, color: Colors.blueGrey, size: 20),
              minLeadingWidth: 16,
              title: const Text('Share app', style: TextStyle(fontSize: 15)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                _onShare(context, 'Website: https://kidzrepublik.com.pk/ \n\n ');
              }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: const Divider(
            height: 15,
            color: Colors.blueGrey,
            thickness: 0.3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
              leading: const Icon(Iconsax.profile_delete, color: Colors.red, size: 20),
              minLeadingWidth: 16,
              title: const Text('Delete User Data', style: TextStyle(fontSize: 15)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                Get.to(DataDeletionPage());
              }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: const Divider(
            height: 15,
            color: Colors.blueGrey,
            thickness: 0.3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            leading: const Icon(Iconsax.logout, color: Colors.blueGrey, size: 20),
            minLeadingWidth: 16,
            title: const Text('Logout', style: TextStyle(fontSize: 15)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: _onLogoutPressed,
          ),
        ),
      ],
    ));
  }

  Future<void> _launchAsInAppWebViewWithCustomHeaders(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void _launchUrl() async {
    ToastContext().init(context);

    Toast.show(
      " Updated: 30 May, 2024",
      // Get.context,
      backgroundRadius: 5,
      //gravity: Toast.top,
    );

    if (!await launchUrl(Uri.parse('https://sites.google.com/view/kidzrepublikprivacy'))) throw 'Could not launch ';
  }

  void _onShare(BuildContext context, String identifier) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(identifier,
        // subject: subject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
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

  Future<void> _imageActionSheet2(
    BuildContext context,
    String title,
  ) async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      print("This is DeniedPremission");
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

  Future<void> _imageActionSheet(BuildContext context, String title, mQ) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          Text("Take ${title} Picture"),
          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                title: Text(
                  'Camera',
                  style: TextStyle(fontSize: 10),
                ),
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.purple,
                  size: 20,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  getProfileImageFromCameraAndUpdate(context);
                },
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  'Gallery',
                  style: TextStyle(fontSize: 10),
                ),
                leading: Icon(Icons.image, color: Colors.cyan, size: 20),
                onTap: () async {
                  Navigator.pop(context);
                  getProfileImageFromStorageAndUpdate(context);
                },
              ),
            ),
          ]),
        ]);
      },
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

  uploadimagetocloudstorage(imagefileP) async {
    final storageRef = FirebaseStorage.instance.ref();
    final file = File(imagefileP.path);
    final metadata = SettableMetadata(contentType: "image/jpeg");
    final filename = "images/user/${controller.name.value}${DateTime.now()}";
    final uploadTask = storageRef.child(filename).putFile(file, metadata);
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          progress = 100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
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
          saveuserimage(storageRef, filename, imageUrl);
          userImage_ = imageUrl;

          break;
      }
      print(imageUrl);
      //     print(imageUrl);
      // print(imageUrl);
    });
  }

  saveuserimage(storageRef, filename, imageUrl) async {
    // print(imageUrl);

    await collectionReference.doc(controller.email.value).update({"userImage": imageUrl});
    // print(imageUrl);
    ToastContext().init(context);
    Toast.show(
      'Photo updated successfully',
      // Get.context,
      duration: 5, backgroundRadius: 5,
      //gravity: Toast.top,
    );
    Navigator.pop(context);
  }

  Future<void> checkconnecntivity() async {
    // Check internet connection with singleton (no custom values allowed)
    await execute(InternetConnectionChecker());

    // Create customized instance which can be registered via dependency injection
    final InternetConnectionChecker customInstance = InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 1),
      checkInterval: const Duration(seconds: 1),
    );

    // Check internet connection with created instance
    await execute(customInstance);
  }

  Future<void> execute(
    InternetConnectionChecker internetConnectionChecker,
  ) async {
    ToastContext().init(context);
    Toast.show('''Internet Connection is : ''', backgroundRadius: 5, gravity: Toast.center, backgroundColor: Colors.blue);
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    // ignore: avoid_print
    ToastContext().init(context);
    Toast.show(isConnected ? 'device is connected with internet' : 'device is not connected', backgroundRadius: 5, gravity: Toast.center, backgroundColor: Colors.blue);
    // returns a bool

    // We can also get an enum instead of a bool
    // ignore: avoid_print
    ToastContext().init(context);
    Toast.show('Current status: ${await InternetConnectionChecker().connectionStatus}', backgroundRadius: 5, gravity: Toast.center, backgroundColor: Colors.blue);
    // Prints either InternetConnectionStatus.connected
    // or InternetConnectionStatus.disconnected

    // actively listen for status updates
    final StreamSubscription<InternetConnectionStatus> listener = InternetConnectionChecker().onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            // ignore: avoid_print
            ToastContext().init(context);
            Toast.show(
                // isConnected?'device is connected with internet':'device is not connected'
                'Data connection is available.',
                backgroundRadius: 5,
                gravity: Toast.center,
                backgroundColor: Colors.green);
            break;
          case InternetConnectionStatus.disconnected:
            // ignore: avoid_print
            ToastContext().init(context);
            Toast.show('You are disconnected from the internet.', backgroundRadius: 5, gravity: Toast.center, backgroundColor: Colors.red);
            break;
        }
      },
    );

    // close listener after 30 seconds, so the program doesn't run forever
    await Future<void>.delayed(const Duration(seconds: 30));
    await listener.cancel();
  }
}
