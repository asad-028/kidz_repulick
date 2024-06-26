import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kids_republik/screens/auth/manager_user_management.dart';
import 'package:kids_republik/screens/home/principal_home.dart';
import 'package:kids_republik/screens/home/teacher_home_select_activity_screen.dart';
import 'package:kids_republik/screens/kids/assign_class_to_child_screen.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/parent_photos_slideshow.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:toast/toast.dart';

import '../main.dart';
import 'dailysheet/manager_report/manager_report_select_child.dart';
import 'home/checkin_checkout_screen.dart';
import 'home/manager_home.dart';
import 'home/parent_home_screen.dart';
import 'kids/widgets/empty_background.dart';

class MainTabs extends StatefulWidget {
  MainTabs();

  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  var _currentIndex = 0;

  buildScreen() {
    switch (role_) {
      case 'Director':
        switch (_currentIndex) {
          case 0:
            return PrincipalHomeScreen();
          case 1:
            return AssignClassToChildren(selectedclass_: 'All Classes');
            // return TeacherHomeChild(activityclass_: teachersClass_);
          case 2:
            return ManagerReportSelectChild(reportstatus_: 'Approved');
        }
      case 'Principal':
        switch (_currentIndex) {
          case 0:
            return PrincipalHomeScreen();
            case 1:
            return AssignClassToChildren(selectedclass_: 'All Classes');
            case 2:
            return ManagerReportSelectChild(reportstatus_: 'Approved');
        }
      case 'Manager':
        switch (_currentIndex) {
          case 0:
            return ManagerHomeScreen();
          case 1:
            return AssignClassToChildren(selectedclass_: 'All Classes');
          case 2:
            return SelectUserOrInvitation();
            // return EmptyBackground(title: "");
        }
      case 'Teacher':
        switch (_currentIndex) {
          case 0:
            return TeacherHomeSelectActivityScreen(teachersclass: teachersClass_);
          case 1:
            return CheckinCheckoutScreen(activityclass_: teachersClass_);
          case 2:
            return ManagerReportSelectChild(reportstatus_: 'Forwarded');
        }
      case 'Parent':
        switch (_currentIndex) {
          case 0:
            return ParentHomeScreen();
          case 1:
            return ParentPhotoSlideshow(fatherEmail: useremail!,babyId: null,);
          case 2:
            return ManagerReportSelectChild(reportstatus_: 'Approved');
        }
      default:
        switch (_currentIndex) {
          case 0:
            // return PrincipalHomeScreen();
            return EmptyBackground(title: 'You have successfully Signed Up. Your account is pending for approval. Please click on logout button and try again later.');
          case 1:
            return EmptyBackground(title: 'You have successfully Signed Up. Your account is pending for approval. Please click on logout button and try again later.');
          case 2:
            return EmptyBackground(title: 'You have successfully Signed Up. Your account is pending for approval. Please click on logout button and try again later.');
        }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // checkconnecntivity();

    return Scaffold(
      body: buildScreen(),
      bottomNavigationBar: SalomonBottomBar(
        // backgroundColor: Color(0xFFD4E7E9),
        // backgroundColor: Color(0xC4E8E9),
        backgroundColor: kprimary,
        // Colors.teal[100],
        currentIndex: _currentIndex,
        margin: EdgeInsets.only(left: 30, right: 30, top: 8, bottom: 8),
        unselectedItemColor: Colors.white60,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.white,
          ),

          (role_ == "Parent")?SalomonBottomBarItem(
            icon: Icon(Icons.photo_size_select_actual),
            title: Text("Activities"),
            selectedColor: Colors.white,
          ):
          SalomonBottomBarItem(
            icon: Icon(Icons.school_outlined),
            title: Text("Class"),
            selectedColor: Colors.white,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.article_outlined),
            title: Text(role_== 'Manager'? "Users":"Reports"),
            selectedColor: Colors.white,
          ),

        ],
      ),
    );
  }

  Future<void> checkconnecntivity() async
  {
    // Check internet connection with singleton (no custom values allowed)
    await execute(InternetConnectionChecker());

    // Create customized instance which can be registered via dependency injection
    final InternetConnectionChecker customInstance =
    InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 1),
      checkInterval: const Duration(seconds: 1),
    );

    // Check internet connection with created instance
    await execute(customInstance);
  }

  Future<void> execute(InternetConnectionChecker internetConnectionChecker) async {
    final StreamSubscription<InternetConnectionStatus> listener =
    internetConnectionChecker.onStatusChange.listen(
          (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
          // Internet connection is back, you can add any logic here
          //   ToastContext().init(context);
          //   Toast.show(
          //     'You are back online.',
          //     backgroundRadius: 5,
          //     gravity: Toast.bottom,
          //     duration: Toast.lengthLong,
          //     backgroundColor: Colors.green,
          //   );
            break;
          case InternetConnectionStatus.disconnected:
          // Internet connection is lost
            ToastContext().init(context);
            Toast.show(
              ' ',textStyle: TextStyle(fontSize: 8),
              backgroundRadius: 5,
              gravity: Toast.top,
              duration: Toast.lengthLong,
              backgroundColor: Colors.red.shade100,
            );
            break;
        }
      },
    );

    // Don't cancel the listener
    // It will keep running until you explicitly cancel it

    // You can add additional logic here if needed, e.g., reconnect attempts

    // You may want to store the subscription so that you can cancel it when needed
    // await listener.cancel();
  }

}
