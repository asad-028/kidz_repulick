import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/auth/signup.dart';
import 'package:kids_republik/screens/kids/widgets/empty_background.dart';
import 'package:kids_republik/utils/const.dart';

import '../../controllers/auth_controllers/signup_controller.dart';
import '../../utils/image_slide_show.dart';

final roles_  =<String> [ 'Principal','Manager','Parent', 'Teacher'];
var condition;
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  SignUpController signUpController = Get.put(SignUpController());
  final collectionRefrence = FirebaseFirestore.instance.collection('users');
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  // UpdateClassController updateCropController = Get.put(UpdateClassController());
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    condition =                (role_ == 'Director')?collectionRefrence.snapshots() :
    (role_ == 'Principal')?
    collectionRefrence
        .where('role', whereIn: ['Manager','Teacher','Parent'])
        .where('status', isEqualTo: 'Activate')
        .snapshots():
    collectionRefrence
        .where('role', isEqualTo: '')
        .snapshots();

}
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;


    return Scaffold(
      backgroundColor: Colors.blue[50],
      // drawer: BaseDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'User Management',
          style: TextStyle(color: kWhite,fontSize: 14),
        ),
        backgroundColor: kprimary,
      ),
      floatingActionButton:FloatingActionButton(onPressed: () {
        Get.to(SignUpScreen());
      },
      // backgroundColor: Colors.transparent,
          child:
      Container(
        width: mQ.width*0.13,decoration: BoxDecoration(

        ),
        child: Center(
          child:
            Icon(
              Icons.add,
              size: 22,
              color: kprimary,
            ),
          ),
        // ),
      )),

      body: SingleChildScrollView(
          child: Column(
        children: [
        ImageSlideShowfunction(context),
          role_=='Director'||role_=='Principal'?Container(
            height: mQ.height * 0.03,
            color: Colors.blue[100],
            width: mQ.width * 0.95,
            // padding:mQ ,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        condition =
                        collectionRefrence
                            .where('role', isEqualTo: '')
                            .snapshots();
                      });
                    },
                    child: Text(
                      'New Users',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        condition =
                        collectionRefrence
                            .where('status', isNotEqualTo: 'Activate')
                            .snapshots();
                      });
                    },
                    child: Text(
                      'Blocked',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        condition =
                        collectionRefrence
                            .where('role', whereIn: ['Principal','Manager','Teacher'])
                            .snapshots();
                      });
                    },
                    child: Text(
                      'Staff',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        condition =
                        collectionRefrence
                            .where('role', isEqualTo: 'Parent')
                            .snapshots();

                      });
                    },
                    child: Text(
                      'Parents',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ):Container(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 14),
            child: StreamBuilder<QuerySnapshot>(
              stream: condition,
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
                  return EmptyBackground(
                    title: 'Click on + button to Add User',
                  ); // No data
                }

                // Data is available, build the list
                return ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: mQ.width*0.0051),
                      child: role_ == 'Director'?
                      PopupMenuButton<String>(
                        iconSize: 16,surfaceTintColor: Colors.green,shadowColor: Colors.limeAccent,
                        color: Colors.green[150], // Generate the menu items from the list
                        itemBuilder:
                            (BuildContext context) {
                          return roles_.map(
                                  (String item) {
                                return PopupMenuItem<
                                    String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList();
                        },
                        onSelected: (String selectedItem) async {
                          await confirm(title: Text("Confirm",style: TextStyle(fontSize: 12)),content: Text("Are You sure to proceed",style: TextStyle(fontSize: 12)), textOK: Text('Yes'),textCancel: Text('No'),context)?
                          collectionRefrence.doc(snapshot.data!.docs[index].id).update({"role": selectedItem }):null;
                        },
                        child: Container(
                        height:
                          // (role_=="Director") ? mQ.height*0.11:
                          mQ.height*0.09,
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

                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (userData['userImage'] == Null)?
                                Image.asset(
                                  'assets/staff.jpg',
                                  //color: kprimary,
                                  width: mQ.width * 0.1,
                                  fit: BoxFit.contain,
                                )
                                    :
                                CachedNetworkImage(
                                  imageUrl: userData['userImage'],
                                  width: mQ.width * 0.1,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Container(
                                    width: mQ.width * 0.1,
                                    height: mQ.width * 0.1,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300], // Placeholder color
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: mQ.width * 0.1,
                                    height: mQ.width * 0.1,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300], // Placeholder color for error
                                    ),
                                    child: Icon(Icons.error),
                                  ),
                                ),


                                SizedBox(
                                  width: mQ.width*0.0005,
                                ),
                                Expanded(
                                  child: Row(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${userData['full_name']}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87.withOpacity(0.7),
                                              fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${userData['role']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            letterSpacing: 0.7,
                                            color: Colors.black87.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                      role_ == 'Manager'? Text(userData['invitation_code']):Column(crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${userData['email']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color:
                                                    Colors.grey,
                                                fontSize: 10),
                                          ),
                                          Text(
                                          (role_ != 'Manager') ?
                                            "${userData['contact_number']}":"",
                                            style: TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 0.7,
                                              color:Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      (userData['status'] != 'Activate')?
                                      IconButton(onPressed: () async {await confirm(context)?collectionRefrence.doc(snapshot.data!.docs[index].id).update({"status": "Activate" }):null;;},   icon: Icon(Icons.verified,size: 18,color: CupertinoColors.systemGreen,), tooltip: 'Activate'):
                                      IconButton(onPressed: () async {await confirm(context)?collectionRefrence.doc(snapshot.data!.docs[index].id).update({"status": "Block" }):null; ;},   icon: Icon(Icons.app_blocking_sharp,size: 18,color: Colors.red),tooltip: 'Block'     ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                        ],
                        ),
                      )):
                      Container(
                        height:
                        mQ.height*0.06,
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

                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (userData['userImage'] == Null)?
                                Image.asset(
                                  'assets/staff.jpg',
                                  //color: kprimary,
                                  width: mQ.width * 0.1,
                                  fit: BoxFit.contain,
                                )
                                    :
                                CachedNetworkImage(
                                  imageUrl: userData['userImage'],
                                  width: mQ.width * 0.1,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Container(
                                    width: mQ.width * 0.1,
                                    height: mQ.width * 0.1,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300], // Placeholder color
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: mQ.width * 0.1,
                                    height: mQ.width * 0.1,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300], // Placeholder color for error
                                    ),
                                    child: Icon(Icons.error),
                                  ),
                                ),


                                SizedBox(
                                  width: mQ.width*0.0005,
                                ),
                                Expanded(
                                  child: Row(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${userData['full_name']}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87.withOpacity(0.7),
                                              fontSize: 12),
                                        ),
                                      ),

                                      Expanded(
                                        child: Text(
                                          "${userData['role']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            letterSpacing: 0.7,
                                            color: Colors.black87.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${userData['email']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color:
                                                Colors.grey,
                                                fontSize: 10),
                                          ),
                                          Text(
                                            (role_ != 'Manager') ?
                                            "${userData['contact_number']}":"",
                                            style: TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 0.7,
                                              color:Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      )
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: mQ.height * 0.08,
          ),
        ],
      )),
    );
  }




  void addInvitationCode(BuildContext context) {
    String invitationCode = signUpController.invitationCodeController.text.trim();

    if (invitationCode.isNotEmpty) {
      // Get a reference to the collection
      CollectionReference invitationCodesCollection = FirebaseFirestore.instance.collection('invitation_codes');

      // Check if the invitation code already exists
      invitationCodesCollection.doc(invitationCode).get().then((docSnapshot) {
        if (docSnapshot.exists) {
          // Show an error message for duplicate entry
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invitation code already exists',
                style: TextStyle(color: Colors.red),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Add the invitation code to the collection
          invitationCodesCollection.doc(invitationCode).set({
            'invitation_code': invitationCode,
            // You can add more fields if needed
          }).then((value) {
            // Clear the text field after adding the invitation code
            signUpController.invitationCodeController.clear();

            // Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.white70,
                content: Text(
                  'Invitation code added successfully',
                  style: TextStyle(color: Colors.green),
                ),
                duration: Duration(seconds: 2),
              ),
            );
          }).catchError((error) {
            // Show an error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.white70,
                content: Text(
                  'Failed to add invitation code: $error',
                  style: TextStyle(color: Colors.red),
                ),
                duration: Duration(seconds: 2),
              ),
            );
          });
        }
      });
    } else {
      // Show a message for empty input case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white70,
          content: Text(
            'Please enter a valid invitation code',
            style: TextStyle(color: Colors.red),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
