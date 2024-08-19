import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/utils/const.dart';

import '../../controllers/auth_controllers/signup_controller.dart';
import '../../utils/image_slide_show.dart';

var condition;
class InvitationCodesScreen extends StatefulWidget {
  const InvitationCodesScreen({super.key});

  @override
  State<InvitationCodesScreen> createState() => _InvitationCodesScreenState();
}

class _InvitationCodesScreenState extends State<InvitationCodesScreen> {
  SignUpController signUpController = Get.put(SignUpController());
  final collectionRefrence = FirebaseFirestore.instance.collection(users);
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  // UpdateClassController updateCropController = Get.put(UpdateClassController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Invitation Codes',
          style: TextStyle(color: kWhite,fontSize: 14),
        ),
        backgroundColor: kprimary,
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              ImageSlideShowfunction(context),
              role_ == 'Manager' ?
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: mQ.height * 0.035,
                    color: Colors.teal[100],
                    width: mQ.width * 0.95,
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                    child: Text(
                      'List of Invitation Codes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 05), // Add space between elements
                  Container(
                    height: 40,
                    color: Colors.grey[200],
                    width: mQ.width * 0.95,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child:

                          Container(
                            color: Colors.black,
                            padding: EdgeInsets.all(0.5),
                            height: 30.0, // Adjust the container height as needed
                            child: TextFormField(
                              controller: signUpController.invitationCodeController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(

                                hintText: "Type New Invitation Code",
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.0),
                                // border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Reduce vertical padding
                                isDense: true, // Further compacts the layout
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10), // Add space between elements
                        ElevatedButton(
                          onPressed: () {
                            // Add functionality to add the invitation code to the collection
                            addInvitationCode(context);
                          },
                          child: Text('Add New'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: kprimary, // Text color
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5), // Add space between elements
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection(invitation_codes).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No invitation codes available.'));
                        }

                        return
                          ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            separatorBuilder: (context, index) => Divider(color: Colors.grey[110],height: 0.2,),
                            itemBuilder: (BuildContext context, int index) {
                              Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              return Container(
                                height: 40,
                                // color: index % 2 == 0 ? Colors.grey[50] : Colors.grey[100], // Alternating vibrant colors
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                  title:
                                  Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['invitation_code'],
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                        ),
                                        IconButton(onPressed: () async {
                                          if (await confirm(context,title: Text('Confirm', ),content: Text('Do you want to delete?'))) {
                                            String documentId = snapshot.data!.docs[index].id; // Get the document ID
                                            await FirebaseFirestore.instance
                                                .collection(invitation_codes)
                                                .doc(documentId)
                                                .delete();
                                          }

                                        }, icon: Icon(Icons.delete_forever_outlined,color: Colors.red,size: 20,))
                                      ]),
                                  dense: true,
                                ),
                              );
                            },
                          );
                      },
                    ),
                  ),
                ],
              )
                  : Container(),

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
      CollectionReference invitationCodesCollection = FirebaseFirestore.instance.collection(invitation_codes);

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
