import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:kids_republik/screens/accounts/fees/fees_form.dart';
import 'package:kids_republik/screens/accounts/fees/update_fees_data.dart';
import 'package:kids_republik/utils/const.dart';

import '../../../main.dart';

final classes_ = <String>[
  'Infant',
  'Toddler',
  'Kinder Garten - I',
  'Kinder Garten - II',
  'Play Group - I'
];
String selectedclass_ = 'Infant';

class FeesDataUpdateScreen extends StatefulWidget {
  String babyId;

  FeesDataUpdateScreen({required this.babyId});

  @override
  _FeesDataUpdateScreenState createState() => _FeesDataUpdateScreenState();
}


class _FeesDataUpdateScreenState extends State<FeesDataUpdateScreen> {

  final isLoading = false.obs;



  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: kprimary,
        title: Text(
          'Update Fees Data',
          style: TextStyle(fontSize: 14),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: mQ.height * 0.03,),
              // (widget.babyId == 'No Baby Selected')
              //     ?
            Column(
                      children: [
                        Text('Tab on Kid to select'),
                        classwisestudents('Infant'),
              SizedBox(height: mQ.height * 0.01,),
                        classwisestudents('Toddler'),
              SizedBox(height: mQ.height * 0.01,),
                        classwisestudents('Play Group - I'),
              SizedBox(height: mQ.height * 0.01,),
                        classwisestudents('Kinder Garten - I'),
              SizedBox(height: mQ.height * 0.01,),
                        classwisestudents('Kinder Garten - II'),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }


  Widget classwisestudents(classname) {
    final mQ = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: mQ.width * 0.02),
      child: StreamBuilder<QuerySnapshot>(
        stream: (role_ == 'Parent')
            ? collectionReferenceBabyData
                .where('class_', isEqualTo: classname)
                .where('fathersEmail', isEqualTo: useremail)
                .snapshots()
            : collectionReferenceBabyData
                .where('class_', isEqualTo: classname)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: mQ.height * 0.01),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              '',
              style: TextStyle(color: Colors.grey),
            ));
          }
          return Column(
            children: <Widget>[
              Container(
                  width: mQ.width,
                  color: Colors.green[50],
                  height: mQ.height * 0.022,
                  child: Text(
                    classname,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.teal),
                  )),
              Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                height: mQ.height * 0.098,
                child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, position) {
                    final childData = snapshot.data!.docs[position].data()
                        as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        widget.babyId = snapshot.data!.docs[position].id;
                        Get.to(FeesDataUpdateScreen2(
                            babyId: widget.babyId));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: mQ.width * 0.1,
                            height: mQ.height * 0.042,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  alignment: FractionalOffset.topCenter,
                                  image: CachedNetworkImageProvider(
                                      childData['picture']),
                                  fit: BoxFit.fitHeight),
                            ),
                          ),
                          Text(" ${childData['childFullName']} ",
                              style: TextStyle(
                                  fontSize: 10,
                                  // fontFamily: 'Comic Sans MS',
                                  fontWeight: FontWeight.normal,
                                  color: Colors.blue)),
                        ],
                      ),
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


}
