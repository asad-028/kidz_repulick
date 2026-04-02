import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/activities/select_childs_for_activity.dart';
import 'package:kids_republik/screens/activities/view_bi_weekly_activities.dart';
import 'package:kids_republik/screens/widgets/base_drawer.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/image_slide_show.dart';

import 'checkin_checkout_screen.dart';

class TeacherHomeSelectActivityScreen extends StatefulWidget {
  final teachersclass;
  const TeacherHomeSelectActivityScreen(
      {required this.teachersclass, super.key});

  @override
  State<TeacherHomeSelectActivityScreen> createState() =>
      _TeacherHomeSelectActivityScreenState();
}

class _TeacherHomeSelectActivityScreenState
    extends State<TeacherHomeSelectActivityScreen> {
  bool deleteionLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: BaseDrawer(),
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
          'Teacher Dashboard',
          style: TextStyle(
            color: kWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SlideShow Section with rounded corners
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Container(
                color: kprimary,
                padding: const EdgeInsets.only(bottom: 20),
                child: ImageSlideShowfunction(context),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dashboard Card
                  _buildDashboardCard(),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Class Activities',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.grey[800],
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _buildActionCard(
                          'Check In',
                          'checkin.png',
                          () => Get.to(CheckinCheckoutScreen(
                              activityclass_: teachersClass_))),
                      _buildActionCard(
                          'Check Out',
                          'checkout.png',
                          () => Get.to(CheckinCheckoutScreen(
                              activityclass_: teachersClass_))),
                      _buildActionCard(
                          'Food', 'food.png', () => _toActivity('Food')),
                      _buildActionCard(
                          'Fluids', 'fluids.png', () => _toActivity('Fluids')),
                      _buildActionCard(
                          'Toilet', 'toilet.png', () => _toActivity('Toilet')),
                      _buildActionCard(
                          'Sleep', 'sleep.png', () => _toActivity('Sleep')),
                      _buildActionCard(
                          'Health', 'health.png', () => _toActivity('Health')),
                      _buildActionCard('Activity', 'activity.png',
                          () => _toActivity('Activity')),
                      _buildActionCard(
                          'Notes', 'notes.png', () => _toActivity('Notes')),
                      _buildActionCard(
                          'Mood', 'mood.png', () => _toActivity('Mood')),
                      _buildActionCard('BiWeekly', 'biweekly.png',
                          () => _toActivity('BiWeekly')),
                      _buildActionCard('Add Activity', 'addactivityteacher.png',
                          () => Get.to(ViewBiweeklyActivities())),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toActivity(String subject) {
    Get.to(SelectChildsForActivity(
        activityclass_: widget.teachersclass, selectedsubject_: subject));
  }

  Widget _buildDashboardCard() {
    return Card(
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
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: kprimary.withOpacity(0.1),
                  radius: 24,
                  child: Icon(Icons.school_rounded, color: kprimary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Class Overview',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Teacher  •  ${widget.teachersclass}",
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
                  "Today: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}",
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
    );
  }

  Widget _buildActionCard(String title, String image, VoidCallback onTap) {
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
                'assets/$image',
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
    );
  }
}
