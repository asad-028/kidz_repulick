import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/bank_account_controller.dart';
import 'package:kids_republik/firebase_options.dart';
import 'package:kids_republik/postman_api/api_services.dart';
import 'package:kids_republik/screens/splash.dart';
import 'package:upgrader/upgrader.dart';
String? role_ = '';
String? table_ = '';
String? useremail ;
String? userImage_ ;
String? teachersClass_ = '';
bool isloadingDate = false;
bool isloadingBiweekly = true;
User? user ;
String users = 'users';
String accounts = 'accounts';
String Activity = 'Activity';
String Reports = 'Reports';
String BabyData = 'BabyData';
String invitation_codes = 'invitation_codes';
String Consent = 'Consent';
String bank_details = 'bank_details';
String ClassRoom = 'ClassRoom';
RxBool isloadingPage = true.obs;
final ApiService apiService = ApiService(
  baseUrl: 'https://app.kidzrepublik.com.pk/api/public/api/upload',
  apiKey: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvYXBpL2F1dGgvbG9naW4iLCJpYXQiOjE3MjIzMjcwNTYsImV4cCI6MTcyMjMzMDY1NiwibmJmIjoxNzIyMzI3MDU2LCJqdGkiOiJ5aVNVNW82WHdtc1NiMU9lIiwic3ViIjoiMSIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.9541rBIhnF_wdus3Pq5mr9xv45yHzRenDjq-G1KlhdE',
);
String? imageUrl ;
final classes_  =<String> [ 'Infant', 'Toddler','Play Group - I', 'Kinder Garten - I', 'Kinder Garten - II',  'Delete', 'Update'];
String?
sleeptime_ = '${TimeOfDay.now().hour} : ${TimeOfDay.now().minute}';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FlutterDownloader.initialize() ; // Initialize flutter_downloader
  runApp(const MyApp());
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Little Diary',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(BankAccountController());
      }),
      // routes: {
      //   '/':(context) => SelectCampusScreen(),
      //   '/webViewContainer': (context) => WebVeiwContainer(),
      // },
      theme: ThemeData(
        useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent).copyWith(background: Colors.blue[50]),
      ),
      home:  UpgradeAlert(
          upgrader: Upgrader(

          ),
          child: SplashScreen ()),
    );
  }

}
setcollectionnames(String? table_){
  users = '${table_}users';
  ClassRoom = '${table_}ClassRoom';
  accounts = '${table_}accounts';
  Activity = '${table_}Activity';
  Reports = '${table_}Reports';
  BabyData = '${table_}BabyData';
  invitation_codes = '${table_}invitation_codes';
  Consent = '${table_}Consent';
  // bank_details remains 'bank_details' (no prefix)
  if (Get.isRegistered<BankAccountController>()) {
    Get.find<BankAccountController>().fetchDetails();
  }
}

