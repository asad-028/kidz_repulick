import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:snackbar/snackbar.dart';

bool isLoading = true;
bool showRecord = false;
List<String> dateRanges = []; // List to store date ranges
List<Map<String, dynamic>> dateRangeData = []; // List to store date range data
var selectedDateRange;
int checkedInCount = 0;
int absentCount = 0;
var selectedItemDocumentId;

final collectionReferencebabydata =
    FirebaseFirestore.instance.collection(BabyData);
final collectionReference = FirebaseFirestore.instance.collection(Activity);
final collectionReferenceReports =
    FirebaseFirestore.instance.collection(Reports);

class BiWeeklyReportPrincipalScreen extends StatefulWidget {
  final String babyID_;
  final String babypicture_;
  final String name_;
  final String date_;
  final String class_;

  BiWeeklyReportPrincipalScreen({
    Key? key,
    required this.babyID_,
    required this.name_,
    required this.date_,
    required this.class_,
    required this.babypicture_,
  }) : super(key: key);

  @override
  _BiWeeklyReportPrincipalScreenState createState() =>
      _BiWeeklyReportPrincipalScreenState();
}

class _BiWeeklyReportPrincipalScreenState
    extends State<BiWeeklyReportPrincipalScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dateRanges.clear();
    dateRangeData.clear();
    selectedDateRange = null;
    showRecord = false;
  }

  bool deleteionLoading = false;
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: (role_ == "Principal")
          ? Container(
              color: kprimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Approve', style: TextStyle(color: Colors.white)),
                  IconButton(
                    icon: Icon(
                      Icons.done_all,
                      size: 24,
                      color: Colors.white,
                    ),
                    onPressed: () async => {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                      await confirm(title: Text('Approve Report', style: TextStyle(fontSize: 12)), content: Text('Do you want to Aapprove?', style: TextStyle(fontSize: 12)), textOK: Text('Yes'), textCancel: Text('No'), context) ? updateDocumentsWithStatusForwarded(widget.babyID_, "Forwarded", "Approved", context) : Get.back(),
                    },
                  ),
                ],
              ),
            )
          : (role_ == "Parent")
              ? Container(
                  color: kprimary,
                  child: TextButton(
                    onPressed: () async {
                      await collectionReferenceReports.doc(widget.babyID_).update(
                          {"BiWeekly_Approved": 0});
                      await FirebaseFirestore.instance
                          .collection(Activity)
                          .doc(selectedItemDocumentId)
                          .update({'parentfeedback_': "Seen"})
                          .then((_) => print(
                              'Status updated to Approved $selectedItemDocumentId'))
                          .catchError((error) =>
                              print('Failed to update status: $error '));
                      Get.back();
                    },
                    child: Text('Close',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                )
              : (role_ == "Director")
                  ? Container(
                      color: kprimary,
                      child: TextButton(
                        onPressed: () async {
                          await collectionReferencebabydata
                              .doc(widget.babyID_)
                              .update({'directorremarks_': "Seen"});
                          Navigator.pop(context);
                        },
                        child: Text('Close',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white)),
                      ))
                  : Container(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: 8.0, bottom: 2.0, right: 8.0, top: 28.0),
              child: Container(
                color: Colors.brown[50],
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                          child: SizedBox(
                            width: mQ.width * 0.1,
                            height: mQ.height * 0.05,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    widget.babypicture_,
                                  ),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: mQ.width * 0.45,
                          height: mQ.height * 0.05,
                          child: Column(
                            children: [
                              Text('BI-WEEKLY ACTIVITIES',
                                  style: TextStyle(
                                      fontSize: mQ.height * 0.018,
                                      fontWeight: FontWeight.bold)),
                              Text('(Academic Session 2024-2025)',
                                  style: TextStyle(
                                      fontSize: mQ.height * 0.013,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          width: mQ.width * 0.1,
                          height: mQ.height * 0.05,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/logo.png',
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(" ${(widget.name_)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: mQ.height * 0.02,
                                fontFamily: 'Comic Sans MS',
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(Activity)
                          .where('child', isEqualTo: widget.babyID_)
                          .where('category_', isEqualTo: 'BiWeeklyReport')
                          .where("biweeklystatus_",
                              isEqualTo: (role_ == 'Principal')
                                  ? "Forwarded"
                                  : "Approved")
                          .orderBy('forwardDate', descending: true)
                          .limit((role_ == 'Principal') ? 1 : 2)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return Text('No new BiWeekly activities.');
                        }
                        dateRanges.clear();
                        dateRangeData.clear();
                        for (var activity in docs) {
                          print(
                              '${activity['dateRange']} ${activity['forwardDate']}');
                          var dateRange = activity['dateRange'];
                          var documentId = activity.id;
                          var checkedInCount = activity['checkedin'];
                          var absentCount = activity['absent'];
                          if (!dateRanges.contains(dateRange)) {
                            dateRanges.add(dateRange);
                            if (dateRanges.isNotEmpty) {
                              dateRangeData.add({
                                'dateRange': dateRange,
                                'checkedInCount': checkedInCount,
                                'absentCount': absentCount,
                                'documentId': documentId,
                              });
                            }
                          }
                        }
                        selectedDateRange =
                            selectedDateRange ?? dateRanges.first;
                        final selectedData2 = dateRangeData.firstWhere(
                          (element) =>
                              element['dateRange'] == selectedDateRange,
                          orElse: () =>
                              {}, // Return an empty map instead of null
                        );
                        checkedInCount = selectedData2[
                            'checkedInCount']; // Handle potential missing value
                        absentCount = selectedData2[
                            'absentCount']; // Handle potential missing value
                        selectedItemDocumentId = selectedData2['documentId'];
                        return StreamBuilder<QuerySnapshot>(
                          stream:
                              // condition
                              (showRecord)
                                  ? collectionReference
                                      .where('id', isEqualTo: widget.babyID_)
                                      .where('category_', isEqualTo: 'BiWeekly')
                                      .where('BiWeeklyReport',
                                          isEqualTo: selectedDateRange)
                                      .snapshots()
                                  : collectionReference
                                      .where('id', isEqualTo: widget.babyID_)
                                      .where('BiWeeklyReport',
                                          isEqualTo: selectedDateRange)
                                      .where('category_', isEqualTo: 'BiWeekly')
                                      // .where('biweeklystatus_', isEqualTo: role_ == 'Principal' ? 'Forwarded' :'Approved')
                                      // .where(condition)
                                      .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(top: mQ.height * 0.3),
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
                              return Center(
                                child: Padding(
                                    padding:
                                        EdgeInsets.only(top: mQ.height * 0.3),
                                    child: Text('No Data')),
                              );
                            }

                            Map<String, List<Map<String, dynamic>>>
                                groupedActivities = {};
                            snapshot.data!.docs.forEach((activity) {
                              String subject = activity['Subject'];
                              if (groupedActivities.containsKey(subject)) {
                                groupedActivities[subject]!.add({
                                  'id': activity.id,
                                  'Activity': activity['Activity'],
                                  'description': activity['description'],
                                  'date_': activity['date_'],
                                  'time_': activity['time_'],
                                  'biweeklystatus_':
                                      activity['biweeklystatus_'],
                                  'isChecked':
                                      false, // Initialize isChecked field for checkboxes
                                });
                              } else {
                                groupedActivities[subject] = [
                                  {
                                    'id': activity.id,
                                    'Activity': activity['Activity'],
                                    'description': activity['description'],
                                    'date_': activity['date_'],
                                    'time_': activity['time_'],
                                    'biweeklystatus_':
                                        activity['biweeklystatus_'],
                                    'isChecked':
                                        false, // Initialize isChecked field for checkboxes
                                  }
                                ];
                              }
                            });

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.035,
                                      child: DropdownButton<String>(
                                        value: selectedDateRange,
                                        onChanged: (newValue) {
                                          if (newValue != null &&
                                              newValue != 'Select Date Range') {
                                            setState(() {
                                              selectedDateRange = newValue;
                                              final selectedData =
                                                  dateRangeData.firstWhere(
                                                (element) =>
                                                    element['dateRange'] ==
                                                    newValue,
                                                orElse: () =>
                                                    {}, // Return an empty map instead of null
                                              );
                                              checkedInCount = selectedData[
                                                  'checkedInCount']; // Handle potential missing value
                                              absentCount = selectedData[
                                                  'absentCount']; // Handle potential missing value
                                              selectedItemDocumentId =
                                                  selectedData['documentId'];
                                              showRecord =
                                                  role_ != 'Principal';
                                            });
                                          }
                                        },
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: 'Select Date Range',
                                            child: Text(
                                              'Select Date Range',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            enabled: false,
                                          ),
                                          ...dateRanges
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.013),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text('Days Present: $checkedInCount',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Colors.blue[900],
                                                  fontSize: mQ.height * 0.013)),
                                          Spacer(),
                                          Text('Absent: $absentCount',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  color: Colors.red[900],
                                                  fontSize: mQ.height * 0.013)),
                                        ],
                                      ),
                                    ),
                                    role_ == "Principal"
                                        ? IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        'Update Attendance'),
                                                    content: StatefulBuilder(
                                                      builder:
                                                          (BuildContext context,
                                                              StateSetter
                                                                  setState) {
                                                        return Form(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              DropdownButtonFormField<
                                                                  String>(
                                                                value:
                                                                    selectedDateRange,
                                                                onChanged:
                                                                    (newValue) {
                                                                  setState(() {
                                                                    selectedDateRange =
                                                                        newValue!;
                                                                    final selectedData =
                                                                        dateRangeData
                                                                            .firstWhere(
                                                                      (element) =>
                                                                          element[
                                                                              'dateRange'] ==
                                                                          newValue,
                                                                    );
                                                                    checkedInCount =
                                                                        selectedData[
                                                                            'checkedInCount'];
                                                                    absentCount =
                                                                        selectedData[
                                                                            'absentCount'];
                                                                  });
                                                                },
                                                                items: dateRanges
                                                                    .map((String
                                                                        value) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value),
                                                                  );
                                                                }).toList(),
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Select Date Range',
                                                                ),
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    checkedInCount
                                                                        .toString(),
                                                                onChanged:
                                                                    (value) {
                                                                  checkedInCount =
                                                                      int.parse(
                                                                          value);
                                                                },
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Present days',
                                                                ),
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    absentCount
                                                                        .toString(),
                                                                onChanged:
                                                                    (value) {
                                                                  absentCount =
                                                                      int.parse(
                                                                          value);
                                                                },
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Absent days',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          // Implement logic to update Firestore data
                                                          updateFirestoreData(
                                                              selectedDateRange,
                                                              checkedInCount,
                                                              absentCount);
                                                          Get.back();
                                                        },
                                                        child: Text('Update'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(Icons.edit, size: 16),
                                          )
                                        : Container(),
                                  ],
                                ),
                                Container(
                                  color: Colors.blue[50],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children:
                                        groupedActivities.entries.map((entry) {
                                      return Column(
                                        children: [
                                          Container(
                                            width: mQ.width * 0.96,
                                            color: Colors.grey[50],
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: Text(
                                                '${entry.key}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: mQ.width * 0.94,
                                            color: Colors.pinkAccent[50],
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children:
                                                  entry.value.map((activity) {
                                                return (activity[
                                                                'biweeklystatus_'] !=
                                                            'Approved' &&
                                                        role_ == 'Parent')
                                                    ? Container()
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  '${activity['Activity']}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              (role_ ==
                                                                      "Parent")
                                                                  ? Container()
                                                                  : InkWell(
                                                                      onTap:
                                                                          () {
                                                                        showEditingDialog(
                                                                          activity[
                                                                              'id'],
                                                                          activity[
                                                                              'Activity'],
                                                                          activity[
                                                                              'description'],
                                                                          entry
                                                                              .key,
                                                                          activity[
                                                                              'biweeklystatus_'],
                                                                        );
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .edit),
                                                                    ),
                                                              (role_ ==
                                                                      "Parent")
                                                                  ? Container()
                                                                  : activity['biweeklystatus_'] ==
                                                                          'Approved'
                                                                      ? Icon(
                                                                          Icons
                                                                              .done_all_sharp,
                                                                          color:
                                                                              Colors.blue[900],
                                                                        )
                                                                      : activity['biweeklystatus_'] ==
                                                                              'Forwarded'
                                                                          ? Icon(
                                                                              Icons.done_all,
                                                                              color: Colors.grey,
                                                                            )
                                                                          : Icon(
                                                                              Icons.done_outlined,
                                                                              color: Colors.grey,
                                                                            ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4.0),
                                                            child: Text(
                                                              '${activity['description']}',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                              }).toList(),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<QuerySnapshot> fetchData() async {
    if (showRecord) {
      return await collectionReference
          .where('id', isEqualTo: widget.babyID_)
          .where('category_', isEqualTo: 'BiWeekly')
          .where('BiWeeklyReport', isEqualTo: selectedDateRange)
          .get();
    } else {
      return await collectionReference
          .where('id', isEqualTo: widget.babyID_)
          .where('BiWeeklyReport', isEqualTo: selectedDateRange)
          .where('category_', isEqualTo: 'BiWeekly')
          .get();
    }
  }

// Inside FutureBuilder

  void updateDocumentsWithStatusForwarded(
      babyid_, existingstatus_, update_, context) async {
    final CollectionReference collection =
        FirebaseFirestore.instance.collection(Activity);
    final QuerySnapshot snapshot = await collection
        .where('biweeklystatus_', isEqualTo: existingstatus_)
        .where('id', isEqualTo: babyid_)
        .get();

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      // Update the status to a new value, e.g., 'UpdatedStatus'
      await collection.doc(doc.id).update({
        'biweeklystatus_': update_,
      });

      await collectionReferenceReports.doc(widget.babyID_).update({
        'BiWeekly_$update_': FieldValue.increment(1),
        'BiWeekly_$existingstatus_': FieldValue.increment(-1)
      });
    }
    // (role_ == 'Principal')
    //   ?
    await updateFirestore(update_, existingstatus_);
    // : Null;
    snack('Report ${update_} successfully',);
  }

  Future<void> updateFirestore(String update_, existingstatus_) async {
    try {
      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query the documents to update
      QuerySnapshot querySnapshot = await firestore
          .collection(Activity)
          .where('dateRange', isEqualTo: selectedDateRange)
          .where('category_', isEqualTo: 'BiWeeklyReport')
          .where('child', isEqualTo: widget.babyID_)
          .get();

      // Update each document found in the query
      querySnapshot.docs.forEach((doc) async {
        // Update the biweeklystatus_ field
        await doc.reference.update({'biweeklystatus_': update_});
      });
   Get.back();
    } catch (error) {
      print('Error updating documents in Firestore: $error');
    Get.back();
    }
    Get.back();
  }

  showEditingDialog(documentId, activity_, description, subject, biweeklystatus_) {
    bool _isEnable = false;
    TextEditingController description_text_controller =
        TextEditingController(text: description);
    TextEditingController subject_text_controller =
        TextEditingController(text: subject);
    TextEditingController activity_text_controller =
        TextEditingController(text: activity_);
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Material(
                child: CupertinoAlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(Icons.cancel,
                              size: 12, color: Colors.black)),
                    ],
                  ),
                  TextField(
                    controller: subject_text_controller,
                    enabled: _isEnable,
                  ),
                ],
              ),
              content: Column(
                children: [
                  TextField(
                    controller: activity_text_controller,
                    enabled: _isEnable,
                  ),
                  TextField(
                    controller: description_text_controller,
                    maxLines: 5,
                    enabled: _isEnable,
                  ),
                  (_isEnable)
                      ? IconButton(
                          onPressed: () {
                            collectionReference.doc(documentId).update({
                              "Subject": subject_text_controller.text,
                              "Activity": activity_text_controller.text,
                              "description": description_text_controller.text,
                            });
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.save,
                            color: Colors.blue,
                          ))
                      : Container(),
                ],
              ),
              actions: [
                deleteionLoading
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: CircularProgressIndicator(),
                      ))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            IconButton(
                                icon: Icon(Icons.edit),
                                iconSize: 18,
                                color: Colors.blue[600],
                                onPressed: () {
                                  setState(() {
                                    _isEnable = true;
                                  });
                                }),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    deleteionLoading = true;
                                  });
                                  deleteDocumentFromFirestore(documentId,biweeklystatus_);
                                },
                                icon: Icon(Icons.delete_outline_sharp,
                                    size: 18, color: Colors.black)),
                          ]),
              ],
            ));
          });
        });
  }

  Future<void> deleteDocumentFromFirestore(String documentId, biweeklystatus_) async {
    // Reference to the Firestore collection and document

    try {
      // Delete the document with the specified document ID
      setState(() {
        deleteionLoading = false;
      });
      await collectionReference.doc(documentId).delete();
      await collectionReferenceReports.doc(widget.babyID_).update({
        'BiWeekly_$biweeklystatus_': FieldValue.increment(-1)
      });
    } catch (e) {
      print('Error deleting document: $e');
    }
    Get.back();
  }

  Future<void> updateFirestoreData(
      String selectedDateRange, int checkedInCount, int absentCount) async {
    try {
      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query the documents to update
      QuerySnapshot querySnapshot = await firestore
          .collection(Activity)
          .where('dateRange', isEqualTo: selectedDateRange)
          .where('category_', isEqualTo: 'BiWeeklyReport')
          .where('child', isEqualTo: widget.babyID_)
          .get();

      // Update each document found in the query
      querySnapshot.docs.forEach((doc) async {
        // Update the checkedInCount and absentCount fields
        await doc.reference.update({
          'checkedin': checkedInCount,
          'absent': absentCount,
        });
        print('Document updated successfully!');
      });
    } catch (error) {
      print('Error updating documents in Firestore: $error');
    }
  }
}
