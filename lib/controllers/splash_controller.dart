import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/auth/login.dart';
import 'package:kids_republik/screens/main_tabs.dart';
import 'package:kids_republik/select_campus.dart';

class SplashController extends GetxController {
  final isLogged = false.obs;
  RxString name = ''.obs;
  RxString email = ''.obs;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection(users);

  @override
  void onInit() {
    Future.delayed(Duration(seconds: 2)).then((val) {
      pickInitialdata();
    });
    super.onInit();
  }

  Future pickInitialdata() async {
    await checkConnectivityAndProceed();
    // checkconnecntivity();
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.delayed(Duration(seconds: 2)).then((val) {
        Get.off(LoginScreen());
      });
      // Get.offAndToNamed(AppRoutes.home);
    } else {
      try {
        DocumentSnapshot userSnapshot =
            await usersCollection.doc(user.email).get();
        table_ = '';
        await setcollectionnames(table_);
        if (!userSnapshot.exists) {
          table_ = 'tsn_';
          await setcollectionnames(table_);
        userSnapshot =
          await
          FirebaseFirestore.instance.collection('tsn_users')
              .doc(user.email)
              .get();
        }
        if (userSnapshot.exists) {
          final data = userSnapshot.data() as Map<String, dynamic>;
          name.value = data['full_name'] ?? '';
          email.value = data['email'] ?? '';
          useremail = data['email'] ?? '';
          role_ = data['role'] ?? '';
          userImage_ = data['userImage'] ?? '';
          // Safely read class from either "class" or "class_" or default to empty
          teachersClass_ = (data['class'] ?? data['class_'] ?? '') as String;
        }

      } catch (e) {
        print('Error fetching user data: $e');
      }
      role_ == 'Director'? Get.to(CampusSelectionScreen()):

      Get.off(MainTabs());
    }
  }

  Future<void> checkConnectivityAndProceed() async {
    // Check internet connection with singleton (no custom values allowed)
    await execute(InternetConnectionChecker());

    // Create customized instance which can be registered via dependency injection
    final InternetConnectionChecker customInstance =
    InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 1),
      checkInterval: const Duration(seconds: 1),
    );

    // Check internet connection with created instance
    await executeAndWait(customInstance);

    // Continue with the rest of your code here
    // ToastContext().init(Context);
    // Toast.show("Internet connection available. Proceeding...");
  }

  Future<void> executeAndWait(InternetConnectionChecker internetConnectionChecker) async {
    Completer<void> completer = Completer<void>();

    final StreamSubscription<InternetConnectionStatus> listener =
    internetConnectionChecker.onStatusChange.listen(
          (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.disconnected:
          // Internet connection is lost
          // You can handle this case as needed
            break;
          case InternetConnectionStatus.connected:
          // Internet connection is back, you can add any logic here
          // Check if the completer is not completed before completing it
            if (!completer.isCompleted) {
              completer.complete();
            }
            break;
        }
      },
    );

    // Wait until the completer is completed, i.e., until the internet connection is available
    await completer.future;
  }

// Your existing execute function remains unchanged
  Future<void> execute(InternetConnectionChecker internetConnectionChecker) async {
    final StreamSubscription<InternetConnectionStatus> listener =
    internetConnectionChecker.onStatusChange.listen(
          (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
          // Internet connection is back, you can add any logic here
            break;
          case InternetConnectionStatus.disconnected:
          // Internet connection is lost
          // You can handle this case as needed
            break;
        }
      },
    );

  }

}
