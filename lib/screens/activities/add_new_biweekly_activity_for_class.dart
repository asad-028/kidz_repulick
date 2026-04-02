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
      backgroundColor: grey100,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: kprimary),
        title: Text(
          'BiWeekly Activity',
          style: k16bold.copyWith(color: kprimary),
        ),
        backgroundColor: kWhite,
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
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "New Activity",
                          style: k16bold.copyWith(color: kprimary),
                        ),
                        Text(
                          "Create a bi-weekly summary for your class",
                          style: k12500.copyWith(color: kGrey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    getCurrentDateforattendance(),
                    style: k12500.copyWith(color: kGrey),
                  ),
                ],
              ),
            ),
            Obx(
              () => addNewConsentController.isLoadingInitial.value
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Activity Details",
                                  style: k14500.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: kBlackColor)),
                              const SizedBox(height: 16),
                              DropdownSearch<String>(
                                popupProps: PopupProps.menu(
                                  showSelectedItems: true,
                                ),
                                items: list,
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: 'Select ActivityType',
                                    hintText: 'Select Activity',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3)),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValue = value!;
                                  });
                                },
                                selectedItem: dropdownValue,
                              ),
                              const SizedBox(height: 16),
                              if (role_ == "Teacher")
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: kprimary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Class: $teachersClass_',
                                    style: k14500.copyWith(color: kprimary),
                                  ),
                                )
                              else
                                DropdownButtonFormField(
                                  value: dropdownValueClasses,
                                  decoration: InputDecoration(
                                    labelText: 'Select Class',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onChanged: (String? value) {
                                    setState(() {
                                      dropdownValueClasses = value!;
                                    });
                                  },
                                  items: classes_
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: addNewConsentController.title_,
                                inputType: TextInputType.text,
                                labelText: "Title",
                                validators: (String? value) {
                                  if (value!.isEmpty) return 'Required';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: addNewConsentController.description_,
                                inputType: TextInputType.multiline,
                                maxLines: 3,
                                labelText: "Description",
                                validators: (String? value) {
                                  if (value!.isEmpty) return 'Required';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

}
