import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:toast/toast.dart';

import '../../utils/const.dart';
import '../../utils/getdatefunction.dart';
import '../../utils/image_slide_show.dart';
import '../kids/widgets/empty_background.dart';
import 'add_new_biweekly_activity_for_class.dart';

bool deleteionLoading = false;
class ViewBiweeklyActivities extends StatefulWidget {
  ViewBiweeklyActivities({super.key});

  @override
  State<ViewBiweeklyActivities> createState() => _ViewBiweeklyActivitiesState();
}

class _ViewBiweeklyActivitiesState extends State<ViewBiweeklyActivities> {
  final collectionReferenceBiweekly =   FirebaseFirestore.instance.collection('Consent');

  // final collectionReferenceActivity = FirebaseFirestore.instance.collection('Activity');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    // notification();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Activities',
          style: TextStyle(color: kWhite, fontSize: 14),
        ),
        backgroundColor: kprimary,
      ),
      backgroundColor: Colors.blue[50],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[50],
        onPressed: () {
          Get.to(AddNewBiweeklyActivityForClass());
        },
        child: const Text('+', style: TextStyle(color: Colors.greenAccent,fontSize: 24)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(right: 4.0,left: 4.0),
        child: Column(
            children: [
              ImageSlideShowfunction(context),
              Container(padding: EdgeInsets.symmetric(horizontal: 6),
            height: mQ.height * 0.03,
            color: Colors.grey[50],
            width: mQ.width * 0.95,
            // padding:mQ ,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Activities for BiWeekly Report',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                  textAlign: TextAlign.left,
                ),

              ],
            ),
          ),
              Container(
                height: mQ.height*0.02,width: mQ.width*0.95,
                decoration: BoxDecoration(
                  color:
                  Colors.indigo[50],
                  borderRadius: BorderRadius.circular(5), // Apply rounded corners if desired
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      spreadRadius: 0.2,
                      blurRadius: 0.1,
                      offset: Offset(0, 1), // Add a shadow effect
                    ),
                  ],
                ),
                // height: mQ.height * 0.02,
                // color: Colors.brown[50],
                // width: mQ.width,
                // padding:mQ ,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                      Text(
                        "Subject",
                        textAlign: TextAlign.left,style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black87.withOpacity(0.7),
                          fontSize: 10),
                      ),
                    ),
                    Expanded(
                      child:
                      Text(
                        "",
                        textAlign: TextAlign.left,style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black87.withOpacity(0.7),
                          fontSize: 10),
                      ),
                    ),
                    Expanded(
                      child:
                      Text(
                        "Class",
                        textAlign: TextAlign.left,style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black87.withOpacity(0.7),
                          fontSize: 10),
                      ),
                    ),
                    Expanded(
                      child:
                      Text(
                        "",
                        textAlign: TextAlign.center,style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black87.withOpacity(0.7),
                          fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
          SingleChildScrollView(padding: EdgeInsets.symmetric(horizontal: mQ.width*0.023,vertical: mQ.height*0.002),
              child: StreamBuilder<QuerySnapshot>(
                stream: (role_ == "Teacher")?
                collectionReferenceBiweekly
                    .where('category_', isEqualTo: 'BiWeekly')
                    .where('class_', isEqualTo: teachersClass_)
                    .snapshots():
                collectionReferenceBiweekly
                    .where('category_', isEqualTo: 'BiWeekly')
                    .orderBy('class_')
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
                    return EmptyBackground(
                      title: 'Create + Button to Add Activity for BiWeekly Report.',
                    ); // No data
                  }

                  // Data is available, build the list
                  return ListView.
                  builder(
                    // separatorBuilder: (context, index) {
                    //   return Divider(
                    //     color: Colors.grey.withOpacity(0.2),
                    //   );
                    // },
                    primary: false,
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final childData = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      return Padding(
                        padding:  EdgeInsets.symmetric(vertical: mQ.height*0.0031),
                        child: Container(
                          height: mQ.height*0.1,width: mQ.width*0.9,
                          decoration: BoxDecoration(
                            color:
                            Colors.white,
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
                          Container(height: mQ.height*0.030,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      " ${childData['subject_']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 10),
                                    ),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.edit),
                                      iconSize: 20,
                                      color: Colors.blue[600],
                                      onPressed: () {
                                        setState(() {
                                          showEditingDialog(
                                              snapshot.data!.docs[index].id,
                                              childData['title_'],
                                              childData['description_'],
                                              childData['subject_'],
                                              childData['class_'],
                                              mQ,
                                              childData,
                                              snapshot,
                                              index                                   );
                                          _isEnable = true;
                                        });
                                      }),
                                  IconButton(
                                      onPressed: () async {
                                        await confirm(title:
                                        Text("Delete?",style: TextStyle(fontSize: 14,color: Colors.red[900])),
                                            content: Text("Do you want to delete?",style: TextStyle(fontSize: 14,color: Colors.black)),
                                            textOK: Text('Yes'),textCancel: Text('No')
                                            ,context)
                                            ?
                                        deleteDocumentFromFirestore(snapshot.data!.docs[index].id)
                                            : Null;
                                        // Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.delete_outline_sharp, size: 18, color: Colors.red)
                                  ),
                                ]),
                          ),
                          Container(height: mQ.height*0.025,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child:
                                    Text(
                                      "${childData['title_']} ",
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blue,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      " ${childData['class_']}",textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                          fontSize: 10),
                                    ),
                                  ),

                                ]),
                          ),
                            Container(height: mQ.height*0.03,alignment: Alignment.topLeft,
                          child:
                          Text(
                            "${childData['description_']}",
                            textAlign: TextAlign.justify,
                            maxLines: 1, // Set the maximum number of lines
                            overflow: TextOverflow.ellipsis, // Display ellipsis (...) when content overflows
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black54,
                                fontSize: 10),
                          ),
                            )]),
                            padding: EdgeInsets.symmetric(horizontal: mQ.width*0.015)
                        ),
                      );
                    },
                  );
                },
              )
          )
        ]),
      ),
    );
  }

  Widget PermissionsFromParent(consenttext, title) {
    return Center(
      child: ElevatedButton(
        child: Text(consenttext),
        onPressed: () async {
          if (await confirm(
              title: title,
              textOK: Text('Yes'),
              textCancel: Text('No'),
              context)) {
            return print('pressedOK');
          }
          return print('pressedCancel');
        },
      ),
    );
  }

  bool _isEnable = false;
  showEditingDialog(documentId, activity_, description, subject, class_, mQ, childData, snapshot, index) {
    TextEditingController activity_text_controller = TextEditingController(text: activity_);
    TextEditingController description_text_controller = TextEditingController(text: description);
    return
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(

            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),

            // title:
            child:

            Container(padding: EdgeInsets.all(18),
              width: double.infinity,
              height: mQ.height * 0.45,
              // color: grey100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade100
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Assign Activity", style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                            alignment: Alignment.topRight,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                                Icons.close, size: 14, color: Colors.black)),
                      ),
                    ],
                  ),
                  // content:
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subject', textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                        TextField(
                          maxLines: 2,
                          controller: activity_text_controller,
                          enabled: _isEnable,
                        ),
                      ]), Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description', textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                      TextField(
                        controller: description_text_controller,
                        maxLines: 4,
                        enabled: _isEnable,
                      ),
                    ],
                  ),
                  // actions: [
                  (_isEnable)
                      ? Expanded(
                    child: IconButton(
                        onPressed: () {
                          collectionReferenceBiweekly
                              .doc(documentId)
                              .update({
                            "title_": activity_text_controller.text,
                            "description_":
                            description_text_controller.text,
                          });
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.save,
                          color: Colors.green,
                        )),
                  )
                      : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Text('Send to: ')),
                        Expanded(
                          child: PopupMenuButton<String>(
                            child: Text('Class', style: TextStyle(
                                color: Colors.blue[900])),
                            itemBuilder: (BuildContext context) {
                              return classes_.map((String item) {
                                return PopupMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList();
                            },
                            onSelected: (String selectedItem) async {
                              // Handle the selected item
                              await confirm(
                                  title: Text("Activity"),
                                  textOK: Text('Yes'),
                                  textCancel: Text('No'),
                                  context)
                                  ? addConsentStatementToClass(
                                  selectedItem,
                                  childData['title_'],
                                  childData['description_'])
                                  : null;
                              // Toast.show('Record added successfully',backgroundColor: Colors.black12,duration: 10 );
                            },
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                              child: Text('All Students'),

                              onPressed: () async {
                                await confirm(
                                    title: Text("Activity"),
                                    textOK: Text('Yes'),
                                    textCancel: Text('No'),
                                    context)
                                    ? addConsentStatementToClass(
                                    'All Students',
                                    childData['title_'],
                                    childData['description_'])
                                    : Null;
                                print(childData['title_']);
                                // Get.to(RequireConsentOfParent(childData['title_'], childData['description_'],));
                              }),
                        ),
                        Expanded(
                          child: TextButton(
                              child: Text('All Present'),

                              onPressed: () async {
                                await confirm(
                                    title: Text("Activity"),
                                    textOK: Text('Yes'),
                                    textCancel: Text('No'),
                                    context)
                                    ? addConsentStatementToClass(
                                    'All Present',
                                    childData['title_'],
                                    childData['description_'])
                                    : Null;
                                print(childData['title_']);
                                // Get.to(RequireConsentOfParent(childData['title_'], childData['description_'],));
                              }),
                        ),

                      ]),

                ],
              ),
            ),
            // ],
          );
        },
      );

  }

  showEditingDialog11(documentId, activity_, description, subject, class_) {
    TextEditingController description_text_controller =
        TextEditingController(text: description);
    TextEditingController subject_text_controller =
        TextEditingController(text: subject);
    TextEditingController activity_text_controller =
        TextEditingController(text: activity_);
    TextEditingController class_text_controller =
        TextEditingController(text: class_);
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Material(
                child: CupertinoAlertDialog(
              title: TextField(
                controller: subject_text_controller,
                enabled: _isEnable,
              ),
              content: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.cancel,
                              size: 12, color: Colors.black)),
                    ],
                  ),
                  TextField(
                    controller: activity_text_controller,
                    enabled: _isEnable,
                  ),
                  TextField(
                    controller: class_text_controller,
                    enabled: _isEnable,
                  ),
                  TextField(
                    controller: description_text_controller,
                    maxLines: 3,
                    enabled: _isEnable,
                  ),
                ],
              ),
              actions: [
                // (_isEnable)
                //     ?
                IconButton(
                    onPressed: () {
                      collectionReferenceBiweekly.doc(documentId).update({
                        "subject_": subject_text_controller.text,
                        "title_": activity_text_controller.text,
                        "description_": description_text_controller.text,
                        "class_": class_text_controller.text,
                      });
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.save,
                      color: Colors.orange,
                    ))
              ],
            ));
          });
        });
  }
  Future<List<DocumentSnapshot>> getStudentsByClass(String className) async {
    QuerySnapshot querySnapshot;
    (className == "All Students")
        ? querySnapshot = await FirebaseFirestore.instance
        .collection('BabyData')
        .where('class_', whereIn: [
      'Infant',
      'Toddler',
      'Play Group - I',
      'Kinder Garten - I',
      'Kinder Garten - II'
    ]).get()
        :
  (className == "All Present")
        ? querySnapshot = await FirebaseFirestore.instance
        .collection('BabyData')
        .where('class_', whereIn: [
      'Infant',
      'Toddler',
      'Play Group - I',
      'Kinder Garten - I',
      'Kinder Garten - II'
    ]).where('checkedin' == "Checked In").get()
        : querySnapshot = await FirebaseFirestore.instance
        .collection('BabyData')
        .where('class_', isEqualTo: className)
        .get();
    return querySnapshot.docs;
  }

  Future<void> addConsentStatementToClass(className, heading, statement) async {
    List<DocumentSnapshot> students = await getStudentsByClass(className);
    CollectionReference consentCollection =
    FirebaseFirestore.instance.collection('Activity');

    students.forEach((student) async {
      String studentid = student.id;
      String fathersEmail = student['fathersEmail'];

      // Create a new document for each student in the class collection
      await consentCollection.add({
        'child_': studentid,
        'parentid_': fathersEmail,
        'title_': heading,
        'description_': statement,
        'date_': getCurrentDate(),
        'result_': 'Waiting',
        'category_': 'BiWeekly'
      });
    });
    ToastContext().init(context);
    Toast.show('Record updated successfully',
        backgroundColor: Colors.black12, duration: 10);
  }
  Future<void> deleteDocumentFromFirestore1(String documentId) async {
    // Reference to the Firestore collection and document

    try {
      // Delete the document with the specified document ID
      setState(() {
        // deleteionLoading = false;
      Navigator.of(context).pop();
      });

      await collectionReferenceBiweekly.doc(documentId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      // Navigator.of(context).pop();
    }
  }
  void deleteDocumentFromFirestore(String documentId) {
    // Reference to the Firestore collection and document

    try {
      // Delete the document with the specified document ID
      setState(() async {
        await collectionReferenceBiweekly.doc(documentId).delete();
        // deleteionLoading = false;
      });

    } catch (e) {
      print('Error deleting document: $e');
    }
  }

}
