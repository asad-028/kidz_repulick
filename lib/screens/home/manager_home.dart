import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/accounts/manager_accounts_home.dart';
import 'package:kids_republik/screens/activities/view_bi_weekly_activities.dart';
import 'package:kids_republik/screens/consent/parent_consent_screen.dart';
import 'package:kids_republik/screens/home/checkin_checkout_screen.dart';
import 'package:kids_republik/screens/home/teacher_management.dart';
import 'package:kids_republik/screens/kids/assign_class_to_child_screen.dart';
import 'package:kids_republik/screens/kids/registration_form.dart';
import 'package:kids_republik/screens/reminder/reminderstoparent.dart';
import 'package:kids_republik/screens/widgets/base_drawer.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:kids_republik/utils/image_slide_show.dart';
import '../activities/select_childs_for_activity.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  CollectionReference collectionReferenceClass =
      FirebaseFirestore.instance.collection(ClassRoom);

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: BaseDrawer(),

      /// ✅ Gradient AppBar
      appBar: AppBar(
        elevation: 0,
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
        title: const Text(
          'Manager Dashboard',
          style: TextStyle(
            color: kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(color: Colors.grey[50]),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Slideshow
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ImageSlideShowfunction(context),
                ),

                SizedBox(height: mQ.height * 0.014),

                /// ✅ Overview Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.blue.shade50.withOpacity(0.3)
                        ],
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
                              child: Icon(
                                Icons.manage_accounts_rounded,
                                color: kprimary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Manager Overview',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "Manager  •  ${table_ == 'tsn_' ? "TSN" : 'KRDC'}",
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
                            Icon(Icons.calendar_today_rounded,
                                size: 16, color: Colors.blue.shade700),
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

                /// ✅ Attendance Snapshot
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics_rounded,
                                color: Colors.blue.shade700, size: 20),
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
                          child: Row(
                            children: [
                              _buildAttendanceLegend(mQ),
                              const SizedBox(width: 12),
                              classSummary(mQ, "Infant", Colors.amber[50]),
                              const SizedBox(width: 8),
                              classSummary(mQ, "Toddler", Colors.green[50]),
                              const SizedBox(width: 8),
                              classSummary(
                                  mQ, "Play Group - I", Colors.pink[50]),
                              const SizedBox(width: 8),
                              classSummary(
                                  mQ, "Kinder Garten - I", Colors.blue[50]),
                              const SizedBox(width: 8),
                              classSummary(
                                  mQ, "Kinder Garten - II", Colors.indigo[50]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Quick Actions Title
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

                /// ✅ Modern Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    _buildActionCard('manager/registration.png',
                        'Register Child', () => Get.to(RegistrationForm())),
                    _buildActionCard(
                        'manager/students.png',
                        'Assign Class',
                        () => Get.to(AssignClassToChildren(
                            selectedclass_: 'All Classes'))),
                    _buildActionCard('manager/staff.png', 'Staff',
                        () => Get.to(TeacherManagementScreen())),
                    _buildActionCard('manager/biweekly1.png', 'Biweekly',
                        () => Get.to(ViewBiweeklyActivities())),
                    _buildActionCard('manager/consent.png', 'Consent',
                        () => Get.to(ParentConsentScreen(babyid: 'null'))),
                    _buildActionCard(
                        'manager/reminder1.png',
                        'Reminders',
                        () => Get.to(
                            ParentReminderScreen(babyid_: "All Reminders"))),
                  ],
                ),

                const SizedBox(height: 24),

                /// ✅ Premium Accounts Button
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
                      onPressed: () => Get.to(ManagerAccountsHomeScreen()),
                      icon: const Icon(Icons.bar_chart_rounded,
                          size: 22, color: Colors.white),
                      label: const Text(
                        'Manager Accounts',
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

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Attendance Legend
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
          _legendItem('Enrolled', Colors.blue),
          _legendItem('Present', Colors.green),
          _legendItem('Absent', Colors.red),
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
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget classSummary(Size mQ, String class_, Color? color) {
    return FutureBuilder<DocumentSnapshot>(
      future: collectionReferenceClass.doc(class_).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final data = snapshot.data!;

        return Container(
          width: mQ.width * 0.22,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(data.id,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 6),
              _dataRow(data['strength_'].toString(), Colors.blue),
              _dataRow(data['present_'].toString(), Colors.green),
              _dataRow(data['absent_'].toString(), Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _dataRow(String value, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }

  Widget _buildActionCard(String imagePath, String title, VoidCallback onTap) {
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
        child: Center(
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
                  'assets/$imagePath',
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
