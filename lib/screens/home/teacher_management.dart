import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/widgets/base_drawer.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:kids_republik/utils/image_slide_show.dart';

final classes_  =<String> [ 'Infant', 'Toddler', 'Kinder Garten - I', 'Kinder Garten - II', 'Play Group - I'];

class TeacherManagementScreen extends StatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  State<TeacherManagementScreen> createState() => _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends State<TeacherManagementScreen> {
  final collectionReference = FirebaseFirestore.instance.collection('users');
  final collectionReferenceClass = FirebaseFirestore.instance.collection('ClassRoom');
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  // UpdateClassController updateCropController = Get.put(UpdateClassController());

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      // drawer: BaseDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Teaching Staff',
          style: TextStyle(color: kWhite,fontSize: 14),
        ),
        backgroundColor: kprimary,
      ),
drawer: BaseDrawer(),
      body: SingleChildScrollView(
          child: Column(
        children: [
          ImageSlideShowfunction(context),
          Container(
            padding: EdgeInsets.only(right: 12, left: 12),
            height: mQ.height * 0.03,
            color: Colors.grey[50],
            width: mQ.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Teachers',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ),
                Expanded(
                  child: Text(
                    textAlign: TextAlign.right,
                    ' ${getCurrentDateforattendance()}',
                    style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Comic Sans MS',
                        fontWeight: FontWeight.normal,
                        color: Colors.grey),
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: CircularProgressIndicator(),
                  ),
                ); // Show loading indicator
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));

              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: mQ.height * 0.05,
                    ),
                    Center(
                      child: Image.asset(
                        'assets/empty_2.png',
                        height: mQ.height * 0.2,
                        width: mQ.width * 0.9,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: 17,
                    ),
                  ],
                );
              }

              // Data is available, build the list
              return ListView.builder(
                // separatorBuilder: (context, index) {
                //   return Divider(
                //     color: Colors.grey.withOpacity(0.2),
                //   );
                // },
                primary: false,
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final userData = snapshot.data!.docs[index].data()
                      as Map<String, dynamic>;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: mQ.width*0.02,vertical: mQ.height*0.0051),
                    child: Container(height: mQ.height*0.1,
                      decoration: BoxDecoration(
                        color:
                        Colors.grey[50],
                        borderRadius: BorderRadius.circular(5), // Apply rounded corners if desired
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
                            spreadRadius: 0.2,
                            blurRadius: 0.5,
                            offset: Offset(0, 3), // Add a shadow effect
                          ),
                        ],
                      ),

                      child:
                      Container(height: mQ.height*0.2,
                        child: Row(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  (role_=="Manager")?Expanded(
                                    child: Column(
                                      children: [
                                        Container(height: mQ.height*0.06,
                                          child:
                                          // (userData['userImage'] == Null)?
                                          Image.asset(
                                            'assets/staff.jpg',
                                            // width: mQ.width * 0.10,
                                            // height: mQ.height * 0.04,
                                            fit: BoxFit.fitHeight,
                                          // )
                                              // :
                                          // Image.network(
                                          //   '${userData['userImage']}',
                                          //   width: mQ.width * 0.05,
                                          //   height: mQ.height * 0.04,
                                          //   fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Text(
                                            "${userData['full_name']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black87.withOpacity(0.7),
                                                fontSize: 12),
                                          ),
                                        ),

                                      ],
                                    )):
                                  Expanded(
                                    child: PopupMenuButton<String>(
                                      iconSize: 16,surfaceTintColor: Colors.green,shadowColor: Colors.limeAccent,
                                      color: Colors.green[150], // Generate the menu items from the list
                                      itemBuilder:
                                          (BuildContext context) {
                                        return classes_ .map(
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
                                        collectionReference.doc(snapshot.data!.docs[index].id).update({"class": selectedItem}):Null;

                                      },
                                    child:
                                    Column(
                                      children: [
                                        Container(height: mQ.height*0.06,
                                          child:
                                          // (userData['userImage'] == Null)?
                                          Image.asset(
                                            'assets/staff.jpg',
                                            // width: mQ.width * 0.10,
                                            // height: mQ.height * 0.04,
                                            fit: BoxFit.fitHeight,
                                          // )
                                              // :
                                          // Image.network(
                                          //   '${userData['userImage']}',
                                          //   width: mQ.width * 0.05,
                                          //   height: mQ.height * 0.04,
                                          //   fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                          Text(
                                            "${userData['full_name']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black87.withOpacity(0.7),
                                                fontSize: 12),
                                          ),
                                        ),

                                      ],
                                    ),
                                  )),
                                  Expanded(child: Text('${userData['class']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.brown[900]),)),
                      Expanded(child: classSummary(mQ, userData['class']))
                                ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          )],
      )),
    );
  }


Widget classSummary(mQ,class_){
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
  return Center(child: Text('Class document does not exist.'));
  }

  final classData = snapshot.data!;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 18.0),
    child: Column(
    mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text('Enrolled: ${classData['strength_']}',style: TextStyle(fontSize: 10,color: Colors.blue[900]),),
    Text('Present: ${classData['present_']}',style: TextStyle(fontSize: 10,color: Colors.green[900]),),
    Text('Absent: ${classData['absent_']}',style: TextStyle(fontSize: 10,color: Colors.red[900]),),
    ],
    ),
  );

}
    );}
}
