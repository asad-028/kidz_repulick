import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:toast/toast.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/image_slide_show.dart';
import 'add_new_reminder.dart';

bool deleteionLoading = false;
class ParentReminderScreen extends StatefulWidget {
String babyid_;
  ParentReminderScreen({required this.babyid_, super.key});

  @override
  State<ParentReminderScreen> createState() => _ParentReminderScreenState();
}

class _ParentReminderScreenState extends State<ParentReminderScreen> {
  final collectionReference = FirebaseFirestore.instance.collection('BabyData');
  final collectionReferenceReminders =
  FirebaseFirestore.instance.collection('Activity');
  CollectionReference collectionReferenceConsents =
      FirebaseFirestore.instance.collection('Consent');

  // final collectionReferenceActivity = FirebaseFirestore.instance.collection('Activity');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Notifications',
          style: TextStyle(color: kWhite,fontSize: 14),
        ),
        backgroundColor: kprimary,
      ),
      backgroundColor: Colors.white,
      floatingActionButton:
      (role_ == "Principal" || role_ == "Director" || role_ == "Manager")
          ?
      FloatingActionButton(
        onPressed: () {
          Get.to(AddNewReminderScreen());
        },
        child: const Text('+', style: TextStyle(fontSize: 24)),
      ):Container(),
      body: SingleChildScrollView(
        child: Column(children: [
          ImageSlideShowfunction(context),
          Container(
            padding: EdgeInsets.only(right: 8, left: 8),
            height: mQ.height * 0.03,
            color: Colors.orange[50],
            width: mQ.width,
            // padding:mQ ,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: Text(
                    textAlign: TextAlign.right,
                    ' ${getCurrentDateforattendance()}',
                    style: TextStyle(
                        fontSize: 10,
                        // fontFamily: 'Comic Sans MS',
                        fontWeight: FontWeight.normal,
                        color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          (role_ == 'Parent')?
          displayReminders(mQ):Container(),
          SingleChildScrollView(
              child: Column(children: [
            StreamBuilder<QuerySnapshot>(
              stream:     (role_ == 'Parent')
                  ?    collectionReferenceReminders
                  .where('child_', isEqualTo: widget.babyid_)
                  .where('category_', isEqualTo: 'Reminder')
                  .where('parentid_', isEqualTo: useremail)
                  .where('result_', isNotEqualTo: 'Waiting')
                  .snapshots()
                  :
            collectionReferenceConsents
                  .where('category_', isEqualTo: 'Reminder')
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
                  return Text(
                    'No Notification',
                  ); // No data
                }

                // Data is available, build the list
                return ListView.separated(
                  padding: EdgeInsets.all(10),
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 0.0, top: 0),
                      child: Divider(
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    );
                  },
                  primary: false,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final childData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    return InkWell(
                      onTap: () {
                        showEditingDialog(
                            snapshot.data!.docs[index].id,
                            childData['title_'],
                            childData['description_'],
                            childData['subject_'],
                            childData['class_'],
                            mQ,
                            childData,
                            snapshot,
                            index);
                        _isEnable = false;
                        },
                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
mainAxisAlignment: MainAxisAlignment.center,
                        // (childData["result_"]== "Waiting")?MainAxisAlignment.start:MainAxisAlignment.end,
                        children: [
                          Container(
                              padding: EdgeInsetsDirectional.symmetric(horizontal: mQ.width*0.02),
                              height: mQ.height*0.1,width: mQ.width*0.95,
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
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(height: mQ.height*0.05,
                                    child: Row(mainAxisAlignment: MainAxisAlignment.end,
                                        children:[
                                          Expanded(
                                            child: Text(
                                              " ${childData['date_']}",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                  fontSize: 10),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              "${childData['title_']} ",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.indigo.withOpacity(0.9),
                                                  fontSize: 12),
                                            ),
                                          ), // Title
                                          Expanded(
                                            child:
                                            (role_ == 'Parent')
                                                ? Container()
                                            // Text(
                                            //       " ${childData['result_']}",
                                            //       textAlign: TextAlign.right,
                                            //       style: TextStyle(
                                            //           fontWeight:
                                            //           FontWeight.normal,
                                            //           color: (childData["result_"]== "Waiting")?Colors.teal:(childData["result_"]== "Yes")?Colors.green[900]
                                            //               :Colors.red[900],
                                            //           fontSize: 12),
                                            //     )
                                                : Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                    children: [
                                                      Expanded(
                                                        child: IconButton(
                                                            icon:
                                                            Icon(Icons.edit),
                                                            alignment: Alignment.centerRight,                              iconSize: 16,
                                                            color:
                                                            Colors.blue[600],
                                                            onPressed: () {
                                                              setState(() {
                                                                showEditingDialog(
                                                                    snapshot
                                                                        .data!
                                                                        .docs[
                                                                    index]
                                                                        .id,
                                                                    childData[
                                                                    'title_'],
                                                                    childData[
                                                                    'description_'],
                                                                    childData[
                                                                    'subject_'],
                                                                    childData[
                                                                    'class_'],
                                                                    mQ,
                                                                    childData,
                                                                    snapshot,
                                                                    index);
                                                                _isEnable = true;
                                                              });
                                                            }),
                                                      ),
                                                      Expanded(
                                                        child: IconButton(
                                                            onPressed: () async {
                                                              await confirm(title: Text("Delete?",style: TextStyle(fontSize: 14,color: Colors.red[900])), content: Text("Do you want to delete?",style: TextStyle(fontSize: 12,color: Colors.black)), textOK: Text('Yes'),textCancel: Text('No'),context)?deleteDocumentFromFirestore(snapshot.data!.docs[index].id):Navigator.of(context).pop;

                                                            },
                                                            icon: Icon(Icons.delete_outline_sharp,
                                                                size: 18, color: Colors.black)),
                                                      ),

                                                    ]),
                                          ),
                                        ]),
                                  ),
                                  Text(
                                    "${childData['description_']}",
                                    textAlign: TextAlign.justify,
                                    maxLines: 1, // Set the maximum number of lines
                                    overflow: TextOverflow.ellipsis, // Display ellipsis (...) when content overflows
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black87.withOpacity(0.7),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),

                    );
                  },
                );
              },
            ),
          ]))
        ]),
      ),
    );
  }


  bool _isEnable = false;
  showEditingDialog(documentId, activity_, description, subject, class_, mQ,
      childData, snapshot, index) {
    TextEditingController activity_text_controller =
    TextEditingController(text: activity_);
    TextEditingController description_text_controller =
    TextEditingController(text: description);
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
              height: mQ.height * 0.5,
              // color: grey100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade100
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          maxLines: 2,
                          controller: activity_text_controller,
                          enabled: _isEnable,
                          style: TextStyle(
                            color: Colors.blue, // Set text color to blue
                            fontWeight: FontWeight.bold, // Set text weight to bold
                          ),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                            alignment: Alignment.topRight,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                                Icons.close, size: 14, color: Colors.black)),
                      ),
                    ],
                  ),
                  // content:
                  TextFormField(
                    controller: description_text_controller,
                    maxLines: null, // Automatically adjust the number of lines based on content
                    enabled: _isEnable,
                    textAlign: TextAlign.justify,
                  ),
                  // TextField(
                  //   controller: description_text_controller,
                  //   maxLines: 10,
                  //   enabled: _isEnable,
                  // ),
                  // actions: [
                  Spacer(),
                  (_isEnable)
                      ? Expanded(
                    child: IconButton(
                        onPressed: () {
                          collectionReferenceConsents
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
                      : (role_ == "Parent")?
                  TextButton(onPressed: () {


                    Navigator.of(context).pop();
                  },
                      child: Text('Close'))

                      :Row(
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
                              child: Text('All Parents'),

                              onPressed: () async {
                                await confirm(
                                    title: Text("Notification"),
                                    textOK: Text('Yes'),
                                    textCancel: Text('No'),
                                    context)
                                    ? addConsentStatementToClass(
                                    'All Parents',
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


  Future<List<DocumentSnapshot>> getStudentsByClass(String className) async {
    QuerySnapshot querySnapshot;
    (className == "All Parents")
        ? querySnapshot = await FirebaseFirestore.instance
            .collection('BabyData')
            .where('class_', whereIn: [
            'Infant',
            'Toddler',
            'Play Group - I',
            'Kinder Garten - I',
            'Kinder Garten - II'
          ]).get()
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
        'category_': 'Reminder'
      });
    });
    ToastContext().init(context);
    Toast.show(
      'Reminders sent to Parents successfully',
      // Get.context,
      backgroundRadius: 5,
      //gravity: Toast.top,
    );
  }
  displayReminders(mQ){
    return  StreamBuilder<QuerySnapshot>(
      stream:
      collectionReferenceReminders
          .where('child_', isEqualTo: widget.babyid_)
          .where('category_', isEqualTo: 'Reminder')
          .where('parentid_', isEqualTo: useremail)
          .where('result_', isEqualTo: 'Waiting')
      // .orderBy('status_', descending: true)
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
          // return Text('Curently, No consent is required.',
          // ); // No data
        }
        // Data is available, build the list
        return ListView.builder(
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final childData = snapshot.data!.docs[index].data()
            as Map<String, dynamic>;
            return
              CupertinoAlertDialog(
              title: Text(
                "${childData['title_']} ",
              ),
              content: InkWell(
                onTap: (){
                  showEditingDialog(
                      snapshot.data!.docs[index].id,
                      childData['title_'],
                      childData['description_'],
                      childData['subject_'],
                      childData['class_'],
                      mQ,
                      childData,
                      snapshot,
                      index);
                  _isEnable = false;

                },
                child: Text(
                  "${childData['description_']}",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                  maxLines: 6,
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Close',style: TextStyle(color: Colors.green)),
                  onPressed: () async {
                    // await confirm(context,title: Text('${childData['title_']} ',style: TextStyle(fontSize: 12),),content: Text('${childData['description_']} ',style: TextStyle(fontSize: 12),),textOK: Text('Ok',style: TextStyle(fontSize: 12),) ,textCancel:Text('Cancel ',style: TextStyle(fontSize: 12),) )
                    //     ?
                    collectionReferenceReminders
                        .doc(snapshot.data!
                        .docs[index].id)
                        .update({
                      "result_": "Yes"
                    })
                        // :null
                    ;
                  },
                ),
              ],
            );
          },
        );
      },
    );

  }

  void deleteDocumentFromFirestore(String documentId) {
    // Reference to the Firestore collection and document

    try {
      // Delete the document with the specified document ID
      setState(() async {
      await collectionReferenceConsents.doc(documentId).delete();
        // deleteionLoading = false;
      });
      // Navigator.of(context).pop();

    } catch (e) {
      print('Error deleting document: $e');
    }
      // Navigator.of(context).pop();
  }

}
