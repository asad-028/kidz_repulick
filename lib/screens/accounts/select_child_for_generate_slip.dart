
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:kids_republik/screens/accounts/fees/fees_form.dart';
import 'package:kids_republik/screens/accounts/generate_fee_slip.dart';
import 'package:kids_republik/utils/const.dart';

import '../../../controllers/fees_form_controller/fees_form_controller.dart';
import '../../../main.dart';

final classes_ = <String>[
  'Infant',
  'Toddler',
  'Kinder Garten - I',
  'Kinder Garten - II',
  'Play Group - I'
];
String selectedclass_ = 'Infant';

class SelectChildForGenerateSlip extends StatefulWidget {
  String babyId;

  SelectChildForGenerateSlip({required this.babyId});

  @override
  _SelectChildForGenerateSlipState createState() =>
      _SelectChildForGenerateSlipState();
}

class _SelectChildForGenerateSlipState extends State<SelectChildForGenerateSlip> {
  UpdateFeesEntryFormController updateFeesEntryFormController =
      Get.put(UpdateFeesEntryFormController());
  // final isLoading = false.obs;
  final TextEditingController childFullName = TextEditingController();
  final TextEditingController RegistrationFees = TextEditingController();
  final TextEditingController SecurityFees = TextEditingController();
  final TextEditingController AnnualRecourceFees = TextEditingController();
  final TextEditingController UniformFees = TextEditingController();
  final TextEditingController AdmissionFormFees = TextEditingController();
  final TextEditingController TuitionFees = TextEditingController();
  final TextEditingController MealsFees = TextEditingController();
  final TextEditingController LateSatFees = TextEditingController();
  final TextEditingController FieldTripsFees = TextEditingController();
  final TextEditingController AfterSchoolFees = TextEditingController();
  final TextEditingController DropIncareFees = TextEditingController();
  final TextEditingController MiscFees = TextEditingController();
  final TextEditingController fathersEmail = TextEditingController();


  final CollectionReference collectionReferenceaccounts =
      FirebaseFirestore.instance.collection(accounts);

  @override
  void dispose() {
    childFullName.dispose();
    RegistrationFees.dispose();
    SecurityFees.dispose();
    AnnualRecourceFees.dispose();
    UniformFees.dispose();
    AdmissionFormFees.dispose();
    TuitionFees.dispose();
    MealsFees.dispose();
    LateSatFees.dispose();
    FieldTripsFees.dispose();
    AfterSchoolFees.dispose();
    DropIncareFees.dispose();
    MiscFees.dispose();
    fathersEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color to your preference
        ),
        backgroundColor: kprimary,
        title: Text(
          'Fees Slip',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
          child: Form(
            key: updateFeesEntryFormController.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
                  child:
                  Column(
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
               ],
            ),
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
                  child:
                  Row(
                    children: [
                      Text('Tab to select'),
                      Spacer(),
                      Text(
                        classname,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.teal),
                      ),
                      Spacer(),
                      Spacer()
                    ],
                  )
              ),
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
                      onTap: () async {
                        isLoading.value = true;
                        // setState(() async {
                        widget.babyId = snapshot.data!.docs[position].id;
                          Get.to(GenerateFeesSlip(
                              documentId: snapshot.data!.docs[position].id));
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

  Future<void> fetchdataintoformChildFunction(
      BuildContext context, babyId) async {

    isLoading.value = true;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(BabyData)
          .doc(babyId)
          .get();
      if (snapshot.exists) {
        setState(() {
          // doc(babyId).update({
          updateFeesEntryFormController.childFullName.text =
              snapshot.get("childFullName");
          imageUrl = snapshot.get("picture");
          updateFeesEntryFormController.fathersName.text =
              snapshot.get("fathersName");
          updateFeesEntryFormController.fathersEmail.text =
              snapshot.get("fathersEmail");
          updateFeesEntryFormController.nameUsuallyKnownBy.text =
              snapshot.get('nameusuallyknownby');
          updateFeesEntryFormController.fathersMobileNo.text =
              snapshot.get("fathersMobileNo");
          updateFeesEntryFormController.fathersMobileNo.text =
              snapshot.get("RegistrationNumber");
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    isLoading.value = false;
  }
}
