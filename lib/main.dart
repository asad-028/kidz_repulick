import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:kids_republik/firebase_options.dart';
import 'package:kids_republik/screens/splash.dart';

String? role_ = '';
String? useremail;
String? userImage_;
String? teachersClass_ = '';
bool isloadingDate = false;
bool isloadingBiweekly = true;
RxBool isloadingPage = true.obs;
String? imageUrl;
final classes_ = <String>['Infant', 'Toddler', 'Kinder Garten - I', 'Kinder Garten - II', 'Play Group - I', 'Delete', 'Update'];
String? sleeptime_ = '${TimeOfDay.now().hour} : ${TimeOfDay.now().minute}';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FlutterDownloader.initialize(); // Initialize flutter_downloader

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kidz Republik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent).copyWith(background: Colors.blue[50]),
      ),
      home: SplashScreen(),
    );
  }
}
