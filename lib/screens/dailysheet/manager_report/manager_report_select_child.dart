import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/bi_weekly/biweekly_report_principal.dart';
import 'package:kids_republik/screens/bi_weekly/biweekly_report_shape.dart';
import 'package:kids_republik/screens/dailysheet/gallery_report_shape.dart';
import 'package:kids_republik/screens/dailysheet/parent_report/daily_report_shape.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:kids_republik/utils/image_slide_show.dart';
var reports_ = <String>[];
// = <String> [ 'Daily' , 'BiWeekly', 'Activities'];
String reportDate_ = getCurrentDate();
String? displayReportDate_ ;
class ManagerReportSelectChild extends StatefulWidget {
  final reportstatus_;
  ManagerReportSelectChild({super.key, this.reportstatus_});

  @override
  State<ManagerReportSelectChild> createState() => _ManagerReportSelectChildState();
}
Color color = Colors.red;

class _ManagerReportSelectChildState extends State<ManagerReportSelectChild> {
  final collectionReference = FirebaseFirestore.instance.collection(BabyData);
  final collectionReferenceActivity = FirebaseFirestore.instance.collection(Activity);
  ScrollController scrollController = ScrollController();
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (role_ == "Teacher")
      setState(() {
    reports_ = <String> [ 'Daily' ,'Forwarded' ,'Approved' , 'BiWeekly', 'Activities'];
      });
    if (role_ == "Parent")
      setState(() {
      reports_ = <String> [ 'Daily' , 'BiWeekly'];
      });
    if (role_ == 'Principal')  setState(() {
      reports_ =  [  'Daily' ,'Approved', 'BiWeekly', 'Activities'];
    });
    if (role_ == 'Director')
      setState(() {
        reports_ = [  'New','Daily','Approved', 'BiWeekly', 'Activities'] ;
      });
}

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
// reports_ = [] ;
}
  @override
  Widget build(BuildContext context) {

    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        // drawer: BaseDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          title: Text(
            'Daily & Bi Weekly Reports',
            style: TextStyle(color: kWhite,fontSize: 14),
          ),
          backgroundColor: kprimary,
        ),
        backgroundColor: Colors.blue[50],
        body:
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: mQ.width*0.01),
          child: Column(children: [
            ImageSlideShowfunction(context),
            Container(
              padding: EdgeInsets.only(left: mQ.width*0.03, right: mQ.width*0.04),
              // padding: EdgeInsets.only(right: 8, left: 8),
              height: mQ.height * 0.03,
              color: Colors.grey[50],
              width: mQ.width,
              // padding:mQ ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'View reports',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                    Expanded(
                    child:
                  InkWell(
                    onTap: ()
                    async {
                      displayReportDate_ = await selectReportDate(context);
                    setState(() {

                    });
                    },
                      child: Text(textAlign: TextAlign.right,
                        // ' ${getCurrentDateforattendance()}',
                        // ' ${getDateforReport()}',
                        ' ${displayReportDate_??getDateforReport()}',
                        style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Comic Sans MS',
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
              (role_=="Teacher")?classwisestudents(teachersClass_) :  Container(),
    (role_=="Teacher")?  Container():
    classwisestudents('Infant'),
    (role_=="Teacher")?  Container():
classwisestudents('Toddler'),
    (role_=="Teacher")?  Container():
classwisestudents('Play Group - I'),
    (role_=="Teacher")?  Container():
classwisestudents('Kinder Garten - I'),
(role_=="Teacher")?  Container():
classwisestudents('Kinder Garten - II')
           ]),
        ));

     }
  Widget classwisestudents(classname){
    final mQ = MediaQuery.of(context).size;
    return
      Padding(
        padding:
        EdgeInsets.symmetric(vertical: 0.0, horizontal: mQ.width*0.02),
        child: StreamBuilder<QuerySnapshot>(
          stream: (role_ == 'Parent') ? collectionReference.where('class_', isEqualTo: classname).where('fathersEmail', isEqualTo: useremail).snapshots():collectionReference.where('class_', isEqualTo: classname).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {return Center(child: Padding(padding: EdgeInsets.only(top: mQ.height*0.01),child: CircularProgressIndicator(),),); }
            if (snapshot.hasError) {return Center(child: Text('Error: ${snapshot.error}'));}
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {return Center(child: Text('',style: TextStyle(color: Colors.grey),));}
            return Column(
              children: <Widget>[
                Container(width: mQ.width,color: Colors.green[50] ,height: mQ.height*0.022,child: Text(classname,textAlign: TextAlign.center,style: TextStyle(color: Colors.teal),)),
                Container(alignment: Alignment.center,
                  color: Colors.transparent,
                  height: mQ.height * 0.098,
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, position) {
                      final childData = snapshot.data!.docs[position].data()
                      as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                        },
                        child:
                        checkforwardedreportsandshowbadge(mQ,(role_ == "Teacher")?"New":(role_ == "Principal")?"Forwarded":(role_ == "Parent")?"Approved":(role_ == "Director")?"Forwarded":"",snapshot.data!.docs[position].id,
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              icon: Container(
                                width: mQ.width * 0.1,
                                height: mQ.height * 0.042,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(alignment: FractionalOffset.topCenter,
                                      image:
                                      CachedNetworkImageProvider(childData['picture']),
                                      fit: BoxFit.fill),
                                ),
                              ),
                              surfaceTintColor: Colors.green,shadowColor: Colors.limeAccent,
                              color: Colors.purple[50], // Generate the menu items from the list
                              itemBuilder:
                                  (BuildContext
                              context) {
                                return reports_.map(
                                        (String item) {
                                      return PopupMenuItem<
                                          String>(
                                        value: item,
                                        child:
                                        Text(
                                            item=='New'?"Initiated":
                                            item=='Activities'?"Gallery":
                                            item=='Daily'?
                                            role_=='Director'? "Forwarded":
                                            role_=='Principal'?"Received":
                                            role_=='Teacher'? "Initiated":
                                                item:item,
                                            style: TextStyle(
                                                color: item=='New'?Colors.green
                                                    :item=='Daily'?(role_=="Teacher")?Colors.green :(role_=="Parent")?Colors.red :Colors.blue
                                                    :item=='Forwarded'?Colors.blue
                                                    :item=='Approved'?Colors.red
                                                    :item=='BiWeekly'?Colors.indigo
                                                    :item=='Activities'? Colors.purple
                                                    :Colors.black
                                            )),
                                      );
                                    }).toList();
                              },
                              onSelected: (String selectedItem) async {

                                await confirm(title: Text("View Report",style: TextStyle(fontSize: 12)),content: Text('Do you want to continue?'), textOK: Text('Yes'),textCancel: Text('No'),context)?
                              (selectedItem == 'Daily')? Get.to(DailyReportShape(babyID_: snapshot.data!.docs[position].id , name_: childData['childFullName'], date_: reportDate_, class_: childData['class_'], childPicture_:  childData['picture'],reportType_:(role_=='Principal'||role_=='Director')? 'Forwarded':(role_=='Parent')? 'Approved':'New'))
                                    : (selectedItem == 'Forwarded')? Get.to(DailyReportShape(babyID_: snapshot.data!.docs[position].id , name_: childData['childFullName'], date_: reportDate_, class_: childData['class_'], childPicture_:  childData['picture'],reportType_: 'Forwarded'))
                                    : (selectedItem == 'Approved')? Get.to(DailyReportShape(babyID_: snapshot.data!.docs[position].id , name_: childData['childFullName'], date_: reportDate_, class_: childData['class_'], childPicture_:  childData['picture'],reportType_: 'Approved'))
                                : (selectedItem == 'New')? Get.to(DailyReportShape(babyID_: snapshot.data!.docs[position].id , name_: childData['childFullName'], date_: reportDate_, class_: childData['class_'], childPicture_:  childData['picture'],reportType_: 'New'))
                                :(selectedItem == 'Activities')? Get.to(GalleryReportShapeScreen(babyID_:  snapshot.data!.docs[position].id ,name_:  childData['childFullName'], date_: reportDate_, class_:  childData['class_'],babypicture_: childData['picture'], fathersEmail_: childData['fathersEmail'],)):
                                // Get.to(BiWeeklyReportShapeScreen(babyID_: snapshot.data!.docs[position].id, name_: childData['childFullName'], date_: getCurrentDate(), class_: childData['class_'], babypicture_:  childData['picture'])):
                              (role_ != 'Teacher')?Get.to(BiWeeklyReportPrincipalScreen(babyID_: snapshot.data!.docs[position].id, name_: childData['childFullName'], date_: reportDate_, class_: childData['class_'], babypicture_:  childData['picture'])):
                                Get.to(BiWeeklyReportShapeScreen(babyID_: snapshot.data!.docs[position].id, name_: childData['childFullName'], reportdate_: reportDate_, class_: childData['class_'], babypicture_:  childData['picture']))
                                // Get.to(ReportShapeScreen(babyID_:  snapshot.data!.docs[position].id ,name_:  childData['childFullName'], date_: getCurrentDate(), class_:  childData['class_'],babypicture_: childData['picture'],))
                                    :Null;
                                // collectionReference.doc(snapshot.data!.docs[position].id).update({"class_": selectedItem});
                              },
                            ),
                            Text(" ${childData['childFullName']} ",
                            style: TextStyle(
                                fontSize: 10,
                                // fontFamily: 'Comic Sans MS',
                                fontWeight: FontWeight.normal,
                                color: Colors.blue)),
                          ],
                        ),),
                      // )
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      );

  }



  Widget checkforwardedreportsandshowbadge(mQ, status, babyid_, Widget pppasa,) {
  double leftposn = 0;
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection(Reports)
        .doc(babyid_)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Container(), // Replace with your loading widget
          ),
        );
      }

      // Retrieve data from the snapshot
      Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;
      // Map <String, dynamic> data = snapshot.data!.data();
      int newVar = 0;
      int forwardVar = 0;
      int approvedVar = 0;
      int biweekly = 0;
      int photosnew_ = 0;
      if (role_ == 'Teacher') {
        biweekly = data?['BiWeekly_New'] ?? 0;
        // photosnew_ = data?['Photos_New'] ?? 0;
      } else if (role_ == 'Principal') {
        biweekly = data?['BiWeekly_Forwarded'] ?? 0;
         // photosnew_ = data?['Photos_Forwarded'] ?? 0;
      } else
        biweekly = data?['BiWeekly_Approved'] ?? 0;
      // photosnew_ = data?['Photos_Approved'] ?? 0;
      if (data?['date_'] == getCurrentDate()) {
        newVar = data?['DailySheet_New'] ?? 0;
        forwardVar = data?['DailySheet_Forwarded'] ?? 0;
        approvedVar = data?['DailySheet_Approved'] ?? 0;
        // biweekly = data?['BiWeekly_New'] ?? 0;
      if (role_ == 'Teacher') {
          photosnew_ = data?['Photos_New'] ?? 0;
        } else if (role_ == 'Principal') {
          photosnew_ = data?['Photos_Forwarded'] ?? 0;
        } else
          photosnew_ = data?['Photos_Approved'] ?? 0;
      }
      // Rest of your code remains unchanged
      // Stack, Positioned, CircleAvatar widgets, etc.
        return Stack(
          children: [
            pppasa,
            Positioned(
              top: 0,
              left:
                photosnew_
                    > 0 ? leftposn += 14 : leftposn,
              child: CircleAvatar(
                radius: 8,
                backgroundColor:
                photosnew_ > 0 ? Colors.purple : Colors.transparent,
                child: Text(
                  photosnew_.toString(),
                  style: TextStyle(
                    color: photosnew_ > 0 ? Colors.white : Colors.transparent,
                    fontSize: 7,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left:
                biweekly
                    > 0 ? leftposn += 14 : leftposn,
              child: CircleAvatar(
                radius: 8,
                backgroundColor:
                biweekly > 0 ? Colors.indigo : Colors.transparent,
                child: Text(
                  biweekly.toString(),
                  style: TextStyle(
                    color: biweekly > 0 ? Colors.white : Colors.transparent,
                    fontSize: 7,
                  ),
                ),
              ),
            ),
            if (role_ == 'Teacher') Positioned(
              top: 0,
              left:
              newVar> 0 ? leftposn += 14 : leftposn,

              child: CircleAvatar(
                radius: 8,
                backgroundColor: newVar > 0 ? Colors.green : Colors.transparent,
                child: Text(
                  newVar.toString(),
                  style: TextStyle(
                    color: newVar > 0 ? Colors.white : Colors.transparent,
                    fontSize: 7,
                  ),
                ),
              ),
            ),
            if (role_ == 'Principal') Positioned(
              top: 0,
              left:
              forwardVar > 0 ? leftposn += 14 : leftposn,

              child: CircleAvatar(
                radius: 8,
                backgroundColor:
                forwardVar > 0 ? Colors.blue : Colors.transparent,
                child: Text(
                  forwardVar.toString(),
                  style: TextStyle(
                    color: forwardVar > 0 ? Colors.white : Colors.transparent,
                    fontSize: 7,
                  ),
                ),
              ),
            ),
            if (role_ == 'Director'||role_ == 'Parent') Positioned(
              top: 0,
              left:
              approvedVar > 0 ? leftposn += 14 : leftposn,

              child: CircleAvatar(
                radius: 8,
                backgroundColor: approvedVar > 0 ? Colors.red : Colors.transparent,
                child: Text(
                  approvedVar.toString(),
                  style: TextStyle(
                    color: approvedVar > 0 ? Colors.white : Colors.transparent,
                    fontSize: 7,
                  ),
                ),
              ),
            ),
        // checkNewPhotoReportsAndShowBadge(mQ,leftposn, babyid_, pppasa),
            // ),)
          ],
        );
      },
    );
  }

  Widget checkNewPhotoReportsAndShowBadge(mQ,leftposn, babyid_, Widget pppasa) {
    return StreamBuilder<QuerySnapshot>(
      stream: collectionReferenceActivity
          .where('id', isEqualTo: babyid_)
          .where('date_', isEqualTo: getCurrentDate().toString())
          .where('photostatus_', isEqualTo: (role_=='Teacher')?'New':(role_=='Principal')?'Forward':'Approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }


        int newPhotoVar = snapshot.data?.docs.length ?? 0;

        return Positioned(
            top: 0,
            left:
            newPhotoVar> 0 ? leftposn += 14 : leftposn,

            child: CircleAvatar(
            radius: 8,
            backgroundColor: newPhotoVar > 0 ? Colors.purple : Colors.transparent,
            child: Text(
          newPhotoVar.toString(),
          style: TextStyle(
            color: newPhotoVar > 0 ? Colors.white : Colors.transparent,
            fontSize: 7,
          ),
        )));
      },
    );
  }

  Future selectReportDate(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year,DateTime.now().month,(role_=='Parent')?DateTime.now().day-1:DateTime.now().day-3,),
        lastDate: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,),
        helpText: 'Select Start Date');
    if (pickedStartDate != null) {
        final now = pickedStartDate;
        final day =
        now.day.toString().padLeft(2, '0'); // Add leading zero if needed
        final month =
        now.month.toString().padLeft(2, '0'); // Add leading zero if needed
        final year = now.year.toString();
        reportDate_ = '$day-$month-$year';
        now.day.toString().padLeft(2, '0'); // Add leading zero if needed

        setState(() {
        displayReportDate_ = ' ${DateFormat.EEEE().format(now)},  ${DateFormat.d().format(now)} ${DateFormat.MMMM().format(now)} ${DateFormat.y().format(now)} ';
        });

      return displayReportDate_;
    }
  }

}
