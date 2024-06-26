import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/bi_weekly/biweekly_report_principal.dart';
import 'package:toast/toast.dart';

import '../../utils/const.dart';
import '../../utils/getdatefunction.dart';
import '../../utils/image_slide_show.dart';
import '../consent/parent_consent_screen.dart';
import '../dailysheet/parent_report/daily_report_shape.dart';
import '../kids/widgets/empty_background.dart';
import '../reminder/reminderstoparent.dart';
import '../widgets/base_drawer.dart';

Color color = Colors.red;

class ParentHomeScreen extends StatefulWidget {
  ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final collectionReference = FirebaseFirestore.instance.collection('BabyData');
  final collectionReferenceActivity = FirebaseFirestore.instance.collection('Activity');
  User? user = FirebaseAuth.instance.currentUser;
  // final collectionReferenceActivity = FirebaseFirestore.instance.collection('Activity');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      drawer: BaseDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Home',
          style: TextStyle(fontSize: 14, color: kWhite),
        ),
        backgroundColor: kprimary,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          ImageSlideShowfunction(context),
          SingleChildScrollView(
              child: Column(children: [
            SizedBox(
              height: 10,
            ),
            Container(
              color: kprimary.withOpacity(0.3),
              width: mQ.width * 0.99,
              child: Text("${role_}'s Dashboard", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              color: Colors.indigoAccent.withOpacity(0.15),
              width: mQ.width * 0.95,
              child: Text("My Kids", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            // Text('My Kids', textAlign: TextAlign.center),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.1, horizontal: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: collectionReference
                    .where('fathersEmail', isEqualTo: useremail)
                    // 'Todlers' )
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

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return EmptyBackground(
                      title: 'No student is registered for ${user?.email} account',
                    ); // No data
                  }

                  // Data is available, build the list
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 0.5, top: 0.5),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      );
                    },
                    primary: false,
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final childData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      fetchAndDisplayActivities(snapshot.data!.docs[index].id);

                      return Container(
                        height: 98,
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl: childData['picture'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.fill,
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Image.asset(
                                      'assets/staff.jpg',
                                      width: 50,
                                      // MediaQuery.of(context).size.width * 0.12,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${childData['childFullName']}  ${childData['fathersName']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '${childData['checkin']}',
                                        style: TextStyle(
                                          // fontWeight: FontWeight.bold,
                                          color: Colors.black87.withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                                consentbadges(
                                  mQ,
                                  "Waiting",
                                  snapshot.data!.docs[index].id,
                                  "Reminder",
                                  IconButton(
                                    onPressed: () {
                                      Get.to(ParentReminderScreen(
                                        babyid_: snapshot.data!.docs[index].id,
                                      ));
                                    },
                                    icon: Icon(
                                      Icons.notifications,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                checkforwardedreportsandshowbadge(
                                  mQ, 'Approved',
                                  snapshot.data!.docs[index].id, 'DailySheet',
                                  // buildCard(mQ, 'Daily', Icons.notifications),
                                  buildCard(mQ, 'Daily', Icons.calendar_today, () {
                                    Get.to(DailyReportShape(
                                      babyID_: snapshot.data!.docs[index].id,
                                      name_: childData['childFullName'],
                                      date_: getCurrentDate(),
                                      class_: childData['class_'],
                                      childPicture_: childData['picture'],
                                      reportType_: 'Approved',
                                    ));
                                  }),
                                ),
                                checkforwardedreportsandshowbadge(
                                    mQ,
                                    'Approved',
                                    snapshot.data!.docs[index].id,
                                    "BiWeekly",
                                    buildCard(
                                      mQ,
                                      'Bi Weekly',
                                      Icons.calendar_view_week,
                                      () {
                                        Get.to(() => BiWeeklyReportPrincipalScreen(
                                              babyID_: snapshot.data!.docs[index].id,
                                              name_: childData['childFullName'],
                                              date_: getCurrentDate(),
                                              class_: childData['class_'],
                                              babypicture_: childData['picture'],
                                            ));
                                      },
                                    )),
                                consentbadges(
                                    mQ,
                                    "Waiting",
                                    snapshot.data!.docs[index].id,
                                    "Consent",
                                    buildCard(
                                      mQ,
                                      'Consents',
                                      Icons.assignment,
                                      () {
                                        Get.to(ParentConsentScreen(
                                          babyid: snapshot.data!.docs[index].id,
                                        ));
                                      },
                                    )),
                              ],
                            ),
                            // status
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ]))
        ]),
      ),
    );
  }

  Widget buildCard(Size mQ, String title, IconData icon, Function() param3) {
    Color cardColor;
    switch (title) {
      case 'Notifications':
        cardColor = Colors.blue[50]!; // Example color
        break;
      case 'Consents':
        cardColor = Colors.green[50]!; // Example color
        break;
      case 'Daily':
        cardColor = Colors.teal[100]!; // Example color
        break;
      case 'Bi Weekly':
        cardColor = Colors.purple[50]!; // Example color
        break;
      default:
        cardColor = Colors.grey; // Default color
        break;
    }

    return InkWell(
      onTap: param3,
      child: Card(
        elevation: 1,
        color: cardColor,
        child: Container(
          width: title == 'Notifications' ? mQ.width * 0.160 : mQ.width * 0.260,
          height: 25,
          // width: mQ.width * 0.20,
          // height: mQ.height * 0.045,
          padding: EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 14), // Set icon color to white
              SizedBox(width: 2),
              Text(
                title == 'Notifications' ? "" : title,
                style: TextStyle(
                    color: Colors.black, // Set text color to white
                    fontWeight: FontWeight.normal,
                    fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget checkforwardedreportsandshowbadge(mQ, status, babyid_, category_, Widget pppasa) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: collectionReferenceActivity
            .where('id', isEqualTo: babyid_)
            .where('date_', isEqualTo: getCurrentDate().toString())
            .where('category_', isEqualTo: category_)
            // .where('status_',isEqualTo:status)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: CircularProgressIndicator(),
              ),
            ); // Show loading indicator
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {}
          return badges.Badge(
            position: badges.BadgePosition.topEnd(top: 1, end: 0),
            badgeAnimation: badges.BadgeAnimation.slide(
              disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
              curve: Curves.easeInCubic,
            ),
            showBadge: (snapshot.data!.docs.length > 0),
            badgeStyle: badges.BadgeStyle(
              badgeColor: color,
            ),
            badgeContent: Text(
              snapshot.data!.docs.length.toString(),
              style: TextStyle(fontSize: 8, color: Colors.white),
            ),
            child: pppasa,
          );
        },
      ),
    );
  }

  // Function to fetch and display activities
  void fetchAndDisplayActivities(String babyId) {
    // Assuming you have a reference to your Firestore collection
    collectionReferenceActivity
        .where('id', isEqualTo: babyId)
        .where('date_', isEqualTo: getCurrentDate().toString())
        .where('Subject', isEqualTo: "Attendance")
        .where('status_', isEqualTo: "Approved")
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          Map<String, dynamic> activityData = doc.data();

          // Display the activity information using Toast
          DateTime parsedTime = DateTime.parse(activityData['time_']);
          String formattedTime = DateFormat.jm().format(parsedTime);
          showToast(
            ' ${activityData['description']} at ${formattedTime}',
          );
          await Future.delayed(Duration(seconds: 5));
        }
      }
      // else {
      //   showToast('No activities found for the current baby and date.');
      // }
    });
  }

// Function to show a Toast message
  void showToast(String message) {
    ToastContext().init(context);
    Toast.show(
      message,
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
    );
  }

  Widget consentbadges(mQ, status, babyid_, category, Widget pppasa) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: collectionReferenceActivity
            .where('child_', isEqualTo: babyid_)
            .where('category_', isEqualTo: category)
            .where('parentid_', isEqualTo: useremail)
            .where('result_', isEqualTo: status)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: CircularProgressIndicator(),
              ),
            ); // Show loading indicator
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // _showCartBadge = false;
          }
// setState(() {
//             _cartBadgeAmount=
//                 snapshot.data!.docs.length;
          // _showCartBadge = (snapshot.data!.docs.length > 0);
// });
          return badges.Badge(
            position: badges.BadgePosition.topEnd(top: 1, end: 0),
            badgeAnimation: badges.BadgeAnimation.slide(
              disappearanceFadeAnimationDuration: Duration(milliseconds: 100),
              curve: Curves.easeInCubic,
            ),
            showBadge: (snapshot.data!.docs.length > 0),
            badgeStyle: badges.BadgeStyle(
              badgeColor: color,
            ),
            badgeContent: Text(
              snapshot.data!.docs.length.toString(),
              style: TextStyle(fontSize: 8, color: Colors.white),
            ),
            child: pppasa,
          );
        },
      ),
    );
  }
}
