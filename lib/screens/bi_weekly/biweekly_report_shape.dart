import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:snackbar/snackbar.dart';
import '../../utils/const.dart';
import 'biweekly_report_principal.dart';

RxBool isLoading = true.obs;
int? checkedInCount ;
int? absentCount ;
List<String> attendanceDateRange = [];
final collectionReferencebabydata = FirebaseFirestore.instance.collection(BabyData);
class BiWeeklyReportShapeScreen extends StatefulWidget {
  final String babyID_;
  final String babypicture_;
  final String name_;
  final String reportdate_;
  final String class_;

  BiWeeklyReportShapeScreen({
    Key? key,
    required this.babyID_,
    required this.name_,
    required this.reportdate_,
    required this.class_,
    required this.babypicture_,
  }) : super(key: key);
  final collectionReference = FirebaseFirestore.instance.collection(Activity);

  @override
  State<BiWeeklyReportShapeScreen> createState() => _BiWeeklyReportShapeScreenState();
}

class _BiWeeklyReportShapeScreenState extends State<BiWeeklyReportShapeScreen> {
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery
        .of(context)
        .size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kprimary, // Change this to the desired color
    ));
    return Scaffold(
        bottomNavigationBar:
        (role_ == "Teacher")
            ? Container(
          color: kprimary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Forward', style: TextStyle(color: Colors.white)),
              IconButton(
                  icon:
                  Icon(color: Colors.white, Icons.send, size: 24),
                  onPressed: () async =>
                  {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => Center(
                        child: CircularProgressIndicator(),

                      ),
                    ),
                    await confirm(title: Text('Forward Report', style: TextStyle(fontSize: 12)), content: Text('Do you want to continue?', style: TextStyle(fontSize: 12)), textOK: Text('Yes'), textCancel: Text('No'), context) ? await updateDocumentsWithStatusForwarded(widget.babyID_, "New", "Forwarded", context) : Get.back(),
                  }),
            ],
          ),
        )
            : Container(),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
              top: mQ.height * 0.05,
              left: mQ.width * 0.02,
              right: mQ.width * 0.02,
              bottom: mQ.height * 0.03),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(10), // Apply rounded corners if desired
              border: Border.all(color: Colors.grey, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2), // Add a shadow effect
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BiWeeklySharingWithParents(
                  baby: widget.babyID_,
                  babypicture: widget.babypicture_,
                  babyname: widget.name_,
                  // MoodScreen(baby: babyID_,
                  subject: "Approved Biweekly",
                  category: 'BiWeekly',
                  reportdate_: widget.reportdate_??getCurrentDate(),
                  subjectcolor_: Colors.brown.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ));
  }

  Future <void> updateDocumentsWithStatusForwarded(babyid_, existingstatus_, update_,
      context) async {
    final CollectionReference collection = FirebaseFirestore.instance.collection(Activity);
    final CollectionReference collectionReferenceReports = FirebaseFirestore.instance.collection(Reports);
    final QuerySnapshot snapshot = await collection
        .where('biweeklystatus_', isEqualTo: existingstatus_)
        .where('id', isEqualTo: babyid_)
        .get();

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      // Update the status to a new value, e.g., 'UpdatedStatus'
      await collection.doc(doc.id).update({
        'biweeklystatus_': update_,
        'BiWeeklyReport':
         '${DateFormat('dd MMM').format(startDate!)} to ${DateFormat('dd MMM yyyy').format(endDate!)}'
      });
      try {
        await collectionReferenceReports.doc(babyid_).set({
          "BiWeekly_Forwarded": FieldValue.increment(1),
          "BiWeekly_New": FieldValue.increment(-1),
        }, SetOptions(merge: true));
      } catch (error) {
        print('Error fetching data: $error');
      }

    }
    await addToFirestore(update_);
    snack('Report ${update_} successfully', );
  }

  Future <void> addToFirestore(update_) async {
    try {
      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Format the date range
      String dateRange = '${DateFormat('dd MMM').format(startDate!)} to ${DateFormat('dd MMM yyyy').format(endDate!)}';

      // Define the data to be added
      Map<String, dynamic> data = {
        'category_' : "BiWeeklyReport",
      'dateRange': dateRange,
      'forwardDate': '${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
        'child': widget.babyID_,
        'checkedin': checkedInCount,
        'absent': absentCount,
        'biweeklystatus_': update_,
        // Add other fields as needed
      };

      // Add the data to Firestore
      await firestore.collection(Activity).add(data);


      print('Data added to Firestore successfully!');
    Get.back();
    } catch (error) {
      print('Error adding data to Firestore: $error');
    Get.back();
    }
    Get.back();
  }
}


class BiWeeklySharingWithParents extends StatefulWidget {
  final baby;
  final reportdate_;
  final subject;
  final babyname;
  final babypicture;
  final category;
  final Color subjectcolor_;
  final fathersEmail_;

  BiWeeklySharingWithParents({
    super.key,
    this.baby,
    this.reportdate_,
    this.subject,
    this.babyname,
    this.babypicture,
    required this.subjectcolor_,
    this.category,
    this.fathersEmail_,
  });
  String activitybabyid_ = '';

  @override
  State<BiWeeklySharingWithParents> createState() =>
      _BiWeeklySharingWithParentsState();
}
  var startDate;
  var endDate;

class _BiWeeklySharingWithParentsState extends State<BiWeeklySharingWithParents> {
  final collectionReference = FirebaseFirestore.instance.collection(Activity);
  bool deleteionLoading = false;
  ScrollController scrollController = ScrollController();
  @override
   initState()  {
    // TODO: implement initState
    super.initState();
 setdaterange();
  }
  setdaterange() {
    DateTime now = DateTime.now();
    DateTime currentDate = DateTime.now();
    DateTime fifteenDaysAgo = currentDate.subtract(Duration(days: 15));

    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    fifteenDaysAgo = DateTime(
        fifteenDaysAgo.year, fifteenDaysAgo.month, fifteenDaysAgo.day);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kprimary, // Change this to the desired color
    ));

    if (now.day >= 1 && now.day <= 15) {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month, 15, 23, 59, 59);
      // endDate = DateTime(now.year, now.month, 15);
    } else {
      startDate = DateTime(now.year, now.month, 16);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      // endDate = DateTime(now.year, now.month, 31);
    };
  }
  bool customDate = false;

  @override
  Widget build(BuildContext context) {

    final mQ = MediaQuery.of(context).size;
   attendanceDateRange= getDateRange();
    return Column(
      children: [
        InkWell(
          onTap: ()
              async {
 await _selectStartDate(context);
await _selectEndDate(context);
            setState(() {

            });
          },
          child:
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(Activity)
                  .where('id', isEqualTo: widget.baby)
                  .where('Subject', isEqualTo: 'Attendance')
                  // .where('Activity', whereIn: ['Checked In', 'Absent'])
                  .where('date_', whereIn: attendanceDateRange)
                  .where('status_', isEqualTo: "Approved")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                checkedInCount = 0;
                absentCount = 0;
                snapshot.data!.docs.forEach((activity) {
                    if (activity['Activity'] == 'Absent') {
                    absentCount= (absentCount! + 1);
                  // print('Absent $absentCount Date: ${activity['date_']}');
                    }
                  else
                  if (activity['Activity'] == 'Checked In') {
                    checkedInCount = checkedInCount! + 1;
                  print('Present $checkedInCount Activity Date: ${activity['date_']} ${DateFormat('dd-MM-yyyy').format(startDate)}');
print(DateFormat('dd-MM-yyyy').format(endDate));
//                   print('End Date : ${endDate}');
                  }

                });

                return Container(
                  color: Colors.brown[50],
                  child: Column(
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: mQ.width * 0.1,
                              height: mQ.height * 0.05,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      widget.babypicture,
                                    ),
                                    fit: BoxFit.fitWidth,
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
                                  // (Academic Session 2024-2025),
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
                                      // width: mQ.width * 0.07),
                                    ),
                                    // Image.network(babypicture_ ,
                                    fit: BoxFit.fitWidth),
                              ),
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date:',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: mQ.height * 0.013),
                                ),
                                Text(
                                  '${DateFormat('dd MMM').format(startDate!)} to ${DateFormat('dd MMM yyyy').format(endDate!)}',
                                  // 'Select Dates',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: mQ.height * 0.013),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                              child: Text(" ${(widget.babyname)}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: mQ.height * 0.02,
                                      fontFamily: 'Comic Sans MS',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue))),
                          // Expanded(child: Text(,textAlign: TextAlign.center,)),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Days Present: $checkedInCount',
                                  textAlign: TextAlign.right,
                                  style:
                                      TextStyle(fontSize: mQ.height * 0.013)),
                              // style: TextStyle(fontSize: 10),),
                              Text('Absent: $absentCount',
                                  textAlign: TextAlign.right,
                                  style:
                                      TextStyle(fontSize: mQ.height * 0.013)),
                              // style: TextStyle(fontSize: 10),),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ), //header of Bi Weekly Report
        StreamBuilder<QuerySnapshot>(
          stream: collectionReference
              .where('category_', isEqualTo: 'BiWeekly')
              .where('id', isEqualTo: widget.baby)
              .where( "biweeklystatus_", whereIn: ["New"]
              )
              // .where(biweeklystatus_)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text('No Activities recorded');
            }


            Map<String, List<Map<String, dynamic>>> groupedActivities = {};
            snapshot.data!.docs.forEach((activity) {
              String subject = activity['Subject'];
              if (groupedActivities.containsKey(subject)) {
                groupedActivities[subject]!.add({
                  'id': activity.id,
                  'Activity': activity['Activity'],
                  'description': activity['description'],
                  'date_': activity['date_'],
                  'time_': activity['time_'],
                  'biweeklystatus_': activity['biweeklystatus_'],
                  'isChecked': false, // Initialize isChecked field for checkboxes
                });
              } else {
                groupedActivities[subject] = [
                  {
                    'id': activity.id,
                    'Activity': activity['Activity'],
                    'description': activity['description'],
                    'date_': activity['date_'],
                    'time_': activity['time_'],
                    'biweeklystatus_': activity['biweeklystatus_'],
                    'isChecked': false, // Initialize isChecked field for checkboxes
                  }
                ];
              }
            });


            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: groupedActivities.entries.map((entry) {
                return Column(
                  children: [
                    Container(
                      width: mQ.width * 0.86,
                      color: Colors.grey[50],
                      child: Text(
                        '${entry.key}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Container(
                      width: mQ.width * 0.84,
                      color: Colors.pinkAccent[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: entry.value.map((activity) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${activity['Activity']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                      child:
                                      activity['biweeklystatus_']=='Approved'? Icon(Icons.done_all_sharp,color: Colors.blue[900],):activity['biweeklystatus_']=='Forwarded'? Icon(Icons.done_all,color: Colors.grey,):Icon(Icons.done_outlined,color: Colors.grey,)
                                    // activity['biweeklystatus_']
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (role_ != "Parent") {
                                        showEditingDialog(
                                          activity['id'],
                                          activity['Activity'],
                                          activity['description'],
                                          entry.key,
                                        );
                                      }
                                    },
                                    child: Icon(Icons.edit),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  '${activity['description']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
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
            );
          },
        ),
      ],
    );
  }
  List<String> getDateRange() {
    List<String> dateRange = [];
    DateTime date = startDate;

    while (date.isBefore(endDate) || date.isAtSameMomentAs(endDate)) {
      dateRange.add(DateFormat('dd-MM-yyyy').format(date));
      date = date.add(Duration(days: 1));
    }

    return dateRange;
  }
  showEditingDialog(documentId, activity_, description, subject) {
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
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: subject_text_controller,
                      enabled: _isEnable,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                        alignment: AlignmentDirectional.topEnd,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon:
                            Icon(Icons.cancel, size: 12, color: Colors.black)),
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
                                  deleteDocumentFromFirestore(documentId);
                                },
                                icon: Icon(Icons.delete_outline_sharp,
                                    size: 18, color: Colors.black)),
                          ]),
              ],
            ));
          });
        });
  }

  Future<void> deleteDocumentFromFirestore(String documentId) async {
    // Reference to the Firestore collection and document

    try {
      // Delete the document with the specified document ID
      setState(() {
        deleteionLoading = false;
      });
      await collectionReference.doc(documentId).delete();
      await collectionReferenceReports.doc(widget.baby).update({
        // "BiWeekly_Forwarded": FieldValue.increment(1),
        "BiWeekly_New": FieldValue.increment(-1),
      });

    } catch (e) {
      print('Error deleting document: $e');
    }
    Get.back();
  }

  Future _selectStartDate(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        helpText: 'Select Start Date');
    if (pickedStartDate != null) {
      setState(() {
        startDate = pickedStartDate;
      });

      return pickedStartDate;
    }
  }

  Future _selectEndDate(BuildContext context) async {
    final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        helpText: 'Select End Date');
    if (pickedEndDate != null) {
      setState(() {
        endDate = pickedEndDate;
        customDate = true;
      });
      // return  pickedEndDate;
    }
  }


}
