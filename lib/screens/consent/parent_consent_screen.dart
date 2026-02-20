import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/consent/view_consent_results.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:toast/toast.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/image_slide_show.dart';
import 'add_new_consent.dart';

class ParentConsentScreen extends StatefulWidget {
  String babyid;
  ParentConsentScreen({required this.babyid, super.key});

  @override
  State<ParentConsentScreen> createState() => _ParentConsentScreenState();
}

class _ParentConsentScreenState extends State<ParentConsentScreen> {
  final collectionReference = FirebaseFirestore.instance.collection(BabyData);
  CollectionReference collectionReferenceConsent =
      FirebaseFirestore.instance.collection(Consent);
  CollectionReference collectionReferenceActivity =
      FirebaseFirestore.instance.collection(Activity);


  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Consents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: kprimary,
        elevation: 0,
        centerTitle: true,
      ),
        floatingActionButton:
        (role_ == "Principal" || role_ == "Director")
            ?
        FloatingActionButton(
        onPressed: () {
          Get.to(AddNewConsentScreen());
        },
        child: const Text('+', style: TextStyle(fontSize: 24)),
      ):Container(),
      body: SingleChildScrollView(
        child: Column(children: [
          ImageSlideShowfunction(context),
          // List of Consents
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.description_rounded, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Consents',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Text(
                  getCurrentDateforattendance(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ],
            ),
          ),
(role_== "Parent")?
displayConsents(mQ):Container(),
          SingleChildScrollView(
              child: Column(children: [
                if (role_ != 'Parent')
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Results:',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569)),
                        ),
                        _buildFilterButton('Waiting', Colors.orange.shade700, Colors.orange.shade50),
                        _buildFilterButton('Yes', Colors.green.shade700, Colors.green.shade50),
                        _buildFilterButton('No', Colors.red.shade700, Colors.red.shade50),
                      ],
                    ),
                  ),
                Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4),
              child: StreamBuilder<QuerySnapshot>(
                stream: (role_ == 'Parent')
                    ? collectionReferenceActivity
                        .where('child_', isEqualTo: widget.babyid)
                        .where('category_', isEqualTo: 'Consent')
                        .where('parentid_', isEqualTo: useremail)
                        .where('result_', isNotEqualTo: "Waiting")
                        // .orderBy('result_', descending: true)
                        .snapshots()
                    : collectionReferenceConsent
                        .where('category_', isEqualTo: 'Consent')
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
                    // return Text('No new consent.',style: TextStyle(fontSize: 12,color: Colors.grey),
                    // ); // No data
                  }
                  // Data is available, build the list
                  return role_ != 'Parent'
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          primary: false,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final childData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                            return _buildStaffConsentCard(snapshot.data!.docs[index].id, childData, mQ, snapshot, index);
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          primary: false,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final childData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                            return _buildParentConsentCard(snapshot.data!.docs[index].id, childData, mQ, snapshot, index);
                          },
                        );
                },
              ),
            ),
          ]))
        ]),
      ),
    );
  }
  Widget _buildFilterButton(String label, Color color, Color bgColor) {
    return InkWell(
      onTap: () => Get.to(ViewConsentResults(results: label)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffConsentCard(String docId, Map<String, dynamic> data, Size mQ, dynamic snapshot, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openEditDialog(docId, data, snapshot, index, mQ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['date_'] ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade300, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue.shade600),
                          onPressed: () {
                            setState(() => _isEnable = true);
                            _openEditDialog(docId, data, snapshot, index, mQ);
                          },
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.black54),
                          onPressed: () async {
                            final confirmed = await confirm(
                              context,
                              title: const Text("Delete Consent"),
                              content: const Text("Are you sure you want to delete this consent statement?"),
                              textOK: const Text('Delete', style: TextStyle(color: Colors.red)),
                              textCancel: const Text('Cancel'),
                            );
                            if (confirmed) deleteDocumentFromFirestore(docId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data['title_'] ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                Text(
                  data['description_'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600, height: 1.4),
                ),
                const SizedBox(height: 12),
                showconsentsummaryofyesnowaiting(mQ, data['description_'], const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParentConsentCard(String docId, Map<String, dynamic> data, Size mQ, dynamic snapshot, int index) {
    final result = data['result_'] ?? 'Waiting';
    Color resultColor = Colors.orange.shade700;
    Color resultBg = Colors.orange.shade50;
    if (result == 'Yes') {
      resultColor = Colors.green.shade700;
      resultBg = Colors.green.shade50;
    } else if (result == 'No') {
      resultColor = Colors.red.shade700;
      resultBg = Colors.red.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openEditDialog(docId, data, snapshot, index, mQ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['date_'] ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade300, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: resultBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: resultColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data['title_'] ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  data['description_'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEditDialog(String docId, Map<String, dynamic> data, dynamic snapshot, int index, Size mQ) {
    showEditingDialog(
      docId,
      data['title_'],
      data['description_'],
      data['subject_'],
      data['class_'],
      mQ,
      data,
      snapshot,
      index,
    );
  }

  Widget showconsentsummaryofyesnowaiting(mQ, consent_text, Widget pppasa) {
    return StreamBuilder<QuerySnapshot>(
      stream: collectionReferenceActivity
          .where('category_', isEqualTo: 'Consent')
          .where('description_', isEqualTo: consent_text)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        int yes = 0, no = 0, waiting = 0;
        for (var doc in snapshot.data!.docs) {
          String result = doc['result_'];
          if (result == 'Yes') yes++;
          else if (result == 'No') no++;
          else if (result == 'Waiting') waiting++;
        }

        return Wrap(
          spacing: 8,
          children: [
            if (yes > 0) _buildBadge(yes.toString(), Colors.green, Icons.check_circle_outline_rounded),
            if (no > 0) _buildBadge(no.toString(), Colors.red, Icons.highlight_off_rounded),
            if (waiting > 0) _buildBadge(waiting.toString(), Colors.orange, Icons.timer_outlined),
          ],
        );
      },
    );
  }

  Widget _buildBadge(String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(count, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget PermissionsFromParent(consenttext, title, documentId) {
    return IconButton(
      icon: Icon(Icons.verified_outlined),
      // child: Text(consenttext),
      onPressed: () async {
        (await confirm(
                title: title,
                textOK: Text('Yes'),
                textCancel: Text('No'),
                context))
            ? collectionReferenceActivity
                .doc(documentId)
                .update({"result_": "Yes"})
            : collectionReferenceActivity
                .doc(documentId)
                .update({"result_": "No"});
      },
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
              height: mQ.height*0.6,
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

                  //         Row(
          //           children: [
          //             Expanded(
          //               child:
          //               Text(
          //                 "Consent",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
          //               ),
          //             ),
          //             Expanded(
          //               child: IconButton(
          //                   alignment: Alignment.topRight,
          //                   onPressed: () {
          //                     Navigator.of(context).pop();
          //                   },
          //                   icon: Icon(Icons.close,size: 14, color: Colors.black)),
          //             ),
          //           ],
          //         ),
          //     // content:
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'Subject',textAlign: TextAlign.left,
          //           style: TextStyle(
          //               fontSize: 12, fontWeight: FontWeight.normal),
          //         ),
          //         TextField(
          //           maxLines: 2,
          //           controller: activity_text_controller,
          //           enabled: _isEnable,
          //         ),
          // ]),
          //         Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          // children: [
          // Text(
          //           'Consent Statement',textAlign: TextAlign.left,
          //           style: TextStyle(
          //               fontSize: 12, fontWeight: FontWeight.normal),
          //         ),
          //         TextField(
          //           controller: description_text_controller,
          //           maxLines: 4,
          //           enabled: _isEnable,
          //         ),
          //       ],
          //     ),
              // actions: [
                (_isEnable)
                    ? Expanded(
                  child: IconButton(
                      onPressed: () {
                        collectionReferenceConsent
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
                    :
                (role_ == "Parent")?
                TextButton(

                  child:  Text(
                      'Close'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // await confirm(context,title: Text('${childData['title_']} ',style: TextStyle(fontSize: 12),),content: Text('${childData['description_']} ',style: TextStyle(fontSize: 12),),textOK: Text('Yes',style: TextStyle(fontSize: 12),) ,textCancel:Text('No ',style: TextStyle(fontSize: 12),) )
                    //     ? collectionReferenceActivity
                    //     .doc(snapshot.data!
                    //     .docs[index].id)
                    //     .update({
                    //   "result_": "Yes"
                    // }
                    // )
                    //     : collectionReferenceActivity
                    //     .doc(snapshot.data!
                    //     .docs[index].id)
                    //     .update({
                    //   "result_": "No"
                    // });
                    // Navigator.of(context).pop;
                  },
                )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: Text('Send to: ')),
                      Expanded(
                        child: PopupMenuButton<String>(
                          child: Text('Class',style: TextStyle(color: Colors.blue[900])),
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
                                title: Text("Consent"),
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
                                  title: Text("Consent"),
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
          );
        },
      );

  }

  Future<List<DocumentSnapshot>> getStudentsByClass(String className) async {
    QuerySnapshot querySnapshot;
    (className == "All Parents")
        ? querySnapshot = await FirebaseFirestore.instance
            .collection(BabyData)
            .where('class_', whereIn: [
            'Infant',
            'Toddler',
            'Play Group - I',
            'Kinder Garten - I',
            'Kinder Garten - II'
          ]).get()
        : querySnapshot = await FirebaseFirestore.instance
            .collection(BabyData)
            .where('class_', isEqualTo: className)
            .get();
    return querySnapshot.docs;
  }

  Future<void> addConsentStatementToClass(className, heading, statement) async {
    List<DocumentSnapshot> students = await getStudentsByClass(className);
    CollectionReference consentCollection =
        FirebaseFirestore.instance.collection(Activity);

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
        'category_': 'Consent'
      });
    });
    ToastContext().init(context);
    Toast.show('Record updated successfully',
        backgroundColor: Colors.black12, duration: 10);
  }

  void deleteDocumentFromFirestore(String documentId) {
    // Reference to the Firestore collection and document

    try {
      // Delete the document with the specified document ID
      setState(() async {
        await collectionReferenceConsent.doc(documentId).delete();
        // deleteionLoading = false;
      });
      // Navigator.of(context).pop();

    } catch (e) {
      print('Error deleting document: $e');
    }
    // Navigator.of(context).pop();
  }

  displayConsents(mQ) {
    return StreamBuilder<QuerySnapshot>(
      stream: collectionReferenceActivity
          .where('child_', isEqualTo: widget.babyid)
          .where('category_', isEqualTo: 'Consent')
          .where('parentid_', isEqualTo: useremail)
          .where('result_', isEqualTo: 'Waiting')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final childData = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kprimary.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    childData['title_'] ?? 'Consent Required',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    childData['description_'] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final confirmed = await confirm(
                              context,
                              title: const Text('Confirm'),
                              content: const Text('Are you sure you want to decline this consent?'),
                              textOK: const Text('Confirm'),
                              textCancel: const Text('Cancel'),
                            );
                            if (confirmed) collectionReferenceActivity.doc(doc.id).update({"result_": "No"});
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirmed = await confirm(
                              context,
                              title: const Text('Confirm'),
                              content: const Text('Do you agree and provide your consent?'),
                              textOK: const Text('Agree'),
                              textCancel: const Text('Cancel'),
                            );
                            if (confirmed) collectionReferenceActivity.doc(doc.id).update({"result_": "Yes"});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text('Agree', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

}
