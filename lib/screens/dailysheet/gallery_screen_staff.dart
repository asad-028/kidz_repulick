import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kids_republik/utils/parent_photos_slideshow2.dart';

import '../../main.dart';
bool ApprovedOnly = false;
class GalleryScreenStaff extends StatefulWidget {
  final baby;
  final reportdate_;
  final biweeklystatus_;
  final subject;
  final category;
  final Color subjectcolor_;
  final fathersEmail_;

  GalleryScreenStaff({
    super.key,
    this.baby,
    this.reportdate_,
    this.subject,
    required this.subjectcolor_,
    this.category, this.fathersEmail_, this.biweeklystatus_,
  });
  String activitybabyid_ = '';

  @override
  State<GalleryScreenStaff> createState() =>
      _GalleryScreenStaffState();
}

class _GalleryScreenStaffState extends State<GalleryScreenStaff> {
  final collectionReference = FirebaseFirestore.instance.collection('Activity');
  final collectionReferenceReports = FirebaseFirestore.instance.collection('Reports');
  bool deleteionLoading = false;
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    var condition;
    (widget.category == 'DailySheet')?
    (role_ == "Teacher")?   condition = collectionReference
        .where('id', isEqualTo: widget.baby)
        .where('date_', isEqualTo: widget.reportdate_)
        .where('photostatus_',isEqualTo: 'New'):
    (role_ == "Principal")?
    (ApprovedOnly)
        ? condition = collectionReference
        .where('id', isEqualTo: widget.baby)
        .where('photostatus_', isEqualTo: 'Approved')
        :
    condition = collectionReference
        .where('id', isEqualTo: widget.baby)
        .where('date_', isEqualTo: widget.reportdate_)
        .where('photostatus_',isEqualTo: 'Forwarded')
        :condition = collectionReference
        .where('id', isEqualTo: widget.baby)
        .where('photostatus_', isEqualTo: 'Approved')

        : condition = collectionReference
        .where('id', isEqualTo: widget.baby)
        .where('date_', isEqualTo: widget.reportdate_)
        .where('category_', isEqualTo: widget.category)
        .where('biweeklystatus_', isEqualTo: widget.biweeklystatus_);

    return Column(
      children: [
        ParentPhotoSlideshow2(fatherEmail: widget.fathersEmail_,babyId: widget.baby,activitydate_: widget.reportdate_,),
        (role_ == 'Principal' || role_ == 'Director') ?
        Padding(padding: const EdgeInsets.all(8.0), child: Row(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Expanded(child: Text('View:')),
              Expanded(child: TextButton(onPressed: () {setState(() {ApprovedOnly = true;});}, child:  Text('Approved Only')),),
              Expanded(child: TextButton(onPressed: () {setState(() {ApprovedOnly = false;});}, child:  Text('Forwarded')),),
            ],
          ),
        )
            :Container(),
        Padding(
          padding: const EdgeInsets.symmetric( horizontal: 14),
          child: StreamBuilder<QuerySnapshot>(
            stream: condition.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Padding(padding: const EdgeInsets.only(top: 25.0), child: CircularProgressIndicator(),),);
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('${widget.subject} - record will be displayed here');
              } //EmptyBackground(title: 'Wait for activities to be updated',); }

              // Data is available, build the list
              return Container(width: mQ.width*0.82,
                color: Colors.blueGrey, height: mQ.height*0.56,
                child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    final activityData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return GestureDetector(onTap: () {(role_ == 'Teacher'|| role_ == 'Principal'|| role_ == 'Director')?showEditingDialog(mQ, snapshot.data!.docs[index].id, activityData['Activity'], activityData['description'], activityData['Subject'], activityData['image_'], activityData):null;}, child:
                    Container(padding: EdgeInsetsDirectional.all(4), width: mQ.width*0.7, decoration: BoxDecoration(color: (activityData["photostatus_"]== "Approved")?Colors.red[50]:(activityData["photostatus_"]== "Forwarded")?Colors.blue[50]:Colors.blue[100], borderRadius: BorderRadius.circular(5), // Apply rounded corners if desired
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.6), spreadRadius: 0.2, blurRadius: 0.5, offset: Offset(0, 3), // Add a shadow effect
                              ),
                            ],),
                          child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color:
                                  (activityData["photostatus_"]== "Approved")?Colors.green[900]:(activityData["photostatus_"]== "Forwarded")?Colors.blue[50]:Colors.blue[900], borderRadius: BorderRadius.circular(5), // Apply rounded corners if desired
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      spreadRadius: 0.2,
                                      blurRadius: 0.5,
                                      offset: Offset(0, 3), // Add a shadow effect
                                    ),
                                  ],
                                ),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${activityData['Subject']} ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text('${activityData['date_']} ${activityData['time_']} ',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[200])),
                                      ),
                                    ]),
                              ),
                              CachedNetworkImage(
                                imageUrl: activityData['image_'],
                                height: mQ.height * 0.28,
                                fit: BoxFit.fitWidth,
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color:
                                  (activityData["photostatus_"]== "Approved")?Colors.green[50]:(activityData["photostatus_"]== "Forwarded")?Colors.grey[50]:Colors.grey[100],
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          '${activityData['Activity']} ',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black)),
                                    ),
                                    activityData['photostatus_']=='Approved'? Icon(Icons.done_all_sharp,color: Colors.blue[900],):activityData['photostatus_']=='Forwarded'? Icon(Icons.done_all,color: Colors.grey,):Icon(Icons.done_outlined,color: Colors.grey,),
                                  ],
                                ),
                              ),
                              Text(
                                  '${activityData['description']}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black)),
                            ],
                          ),
                        )
                      ,);},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  showEditingDialog(mQ, documentId, activity_, description, subject, image, Map<String, dynamic> activityData) {
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
                      title:
                      Row(
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
                                alignment: AlignmentDirectional.topEnd,onPressed: () {
                              Navigator.of(context).pop();
                            },
                                icon: Icon(Icons.cancel,
                                    size: 12, color: Colors.black)),
                          ),
                        ],
                      ),
                      content: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: image,
                            height: mQ.height * 0.28,
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                CircularProgressIndicator(value: downloadProgress.progress),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),

                      TextField(
                            controller: activity_text_controller,
                            enabled: _isEnable,
                          ),
                          TextField(
                            controller: description_text_controller,
                            maxLines: 3,
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
                                color: Colors.orange,
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
                              (role_ == 'Teacher')?
                              TextButton(
                                  onPressed: () async {
                                    await collectionReference
                                        .doc(documentId)
                                        .update({"photostatus_": 'Forwarded'});

                                    await collectionReferenceReports.doc(widget.baby).update({"Photos_New": FieldValue.increment(-1), "Photos_Forwarded": FieldValue.increment(1),});
                                    Navigator.of(context).pop();
                                  },
                child: Text('Forward',style: TextStyle(fontSize: 8))):Container(),
             // Icon(Icons.arrow_circle_right_outlined,
                                  //     size: 18, color: Colors.green[600])):
                              (role_ == 'Principal' || role_ == 'Director' )?
                              TextButton(
                                  onPressed: () async {
                                    await collectionReference
                                        .doc(documentId)
                                        .update({"photostatus_": "Approved"});
                                    await collectionReferenceReports.doc(widget.baby).update({"Photos_Approved": FieldValue.increment(1), "Photos_Forwarded": FieldValue.increment(-1),});

                                    Navigator.of(context).pop();
                                  },
                child: Text('Approve',style: TextStyle(fontSize: 8))):Container(),
                                  // icon: Icon(Icons.approval,
                                  //     size: 18, color: Colors.green[600])):Container(),
                              (role_ == 'Principal' || role_ == 'Director' )?
                              Expanded(
                                child:
                                TextButton(
                                    onPressed: () async {
                                      await confirm(
                                          title: Text("Reject"),
                                          content: Text("Do you want to reject?"),
                                          textOK: Text('Yes'),
                                          textCancel: Text('No'),
                                          context)
                                          ?() async {
                                        await collectionReference
                                            .doc(documentId)
                                            .update(
                                            {"photostatus_": 'rejected',});
                                        await collectionReferenceReports.doc(widget.baby).update({"Photos_Forwarded": FieldValue.increment(-1),});
                                      }
                                          :null;
                                      Navigator.of(context).pop();
                                    },
                child: Text('Reject',style: TextStyle(fontSize: 8)))):
                              TextButton(
                                  onPressed: () async {
                                    bool confirmResult = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: Text("Remove"),
                                        content: Text("Do you want to remove the photo from the list?"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmResult) {
                                      try {
                                        await collectionReference.doc(documentId).update({"photostatus_": 'Removed'});} catch (e) {print('Error updating document: $e');}
                                        await collectionReferenceReports.doc(widget.baby).update({"Photos_New": FieldValue.increment(-1),});
                                    }
                                    Navigator.of(context).pop();
                                  },
                child: Text('Remove',style: TextStyle(fontSize: 8,color: Colors.red))),
                            ]),
                      ],
                    ));
              });
        });
  }


}
