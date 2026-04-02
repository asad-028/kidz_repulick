import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/main.dart';
import '../../utils/const.dart';
import '../../utils/getdatefunction.dart';
import '../../utils/image_slide_show.dart';
import '../../utils/updateclassstrength.dart';
import '../kids/widgets/empty_background.dart';

bool saveCheckIn = false;
var classData;

class CheckinCheckoutScreen extends StatefulWidget {
  final activityclass_;
  CheckinCheckoutScreen({required this.activityclass_, super.key});

  @override
  State<CheckinCheckoutScreen> createState() => _CheckinCheckoutScreenState();
}

class _CheckinCheckoutScreenState extends State<CheckinCheckoutScreen> {
  final collectionReference = FirebaseFirestore.instance.collection(BabyData);
  final collectionReferenceActivity =
      FirebaseFirestore.instance.collection(Activity);
  final collectionReferenceReports =
      FirebaseFirestore.instance.collection(Reports);
  final collectionReferenceClass =
      FirebaseFirestore.instance.collection(ClassRoom);

  @override
  void initState() {
    super.initState();
    (role_ == "Director" || role_ == "Principal" || role_ == "Manager")
        ? teachersClass_ = widget.activityclass_
        : null;
  }

  Widget _buildAttendanceSummary(Size mQ, String attendanceclass_) {
    return StreamBuilder<QuerySnapshot>(
      stream: collectionReferenceClass
          .where("class_", isEqualTo: attendanceclass_)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 80, child: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final attendanceData =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;
        UpdateClassRoomStrength(teachersClass_!, context);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Class Statistics",
                    style: k16bold.copyWith(color: kprimary),
                  ),
                  Text(
                    getCurrentDateforattendance(),
                    style: k12500.copyWith(color: kGrey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    Icons.people_alt,
                    "Total",
                    "${(attendanceData['present_'] ?? 0) + (attendanceData['absent_'] ?? 0)}",
                    kprimary,
                  ),
                  _buildSummaryItem(
                    Icons.check_circle,
                    "Present",
                    "${attendanceData['present_'] ?? 0}",
                    kSuccessColor,
                  ),
                  _buildSummaryItem(
                    Icons.cancel,
                    "Absent",
                    "${attendanceData['absent_'] ?? 0}",
                    kRedColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: k16bold.copyWith(color: color)),
        Text(label, style: k12500.copyWith(color: kGrey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: grey100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: kprimary),
        title: Text(
          'Class ${teachersClass_}',
          style: k16bold.copyWith(color: kprimary),
        ),
        backgroundColor: kWhite,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ImageSlideShowfunction(context),
                _buildAttendanceSummary(mQ, widget.activityclass_),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: kprimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Student List",
                        style: k16bold.copyWith(color: kprimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: collectionReference
                      .where('class_', isEqualTo: widget.activityclass_)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: EmptyBackground(
                          title:
                              'No students assigned to ${widget.activityclass_}',
                        ),
                      );
                    }

                    return ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final childData = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        return _buildStudentCard(snapshot, index, childData);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(AsyncSnapshot<QuerySnapshot> snapshot, int index,
      Map<String, dynamic> childData) {
    final status = childData['checkin'] ?? "Not Reported";
    final isCheckedIn = status == 'Checked In';
    final isAbsent = status == 'Absent';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      color: kWhite,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: grey100,
                border: Border.all(color: kprimary.withOpacity(0.1), width: 1),
              ),
              child: ClipOval(
                child: (childData['picture'] != null &&
                        childData['picture'].isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: childData['picture'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.person, color: kGreyColor),
                      )
                    : Icon(Icons.person, color: kGreyColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    childData['childFullName'] ?? "Unknown",
                    style: k14500.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Father: ${childData['fathersName'] ?? "N/A"}",
                    style: k12500.copyWith(color: kGrey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCheckedIn
                          ? kSuccessLightColor
                          : isAbsent
                              ? kWarningLightColor
                              : kInfoLightColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isCheckedIn
                            ? kSuccessColor
                            : isAbsent
                                ? kWarningColor
                                : kInfoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.login,
                  color: kSuccessColor,
                  onTap: () => _showConfirmationDialog(
                      snapshot, index, childData, "Checked In", context),
                  isActive: !isCheckedIn,
                  tooltip: "Check In",
                ),
                _buildActionButton(
                  icon: Icons.logout,
                  color: kRedColor,
                  onTap: () => _showConfirmationDialog(
                      snapshot, index, childData, "Checked Out", context),
                  isActive: isCheckedIn,
                  tooltip: "Check Out",
                ),
                _buildActionButton(
                  icon: Icons.person_off,
                  color: kWarningColor,
                  onTap: () => _showConfirmationDialog(
                      snapshot, index, childData, "Absent", context),
                  isActive: !isCheckedIn && !isAbsent,
                  tooltip: "Absent",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isActive,
    required String tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: IconButton(
        onPressed: isActive ? onTap : null,
        icon: Icon(icon, size: 22),
        color: color,
        disabledColor: kGreyColor.withOpacity(0.3),
        tooltip: tooltip,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

void _showConfirmationDialog(
    snapshot, index, childData, status_, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Do you want to proceed with this action?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text('Proceed'),
            onPressed: () async {
              Get.back();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => Center(
                  child: CircularProgressIndicator(),
                ),
              );

              await checkinsavefunction(snapshot, index, childData, status_);

              Get.back();
            },
          ),
        ],
      );
    },
  );
}

checkinsavefunction(snapshot, index, childData, attendancestatus_) async {
  var date_ = getCurrentDate();

  // Optimized: Use batch operations to reduce Firebase writes
  final batch = FirebaseFirestore.instance.batch();

  // Add activity document
  final activityRef = collectionReferenceActivity.doc();
  batch.set(activityRef, {
    "id": snapshot.data!.docs[index].id,
    "Subject": "Attendance",
    "Activity": attendancestatus_,
    "date_": date_,
    "time_": DateFormat('HH:mm:a').format(DateTime.now()),
    "image_": imageUrl,
    "description": (attendancestatus_ == 'Absent')
        ? "${childData['childFullName']} is absent today"
        : "${childData['childFullName']} has ${attendancestatus_}",
    "status_": "Approved",
    "category_": "DailySheet"
  });

  // Update child checkin status
  batch.update(collectionReference.doc(snapshot.data!.docs[index].id),
      {"checkin": attendancestatus_});

  // Update class attendance counts
  final classRef = collectionReferenceClass.doc(childData['class_']);
  if (attendancestatus_ == 'Checked In') {
    batch.update(classRef, {
      'present_': FieldValue.increment(1),
      'absent_': FieldValue.increment(-1)
    });
  } else {
    batch.update(classRef, {
      'present_': FieldValue.increment(-1),
      'absent_': FieldValue.increment(1)
    });
  }

  // 4. Update reports document (optimized: single read, then batch write)
  try {
    final reportDocRef =
        collectionReferenceReports.doc(snapshot.data!.docs[index].id);
    final reportDoc = await reportDocRef.get();
    final docDate = reportDoc.data()?['date_'] ?? 'No Record';

    if (docDate == date_) {
      // Update existing document
      batch.update(
          reportDocRef, {"DailySheet_Approved": FieldValue.increment(1)});
    } else {
      // Set new document with all fields at once
      batch.set(reportDocRef, {
        "id": snapshot.data!.docs[index].id,
        "date_": date_,
        "DailySheet_New": 0,
        "DailySheet_Forwarded": 0,
        "DailySheet_Approved": 1,
        "BiWeekly_New": 0,
        "BiWeekly_Forwarded": 0,
        "Photos_New": 0,
        "Photos_Forwarded": 0,
        "Photos_Approved": 0,
      });
    }

    // Commit all operations atomically (reduces from 4-5 separate writes to 1 batch write)
    await batch.commit();
  } catch (error) {
    print('Error in batch operation: $error');
    // Consider showing error to user
  }
// launchWhatsApp(childData['fathersMobileNo'],
//     (attendancestatus_ == "Absent") ?
//     "${childData['childFullName']} is absent today" :
//     "${childData['childFullName']} has ${attendancestatus_}"
// );
}
// launchWhatsApp(to, message) async {
//   final link = WhatsAppUnilink(
//     phoneNumber: to, // Replace with the recipient's phone number
//     text: message,
//
//   );
//   // await launchUrl(link.asUri());
// }
}
