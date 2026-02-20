import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/screens/dailysheet/gallery_screen_staff.dart';

import '../../main.dart';

RxBool isLoading = true.obs;
final subjects_ = <String>['Food', 'Fluids', 'Health', 'Activity'];

class GalleryReportShapeScreen extends StatelessWidget {
  final String babyID_;
  final String babypicture_;
  final String name_;
  final String date_;
  final String class_;
  final String fathersEmail_;

  GalleryReportShapeScreen({
    Key? key,
    required this.babyID_,
    required this.name_,
    required this.date_,
    required this.class_,
    required this.babypicture_,
    required this.fathersEmail_,
  }) : super(key: key);
  final collectionReference = FirebaseFirestore.instance.collection(Activity);

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    final formattedDate = DateFormat('EEE, d MMM yyyy')
        .format(DateFormat('d-M-yyyy').parse(date_));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern light slate background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        toolbarHeight: mQ.height * 0.08,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CachedNetworkImage(
              imageUrl: babypicture_,
              imageBuilder: (context, imageProvider) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.shade50,
                child: Icon(Icons.person, color: Colors.blue.shade300),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name_,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87.withOpacity(0.6),
                        ),
                      ),
                      if (class_.trim().isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            class_,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: GalleryScreenStaff(
                baby: babyID_,
                subject: 'Activity',
                category: 'DailySheet',
                reportdate_: date_,
                subjectcolor_: const Color(0xFF0EA5E9), // Modern Sky Blue
              ),
            ),
          ),
        ),
      ),
    );
  }
}
