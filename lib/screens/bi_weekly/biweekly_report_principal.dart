import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:snackbar/snackbar.dart';

import '../widgets/primary_button.dart';

bool isLoading = true;
bool showRecord = false;
List<String> dateRanges = []; // List to store date ranges
List<Map<String, dynamic>> dateRangeData = []; // List to store date range data
var selectedDateRange;
int checkedInCount = 0;
int absentCount = 0;
var selectedItemDocumentId;

final collectionReferencebabydata =
    FirebaseFirestore.instance.collection(BabyData);
final collectionReference = FirebaseFirestore.instance.collection(Activity);
final collectionReferenceReports =
    FirebaseFirestore.instance.collection(Reports);

class BiWeeklyReportPrincipalScreen extends StatefulWidget {
  final String babyID_;
  final String babypicture_;
  final String name_;
  final String date_;
  final String class_;

  BiWeeklyReportPrincipalScreen({
    Key? key,
    required this.babyID_,
    required this.name_,
    required this.date_,
    required this.class_,
    required this.babypicture_,
  }) : super(key: key);

  @override
  _BiWeeklyReportPrincipalScreenState createState() =>
      _BiWeeklyReportPrincipalScreenState();
}

class _BiWeeklyReportPrincipalScreenState
    extends State<BiWeeklyReportPrincipalScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dateRanges.clear();
    dateRangeData.clear();
    selectedDateRange = null;
    showRecord = false;
  }

  bool deleteionLoading = false;

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: grey100,
      bottomNavigationBar: _buildBottomActions(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(mQ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAttendanceSummary(mQ),
                  const SizedBox(height: 16),
                  _buildReportContent(mQ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size mQ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: mQ.height * 0.06, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: kprimary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kWhite, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                )
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.babypicture_,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                  color: kWhite,
                  strokeWidth: 2,
                )),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.person, size: 40, color: kWhite),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.name_,
            style: kMediumTitle.copyWith(color: kWhite),
          ),
          const SizedBox(height: 4),
          Text(
            'Bi-Weekly Report',
            style: k14500.copyWith(color: kWhite.withOpacity(0.9)),
          ),
          const SizedBox(height: 8),
          Text(
            '(Academic Session 2024-2025)',
            style: kGrey15500.copyWith(color: kWhite.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary(Size mQ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAttendanceItem(
                  Icons.check_circle_outline,
                  "Days Present",
                  checkedInCount.toString(),
                  kSuccessColor,
                ),
              ),
              Container(width: 1, height: 40, color: grey100),
              Expanded(
                child: _buildAttendanceItem(
                  Icons.cancel_outlined,
                  "Absent",
                  absentCount.toString(),
                  kRedColor,
                ),
              ),
              if (role_ == "Principal")
                IconButton(
                  onPressed: _showAttendanceUpdateDialog,
                  icon: Icon(Icons.edit_note, color: kprimary, size: 28),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: k12500.copyWith(color: kGrey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: k16bold.copyWith(color: color)),
      ],
    );
  }

  Widget _buildReportContent(Size mQ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(Activity)
          .where('child', isEqualTo: widget.babyID_)
          .where('category_', isEqualTo: 'BiWeeklyReport')
          .where("biweeklystatus_",
              isEqualTo: (role_ == 'Principal') ? "Forwarded" : "Approved")
          .orderBy('forwardDate', descending: true)
          .limit((role_ == 'Principal') ? 1 : 10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        var docs = snapshot.data!.docs;
        _updateDateRanges(docs);

        return Column(
          children: [
            _buildDateRangeSelector(mQ),
            const SizedBox(height: 16),
            _buildActivityStreams(mQ),
          ],
        );
      },
    );
  }

  void _updateDateRanges(List<QueryDocumentSnapshot> docs) {
    dateRanges.clear();
    dateRangeData.clear();
    for (var activity in docs) {
      var dateRange = activity['dateRange'];
      if (!dateRanges.contains(dateRange)) {
        dateRanges.add(dateRange);
        dateRangeData.add({
          'dateRange': dateRange,
          'checkedInCount': activity['checkedin'],
          'absentCount': activity['absent'],
          'documentId': activity.id,
        });
      }
    }
    selectedDateRange ??= dateRanges.first;
    final selectedData = dateRangeData.firstWhere(
      (element) => element['dateRange'] == selectedDateRange,
      orElse: () => {},
    );
    if (selectedData.isNotEmpty) {
      checkedInCount = selectedData['checkedInCount'];
      absentCount = selectedData['absentCount'];
      selectedItemDocumentId = selectedData['documentId'];
    }
  }

  Widget _buildDateRangeSelector(Size mQ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedDateRange,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: kprimary),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                selectedDateRange = newValue;
                final selectedData = dateRangeData.firstWhere(
                  (element) => element['dateRange'] == newValue,
                  orElse: () => {},
                );
                if (selectedData.isNotEmpty) {
                  checkedInCount = selectedData['checkedInCount'];
                  absentCount = selectedData['absentCount'];
                  selectedItemDocumentId = selectedData['documentId'];
                }
              });
            }
          },
          items: dateRanges.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: k14500),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityStreams(Size mQ) {
    return StreamBuilder<QuerySnapshot>(
      stream: collectionReference
          .where('id', isEqualTo: widget.babyID_)
          .where('BiWeeklyReport', isEqualTo: selectedDateRange)
          .where('category_', isEqualTo: 'BiWeekly')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No activities found for this period.'));
        }

        Map<String, List<Map<String, dynamic>>> groupedActivities = {};
        for (var activity in snapshot.data!.docs) {
          String subject = activity['Subject'];
          groupedActivities.putIfAbsent(subject, () => []);
          groupedActivities[subject]!.add({
            'id': activity.id,
            'Activity': activity['Activity'],
            'description': activity['description'],
            'biweeklystatus_': activity['biweeklystatus_'],
          });
        }

        return Column(
          children: groupedActivities.entries.map((entry) {
            return _buildActivityCard(entry.key, entry.value, mQ);
          }).toList(),
        );
      },
    );
  }

  Widget _buildActivityCard(
      String subject, List<Map<String, dynamic>> activities, Size mQ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kprimary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              subject,
              style:
                  k14500.copyWith(fontWeight: FontWeight.bold, color: kprimary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: activities.map((activity) {
                if (activity['biweeklystatus_'] != 'Approved' &&
                    role_ == 'Parent') {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity['Activity'],
                              style:
                                  k12500.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (role_ != "Parent")
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.edit_outlined,
                                  size: 18, color: kGrey),
                              onPressed: () => showEditingDialog(
                                activity['id'],
                                activity['Activity'],
                                activity['description'],
                                subject,
                                activity['biweeklystatus_'],
                              ),
                            ),
                          _buildStatusIcon(activity['biweeklystatus_']),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity['description'],
                        style: k12500.copyWith(color: kGrey),
                      ),
                      if (activities.indexOf(activity) != activities.length - 1)
                        const Divider(height: 24, thickness: 0.5),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    if (role_ == "Parent") return const SizedBox.shrink();

    switch (status) {
      case 'Approved':
        return const Icon(Icons.check_circle, color: kSuccessColor, size: 18);
      case 'Forwarded':
        return Icon(Icons.check_circle_outline, color: kprimary, size: 18);
      default:
        return Icon(Icons.radio_button_unchecked, color: grey100, size: 18);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: grey100),
            const SizedBox(height: 16),
            Text('No Bi-Weekly activities found.',
                style: k14500.copyWith(color: kGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    if (role_ == "Principal") {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: PrimaryButton(
          label: 'Approve Report',
          onPressed: () async {
            if (await confirm(context,
                title: const Text('Approve Report'),
                content: const Text('Do you want to approve this report?'))) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    const Center(child: CircularProgressIndicator()),
              );
              updateDocumentsWithStatusForwarded(
                  widget.babyID_, "Forwarded", "Approved", context);
            }
          },
        ),
      );
    }

    if (role_ == "Parent") {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: PrimaryButton(
          label: 'Close',
          onPressed: () async {
            await collectionReferenceReports
                .doc(widget.babyID_)
                .update({"BiWeekly_Approved": 0});
            await FirebaseFirestore.instance
                .collection(Activity)
                .doc(selectedItemDocumentId)
                .update({'parentfeedback_': "Seen"});
            Get.back();
          },
        ),
      );
    }

    if (role_ == "Director") {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: PrimaryButton(
          label: 'Close',
          onPressed: () async {
            await collectionReferencebabydata
                .doc(widget.babyID_)
                .update({'directorremarks_': "Seen"});
            Get.back();
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showAttendanceUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Update Attendance'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: checkedInCount.toString(),
                    onChanged: (value) =>
                        checkedInCount = int.tryParse(value) ?? checkedInCount,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Present days'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: absentCount.toString(),
                    onChanged: (value) =>
                        absentCount = int.tryParse(value) ?? absentCount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Absent days'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                updateFirestoreData(
                    selectedDateRange, checkedInCount, absentCount);
                Get.back();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<QuerySnapshot> fetchData() async {
    return await collectionReference
        .where('id', isEqualTo: widget.babyID_)
        .where('BiWeeklyReport', isEqualTo: selectedDateRange)
        .where('category_', isEqualTo: 'BiWeekly')
        .get();
  }

  void updateDocumentsWithStatusForwarded(String babyid_,
      String existingstatus_, String update_, BuildContext context) async {
    try {
      final QuerySnapshot snapshot = await collectionReference
          .where('biweeklystatus_', isEqualTo: existingstatus_)
          .where('id', isEqualTo: babyid_)
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.update({'biweeklystatus_': update_});

        await collectionReferenceReports.doc(widget.babyID_).update({
          'BiWeekly_$update_': FieldValue.increment(1),
          'BiWeekly_$existingstatus_': FieldValue.increment(-1)
        });
      }

      await _updateReportStatus(update_);
      Get.back(); // Remove loading dialog
      snack('Report updated successfully');
    } catch (e) {
      Get.back(); // Remove loading dialog
      snack('Failed to update report: $e');
    }
  }

  Future<void> _updateReportStatus(String update_) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Activity)
          .where('dateRange', isEqualTo: selectedDateRange)
          .where('category_', isEqualTo: 'BiWeeklyReport')
          .where('child', isEqualTo: widget.babyID_)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'biweeklystatus_': update_});
      }
    } catch (error) {
      print('Error updating report status: $error');
    }
  }

  void showEditingDialog(String documentId, String activity_,
      String description, String subject, String biweeklystatus_) {
    TextEditingController descriptionController =
        TextEditingController(text: description);
    TextEditingController activityController =
        TextEditingController(text: activity_);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit $subject', style: k16bold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: activityController,
                decoration: const InputDecoration(labelText: 'Activity'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await confirm(context,
                    title: const Text("Delete Activity"),
                    content: const Text(
                        "Are you sure you want to delete this activity?"))) {
                  deleteDocumentFromFirestore(documentId, biweeklystatus_);
                }
              },
              child: Text('Delete', style: TextStyle(color: kRedColor)),
            ),
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (await confirm(context,
                    title: const Text("Update Activity"))) {
                  await collectionReference.doc(documentId).update({
                    "Activity": activityController.text,
                    "description": descriptionController.text,
                  });
                  Get.back();
                  snack('Activity updated');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteDocumentFromFirestore(
      String documentId, String biweeklystatus_) async {
    try {
      await collectionReference.doc(documentId).delete();
      await collectionReferenceReports
          .doc(widget.babyID_)
          .update({'BiWeekly_$biweeklystatus_': FieldValue.increment(-1)});
      Get.back(); // Close dialog
      snack('Activity deleted');
    } catch (e) {
      print('Error deleting document: $e');
      snack('Failed to delete activity');
    }
  }

  Future<void> updateFirestoreData(
      String dateRange, int present, int absent) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Activity)
          .where('dateRange', isEqualTo: dateRange)
          .where('category_', isEqualTo: 'BiWeeklyReport')
          .where('child', isEqualTo: widget.babyID_)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'checkedin': present,
          'absent': absent,
        });
      }
      setState(() {
        checkedInCount = present;
        absentCount = absent;
      });
      snack('Attendance updated');
    } catch (error) {
      print('Error updating attendance: $error');
      snack('Failed to update attendance');
    }
  }
}
