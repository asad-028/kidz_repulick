import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/kids/registration_form.dart';
import 'package:kids_republik/screens/kids/update_registration_form.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/getdatefunction.dart';
import '../../utils/image_slide_show.dart';

class AssignClassToChildren extends StatefulWidget {
  final selectedclass_;
  AssignClassToChildren({super.key, required this.selectedclass_});
  String activitybabyid_ = '';

  @override
  State<AssignClassToChildren> createState() => _AssignClassToChildrenState();
}

class _AssignClassToChildrenState extends State<AssignClassToChildren> {
  bool deleteionLoading = false;
  final collectionReference = FirebaseFirestore.instance.collection(BabyData);
  final collectionReferenceClassRoom =
      FirebaseFirestore.instance.collection(ClassRoom);
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          title: Text(
            'Students',
            style: TextStyle(fontSize: 14, color: kWhite),
          ),
          backgroundColor: kprimary,
        ),
        backgroundColor: Colors.blue[50],
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(RegistrationForm());
            },
            child: Container(
              width: mQ.width * 0.13,
              decoration: BoxDecoration(),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 22,
                  color: kprimary,
                ),
              ),
            )),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: mQ.width * 0.01),
          child: Column(children: [
            ImageSlideShowfunction(context),
            Container(
              padding: EdgeInsets.only(
                  left: mQ.width * 0.03, right: mQ.width * 0.04),
              height: mQ.height * 0.03,
              color: Colors.grey[50],
              width: mQ.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Students',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.right,
                      ' ${getCurrentDate()}',
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
            if (role_ == "Principal") classwisestudents('NewAdmission'),
            classwisestudents('Infant'),
            classwisestudents('Toddler'),
            classwisestudents('Play Group - I'),
            classwisestudents('Kinder Garten - I'),
            classwisestudents('Kinder Garten - II'),
          ]),
        ));
  }

  Widget classwisestudents(classname) {
    final mQ = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8),
      child: StreamBuilder<QuerySnapshot>(
        stream: collectionReference
            .where('class_', isEqualTo: classname)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              'No Students in the ${classname} class',
              style: TextStyle(color: Colors.grey),
            ));
          }
          return Column(
            children: <Widget>[
              Container(
                  width: mQ.width,
                  height: mQ.height * 0.022,
                  color: Colors.green[50],
                  child: Text(
                    classname,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.teal),
                  )),
              Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                height: mQ.height * 0.13,
                child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, position) {
                    final childData = snapshot.data!.docs[position].data()
                        as Map<String, dynamic>;
                    final avatarSize = mQ.width * 0.14;

                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: mQ.width * 0.015),
                      child: Card(
                        elevation: 3,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(mQ.width * 0.05),
                        ),
                        color: Colors.blue[50],
                        child: Container(
                          width: mQ.width * 0.26,
                          padding: EdgeInsets.symmetric(
                            vertical: mQ.height * 0.006,
                            horizontal: mQ.width * 0.012,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<String>(
                                icon: Container(
                                  width: avatarSize,
                                  height: avatarSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        alignment: FractionalOffset.topCenter,
                                        image: CachedNetworkImageProvider(
                                            childData['picture']),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                surfaceTintColor: Colors.green,
                                shadowColor: Colors.limeAccent,
                                color: Colors.purple[50],
                                itemBuilder: (BuildContext context) {
                                  return (role_ == "Principal" ||
                                          role_ == "Manager")
                                      ? classes_.map((String item) {
                                          return PopupMenuItem<String>(
                                            value: item,
                                            child: Text(item),
                                          );
                                        }).toList()
                                      : [];
                                },
                                onSelected: (String selectedItem) async {
                                  (role_ == "Principal" || role_ == "Manager")
                                      ? await confirm(
                                              title: Text("Confirm",
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                              content: Text(
                                                  "Are You sure to proceed",
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                              textOK: Text('Yes'),
                                              textCancel: Text('No'),
                                              context)
                                          ? {
                                              selectedItem == 'Delete'
                                                  ? await confirm(
                                                          title: Text(
                                                            "Confirm Delete",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .red[900]),
                                                          ),
                                                          content: Text(
                                                            "Are You sure to Delete",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .red[900]),
                                                          ),
                                                          textOK: Text('Yes'),
                                                          textCancel:
                                                              Text('No'),
                                                          context)
                                                      ? deleteDocumentFromFirestore(
                                                          snapshot
                                                              .data!
                                                              .docs[position]
                                                              .id)
                                                      : null
                                                  : selectedItem == 'Update'
                                                      ? Get.to(
                                                          UpdateRegistrationForm(
                                                              babyId: snapshot
                                                                  .data!
                                                                  .docs[
                                                                      position]
                                                                  .id))
                                                      : await collectionReference
                                                          .doc(snapshot
                                                              .data!
                                                              .docs[position]
                                                              .id)
                                                          .update({
                                                          "class_": selectedItem
                                                        }),
                                              await collectionReferenceClassRoom
                                                  .doc(selectedItem)
                                                  .update({
                                                "strength_":
                                                    FieldValue.increment(1),
                                                'absent_':
                                                    FieldValue.increment(1)
                                              })
                                            }
                                          : null
                                      : null;
                                },
                              ),
                              SizedBox(height: mQ.height * 0.003),
                              Text(
                                " ${childData['childFullName']} ",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Comic Sans MS',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Future<void> deleteDocumentFromFirestore(String documentId) async {
    // Reference to the Firestore collection and document

    try {
      // Delete the document with the specified document ID
      setState(() {
        deleteionLoading = false;
      });
      await collectionReference.doc(documentId).delete();
      // Get.back();
    } catch (e) {
      print('Error deleting document: $e');
      // Get.back();
    }
    // Navigator.of(context).pop();
  }
}
