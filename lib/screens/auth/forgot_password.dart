import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/auth_controllers/forgot_password_controller.dart';
import 'package:kids_republik/screens/widgets/auth_field.dart';
import 'package:kids_republik/screens/widgets/circle_button.dart';
import 'package:kids_republik/utils/const.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool oldPVisible = false;
  bool newPVisible = false;

  ForgotPasswordController forgotPasswordController = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: forgotPasswordController.formKey,
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
                  child: Text("Forgot Password?", style: kMediumTitle),
                ),
                SizedBox(height: mQ.height * 0.008),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    "Enter your email below to recieve \nyour password through email",
                    style: kGrey15500,
                  ),
                ),
                SizedBox(height: mQ.height * 0.04),
                Container(
                  width: double.infinity,
                  height: mQ.height * 0.79,
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
                          SizedBox(height: mQ.height * 0.08),
                          AuthTextField(
                            controller: forgotPasswordController.emailController,
                            inputType: TextInputType.emailAddress,
                            labelText: "Email",
                            hintText: "user@gmail.com",
                            validators: (String? value) {
                              if (value!.isEmpty) {
                                return 'Email required';
                              } else if (!value.contains('@')) {
                                return 'Invalid Email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mQ.height * 0.06),
                          Obx(
                            () => forgotPasswordController.isLoading.value
                                ? CircularProgressIndicator()
                                : SizedBox(
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
                                        forgotPasswordController.forgotPassword(context);
                                      },
                                      child: const Text("Continue",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                              fontSize: 16,
                                              color: kWhite)),
                                    )),
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
      ),
    );
  }
}
