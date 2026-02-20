import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/accounts/manager_accounts_home.dart';
import 'package:kids_republik/screens/activities/select_childs_for_activity.dart';
import 'package:kids_republik/screens/activities/view_bi_weekly_activities.dart';
import 'package:kids_republik/screens/consent/parent_consent_screen.dart';
import 'package:kids_republik/screens/home/checkin_checkout_screen.dart';
import 'package:kids_republik/screens/home/home_user_management.dart';
import 'package:kids_republik/screens/home/teacher_management.dart';
import 'package:kids_republik/screens/widgets/base_drawer.dart';
import 'package:kids_republik/select_campus.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:kids_republik/utils/image_slide_show.dart';

import '../dailysheet/manager_report/manager_report_select_child.dart';
import '../reminder/reminderstoparent.dart';

final subject_ = <String>[
  'Check In',
  'Food',
  'Fluids',
  'Health',
  'Activity',
  'Check Out'
];

int strengthinclass = 0;
int presentinclass = 0;
int absentinclass = 0;
bool? setattendance_;
var attendanceData;

class PrincipalHomeScreen extends StatefulWidget {
  const PrincipalHomeScreen({super.key});

  @override
  State<PrincipalHomeScreen> createState() => _PrincipalHomeScreenState();
}

class _PrincipalHomeScreenState extends State<PrincipalHomeScreen> {
  CollectionReference collectionReferenceClass =
      FirebaseFirestore.instance.collection(ClassRoom);
  CollectionReference collectionReferenceActivity =
      FirebaseFirestore.instance.collection(Activity);
  CollectionReference collectionReferenceUsers =
      FirebaseFirestore.instance.collection(users);
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  Widget checkforwardedreportsandshowbadge(
      mQ, status, color, Widget displayonthis) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: collectionReferenceActivity
            .where('date_', isEqualTo: getCurrentDate().toString())
            .where('status_', isEqualTo: status)
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
            // No data or empty – just show the original child without a badge.
            return displayonthis;
          }

          return badges.Badge(
            position: badges.BadgePosition.topEnd(top: -2, end: -2),
            badgeAnimation: badges.BadgeAnimation.slide(
              disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
              curve: Curves.easeInCubic,
            ),
            showBadge: snapshot.data!.docs.isNotEmpty,
            badgeStyle: badges.BadgeStyle(
              badgeColor: color,
            ),
            badgeContent: Text(
              snapshot.data!.docs.length.toString(),
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
            child: displayonthis,
          );
        },
      ),
    );
  }

  Widget specialbadge(mQ, checkwhat, color, Widget displayonthis) {
    // QuerySnapshot checkwhat2 = checkwhat;

    return Padding(
        padding: const EdgeInsets.all(0.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: checkwhat.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: CircularProgressIndicator(),
                ),
              ); // Show loading indicator
            }

            if (snapshot.hasError) {
              // In case of error, just show the original child.
              return displayonthis;
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // No data or empty – just show the original child without a badge.
              return displayonthis;
            }

            return badges.Badge(
              position: badges.BadgePosition.topEnd(top: -10, end: -3),
              badgeAnimation: badges.BadgeAnimation.slide(
                disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
                curve: Curves.easeInCubic,
              ),
              showBadge: snapshot.data!.docs.isNotEmpty,
              badgeStyle: badges.BadgeStyle(
                badgeColor: color,
              ),
              badgeContent: Text(
                snapshot.data!.docs.length.toString(),
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              child: displayonthis,
            );
          },
        ));
  }

  @override
  void initState() {
    setcollectionnames(table_);

    super.initState();
//     _activitiesFuture = apiService.getAllActivities();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        drawer: BaseDrawer(),
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kprimary, kprimary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: kWhite),
          title: Text(
            role_ == 'Director' ? 'Campus Dashboard' : 'Principal Home',
            style: const TextStyle(
              color: kWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          actions: [
            if (role_ == 'Director')
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: () => Get.to(CampusSelectionScreen()),
                  icon: const Icon(Icons.location_city_rounded, color: Colors.white),
                  tooltip: 'Select Campus',
                ),
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ImageSlideShowfunction(context),
                      ),
                      SizedBox(height: mQ.height * 0.012),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        color: Colors.white,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: kprimary.withOpacity(0.1),
                                    radius: 24,
                                    child: Icon(Icons.person_rounded, color: kprimary, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          role_ == 'Director' ? 'Campus Overview' : 'Principal Dashboard',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          "${role_}  •  ${table_ == 'tsn_' ? "TSN" : 'KRDC'}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16, color: Colors.blue.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Today: ${getCurrentDate()}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: mQ.height * 0.014),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.analytics_rounded, color: Colors.blue.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Attendance Snapshot',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    _buildAttendanceLegend(mQ),
                                    const SizedBox(width: 12),
                                    classSummary(mQ, "Infant", Colors.amber[50]),
                                    const SizedBox(width: 8),
                                    classSummary(mQ, "Toddler", Colors.green[50]),
                                    const SizedBox(width: 8),
                                    classSummary(mQ, "Play Group - I", Colors.pink[50]),
                                    const SizedBox(width: 8),
                                    classSummary(mQ, "Kinder Garten - I", Colors.blue[50]),
                                    const SizedBox(width: 8),
                                    classSummary(mQ, "Kinder Garten - II", Colors.indigo[50]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: mQ.height * 0.014),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 1,
                        color: Colors.white.withOpacity(0.96),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Users Overview',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: mQ.width,
                                child: BadgeScreen(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                        children: [
                          _buildActionCard(
                            context,
                            'Users',
                            'useraccountsprincipal.png',
                            () => Get.to(UserManagementScreen()),
                            badge: specialbadge(
                              mQ,
                              collectionReferenceUsers
                                  .where('role', isEqualTo: '')
                                  .where('status', isNotEqualTo: 'Activate'),
                              Colors.red,
                              const SizedBox.shrink(),
                            ),
                          ),
                          _buildActionCard(
                            context,
                            'Teachers',
                            'teacherprincipal.png',
                            () => Get.to(TeacherManagementScreen()),
                          ),
                          _buildActionCard(
                            context,
                            'Reports',
                            'reportprincipal.png',
                            () => Get.to(ManagerReportSelectChild(reportstatus_: 'Approved')),
                            badge: checkforwardedreportsandshowbadge(
                              mQ,
                              (role_ == "Principal") ? "Forwarded" : "Approved",
                              (role_ == "Principal") ? Colors.blue : Colors.red,
                              const SizedBox.shrink(),
                            ),
                          ),
                          _buildActionCard(
                            context,
                            'Consent',
                            'consentprincipal.png',
                            () => Get.to(ParentConsentScreen(babyid: 'All Consents')),
                          ),
                          _buildActionCard(
                            context,
                            'Activities',
                            'addactivity.png',
                            () => Get.to(ViewBiweeklyActivities()),
                          ),
                          _buildActionCard(
                            context,
                            'Reminders',
                            'reminderprincipal.png',
                            () => Get.to(ParentReminderScreen(babyid_: "All Reminders")),
                          ),
                        ],
                      ),
                      if (role_ == "Director") ...[
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade200.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  Get.to(ManagerAccountsHomeScreen()),
                              icon: const Icon(Icons.bar_chart_rounded,
                                  size: 22, color: Colors.white),
                              label: const Text(
                                'Campus Accounts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2962FF),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildActionCard(BuildContext context, String title, String image, VoidCallback onTap, {Widget? badge}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/principal/$image',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: badge,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceLegend(Size mQ) {
    return Container(
      width: mQ.width * 0.22,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kprimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kprimary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: kprimary,
            ),
          ),
          const SizedBox(height: 8),
          _legendItem('Enrolled', Colors.blue.shade700),
          _legendItem('Present', Colors.green.shade700),
          _legendItem('Absent', Colors.red.shade700),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget BadgeScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(users).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        int teacherCount = 0;
        int parentCount = 0;
        int activateCount = 0;
        int blockCount = 0;

        users.forEach((user) {
          String role = user['role'];
          String status = user['status'];

          if (role == 'Teacher') {
            teacherCount++;
          } else if (role == 'Parent') {
            parentCount++;
          }

          if (status == 'Activate') {
            activateCount++;
          } else {
            blockCount++;
          }
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Teachers', teacherCount, Colors.indigo),
                _buildStatItem('Parents', parentCount, Colors.brown),
                _buildStatItem('Active', activateCount, Colors.teal),
                _buildStatItem('Blocked', blockCount, Colors.redAccent),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color.withOpacity(0.8),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget classSummary(mQ, class_, decorationcolor_) {
    return FutureBuilder<DocumentSnapshot>(
        future: collectionReferenceClass.doc(class_).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 80,
              height: 100,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Container(
              width: 80,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  class_,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final classData = snapshot.data!;
          final String title = (classData.id == 'Kinder Garten - I')
              ? 'KG-I'
              : (classData.id == 'Kinder Garten - II')
                  ? 'KG-II'
                  : (classData.id == 'Play Group - I')
                      ? 'PG-I'
                      : classData.id;

          final classCard = Container(
            width: mQ.width * 0.22,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: decorationcolor_,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: Colors.brown[900],
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _dataRow(classData['strength_'].toString(), Colors.blue.shade700),
                const SizedBox(height: 4),
                _dataRow(classData['present_'].toString(), Colors.green.shade700),
                const SizedBox(height: 4),
                _dataRow(classData['absent_'].toString(), Colors.red.shade700),
              ],
            ),
          );

          if (role_ == 'Director') return classCard;

          return PopupMenuButton<String>(
            tooltip: 'Class Actions',
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => subject_
                .map((item) =>
                    PopupMenuItem(value: item, child: Text(item)))
                .toList(),
            onSelected: (selectedItem) async {
              if (await confirm(
                context,
                title: const Text("Confirm Action"),
                content: Text("Proceed with $selectedItem for $title?"),
                textOK: const Text('Yes'),
                textCancel: const Text('No'),
              )) {
                if (selectedItem == 'Check In' ||
                    selectedItem == 'Check Out') {
                  Get.to(CheckinCheckoutScreen(activityclass_: class_));
                } else {
                  Get.to(SelectChildsForActivity(
                      activityclass_: class_,
                      selectedsubject_: selectedItem));
                }
              }
            },
            child: classCard,
          );
        });
  }

  Widget _dataRow(String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
// Assuming you have initialized Firebase and Firestore

  Future<void> updateApprovedActivities() async {
    try {
      final activitiesRef = FirebaseFirestore.instance.collection(Activity);
      final snapshot = await activitiesRef
          .where('biweeklystatus_', isEqualTo: 'Approved')
          .get();

      // if (snapshot.isEmpty) {
      //   print('No documents found to update.');
      //   return;
      // }

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'biweeklystatus_': 'Restored'});
      }

      await batch.commit();
      print('Approved activities updated successfully.');
    } catch (error) {
      print('Error updating documents: $error');
    }
  }
}
