import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:toast/toast.dart';

class CreateActivityScreenController extends GetxController {
  RxString currentDate = ''.obs;
  RxString currentTime = ''.obs;
  RxString biweeklytitle = ''.obs;
  RxString biweeklydescription = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingInitial = true.obs;
  // CollectionReference collectionReference = FirebaseFirestore.instance
  //     .collection('ClassActivity');
  CollectionReference collectionReferenceActivity = FirebaseFirestore.instance.collection(Activity);
  CollectionReference collectionReferenceReports = FirebaseFirestore.instance.collection(Reports);


  // TextEditingController selectedBabyID_ = TextEditingController();
  TextEditingController subject_ = TextEditingController();
  TextEditingController activity_ = TextEditingController();
  TextEditingController description_ = TextEditingController();


  // Class Activity
  // RxList<DocumentSnapshot> dropdownItemsClassActivity = <DocumentSnapshot>[]
  //     .obs;
  DocumentSnapshot? selectedItemClassActivity;
  RxString classActivityName = ''.obs;
  RxString classActivitySubject = ''.obs;
  RxString classActivityDescription = ''.obs;


  addActivityfunction(BuildContext context,selectedBabies, subject, activity, descriptions, imageUrl, activitytime_,categorys) async {
    // currentTime.value = activitytime_;
    isLoading.value = true;
      for (var selectedBaby in selectedBabies) {
        try {
          await collectionReferenceActivity
              .add({
            "id":
            selectedBaby['babyId'],
            // "id": childId,
            "Subject": subject,
            "Activity": activity,
            "date_": currentDate.value,
            "time_": activitytime_,
            "description": descriptions,
            "image_": imageUrl,
            "status_": (categorys == 'BiWeekly') ? '' :(role_=="Teacher")? "New":'Forwarded',
            "photostatus_": (subject == 'Food' || subject == 'Fluids' ||
                subject == 'Activity' || subject == 'Health') &&
                (imageUrl != '') ?
            // "New" : '',
            (role_=="Teacher")? "New":'Forwarded':'',
            "category_": categorys,
            "biweeklystatus_": (categorys == 'BiWeekly') ? 'New' : ''
          });
        } catch (error) {
          print('Error fetching data: $error');
        }
        try {
          await collectionReferenceReports.doc(selectedBaby['babyId']).set({
            "id": selectedBaby['babyId'],
            "${categorys}_${role_ == "Teacher" ? "New" : 'Forwarded'}": FieldValue.increment(1),
            "Photos_${role_ == "Teacher" ? "New" : 'Forwarded'}":
            (subject == 'Food' || subject == 'Fluids' ||
                subject == 'Activity' || subject == 'Health') && (imageUrl != '')
                ? FieldValue.increment(1)
                : FieldValue.increment(0),
          }, SetOptions(merge: true));
        } catch (error) {
          print('Error fetching data: $error');
        }
      }
    isLoading.value = false;

    ToastContext().init(context);

    Toast.show(
      'Record Added Successfully',
      // Get.context,
      backgroundRadius: 5,duration: 3
      //gravity: Toast.top,
    );
    Get.back();
  }


  String getCurrentDate() {
    final now = DateTime.now();
    final day =
    now.day.toString().padLeft(2, '0'); // Add leading zero if needed
    final month =
    now.month.toString().padLeft(2, '0'); // Add leading zero if needed
    final year = now.year.toString();

    isLoadingInitial = false.obs;
    return '$day-$month-$year';
  }

  String getCurrentTime() {
    final now = TimeOfDay.now();
    final hours = now.hour.toString().padLeft(2, '0');
    final minutes = now.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  TimeOfDay? selectedTime = TimeOfDay.now();

  selectTimeofDay(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            child: const Text('Time'),
            onPressed: () async {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
                initialEntryMode: TimePickerEntryMode.dial,
                orientation: Orientation.portrait,
          );
              selectedTime = time;
            },
          ),
        ),
        if (selectedTime != null)
            Text(selectedTime!.format(context))




      ],
    );
  }

  selectTime(context) async {

    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(), cancelText: 'Cancel',confirmText: 'Select', context: context,);
    if (pickedTime != null) {
      final hours = pickedTime.hour.toString().padLeft(2, '0');
      final minutes = pickedTime.minute.toString().padLeft(2, '0');
print('$hours:$minutes');
      return '$hours:$minutes';
      // DateTime parsedTime = DateFormat.jm().parse(
      //     pickedTime.format(context).toString());
      // String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
      // currentTime.value = formattedTime; //set the value of text field.
    }
  }
  // Notes(selectedbabyid_) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start, children: [
  //     // Text(
  //     //   ' Select from saved list ',
  //     //   style: TextStyle(
  //     //       fontSize: 12,
  //     //       fontFamily: 'Comic Sans MS',
  //     //       fontWeight: FontWeight.bold,
  //     //       color: Colors.black),
  //     // ),
  //     // // BiWeeklyDropDown(selectedbabyid_),
  //     // SizedBox(height: 20,),
  //     // Text(
  //     //   'Type ',
  //     //   textAlign: TextAlign.left,
  //     //   style: TextStyle(
  //     //       fontSize: 12,
  //     //       fontFamily: 'Comic Sans MS',
  //     //       fontWeight: FontWeight.bold,
  //     //       color: Colors.black),
  //     // ),
  //   ],
  //   );
  //
  // }

}

