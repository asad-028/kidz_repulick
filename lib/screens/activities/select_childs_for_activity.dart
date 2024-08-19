import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/activities/create_activity_multiple_childs.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/image_slide_show.dart';
import '../kids/widgets/empty_background.dart';

class SelectChildsForActivity extends StatefulWidget {
  final activityclass_;
  final selectedsubject_;
  SelectChildsForActivity(
      {this.activityclass_, super.key, required this.selectedsubject_});
  // String activitybabyid_ = '';

  @override
  State<SelectChildsForActivity> createState() => _SelectChildsForActivityState();
}

class _SelectChildsForActivityState extends State<SelectChildsForActivity> {
  final collectionReference = FirebaseFirestore.instance.collection(BabyData);
  ScrollController scrollController = ScrollController();
    List<Map<String, dynamic>> selectedBabies = [];
  int selectedChildIndex = -1; // Initialize with -1, indicating no selection
@override
  void initState() {
    // TODO: implement initState
  selectedBabies = [];
  super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          title: Text(
            'Class ${(widget.activityclass_)}',
            style: TextStyle(fontSize: 14,color: kWhite),
          ),
          backgroundColor: kprimary,
        ),
        backgroundColor: Colors.blue[50],
        body:
        Column(children: [
          ImageSlideShowfunction(context),
          Container(
            height: mQ.height * 0.025,
            color: Colors.grey[50],
            width: mQ.width,
            child: Text(
              'Select from ${((widget.activityclass_)=='Kinder Garten - I')?'KG-I':(widget.activityclass_=='Kinder Garten - II')?'KG-II':(widget.activityclass_=='Play Group - I')?'PG-I':widget.activityclass_} class for ${widget.selectedsubject_}',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
            child: StreamBuilder<QuerySnapshot>(
              stream: collectionReference
                  .where('class_', isEqualTo: widget.activityclass_)
                  .where('checkin', isEqualTo: 'Checked In')
                  // 'Todlers' )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: CircularProgressIndicator(),
                    ),
                  ); // Show loading indicator
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return EmptyBackground(
                    title: 'Curently, No student is present in the class. First Check In the student then select activity to select Student(s)',
                  ); // No data
                }

                // Data is available, build the list
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: mQ.height * 0.18,
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, position) {
                          final childData = snapshot.data!.docs[position].data()
                              as Map<String, dynamic>;
                          return
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  // Check if the baby is already selected
                                  bool isAlreadySelected = selectedBabies.any((baby) => baby['babyId'] == snapshot.data!.docs[position].id);

                                  // If already selected, remove it; otherwise, add it
                                  if (isAlreadySelected) {
                                    selectedBabies.removeWhere((baby) => baby['babyId'] == snapshot.data!.docs[position].id);
                                    selectedChildIndex = -1; // No baby is selected
                                  } else {
                                    selectedBabies.add({
                                      'babyId': snapshot.data!.docs[position].id,
                                      // 'fullName': childData['childFullName'],
                                      // 'picture': childData['picture'],
                                      // ... other parameters
                                    });
                                    selectedChildIndex = position; // Update selected index
                                  }
                                });
                              },

                            child:
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: mQ.width * 0.15,
                                    height: mQ.height * 0.07,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          childData['picture'],
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                      border: selectedBabies.any((baby) => baby['babyId'] == snapshot.data!.docs[position].id)
                                          ? Border.all(color: kprimary, width: 4.0) // Change the color and width as needed
                                          : null,
                                    ),
                                  ),
                                  Text(" ${childData['childFullName']}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Comic Sans MS',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue)),
                                   Text(
                                        '${childData['fathersName']}',
                                        style: TextStyle(
                                            color: Colors.black)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    TextButton(
                        onPressed:() {
                      Get.to(CreateActivityForMultipleChildsScreen(selectedBabies: selectedBabies,selectedsubject_: widget.selectedsubject_,));
                      },
                        child: Text(textAlign: TextAlign.center,'Proceed>>')
                    )

                  ],
                );
              },
            ),
          ),
        ]));
  }
}
