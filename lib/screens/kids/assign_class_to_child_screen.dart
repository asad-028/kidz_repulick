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
  AssignClassToChildren(
      { super.key, required this.selectedclass_});
  String activitybabyid_ = '';

  @override
  State<AssignClassToChildren> createState() => _AssignClassToChildrenState();
}

class _AssignClassToChildrenState extends State<AssignClassToChildren> {
bool deleteionLoading = false;
  final collectionReference = FirebaseFirestore.instance.collection('BabyData');
  final collectionReferenceClassRoom = FirebaseFirestore.instance.collection('ClassRoom');
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          title: Text(
            'Students',
            style: TextStyle(fontSize: 14,color: kWhite),
          ),
          backgroundColor: kprimary,
        ),
        backgroundColor: Colors.blue[50],
        floatingActionButton:FloatingActionButton(onPressed: () {
          Get.to(RegistrationForm());
        },
            child:
            Container(
              width: mQ.width*0.13,decoration: BoxDecoration(

            ),
              child: Center(
                child:
                Icon(
                  Icons.add,
                  size: 22,
                  color: kprimary,
                ),
              ),
              // ),
            )),
        body:
        SingleChildScrollView(
          child: Container(
            child: Column(children: [
              ImageSlideShowfunction(context),

 Column(
             children: [

               (role_ == "Principal")?classwisestudents('NewAdmission'):Container(
   padding: EdgeInsets.only(right: 8, left: 8),
   height: mQ.height * 0.025,
   color: Colors.grey[50],
   width: mQ.width,
   // padding:mQ ,
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
       classwisestudents('Infant'),
       classwisestudents('Toddler'),
       classwisestudents('Play Group - I'),
       classwisestudents('Kinder Garten - I'),
       classwisestudents('Kinder Garten - II'),
       ],
       ),

            ]),
          ),
        ));
  }
Widget classwisestudents(classname){
  final mQ = MediaQuery.of(context).size;
    return
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8),
        child: StreamBuilder<QuerySnapshot>(
          stream: collectionReference.where('class_', isEqualTo: classname).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {return Center(child: Padding(padding: const EdgeInsets.only(top: 8.0),child: CircularProgressIndicator(),),); }
            if (snapshot.hasError) {return Center(child: Text('Error: ${snapshot.error}'));}
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {return Center(child: Text('No Students in the ${classname} class',style: TextStyle(color: Colors.grey),));}
            return
              Column(
              children: <Widget>[
                Container(width: mQ.width,color: Colors.green[50] ,child: Text(classname,textAlign: TextAlign.center,style: TextStyle(color: Colors.teal),)),
                Container(color: Colors.transparent,
                  height: mQ.height * 0.1,
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, position) {
                      final childData = snapshot.data!.docs[position].data() as Map<String, dynamic>;
                      return Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<String>(
                            icon: Container(
                        width: mQ.width * 0.12,
                        height: mQ.height * 0.045,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(alignment: FractionalOffset.topCenter,
                              image:
                              CachedNetworkImageProvider(childData['picture']),
                              // NetworkImage(
                              //   childData['picture'],
                              // ),
                              // Image.network(babypicture_ , width: mQ.width * 0.07),
                              fit: BoxFit.fill),
                        ),
                      ),
                            surfaceTintColor: Colors.green,shadowColor: Colors.limeAccent,
                            color: Colors.purple[50], // Generate the menu items from the list
                            itemBuilder:
                                (BuildContext
                            context) {
                              return (role_ == "Principal"||role_ == "Manager")? classes_.map(
                                      (String item) {
                                    return PopupMenuItem<
                                        String>(
                                      value: item,
                                      child: Text(item),
                                    );
                                  }).toList(): [];
                            },
                            onSelected: (String
                            selectedItem) async {

                              (role_ == "Principal"  || role_ == "Manager")? await confirm(title: Text("Confirm",style: TextStyle(fontSize: 12)),content: Text("Are You sure to proceed",style: TextStyle(fontSize: 12)), textOK: Text('Yes'),textCancel: Text('No'),context)?
                              {selectedItem == 'Delete'?await confirm(title: Text("Confirm Delete",style: TextStyle(fontSize: 12,color: Colors.red[900])),content: Text("Are You sure to Delete",style: TextStyle(fontSize: 12,color: Colors.red[900])), textOK: Text('Yes'),textCancel: Text('No'),context)?deleteDocumentFromFirestore(snapshot.data!.docs[position].id):null:
                            selectedItem == 'Update'?Get.to(UpdateRegistrationForm(babyId: snapshot.data!.docs[position].id)):
                                        await collectionReference
                                            .doc(snapshot
                                                .data!.docs[position].id)
                                            .update({"class_": selectedItem}),
                                        await collectionReferenceClassRoom
                                            .doc(selectedItem)
                                            .update({"strength_":FieldValue.increment(1),
                                        'absent_': FieldValue.increment(1)
                                            })
                                      }
                                    :Null:null;
                            },
                          ),
                              Text(" ${childData['childFullName']} ",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'Comic Sans MS',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                          ],
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
    } catch (e) {
      print('Error deleting document: $e');
    }
    Get.back();
    // Navigator.of(context).pop();
  }

}
