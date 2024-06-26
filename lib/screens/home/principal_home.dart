import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/activities/select_childs_for_activity.dart';
import 'package:kids_republik/screens/activities/view_bi_weekly_activities.dart';
import 'package:kids_republik/screens/consent/parent_consent_screen.dart';
import 'package:kids_republik/screens/home/checkin_checkout_screen.dart';
import 'package:kids_republik/screens/home/home_user_management.dart';
import 'package:kids_republik/screens/home/teacher_management.dart';
import 'package:kids_republik/screens/widgets/base_drawer.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:kids_republik/utils/image_slide_show.dart';

import '../dailysheet/manager_report/manager_report_select_child.dart';
import '../reminder/reminderstoparent.dart';

final subject_  =  <String>  [ 'Check In', 'Food', 'Fluids', 'Health', 'Activity', 'Check Out'];


int strengthinclass = 0;
int presentinclass = 0;
int absentinclass = 0;
bool? setattendance_;
var attendanceData;

class PrincipalHomeScreen extends StatefulWidget {
  const PrincipalHomeScreen({super.key});

  @override
  State<PrincipalHomeScreen> createState() => _PrincipalHomeScreenState();
}

final collectionReferenceClass = FirebaseFirestore.instance.collection('ClassRoom');
final collectionReferenceActivity = FirebaseFirestore.instance.collection('Activity');
final collectionReferenceUsers = FirebaseFirestore.instance.collection('users');

class _PrincipalHomeScreenState extends State<PrincipalHomeScreen> {
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  Widget checkforwardedreportsandshowbadge(mQ,status,color, Widget displayonthis) {
    return
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: collectionReferenceActivity
                  .where('date_',isEqualTo:getCurrentDate().toString())
                  .where('status_',isEqualTo:status)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: CircularProgressIndicator(),
                    ),
                  ); // Show loading indicator
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

                }
                // _cartBadgeAmount=snapshot.data!.docs.length;
                return
                  badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -2, end: -2),
                    badgeAnimation: badges.BadgeAnimation.slide(
                      disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
                      curve: Curves.easeInCubic,
                    ),
                    showBadge: (snapshot.data!.docs.length > 0),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: color,
                    ),
                    badgeContent: Text(
                      snapshot.data!.docs.length.toString(),
                      style: TextStyle(fontSize: 12,color: Colors.white),
                    ),
                    child: displayonthis,
                  )
                ;
              },
            ),
          );
  }
  Widget specialbadge(mQ,checkwhat,color, Widget displayonthis) {
    // QuerySnapshot checkwhat2 = checkwhat;

    return
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: checkwhat.snapshots(),
              builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(
    child: Padding(
    padding: const EdgeInsets.only(top: 0.0),
    child: CircularProgressIndicator(),
    ),
    ); // Show loading indicator
    }

    if (snapshot.hasError) {
    // return Center(child: Text('Error: ${snapshot.error}'));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

    // return Text('error');
    }
    return

    badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -10, end: -3),
                    badgeAnimation: badges.BadgeAnimation.slide(
                      disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
                      curve: Curves.easeInCubic,
                    ),
                    showBadge: (snapshot.data!.docs.length > 0),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: color,
                    ),
                    badgeContent: Text(
                      snapshot.data!.docs.length.toString(),
                      style: TextStyle(fontSize: 10,color: Colors.white),
                    ),
                    child: displayonthis,
                  )
                ;
    },
            ));
    }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.blue[50],
        drawer: BaseDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          title: Text(
            'Home',
            style: TextStyle(color: kWhite,fontSize: 14),
          ),
          backgroundColor: kprimary,
        ),
        body: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
          ImageSlideShowfunction(context),
          // (isloadingDate)
          //     ?
                SizedBox(height: mQ.height * 0.01,),
              Container(color: grey100,width: mQ.width*0.9,child: Text("${role_}'s Dashboard" ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),),
                // SizedBox(height: mQ.height * 0.01,),

              // setattendance(mQ, "Infant"),
              Row(
                children: [
                  Padding (
                    padding: EdgeInsets.only(left: mQ.width*0.05),
                    child: Container(
                      width: mQ.width*0.15,
                      decoration: BoxDecoration(
                        color: kprimary,
                        // Colors.green,
                        borderRadius: BorderRadius.circular(2), // Apply rounded corners if desired
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.6),
                            spreadRadius: 0.2,
                            blurRadius: 0.5,
                            offset: Offset(0, 3), // Add a shadow effect
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('Class',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),),
                          Text('Enrolled',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),),
                          Text('Present',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),),
                          Text('Absent',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white),),
                        ],
                      ),
                    ),
                  ),
                    classSummary(mQ, "Infant",Colors.grey[50]),
                    classSummary(mQ, "Toddler",Colors.green[50]),
                    classSummary(mQ, "Play Group - I",Colors.pink[50]),
                    classSummary(mQ, "Kinder Garten - I",Colors.blue[50]),
                    classSummary(mQ, "Kinder Garten - II",Colors.brown[50]),
                ],
              ),
                // SizedBox(height: mQ.height * 0.001,),
              Container(color: kprimary2,width: mQ.width*0.9,child: Text('Users' ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.white)),),
              Container(width: mQ.width*0.9,color: Colors.greenAccent[80],child: BadgeScreen()),

          Padding(
            padding:
            (role_=="Principal")?
            const
            EdgeInsets.only(top: 20,left: 18.0, right: 18):
            const
             EdgeInsets.only(top: 2,left: 18.0, right: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: specialbadge(mQ,collectionReferenceUsers.where('role',isEqualTo:'').where('status',isNotEqualTo:'Activate'), Colors.red,
                      IconButton(
                        onPressed: () {
                          Get.to(UserManagementScreen());
                        },
                        icon:
                        Image.asset('assets/principal/useraccountsprincipal.png',
                            width: mQ.width * 0.29),
                      ),)),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          Get.to(TeacherManagementScreen());
                        },
                        icon: Image.asset('assets/principal/teacherprincipal.png',
                            width: mQ.width * 0.29),
                      ),
                    ),
                    Expanded(child: checkforwardedreportsandshowbadge(mQ,(role_=="Principal")?"Forwarded":"Approved",(role_=="Principal")?Colors.blue:Colors.red,
                      IconButton(
                        onPressed: () {
                          Get.to(ManagerReportSelectChild(
                              reportstatus_: 'Approved'));
                        },
                        icon:
                        Image.asset('assets/principal/reportprincipal.png',
                            width: mQ.width * 0.29),
                      ),
                    )),
                  ],
                ),
                SizedBox(height: mQ.height * 0.005,),
                Row(
                  children: [
                    Expanded(
                      child:
                      IconButton(
                        onPressed: () {
                          Get.to(ParentConsentScreen(babyid: 'All Consents',));
                          // Get.to(ViewBiweeklyActivities());
                        },
                        icon:
                        Image.asset('assets/principal/consentprincipal.png',
                            width: mQ.width * 0.29),
                        // child: const Text('Consent Statements'),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          Get.to(ViewBiweeklyActivities());
                        },
                        icon: Image.asset('assets/principal/addactivity.png', width: mQ.width * 0.29),
                        // child: const Text('Consent Statements'),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          Get.to(ParentReminderScreen(babyid_: "All Reminders",));
                        },
                        icon:
                        Image.asset('assets/principal/reminderprincipal.png',
                            width: mQ.width * 0.29),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ])));
  }

  // UpdateClassController updateCropController = Get.put(UpdateClassController());

  Widget BadgeScreen (){
    return  StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        int teacherCount = 0;
        int parentCount = 0;
        int activateCount = 0;
        int blockCount = 0;

        users.forEach((user) {
          String role = user['role'];
          String status = user['status'];

          if (role == 'Teacher') {
            teacherCount++;
          } else if (role == 'Parent') {
            parentCount++;
          }

          if (status == 'Activate') {
            activateCount++;
          } else if (status != 'Activate') {
            blockCount++;
          }
        });

        return
        Row(
          children: <Widget>[
            // ListTile(
            //   title:
              // trailing:
              Expanded(
                child: badges.Badge(
                  badgeContent: Text('Teachers ${teacherCount.toString()}',style: TextStyle(color: Colors.white,fontSize: 10),textAlign: TextAlign.center),

                  badgeStyle:
                  BadgeStyle(shape: badges.BadgeShape.square,badgeColor: Colors.blue,),


        ),
              ),
        Expanded(
          child: badges.Badge(
                  badgeContent: Text('Parents: ${parentCount.toString()}',style: TextStyle(color: Colors.white,fontSize: 10),textAlign: TextAlign.center),
                  badgeStyle: BadgeStyle(shape: badges.BadgeShape.square,badgeColor: Colors.brown,)
                  ),
        ),
        Expanded(
          child: badges.Badge(
            badgeContent: Text('Activated: ${activateCount.toString()}',style: TextStyle(color: Colors.white,fontSize: 10),textAlign: TextAlign.center),
        badgeStyle: BadgeStyle(shape: badges.BadgeShape.square,badgeColor: Colors.green,)
                ),
        ),
        Expanded(
          child: badges.Badge(
        badgeContent: Text('Blocked: ${blockCount.toString()}',style: TextStyle(color: Colors.white,fontSize: 10),textAlign: TextAlign.center),
        badgeStyle: BadgeStyle(shape: badges.BadgeShape.square,badgeColor: Colors.red,)
          ),
        ),
          ],
        );
      },
    );
  }
  Widget classSummary(mQ,class_,decorationcolor_){
    return
      FutureBuilder<DocumentSnapshot>(
          future: collectionReferenceClass.doc(class_).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Class does not exist.'));
            }

            final classData = snapshot.data!;

            return
             (role_ == 'Director') ?
                 Container(
                   width: mQ.width*0.15,
                   // padding: EdgeInsets.symmetric(horizontal: 7),
                   decoration: BoxDecoration(
                     color:
                     decorationcolor_,
                     boxShadow: [
                       BoxShadow(
                         color: Colors.grey.withOpacity(0.6),
                         spreadRadius: 0.2,
                         blurRadius: 0.3,
                         offset: Offset(0, 3), // Add a shadow effect
                       ),
                     ],
                   ),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text('${(classData.id=='Kinder Garten - I')?'KG-I':(classData.id=='Kinder Garten - II')?'KG-II':(classData.id=='Play Group - I')?'PG-I':classData.id}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10,color: Colors.brown[900]),),
                       Text('${classData['strength_']}',textAlign: TextAlign.center,style: TextStyle(fontSize: 12,color: Colors.blue[900]),),
                       Text('${classData['present_']}',textAlign: TextAlign.center,style: TextStyle(fontSize: 12,color: Colors.green[900]),),
                       Text('${classData['absent_']}',textAlign: TextAlign.center,style: TextStyle(fontSize: 12,color: Colors.red[900]),),
                     ],
                   ),
                 ):
             PopupMenuButton<String>(
                iconSize: 16,surfaceTintColor: Colors.green,shadowColor: Colors.limeAccent,
                color: Colors.green[
                150], // Generate the menu items from the list
                itemBuilder:
            (BuildContext
                context) {
              return subject_ .map(
                      (String item) {
                    return PopupMenuItem<
                        String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList();
            },
            onSelected: (String
            selectedItem) async {
            await confirm(title: Text("Confirm",style: TextStyle(fontSize: 12)),content: Text("Are You sure to proceed",style: TextStyle(fontSize: 12)), textOK: Text('Yes'),textCancel: Text('No'),context)?
            // collectionReference.doc(snapshot.data!.docs[index].id).update({"class": selectedItem}):Null;
            (selectedItem=='Check In'||selectedItem=='Check Out')?Get.to (CheckinCheckoutScreen(activityclass_: class_)):
                Get.to(SelectChildsForActivity(activityclass_: class_, selectedsubject_: selectedItem)):null;

            },
            // child:
            // InkWell(
            //   onTap: (){

              // },
              child: Container(
                width: mQ.width*0.15,
                // padding: EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  color:
                  decorationcolor_,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      spreadRadius: 0.2,
                      blurRadius: 0.3,
                      offset: Offset(0, 3), // Add a shadow effect
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${(classData.id=='Kinder Garten - I')?'KG-I':(classData.id=='Kinder Garten - II')?'KG-II':(classData.id=='Play Group - I')?'PG-I':classData.id}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10,color: Colors.brown[900]),),
                    Text('${classData['strength_']}',textAlign: TextAlign.center,style: TextStyle(fontSize: 12,color: Colors.blue[900]),),
                    Text('${classData['present_']}',textAlign: TextAlign.center,style: TextStyle(fontSize: 12,color: Colors.green[900]),),
                    Text('${classData['absent_']}',textAlign: TextAlign.center,style: TextStyle(fontSize: 12,color: Colors.red[900]),),
                  ],
                ),
              ),
            );

          }
      );
  }
}





