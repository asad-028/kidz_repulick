import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/activities/view_bi_weekly_activities.dart';
import 'package:kids_republik/screens/consent/parent_consent_screen.dart';
import 'package:kids_republik/screens/home/checkin_checkout_screen.dart';
import 'package:kids_republik/screens/home/principal_home.dart';
import 'package:kids_republik/screens/home/teacher_management.dart';
import 'package:kids_republik/screens/kids/assign_class_to_child_screen.dart';
import 'package:kids_republik/screens/kids/registration_form.dart';
import 'package:kids_republik/screens/reminder/reminderstoparent.dart';
import 'package:kids_republik/screens/widgets/base_drawer.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/image_slide_show.dart';

import '../activities/select_childs_for_activity.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.green[50],

        // backgroundColor: Colors.blue[50],
        drawer: BaseDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          title: Text(
            'Home',
            style: TextStyle(fontSize: 14,color: kWhite),
          ),
          backgroundColor: kprimary,
        ),
        body: SingleChildScrollView(
            // padding:EdgeInsets.symmetric(horizontal:
            // mQ.width*0.05),

            child: Column(
                children: <Widget>[
              ImageSlideShowfunction(context),
              SizedBox(height: mQ.height * 0.03,),
              Container(color: grey100,width: mQ.width*0.9,child: Text("${role_}'s Dashboard" ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),),
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
              SizedBox(height: mQ.height * 0.03,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
            IconButton(
              onPressed: () {
                Get.to(RegistrationForm());
              },
              icon: Image.asset('assets/manager/registration.png',
                  width: mQ.width * 0.27),
              // child: const Text('Consent Statements'),
            ),
            IconButton(
              onPressed: () {
                Get.to(AssignClassToChildren(selectedclass_: 'All Classes'));
              },
              icon: Image.asset('assets/manager/students.png',
                  width: mQ.width * 0.27),
              // child: const Text('Consent Statements'),
            ),
            IconButton(
              icon: Image.asset('assets/manager/staff.png',
                  width: mQ.width * 0.27),
              onPressed: () {
                Get.to(TeacherManagementScreen());
              },
            ),
          ]),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                IconButton(
                  onPressed: () {
                    Get.to(ViewBiweeklyActivities());
                  },
                  icon: Image.asset('assets/manager/biweekly1.png',
                      width: mQ.width * 0.27),
                ),
                IconButton(
                  onPressed: () {
                    Get.to(ParentConsentScreen(babyid: 'null',));
                  },
                  icon: Image.asset('assets/manager/consent.png',
                      width: mQ.width * 0.27),
                ),
                IconButton(
                  onPressed: () {
                    Get.to(ParentReminderScreen(babyid_: "All Reminders",));
                  },
                  icon: Image.asset('assets/manager/reminder1.png',
                      width: mQ.width * 0.27),
                ),
              ]),

            ]
            )
        )
    );
  }

  // UpdateClassController updateCropController = Get.put(UpdateClassController());

  Padding showDetailsRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ],
      ),
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
