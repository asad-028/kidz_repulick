import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/consent_controllers/add_new_consent_controller.dart';
import 'package:kids_republik/utils/getdatefunction.dart';

import '../../main.dart';
import '../../utils/const.dart';
import '../../utils/image_slide_show.dart';
import '../kids/widgets/custom_textfield.dart';
import '../widgets/primary_button.dart';
    final list  = <String> ['Phonics - Literacy', 'Numeracy', 'Creative Learning and Crafts', 'Reading - Story Telling', 'Movie - Music - Circle Time', 'Knowledge of the World', 'Fine Motor Skills', 'Physical Activity','Science Fusion ','Other'];
var dropdownValue = list.first;
var dropdownValueClasses = classes_.first;
class AddNewBiweeklyActivityForClass extends StatefulWidget {
  AddNewBiweeklyActivityForClass({ super.key});

  @override
  State<AddNewBiweeklyActivityForClass> createState() => _AddNewBiweeklyActivityForClassState();

}

class _AddNewBiweeklyActivityForClassState extends State<AddNewBiweeklyActivityForClass> {

  AddNewConsentController addNewConsentController = Get.put(AddNewConsentController());
  @override
  void initState() {
    super.initState();
    print('$role_ - $teachersClass_');

    addNewConsentController.currentDate.value = addNewConsentController.getCurrentDate();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'BiWeekly Activity',
          style: TextStyle(color: kWhite,fontSize: 14),
        ),
        backgroundColor: kprimary,
      ),
      bottomNavigationBar:
      Obx(
            () => addNewConsentController.isLoading.value
            ? Center(child: const CircularProgressIndicator())
            : SizedBox(
          width: mQ.width * 0.5,
          height: mQ.height * 0.055,
          child: PrimaryButton(
            onPressed: () async {

setState(() {
addNewConsentController.isLoading.value = true;
});
          await
addNewConsentController.addclasswiseActivityfunction(
                  context,dropdownValue,
                  role_ == "Teacher" ? teachersClass_! :
                  dropdownValueClasses);
          setState(() {
addNewConsentController.isLoading.value = false;

          });
            },
            label: "Add",
            elevation: 3,
            bgColor: kprimary,
            labelStyle: kTextPrimaryButton.copyWith(
                fontWeight: FontWeight.w500),
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ImageSlideShowfunction(context),
            SizedBox(height: 3,),
            Container(padding: EdgeInsets.symmetric(horizontal: mQ.width*0.02),
              height: mQ.height * 0.03,
              color: Colors.grey[50],
              width: mQ.width * 0.98,
              // padding:mQ ,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'New Activity',
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
            Obx(
                  () => addNewConsentController.isLoadingInitial.value
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownSearch<String>(
                        popupProps: PopupProps.menu(
                          showSelectedItems: true,
                          disabledItemFn: (String s) => s.startsWith('I'),
                        ),
                        items: list,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                  // elevation: 16,
                            labelText:
                            'select Activity',
                            // teacherAssignments[index][i],
                            hintText:
                            'select Activity',
                  hintStyle: const TextStyle(color: Colors.deepPurple),
                  // icon: const Icon(Icons.arrow_downward),
                            // teacherAssignments[index][i],
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                        selectedItem:
                        dropdownValue,
                        // teacherAssignments[index][i],
                      ),


                      SizedBox(
                        height: mQ.height * 0.02,
                      ),
                      (role_ == "Teacher") ?
                        Text('${teachersClass_}')
                       :
                      DropdownButtonFormField(
                  value: dropdownValueClasses,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                    dropdownValueClasses = value!;
                    });
                  },
                  items: classes_.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                      SizedBox(
                        height: mQ.height * 0.02,
                      ),
                      CustomTextField(
                        enabled: true,
                        controller: addNewConsentController.title_,
                        inputType: TextInputType.text,
                        labelText: "Title",
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
                        inputType: TextInputType.multiline,
                        maxLines: 2,
                        labelText: "Description",
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
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: mQ.height*0.5,),
            ],
        ),
      ),
    );
  }

}
