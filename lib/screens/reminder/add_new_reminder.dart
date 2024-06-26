import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/consent_controllers/add_new_consent_controller.dart';
import 'package:kids_republik/utils/getdatefunction.dart';
import 'package:toast/toast.dart';

import '../../utils/const.dart';
import '../../utils/image_slide_show.dart';
import '../kids/widgets/custom_textfield.dart';
import '../widgets/primary_button.dart';

class AddNewReminderScreen extends StatefulWidget {
  AddNewReminderScreen({ super.key});

  @override
  State<AddNewReminderScreen> createState() => _AddNewReminderScreenState();

}

class _AddNewReminderScreenState extends State<AddNewReminderScreen> {

  AddNewConsentController addNewConsentController = Get.put(AddNewConsentController());
  @override
  void initState() {
    super.initState();
    addNewConsentController.currentDate.value = addNewConsentController.getCurrentDate();
  }
CollectionReference collectionReferenceConsent = FirebaseFirestore.instance.collection('Consent');
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Add Reminder Statement',
          style: TextStyle(color: kWhite,fontSize: 14),
        ),
        backgroundColor: kprimary,
      ),
      // bottomNavigationBar: MainTabsBottomNavigation(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ImageSlideShowfunction(context),
          SizedBox(height: 3,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: mQ.height * 0.03,
              color: Colors.grey[50],
              width: mQ.width * 0.94,
              padding: EdgeInsets.symmetric(horizontal: mQ.width*0.01 ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'New Reminder',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(textAlign: TextAlign.right,
                      ' ${getCurrentDateforattendance()}',
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
          ),

          // Container(height: mQ.height*0.03,color: Colors.grey[50],width: mQ.width,child: Text('Add New Consent Statement',style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),),
          SizedBox(height: 13,),
          Obx(
                () => addNewConsentController.isLoadingInitial.value
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 4.0, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextField(
                      enabled: true,
                      controller: addNewConsentController.title_,
                      inputType: TextInputType.text,
                      labelText: "Heading",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: mQ.height * 0.02,
                    ),
                    CustomTextField(
                      enabled: true,
                      controller: addNewConsentController.description_,
                      inputType: TextInputType.text,
                      labelText: "Reminder",
                      validators: (String? value) {
                        if (value!.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: mQ.height * 0.005,
                    ),
                    Obx(
                          () => addNewConsentController.isLoading.value
                          ? Center(child: const CircularProgressIndicator())
                          : SizedBox(
                        width: mQ.width * 0.85,
                        height: mQ.height * 0.065,
                        child: PrimaryButton(
                          onPressed: () {
                            addNewConsentController.isLoading.value = true;
                              try {
                                collectionReferenceConsent.add(
                                    {'child_': ' ',
                                      'subject_': 'Reminder',
                                        'title_': addNewConsentController.title_.text,
                                    'description_': addNewConsentController.description_.text,
                                      'date_': addNewConsentController.currentDate.value,
                                    'result_': 'Reminder Statement',
                                      'category_': 'Reminder'
                                    });
                              } catch (error) {
                                print('Error fetching data: $error');
                              }

                              ToastContext().init(context);

                              Toast.show(
                                'Reminder Registered Successfully',
                                // Get.context,
                                backgroundRadius: 5,
                                //gravity: Toast.top,
                              );
                            // }
                            addNewConsentController.isLoading.value = false;
                            // Get.back();
                            Navigator.of(context).pop();

                            // addNewConsentController.addActivityfunction(
                            //     context);
                          },
                          label: "Create",
                          elevation: 3,
                          bgColor: kprimary,
                          labelStyle: kTextPrimaryButton.copyWith(
                              fontWeight: FontWeight.w500),
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
