import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/screens/dailysheet/gallery_screen_staff.dart';

import '../../main.dart';


RxBool isLoading = true.obs;
final subjects_ = <String> ['Food','Fluids','Health','Activity'];
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
    required this.babypicture_, required this.fathersEmail_,
  }) : super(key: key);
  final collectionReference = FirebaseFirestore.instance.collection(Activity);


  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // mainAxisSize: MainAxisSize.max,
              children: [
                // Image.asset('assets/todlerlog.png', width: mQ.width * 0.3),
                Expanded(
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: babypicture_,
                        imageBuilder: (context, imageProvider) => Container(
                          width: mQ.width * 0.14,
                          height: mQ.height * 0.1,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      Expanded(
                        child: Container(
                          width: mQ.width * 0.14,
                          height: mQ.height * 0.1,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(" ${(name_)}",textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Comic Sans MS',
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                ),
                Expanded(
                  child: Text(
                      // ' ${(getCurrentDateforattendance())}',
                      ' ${DateFormat('E, d, MMM, yyyy').format(DateFormat('d-M-yyyy').parse(date_))},',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Comic Sans MS',
                          fontWeight: FontWeight.normal,
                          color: Colors.grey)),
                ),
              ]),

        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              GalleryScreenStaff(
                      baby: babyID_,
                      // MoodScreen(baby: babyID_,
                      subject: 'Activity',
                      category: 'DailySheet',
                      reportdate_: date_,
                      subjectcolor_: Colors.teal.withOpacity(0.8)),
              ],
    ),
          )
        );
  }



}
