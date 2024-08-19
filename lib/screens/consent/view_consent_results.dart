import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:toast/toast.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/image_slide_show.dart';

class ViewConsentResults extends StatefulWidget {
  String results;
  ViewConsentResults({required this.results, super.key});

  @override
  State<ViewConsentResults> createState() => _ViewConsentResultsState();
}

class _ViewConsentResultsState extends State<ViewConsentResults> {
  final collectionReference = FirebaseFirestore.instance.collection(BabyData);
  CollectionReference collectionReferenceConsent =
  FirebaseFirestore.instance.collection(Consent);
  CollectionReference collectionReferenceActivity =
  FirebaseFirestore.instance.collection(Activity);


  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Consents result: ${widget.results}',
          style: TextStyle(fontSize: 14, color: kWhite),
        ),
        backgroundColor: kprimary,
      ),
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageSlideShowfunction(context),
            Container(
              padding: EdgeInsets.only(right: 8, left: 8),
              height: mQ.height * 0.03,
              color: Colors.white,
              width: mQ.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Consents',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      getCurrentDateforattendance(),
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Comic Sans MS',
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'View Results',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            widget.results = 'Waiting';
                          });
                        },
                        child: Text(
                          'Waiting',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            widget.results = 'Yes';
                          });
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(color: Colors.green[900]),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            widget.results = 'No';
                          });
                        },
                        child: Text(
                          'No',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: collectionReferenceActivity
                          .where('category_', isEqualTo: 'Consent')
                          .where('result_', isEqualTo: widget.results)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          // Handle case when no data is available
                          return Text(
                            'No new consent.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          );
                        }

                        List<Map<String, dynamic>> uniqueEntries = [];

                        return ListView.separated(
                          padding: EdgeInsets.all(3),
                          separatorBuilder: (context, index) {
                            return Divider(
                              color: Colors.grey.withOpacity(0.1),
                            );
                          },
                          primary: false,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final childData =
                            snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                            bool isUniqueEntry = !uniqueEntries.any((entry) =>
                            entry['date'] == childData['date_'] &&
                                entry['title'] == childData['title_'] &&
                                entry['description'] ==
                                    childData['description_']);

                            if (isUniqueEntry) {
                              uniqueEntries.add({
                                'date': childData['date_'],
                                'title': childData['title_'],
                                'description': childData['description_'],
                              });

                              return Column(
                                children: [
                                  Container(
                                    padding: EdgeInsetsDirectional.symmetric(
                                        horizontal: mQ.width * 0.02),
                                    height: mQ.height * 0.1,
                                    width: mQ.width * 0.95,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.6),
                                          spreadRadius: 0.2,
                                          blurRadius: 0.5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: mQ.height * 0.05,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  " ${childData['date_']}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.grey.withOpacity(
                                                        0.4),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "${childData['title_']} ",
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.indigo
                                                        .withOpacity(0.9),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                        Expanded(
                                          child: IconButton(
                                            onPressed: () async {
                                              await confirm(
                                                  title: Text(
                                                    "Delete?",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red[900],
                                                    ),
                                                  ),
                                                  content: Text(
                                                    "Do you want to delete?",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  textOK: Text('Yes'),
                                                  textCancel: Text('No'),
                                                  context)
                                                  ? deleteDocumentFromFirestore(
                                                  snapshot.data!.docs[index].id)
                                                  : Navigator.of(context).pop;
                                            },
                                            icon: Icon(
                                              Icons.delete_outline_sharp,
                                              size: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                              // Expanded(
                                              //   child: Text(
                                              //     "${childData['child_']}",
                                              //     textAlign: TextAlign.right,
                                              //     style: TextStyle(
                                              //       fontWeight: FontWeight.normal,
                                              //       color: (childData["result_"] ==
                                              //           "Waiting")
                                              //           ? Colors.orange
                                              //           : (childData["result_"] ==
                                              //           "Yes")
                                              //           ? Colors.green[900]
                                              //           : Colors.red,
                                              //       fontSize: 12,
                                              //     ),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "${childData['description_']}",
                                          textAlign: TextAlign.justify,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black87.withOpacity(0.7),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Display BabyData details for each entry
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(BabyData)
                                        .doc(childData['child_'])
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.only(top: 25.0),
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      }
                                      if (!snapshot.hasData ||
                                          !snapshot.data!.exists) {
                                        print(childData['child_']);

                                        return
                                          Text('No data available for ${childData['child_']}');
                                      }

                                      final babyData =
                                      snapshot.data!.data() as Map<String, dynamic>;

                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: mQ.width * 0.03),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.teal[50],
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: CachedNetworkImageProvider(babyData['picture']),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${babyData['childFullName']} - ${babyData['fathersName']}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Class: ${babyData['class_']}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            }
                            else {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection(BabyData)
                                          .doc(childData['child_'])
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.only(top: 25.0),
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        }
                                        if (!snapshot.hasData ||
                                            !snapshot.data!.exists) {
                                          print(childData['child_']);

                                          return
                                            Text('No data available.${childData['child_']}');
                                        }

                                        final babyData = snapshot.data!.data()
                                        as Map<String, dynamic>;

                                        return Padding(
                                          padding: EdgeInsets.symmetric(horizontal: mQ.width * 0.03),
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.teal[50],
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 70,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: CachedNetworkImageProvider(babyData['picture']),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${babyData['childFullName']} - ${babyData['fathersName']}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Class: ${babyData['class_']}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }


   deleteDocumentFromFirestore(String documentId) {
    // Reference to the Firestore collection and document

    try {
      // Delete the document with the specified document ID
      setState(() async {
        await collectionReferenceActivity.doc(documentId).delete();
        // deleteionLoading = false;
      });
      // Navigator.of(context).pop();

    } catch (e) {
  // ToastContext().init(context);
  // Toast.show('Record ${documentId} can not deleted',
  // backgroundColor: Colors.red, duration: 10);
      print('Error deleting document: $e');
    }
  ToastContext().init(context);
  Toast.show('Record ${documentId} deleted',
  backgroundColor: Colors.red, duration: 5);
    // Navigator.of(context).pop();
  }


}
