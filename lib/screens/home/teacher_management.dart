import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:kids_republik/utils/image_slide_show.dart';

final classes_ = <String>[
  'Infant',
  'Toddler',
  'Kinder Garten - I',
  'Kinder Garten - II',
  'Play Group - I'
];

class TeacherManagementScreen extends StatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  State<TeacherManagementScreen> createState() =>
      _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends State<TeacherManagementScreen> {
  final collectionReference = FirebaseFirestore.instance.collection(users);
  final collectionReferenceClass =
      FirebaseFirestore.instance.collection(ClassRoom);
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  // UpdateClassController updateCropController = Get.put(UpdateClassController());

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Teaching Staff',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: kprimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageSlideShowfunction(context),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.groups_rounded,
                      size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Teachers',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF1E293B)),
                    ),
                  ),
                  Text(
                    getCurrentDateforattendance(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: collectionReference
                  .where('role', isEqualTo: 'Teacher')
                  .where('status', isEqualTo: 'Activate')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: mQ.height * 0.1),
                      Opacity(
                        opacity: 0.6,
                        child: Image.asset(
                          'assets/${table_}empty_2.png',
                          height: mQ.height * 0.2,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No teachers found',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey.shade400,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final userData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Teacher Profile & Assignment Trigger
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: role_ == "Manager"
                                      ? null
                                      : () {
                                          // Trigger popup menu logic is handled by PopupMenuButton itself
                                        },
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(16)),
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.blue.shade50.withOpacity(0.5),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                              left: Radius.circular(16)),
                                    ),
                                    child: (role_ == "Manager")
                                        ? _buildTeacherProfileColumn(userData)
                                        : PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            position: PopupMenuPosition.under,
                                            itemBuilder: (context) {
                                              return classes_
                                                  .map((String item) {
                                                return PopupMenuItem<String>(
                                                  value: item,
                                                  child: Text(item,
                                                      style: const TextStyle(
                                                          fontSize: 13)),
                                                );
                                              }).toList();
                                            },
                                            onSelected:
                                                (String selectedItem) async {
                                              final confirmed = await confirm(
                                                context,
                                                title:
                                                    const Text("Assign Class"),
                                                content: Text(
                                                    "Assign $selectedItem to ${userData['full_name']}?"),
                                                textOK: const Text('Assign'),
                                                textCancel:
                                                    const Text('Cancel'),
                                              );
                                              if (confirmed) {
                                                collectionReference
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .update({
                                                  "class": selectedItem
                                                });
                                              }
                                            },
                                            child: _buildTeacherProfileColumn(
                                                userData),
                                          ),
                                  ),
                                ),
                              ),
                              // Class Info
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Assigned Class',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey,
                                            letterSpacing: 0.5),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${userData['class']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Summary Stats
                              const VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Color(0xFFF1F5F9),
                                  indent: 12,
                                  endIndent: 12),
                              Expanded(
                                flex: 4,
                                child: classSummary(mQ, userData['class']),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherProfileColumn(Map<String, dynamic> userData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.shade100, width: 2),
            image: const DecorationImage(
              image: AssetImage('assets/staff.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${userData['full_name']}",
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget classSummary(mQ, String? class_) {
    if (class_ == null || class_.isEmpty) {
      return const Center(
        child: Text(
          'No Class Assigned',
          style: TextStyle(
              fontSize: 10,
              color: Colors.blueGrey,
              fontStyle: FontStyle.italic),
        ),
      );
    }
    return FutureBuilder<DocumentSnapshot>(
      future: collectionReferenceClass.doc(class_).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)));
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
              child:
                  Icon(Icons.error_outline, size: 16, color: Colors.redAccent));
        }

        final classData = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Enrolled', '${classData['strength_']}',
                  Colors.blue.shade700, Icons.person_outline_rounded),
              const SizedBox(height: 4),
              _buildStatRow('Present', '${classData['present_']}',
                  Colors.green.shade700, Icons.check_circle_outline_rounded),
              const SizedBox(height: 4),
              _buildStatRow('Absent', '${classData['absent_']}',
                  Colors.red.shade700, Icons.highlight_off_rounded),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          '$label:',
          style: TextStyle(
              fontSize: 10,
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}
