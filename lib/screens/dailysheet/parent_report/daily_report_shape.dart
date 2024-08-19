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
    required this.class_, required this.childPicture_, required this.reportType_,
  }) : super(key: key);
  final collectionReference = FirebaseFirestore.instance.collection(Activity);
  final collectionReferencebabydata = FirebaseFirestore.instance.collection(BabyData);
  final collectionReferenceReports = FirebaseFirestore.instance.collection(Reports);
  List<Map<String, dynamic>>? activityPhotos;


  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery
        .of(context)
        .size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kprimary, // Change this to the desired color
    ));
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar:

        (role_ == "Principal" ) ?
        Container(
          color: kprimary,
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (reportType_!="Approved")?
              TextButton(
                child:
              Text(
                  'Approve'
                  ,style: TextStyle(color: Colors.white)
              ),
                // icon: Icon(Icons.done,size: 24,color: Colors.white,)
                // ,
                  onPressed: () async => {
                await confirm(context)?updateDocumentsWithStatusForwarded(babyID_,"Forwarded","Approved",context):Get.back(),

              },)
              :TextButton(
              child: Text(
                  'Close'
                  ,style: TextStyle(color: Colors.white)
              ),
                onPressed: () async => {
                Get.back(),

              },)
              ,
            ],
          ),
        ):
        (role_ == "Teacher") ?
        Container(
          color: kprimary,
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
              (reportType_=="Approved"||reportType_=="Forwarded") ?
              'Close':
                  'Forward',style: TextStyle(color: Colors.white)),
              (reportType_=="Approved"||reportType_=="Forwarded") ?
              IconButton(icon: Icon(color:Colors.white, Icons.close,size: 24),onPressed: () async => {
                Get.back(),
              }):IconButton(icon: Icon(color:Colors.white, Icons.send,size: 24),onPressed: () async => {
                await confirm(context)?updateDocumentsWithStatusForwarded(babyID_,"New","Forwarded",context):null,
                Get.back(),
              }),
            ],
          ),
        )
            :
        (role_ == "Parent") ?
        Container(color: kprimary,
          child: TextButton(
              onPressed: () async {
                await collectionReferenceReports.doc(babyID_).set({"DailySheet_Approved": 0}, SetOptions(merge: true));

                await collectionReferencebabydata
                    .doc(babyID_)
                    .update({'parentfeedback_': "Seen"});
                Get.back();
              },
              child: Text('Close',style: TextStyle(fontSize: 14, color: Colors.white,)),
        ))
        :
        (role_ == "Director") ?
        Container(color: kprimary,
          child: TextButton(
              onPressed: () async {
                await collectionReferencebabydata
                    .doc(babyID_)
                    .update({'directorremarks_': "Seen"});
                Get.back();
              },
            child:
               Text('Close',style: TextStyle(
                  fontSize: 14, color: Colors.white),
               )
            ),
        ):Container(),

        body: SingleChildScrollView(
          padding: EdgeInsets.only(top: mQ.height*0.04,left: mQ.width*0.03,right: mQ.width*0.03,bottom: mQ.height*0.03),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white], // Define your gradient colors
              ),
              borderRadius: BorderRadius.circular(10), // Apply rounded corners if desired
              border: Border.all(color: Colors.grey,width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2), // Add a shadow effect
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 7),
                                height: mQ.height*0.03,alignment: AlignmentDirectional.bottomStart,
                                child:  Text(" ${(name_)}'s Report",
                                    style: TextStyle(
                                        fontSize: mQ.height*0.022,
                                        fontFamily: 'Comic Sans MS',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue)),
                              ),
                              Container(height: 20,
                                padding: EdgeInsets.only(left: 7),
                                child: Text(
                                    ' ${DateFormat('E, d, MMM, yyyy').format(DateFormat('d-M-yyyy').parse(date_))},',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Comic Sans MS',
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blue[900])),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(width: mQ.width*0.45),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 7),
                                  alignment: AlignmentDirectional.bottomEnd,
                                  width: mQ.width * 0.08,
                                  height: mQ.height * 0.05,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    // image: DecorationImage(image:NetworkImage(childPicture_),fit: BoxFit.scaleDown),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 7),
                                  alignment: AlignmentDirectional.bottomEnd,
                                  width: mQ.width * 0.08,
                                  height: mQ.height * 0.05,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    // image: DecorationImage(image:NetworkImage(childPicture_),fit: BoxFit.scaleDown),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 7),
                                  alignment: AlignmentDirectional.bottomEnd,
                                  width: mQ.width * 0.08,
                                  height: mQ.height * 0.05,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(image:NetworkImage(childPicture_),fit: BoxFit.fill),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                Row(
                      children: [
                        Expanded(child: ParentDailySheetScreen(baby: babyID_, subject: 'Attendance', reportdate_: date_, subjectcolor_: Colors.green, boxcolor_: Colors.transparent,category: 'DailySheet',boxheading: "Checked In", boxwidth_: mQ.width*0.9, boxheight_: mQ.height*0.03,reportType_: reportType_)),
                        Expanded(child: ParentDailySheetScreen(baby: babyID_, subject: 'Attendance', reportdate_: date_, subjectcolor_: Colors.red, boxcolor_: Colors.transparent,category: 'DailySheet',boxheading: "Checked Out", boxwidth_: mQ.width*0.9, boxheight_: mQ.height*0.03,reportType_: reportType_)),
                      ],
                    ),
                Row(
                  children: [
                    Expanded(child: ParentDailySheetScreen(baby: babyID_, subject: 'Food', reportdate_: date_, subjectcolor_: Colors.brown.withOpacity(0.8), boxcolor_: Colors.deepOrange.shade50,category: 'DailySheet',boxheading: "Feeding", boxwidth_: mQ.width*0.45,reportType_: reportType_)),
                    Expanded(child: ParentDailySheetScreen(baby: babyID_, subject: 'Fluids', reportdate_: date_, subjectcolor_: Colors.cyan.withOpacity(0.8), boxcolor_: Colors.blue.shade50,category: "DailySheet",boxheading: "Water / Juice", boxwidth_: mQ.width*0.45,reportType_: reportType_)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: ParentDailySheetScreen(baby: babyID_, subject: 'Mood', reportdate_: date_, subjectcolor_: Colors.purple.withOpacity(0.8), boxcolor_: Colors.green.shade50,category: "DailySheet",boxheading: "Mood", boxwidth_: mQ.width*0.45,reportType_: reportType_,boxheight_: mQ.height*0.065,)),
                    Expanded(child: ParentDailySheetScreen(baby: babyID_, subject: 'Sleep', reportdate_: date_, subjectcolor_: Colors.black.withOpacity(0.8), boxcolor_: CupertinoColors.extraLightBackgroundGray,category: "DailySheet",boxheading: "Napping", boxwidth_: mQ.width*0.45,reportType_: reportType_,boxheight_: mQ.height*0.065)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: ParentDailySheetScreen(baby: babyID_, subject: 'Toilet', reportdate_: date_, subjectcolor_: Colors.deepPurple.withOpacity(0.8), boxcolor_:Colors.orange.shade50,category: "DailySheet",boxheading: "Diapers / Potty", boxwidth_: mQ.width*0.45,reportType_: reportType_,boxheight_: mQ.height*0.065)),
                    Expanded(child: ParentDailySheetScreen(baby: babyID_, subject: 'Health', reportdate_: date_, subjectcolor_: Colors.green.withOpacity(0.8), boxcolor_: CupertinoColors.quaternaryLabel,category: "DailySheet",boxheading: "Medicine", boxwidth_: mQ.width*0.45,reportType_: reportType_,boxheight_: mQ.height*0.065,)),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: collectionReference
                            .where('id', isEqualTo: babyID_)
                            .where('date_', isEqualTo: date_)
                            .where('photostatus_', isEqualTo: 'Approved')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Image.asset('assets/dailycars.png', height: mQ.height * 0.08);
                          }

                          activityPhotos = [];

                          for (var doc in snapshot.data!.docs) {
                            var imageUrl = doc['image_'];
                            activityPhotos?.add({'image_': imageUrl});
                          }

                          return Row(
                            children: snapshot.data!.docs.asMap().entries.map((entry) {
                              final index = entry.key;
                              final imageUrl = entry.value['image_'] as String;

                              return Padding(
                                padding: EdgeInsets.all(mQ.width * 0.01),
                                child:
                                InkWell(
                                  onTap: () {
                                    Get.to(ZoomableImageGallery(imageUrls: activityPhotos ?? [], initialIndex: index));
                                  },
                                  child: CachedNetworkImage(
                                    alignment: Alignment.center,
                                    imageUrl: imageUrl,
                                    width: mQ.width * 0.2,
                                    height: 100,
                                    fit: BoxFit.fill,
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                     Padding(
                       padding: EdgeInsets.symmetric(horizontal: 4.0),
                       child: ParentDailySheetScreen(baby: babyID_, subject: 'Activity', reportdate_: date_, subjectcolor_: Colors.pink.withOpacity(0.8), boxcolor_: CupertinoColors.extraLightBackgroundGray,category: "DailySheet",boxheading: "Today's Activities", boxwidth_: mQ.width*0.95, boxheight_: mQ.height*0.24,reportType_: reportType_),
                     ),
                    Padding(
                       padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: ParentDailySheetScreen(baby: babyID_, subject: 'Notes', reportdate_: date_, subjectcolor_: Colors.brown.withOpacity(0.8), boxcolor_: Colors.brown.shade50,category: "DailySheet",boxheading: "Notes", boxwidth_: mQ.width*0.95, boxheight_: mQ.height*0.08,reportType_: reportType_),
                    ),
              SizedBox(height: mQ.height*0.01,)
              ],
            ),
          ),
        ));
  }



}

void updateDocumentsWithStatusForwarded(babyid_,existingstatus_, update_,context) async {
  final CollectionReference collection = FirebaseFirestore.instance.collection(Activity);
  final CollectionReference collectionReferenceReports = FirebaseFirestore.instance.collection(Reports);
  final QuerySnapshot snapshot = await collection
      .where('status_', isEqualTo: existingstatus_)
      .where('date_',isEqualTo: getCurrentDate())
      // .where('Subject',isEqualTo: getCurrentDate())
      .where('id', isEqualTo: babyid_).get();

  for (QueryDocumentSnapshot doc in snapshot.docs) {
    // Update the status to a new value, e.g., 'UpdatedStatus'
    await collection.doc(doc.id).update({'status_': update_});
    await collectionReferenceReports.doc(babyid_).update({'DailySheet_$update_': FieldValue.increment(1),'DailySheet_$existingstatus_': FieldValue.increment(-1)});
  }
  snack('Report ${update_} successfully', );
  Get.back();
}
