import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:toast/toast.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/image_slide_show.dart';
import 'add_new_reminder.dart';

bool deleteionLoading = false;
class ParentReminderScreen extends StatefulWidget {
String babyid_;
  ParentReminderScreen({required this.babyid_, super.key});

  @override
  State<ParentReminderScreen> createState() => _ParentReminderScreenState();
}

class _ParentReminderScreenState extends State<ParentReminderScreen> {
  final collectionReference = FirebaseFirestore.instance.collection(BabyData);
  final collectionReferenceReminders =
  FirebaseFirestore.instance.collection(Activity);
  CollectionReference collectionReferenceConsents =
      FirebaseFirestore.instance.collection(Consent);

  // final collectionReferenceActivity = FirebaseFirestore.instance.collection(Activity);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey100,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhite),
        backgroundColor: kprimary,
        title: const Text(
          'Notifications',
          style: TextStyle(color: kWhite, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: (role_ == "Principal" || role_ == "Director" || role_ == "Manager")
          ? FloatingActionButton.extended(
              onPressed: () => Get.to(AddNewReminderScreen()),
              backgroundColor: kprimary,
              icon: const Icon(Icons.add, color: kWhite),
              label: const Text('Add New', style: TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ImageSlideShowfunction(context),
              _buildHeader(),
              if (role_ == 'Parent') displayReminders(MediaQuery.of(context).size),
              _buildNotificationsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: kWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Notifications',
            style: k14bold,
          ),
          Text(
            getCurrentDateforattendance(),
            style: k12500.copyWith(color: kGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: (role_ == 'Parent')
          ? collectionReferenceReminders
              .where('child_', isEqualTo: widget.babyid_)
              .where('category_', isEqualTo: 'Reminder')
              .where('parentid_', isEqualTo: useremail)
              .where('result_', isNotEqualTo: 'Waiting')
              .snapshots()
          : collectionReferenceConsents.where('category_', isEqualTo: 'Reminder').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: kRedColor)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          primary: false,
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildNotificationCard(doc.id, data, snapshot, index);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.notifications_none_outlined, size: 64, color: grey300),
          const SizedBox(height: 16),
          Text('No notifications yet', style: k16500.copyWith(color: kGrey)),
          const SizedBox(height: 8),
          Text('You will see important updates here.', style: k12500.copyWith(color: kGrey.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String docId, Map<String, dynamic> data, AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _isEnable = false;
            showEditingDialog(docId, data['title_'], data['description_'], data['subject_'], data['class_'], MediaQuery.of(context).size, data, snapshot, index);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['title_'] ?? 'Notification',
                        style: k14bold.copyWith(color: kprimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      data['date_'] ?? '',
                      style: k10500.copyWith(color: kGrey.withOpacity(0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data['description_'] ?? '',
                  style: k12500.copyWith(color: kBlackColor.withOpacity(0.7)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (role_ != 'Parent') ...[
                  const Divider(height: 24, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                        onPressed: () {
                          _isEnable = true;
                          showEditingDialog(docId, data['title_'], data['description_'], data['subject_'], data['class_'], MediaQuery.of(context).size, data, snapshot, index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: kRedColor),
                        onPressed: () async {
                          if (await confirm(context,
                              title: const Text('Delete Notification'),
                              content: const Text('Are you sure you want to delete this notification?'))) {
                            deleteDocumentFromFirestore(docId);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }


  bool _isEnable = false;
  showEditingDialog(documentId, activity_, description, subject, class_, mQ, childData, snapshot, index) {
    TextEditingController activity_text_controller = TextEditingController(text: activity_);
    TextEditingController description_text_controller = TextEditingController(text: description);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: kWhite,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_isEnable ? 'Edit Notification' : 'Notification Details', style: k16bold.copyWith(color: kprimary)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20, color: kGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isEnable) ...[
                  TextField(
                    controller: activity_text_controller,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: k12500.copyWith(color: kGrey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: k14500,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: description_text_controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: k12500.copyWith(color: kGrey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: k14500,
                  ),
                ] else ...[
                  Text(activity_, style: k14bold.copyWith(color: kBlackColor)),
                  const SizedBox(height: 12),
                  Text(description, style: k14500.copyWith(color: kBlackColor.withOpacity(0.7), height: 1.5)),
                  const SizedBox(height: 8),
                  Text('Dated: ${childData['date_']}', style: k10500.copyWith(color: kGrey)),
                ],
                const SizedBox(height: 32),
                _buildDialogActions(documentId, activity_text_controller, description_text_controller, childData),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogActions(String documentId, TextEditingController titleCtrl, TextEditingController descCtrl, Map<String, dynamic> childData) {
    if (_isEnable) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            collectionReferenceConsents.doc(documentId).update({
              "title_": titleCtrl.text,
              "description_": descCtrl.text,
            });
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kprimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save Changes', style: TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (role_ == "Parent") {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: k14bold),
        ),
      );
    }

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text('Broadcast Notification', style: k12500),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showClassPicker(childData),
                icon: const Icon(Icons.class_outlined, size: 18),
                label: const Text('Class'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kprimary,
                  side: BorderSide(color: kprimary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (await confirm(context, title: const Text("Broadcast All"), content: const Text("Send this notification to all parents?"))) {
                    addConsentStatementToClass('All Parents', childData['title_'], childData['description_']);
                  }
                },
                icon: const Icon(Icons.groups_outlined, size: 18),
                label: const Text('All Parents'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kprimary.withOpacity(0.1),
                  foregroundColor: kprimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showClassPicker(Map<String, dynamic> childData) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Class', style: k16bold),
              const SizedBox(height: 16),
              ...classes_.map((item) => ListTile(
                    title: Text(item, style: k14500),
                    onTap: () {
                      Navigator.pop(context);
                      addConsentStatementToClass(item, childData['title_'], childData['description_']);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  displayReminders(Size mQ) {
    return StreamBuilder<QuerySnapshot>(
      stream: collectionReferenceReminders
          .where('child_', isEqualTo: widget.babyid_)
          .where('category_', isEqualTo: 'Reminder')
          .where('parentid_', isEqualTo: useremail)
          .where('result_', isEqualTo: 'Waiting')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          primary: false,
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWarningLightColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kWarningColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.priority_high, color: kWarningColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(data['title_'] ?? 'Action Required', style: k14bold.copyWith(color: kWarningColor))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(data['description_'] ?? '', style: k12500.copyWith(color: kBlackColor.withOpacity(0.7))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          collectionReferenceReminders.doc(snapshot.data!.docs[index].id).update({"result_": "Yes"});
                        },
                        child: const Text('Dismiss', style: TextStyle(color: kWarningColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> getStudentsByClass(String className) async {
    QuerySnapshot querySnapshot;
    (className == "All Parents")
        ? querySnapshot = await FirebaseFirestore.instance
            .collection(BabyData)
            .where('class_', whereIn: [
            'Infant',
            'Toddler',
            'Play Group - I',
            'Kinder Garten - I',
            'Kinder Garten - II'
          ]).get()
        : querySnapshot = await FirebaseFirestore.instance
            .collection(BabyData)
            .where('class_', isEqualTo: className)
            .get();

    return querySnapshot.docs;
  }

  Future<void> addConsentStatementToClass(className, heading, statement) async {
    List<DocumentSnapshot> students = await getStudentsByClass(className);
    CollectionReference consentCollection =
        FirebaseFirestore.instance.collection(Activity);

    for (var student in students) {
      String studentid = student.id;
      String fathersEmail = student['fathersEmail'];

      await consentCollection.add({
        'child_': studentid,
        'parentid_': fathersEmail,
        'title_': heading,
        'description_': statement,
        'date_': getCurrentDate(),
        'result_': 'Waiting',
        'category_': 'Reminder'
      });
    }

    ToastContext().init(context);
    Toast.show(
      'Reminders sent to Parents successfully',
      backgroundRadius: 5,
    );
  }

  Future<void> deleteDocumentFromFirestore(String documentId) async {
    try {
      await collectionReferenceConsents.doc(documentId).delete();
      setState(() {});
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

}
