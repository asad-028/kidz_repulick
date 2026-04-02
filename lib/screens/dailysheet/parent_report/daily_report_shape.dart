import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/screens/gallery/zoomable_image.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:snackbar/snackbar.dart';

import '../../../main.dart';
import 'parent_report_recomendations.dart';
import '../../widgets/primary_button.dart';

RxBool isLoading = true.obs;

class DailyReportShape extends StatelessWidget {
  final String babyID_;
  final String name_;
  final String date_;
  final String class_;
  final String childPicture_;
  final String reportType_;

  DailyReportShape({
    Key? key,
    required this.babyID_,
    required this.name_,
    required this.date_,
    required this.class_,
    required this.childPicture_,
    required this.reportType_,
  }) : super(key: key);
  final collectionReference = FirebaseFirestore.instance.collection(Activity);
  final collectionReferencebabydata =
      FirebaseFirestore.instance.collection(BabyData);
  final collectionReferenceReports =
      FirebaseFirestore.instance.collection(Reports);
  List<Map<String, dynamic>>? activityPhotos;

  @override
  Widget build(BuildContext context) {
    print("Report Type: $reportType_");
    print(babyID_);
    final mQ = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kprimary, // Change this to the desired color
    ));
    return Scaffold(
        backgroundColor: grey100,
        bottomNavigationBar: _buildBottomActions(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(mQ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildAttendanceSection(mQ),
                      _buildActivityGrid(mQ),
                      _buildGallerySection(mQ),
                      _buildLongSections(mQ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
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
              child: (childPicture_ != null && childPicture_.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: childPicture_,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                        color: kWhite,
                        strokeWidth: 2,
                      )),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person, size: 40, color: kWhite),
                    )
                  : const Icon(Icons.person, size: 40, color: kWhite),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "$name_'s Report",
            style: kMediumTitle.copyWith(color: kWhite),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, d MMMM, yyyy')
                .format(DateFormat('d-M-yyyy').parse(date_)),
            style: k12500.copyWith(color: kWhite.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(Size mQ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: kprimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text("Attendance",
                  style: k14500.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceItem(
                  Icons.login,
                  "Check In",
                  'Attendance',
                  'Checked In',
                  kSuccessColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttendanceItem(
                  Icons.logout,
                  "Check Out",
                  'Attendance',
                  'Checked Out',
                  kRedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(IconData icon, String label, String subject,
      String boxheading, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: k12500.copyWith(color: kGrey)),
          ParentDailySheetScreen(
            baby: babyID_,
            subject: subject,
            reportdate_: date_,
            subjectcolor_: color,
            boxcolor_: Colors.transparent,
            category: 'DailySheet',
            boxheading: boxheading,
            boxwidth_: 100,
            boxheight_: 40,
            reportType_: reportType_,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityGrid(Size mQ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _buildGridItem('Food', 'Feeding', Icons.restaurant, Colors.brown,
              Colors.orange.shade50),
          _buildGridItem('Fluids', 'Water / Juice', Icons.water_drop,
              Colors.cyan, Colors.blue.shade50),
          _buildGridItem(
              'Mood', 'Mood', Icons.mood, Colors.purple, Colors.green.shade50),
          _buildGridItem('Sleep', 'Napping', Icons.hotel, Colors.black,
              CupertinoColors.extraLightBackgroundGray),
          _buildGridItem('Toilet', 'Diapers / Potty', Icons.wc,
              Colors.deepPurple, Colors.orange.shade50),
          _buildGridItem('Health', 'Medicine', Icons.medical_services,
              Colors.green, CupertinoColors.quaternaryLabel),
        ],
      ),
    );
  }

  Widget _buildGridItem(String subject, String heading, IconData icon,
      Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(heading,
                  style: k12500.copyWith(
                      fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ParentDailySheetScreen(
              baby: babyID_,
              subject: subject,
              reportdate_: date_,
              subjectcolor_: color,
              boxcolor_: Colors.transparent,
              category: "DailySheet",
              boxheading: heading,
              boxwidth_: 150,
              boxheight_: 40,
              reportType_: reportType_,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(Size mQ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: kprimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text("Activity Gallery",
                  style: k14500.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: StreamBuilder<QuerySnapshot>(
            stream: collectionReference
                .where('id', isEqualTo: babyID_)
                .where('date_', isEqualTo: date_)
                .where('photostatus_', isEqualTo: 'Approved')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const SizedBox.shrink();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          color: kGreyColor, size: 32),
                      const SizedBox(height: 4),
                      Text("No photos today",
                          style: k12500.copyWith(color: kGreyColor)),
                    ],
                  ),
                );
              }

              activityPhotos = [];
              for (var doc in snapshot.data!.docs) {
                activityPhotos?.add({'image_': doc['image_']});
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final imageUrl =
                      snapshot.data!.docs[index]['image_'] as String;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        Get.to(ZoomableImageGallery(
                            imageUrls: activityPhotos ?? [],
                            initialIndex: index));
                      },
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: (imageUrl != null && imageUrl.isNotEmpty)
                                ? CachedNetworkImageProvider(imageUrl)
                                : const AssetImage('assets/staff.jpg')
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLongSections(Size mQ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildLongSectionItem("Today's Activities", 'Activity', Colors.pink,
              CupertinoColors.extraLightBackgroundGray, 120),
          const SizedBox(height: 12),
          _buildLongSectionItem(
              "Notes", 'Notes', Colors.brown, Colors.brown.shade50, 60),
        ],
      ),
    );
  }

  Widget _buildLongSectionItem(String heading, String subject, Color color,
      Color bgColor, double height) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading,
              style:
                  k14500.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          ParentDailySheetScreen(
            baby: babyID_,
            subject: subject,
            reportdate_: date_,
            subjectcolor_: color,
            boxcolor_: Colors.transparent,
            category: "DailySheet",
            boxheading: heading,
            boxwidth_: 400,
            boxheight_: height,
            reportType_: reportType_,
          ),
        ],
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
        child: reportType_ != "Approved"
            ? PrimaryButton(
                onPressed: () async {
                  if (await confirm(context)) {
                    updateDocumentsWithStatusForwarded(
                        babyID_, "Forwarded", "Approved", context);
                  }
                },
                label: "Approve Report",
                bgColor: kprimary,
              )
            : PrimaryButton(
                onPressed: () => Get.back(),
                label: "Close",
                bgColor: kGrey,
              ),
      );
    }

    if (role_ == "Teacher") {
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
        child: (reportType_ == "Approved" || reportType_ == "Forwarded")
            ? PrimaryButton(
                onPressed: () => Get.back(),
                label: "Close",
                bgColor: kGrey,
              )
            : PrimaryButton(
                onPressed: () async {
                  if (await confirm(context)) {
                    updateDocumentsWithStatusForwarded(
                        babyID_, "New", "Forwarded", context);
                  }
                },
                label: "Forward to Principal",
                bgColor: kprimary,
              ),
      );
    }

    if (role_ == "Parent" || role_ == "Director") {
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
          onPressed: () async {
            if (role_ == "Parent") {
              await collectionReferenceReports
                  .doc(babyID_)
                  .set({"DailySheet_Approved": 0}, SetOptions(merge: true));
              await collectionReferencebabydata
                  .doc(babyID_)
                  .update({'parentfeedback_': "Seen"});
            } else {
              await collectionReferencebabydata
                  .doc(babyID_)
                  .update({'directorremarks_': "Seen"});
            }
            Get.back();
          },
          label: "Close",
          bgColor: kprimary,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

void updateDocumentsWithStatusForwarded(
    babyid_, existingstatus_, update_, context) async {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection(Activity);
  final CollectionReference collectionReferenceReports =
      FirebaseFirestore.instance.collection(Reports);
  final QuerySnapshot snapshot = await collection
      .where('status_', isEqualTo: existingstatus_)
      .where('date_', isEqualTo: getCurrentDate())
      // .where('Subject',isEqualTo: getCurrentDate())
      .where('id', isEqualTo: babyid_)
      .get();

  for (QueryDocumentSnapshot doc in snapshot.docs) {
    // Update the status to a new value, e.g., 'UpdatedStatus'
    await collection.doc(doc.id).update({'status_': update_});
    await collectionReferenceReports.doc(babyid_).update({
      'DailySheet_$update_': FieldValue.increment(1),
      'DailySheet_$existingstatus_': FieldValue.increment(-1)
    });
  }
  snack(
    'Report ${update_} successfully',
  );
  Get.back();
}
