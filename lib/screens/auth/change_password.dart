import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/auth_controllers/change_password.dart';
import 'package:kids_republik/screens/widgets/auth_field.dart';
import 'package:kids_republik/screens/widgets/circle_button.dart';
import 'package:kids_republik/utils/const.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool oldPVisible = false;
  bool newPVisible = false;

  ChangePasswordController changePasswordController =
      Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: mQ.height * 0.008),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CircleButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              SizedBox(height: mQ.height * 0.02),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text("Change Password", style: kMediumTitle),
              ),
              SizedBox(height: mQ.height * 0.008),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "Secure your password",
                  style: kGrey15500,
                ),
              ),
              SizedBox(height: mQ.height * 0.04),
              Container(
                width: double.infinity,
                //    height: mQ.height * 0.74,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0)),
                  color: kWhite,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Column(
                      children: [
                        SizedBox(height: mQ.height * 0.06),
                        AuthTextField(
                          controller:
                              changePasswordController.currentcontroller,
                          inputType: TextInputType.text,
                          labelText: "Current Password",
                          hintText: "********",
                          validators: (String? value) {
                            if (value!.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: mQ.height * 0.035),
                        AuthTextField(
                          controller:
                              changePasswordController.newpasswordcontroller,
                          inputType: TextInputType.text,
                          labelText: "New Password",
                          hintText: "********",
                          validators: (String? value) {
                            if (value!.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: mQ.height * 0.035),
                        AuthTextField(
                          controller: changePasswordController
                              .confirmpasswordcontroller,
                          inputType: TextInputType.text,
                          labelText: "Confirm New Password",
                          hintText: "********",
                          validators: (String? value) {
                            if (value!.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: mQ.height * 0.06),
                        Obx(
                          () => changePasswordController.isLoading.value
                              ? CircularProgressIndicator()
                              : Column(
                                  children: [
                                    SizedBox(
                                        width: mQ.width * 0.85,
                                        height: mQ.height * 0.065,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kprimary,
                                            elevation: 0,
                                            // textStyle: TextStyle(
                                            //     fontWeight: FontWeight.bold,
                                            //     letterSpacing: 0.3,
                                            //     fontSize: 16,
                                            //     color: kWhite) ,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(22.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            changePasswordController
                                                .changePassword();
                                          },
                                          child: const Text("Change Password",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.3,
                                                  fontSize: 16,
                                                  color: kWhite)),
                                        )),
                                    SizedBox(
                                      height: mQ.height * 0.03,
                                    ),
                                  ],
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
