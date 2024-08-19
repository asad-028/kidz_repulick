import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

class ParentDailySheetScreen extends StatefulWidget {
  final baby;
  final reportdate_;
  final subject;
  final boxheading;
  final category;
  final Color subjectcolor_;
  final Color boxcolor_;
  final double boxwidth_;
  final double? boxheight_;
final String reportType_;
  ParentDailySheetScreen({
    super.key,
    this.baby,
    this.reportdate_,
    this.subject,
    required this.subjectcolor_,
    this.category, this.boxheading, this.boxheight_, required this.boxcolor_, required this.boxwidth_, required this.reportType_,
  });
  String activitybabyid_ = '';

  @override
  State<ParentDailySheetScreen> createState() => _ParentDailySheetScreenState();
}

class _ParentDailySheetScreenState extends State<ParentDailySheetScreen> {
  final collectionReference = FirebaseFirestore.instance.collection(Activity);
  final collectionReferenceReports = FirebaseFirestore.instance.collection(Reports);
  bool deleteionLoading = false;
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    var condition;
    (role_ == "Teacher") ?  condition = collectionReference
        .where('id', isEqualTo: widget.baby)
        .where('date_', isEqualTo: widget.reportdate_)
        .where('Subject', isEqualTo: widget.subject)
        .where('category_', isEqualTo: widget.category)
        .where('status_', isEqualTo: widget.reportType_)
        :
    (role_ == "Principal") ? condition = collectionReference
        .where('id', isEqualTo: widget.baby)
        .where('date_', isEqualTo: widget.reportdate_)
        .where('Subject', isEqualTo: widget.subject)
        .where('category_', isEqualTo: widget.category)
        .where('status_', isEqualTo: widget.reportType_)
        // .where('status_', isEqualTo: 'Forwarded')
        :(role_ == "Director") ? condition = collectionReference
        .where('id', isEqualTo: widget.baby)
        .where('date_', isEqualTo: widget.reportdate_)
        .where('Subject', isEqualTo: widget.subject)
        .where('category_', isEqualTo: widget.category)
        .where('status_', isEqualTo: widget.reportType_)
        :
    (role_ == "Parent")?
    condition = collectionReference
        .where('id', isEqualTo: widget.baby)
        .where('date_', isEqualTo: widget.reportdate_)
        .where('Subject', isEqualTo: widget.subject)
        .where('category_', isEqualTo: widget.category)
        .where('status_', isEqualTo: 'Approved')
        : Null
    ;


    return
    Column(
        children: [
      Container(
        height: mQ.height * 0.016,
        color: Colors.grey[50],
        width: mQ.width*0.4,
        alignment: FractionalOffset.center,
        child:
        Text(
          widget.boxheading,
          style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontFamily: "Comic Sans MS",
              color: widget.subjectcolor_,
              fontSize: mQ.height*0.013),
        ),
      ), //Subject
      StreamBuilder<QuerySnapshot>(
        stream: condition.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // return Text(
            //     '${widget.subject} record will be displayed here',style: TextStyle(color: Colors.red,
            //     fontSize: mQ.height*0.013
            // ),);
          }
          return Container(
            alignment:
            AlignmentDirectional.centerStart,
            width: widget.boxwidth_,
            height: (widget.boxheight_)??(mQ.height * 0.15),
            color: widget.boxcolor_,
            child: ListView.builder(
              padding: EdgeInsets.only(left: mQ.width*0.01),
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              controller: scrollController,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final activityData = snapshot.data!.docs[index]
                    .data() as Map<String, dynamic>;

                return
                  InkWell(
                    onTap: () {
                      _isEnable = (role_ == 'Principal' || role_ == 'Teacher' || role_ == 'Director');

                      showParentDialog(
                        snapshot.data!.docs[index].id,
                        activityData['Activity'],
                        activityData['description'],
                        activityData['Subject'],
                        activityData['image_'],
                        mQ,
                        activityData,
                        snapshot,
                        index,
                      );
                    },
                    child:
                    (widget.boxheading == 'Checked In')
                        ? (activityData['Activity'] == 'Checked In' || activityData['Activity'] == 'Absent')
                        ? Text(
                          '${activityData['Activity']} : ${activityData['time_']} ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: mQ.height * 0.014,
                            fontWeight: FontWeight.normal,
                            color: Colors.green[900],
                          ),
                        )
                        : Container()
                        : (widget.boxheading == 'Checked Out')
                        ? (activityData['Activity'] == 'Checked Out')
                        ? Text(
                          ' ${activityData['time_']} ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: mQ.height * 0.014,
                            fontWeight: FontWeight.normal,
                            color: Colors.green[900],
                          ),
                        )
                        : Container()
                        : (widget.subject == 'Attendance')
                        ? printattendance(activityData, mQ, widget.boxheading)
                        : (widget.subject == 'Food')
                        ? printfeeding(activityData, mQ)
                        : (widget.subject == 'Toilet')
                        ? printtoilet(activityData, mQ)
                        : (widget.subject == 'Fluids')
                        ? printfluids(activityData, mQ)
                        : (widget.subject == 'Sleep')
                        ? printsleep(activityData, mQ)
                        : (widget.subject == 'Mood')
                        ? printmood(activityData, mQ)
                        : (widget.subject == 'Health')
                        ? printhealth(activityData, mQ)
                        : (widget.subject == 'Activity')
                        ? printactivity(activityData, mQ)
                        : (widget.subject == 'Notes')
                        ? printnotes(activityData, mQ)
                        : Expanded(child: Text('No data to show', style: TextStyle(fontSize: 12),)),
                  );

                  },
            ),
          );
        },
      ),
    ]);

  }

  late bool _isEnable;
  showParentDialog(documentId, activity_, description, subject, class_, mQ, childData, snapshot, index) {
    TextEditingController activity_text_controller =
    TextEditingController(text: activity_);
    TextEditingController description_text_controller =
    TextEditingController(text: description);
    TextEditingController time_text_controller =
    TextEditingController(text: childData['time_']);
    return
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            // title:
            child:

            Container(padding: EdgeInsets.only(left: 16,right: 16,top: 16),
              width: double.infinity,
              height: mQ.height*0.45,
              // color: grey100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade100
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: mQ.height*0.035,
                    child: Row(
                      children: [
                        Expanded(child: Text("Daily Report",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),),
                        Expanded(child: IconButton(
                              alignment: Alignment.topRight,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.close,size: 14, color: Colors.black)),),
                      ],
                    ),
                  ),
                  // content:
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(childData['Subject'],textAlign: TextAlign.left, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),),
                        SizedBox(height: mQ.height*0.035,child: TextField(controller: activity_text_controller, enabled: _isEnable,)),
                      ]),
                  SizedBox(height: mQ.height*0.01,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time',textAlign: TextAlign.left, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),),
                      SizedBox(height: mQ.height*0.035,child: TextField(controller: time_text_controller, enabled: _isEnable,)),
                    ],
                  ),
                  SizedBox(height: mQ.height*0.01,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Activity',textAlign: TextAlign.left, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),),
                      SizedBox(height: mQ.height*0.18,child: TextField(controller: description_text_controller, maxLines: 3, enabled: _isEnable,)),
                    ],
                  ),
                  // actions: [
                  if (role_ == 'Principal'|| role_ == 'Teacher'|| role_ == 'Director')

                  if(_isEnable)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: IconButton(
                          onPressed: () async {
                            await confirm(
                                title: Text("Update"),
                                textOK: Text('Yes'),
                                textCancel: Text('No'),
                                context)
                                ?
                            await collectionReference
                                .doc(documentId)
                                .update({
                              "Activity": activity_text_controller.text,
                              "description":
                              description_text_controller.text,
                            })
                            :null;
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.save,
                            size: mQ.height*0.028,
                            color: Colors.green,
                          )),
                        ),
                        Expanded(
                          child:
                          IconButton(
                            onPressed: () async {
                              bool confirmed = await confirm(
                                title: Text("Delete"),
                                textOK: Text('Yes'),
                                textCancel: Text('No'),
                                 context,
                              );
                              if (confirmed) {
                                try {
                                  // Decrement the counter for the current status in the 'Reports' collection
                                  await collectionReferenceReports.doc(childData['id']).update({
                                    'DailySheet_${childData['status_']}': FieldValue.increment(-1)
                                  });
                                  // Update the status to 'rejected' in the other collection
                                  await collectionReference.doc(documentId).update({
                                    "status_": 'rejected',
                                  });
                                } catch (e) {
                                  print('An error occurred: $e');
                                }
                              }
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.delete_outline_sharp,
                              size: mQ.height * 0.028,
                              color: Colors.red,
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                  if (role_ == 'Parent')
                  Expanded(
                    child: IconButton(
                        alignment: Alignment.center,
                        onPressed: () async {
                          // await confirm(
                          //     title: Text("Allow Share"),
                          //     textOK: Text('Yes'),
                          //     textCancel: Text('No'),
                          //     context)
                          //     ?
                          // await collectionReference
                          //     .doc(documentId)
                          //     .update({'feedback_': "Share"}):null;
                          Navigator.of(context).pop();
                        },
                        icon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Close'),
                            Icon(Icons.close,
                                size: 18, color: Colors.green[600]),
                          ],
                        )),
                  ),

                 ],
              ),
            ),
            // ],
          );
        },
      );

  }
printfeeding(activityData,mQ){
return
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('${activityData['Activity']} ${activityData['time_']}',
          style: TextStyle(
              fontSize: mQ.height*0.018,
              // fontSize: mQ.height*0.020,
              fontWeight: FontWeight.normal,
              color: widget.subjectcolor_)),
      Text('${activityData['description']} ',
          style: TextStyle(
              fontSize: mQ.height*0.016,
              fontWeight: FontWeight.normal,
              color: Colors.black)),
    ],
  );

}
printtoilet(activityData,mQ){
return
  Padding(
    padding: const EdgeInsets.only(left: 5.0,right: 5.0),
    child:
    Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${activityData['Activity']} ${activityData['time_']}',
            style: TextStyle(
                fontSize: mQ.height*0.016,
                fontWeight: FontWeight.normal,
                color: widget.subjectcolor_)),
        Text('${activityData['description']} ',
            style: TextStyle(
                fontSize: mQ.height*0.015,
                fontWeight: FontWeight.normal,
                color: Colors.black)),
      ],
    ),
  );
  }
printfluids(activityData,mQ){
return
  Column(crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('${activityData['Activity']} ${activityData['time_']}',
          style: TextStyle(
              fontSize: mQ.height*0.015,
              fontWeight: FontWeight.normal,
              color: widget.subjectcolor_)),
      Text('${activityData['description']} ',
          style: TextStyle(
              fontSize: mQ.height*0.015,
              fontWeight: FontWeight.normal,
              color: Colors.black)),

    ],
  );
 }
  printsleep(activityData,mQ){
    return
      Padding(
      padding: const EdgeInsets.only(left: 5.0,right: 5.0),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${activityData['Activity']} ${activityData['time_']}',
              style: TextStyle(
                  fontSize: mQ.height*0.016,
                  // fontSize: mQ.height*0.018,
                  fontWeight: FontWeight.normal,
                  color: widget.subjectcolor_)),
          Text('${activityData['description']} ',
          style: TextStyle(
              fontSize: mQ.height*0.012,
              fontWeight: FontWeight.normal,
              color: widget.subjectcolor_)),
        ],
      ),
    );
  }
  printattendance(activityData,mQ,status_){
    return
       (activityData['Activity'] == 'Checked In'|| activityData['Activity'] == 'Absent')?
      Expanded(
        child: Text('${activityData['time_']} ',
        textAlign: TextAlign.center,
            style: TextStyle(
            fontSize: mQ.height*0.015,
          fontWeight: FontWeight.normal,
          color: Colors.green[900])),
      )
           :
       // (activityData['Activity'] == 'Checked Out')?
      Expanded(
        child: Text('${activityData['time_']} ',
        textAlign: TextAlign.center,
            style: TextStyle(
            fontSize: mQ.height*0.015,
          fontWeight: FontWeight.normal,
          color: Colors.green[900])),
      );
    // : Container();
  }
  printmood(activityData,mQ){
    return  Padding(
      padding: const EdgeInsets.only(left: 5.0,right: 5.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text('${activityData['description']} ',
            style: TextStyle(
                fontSize: mQ.height*0.015,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        // Text('${activityData['Activity']} ',
        //     textAlign: TextAlign.left,  style: TextStyle(
        //         fontSize: mQ.height*0.015,
        //         fontWeight: FontWeight.normal,
        //         color: Colors.cyan)),
      ]),
    );
  }
  printhealth(activityData,mQ){
    return  Padding(
      padding: const EdgeInsets.only(left: 5.0,right: 5.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,children: [

        Text('${activityData['Activity']} ',
            textAlign: TextAlign.left,  style: TextStyle(
                fontSize: mQ.height*0.016,
                fontWeight: FontWeight.normal,
                color: widget.subjectcolor_)),
        Text('${activityData['description']} ',
            style: TextStyle(
                fontSize: mQ.height*0.013,
                fontWeight: FontWeight.normal,
                color: Colors.black)),
      ]),
    );
  }
  printactivity(activityData,mQ){
    return  Padding(
      padding: const EdgeInsets.only(left: 5.0,right: 5.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,children: [
        Text('${activityData['Activity']} ',
            textAlign: TextAlign.left,  style: TextStyle(
                fontSize: mQ.height*0.018,
                fontWeight: FontWeight.normal,
                color: widget.subjectcolor_)),
        Text('${activityData['description']} ',
            style: TextStyle(
                fontSize: mQ.height*0.016,
                fontWeight: FontWeight.normal,
                color: Colors.black)),
      ]),
    );
  }
  printnotes(activityData,mQ){
    return  Padding(
      padding: const EdgeInsets.only(left: 5.0,right: 5.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,children: [
        Text('${activityData['Activity']} ',
            textAlign: TextAlign.left,  style: TextStyle(
                fontSize: mQ.height*0.018,
                fontWeight: FontWeight.bold,
                color: Colors.cyan)),
        Text('${activityData['description']} ',
            style: TextStyle(
                fontSize: mQ.height*0.016,
                fontWeight: FontWeight.normal,
                color: Colors.black)),
      ]),
    );
  }

}
