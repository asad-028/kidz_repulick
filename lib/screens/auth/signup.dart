import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/auth_controllers/signup_controller.dart';
import 'package:kids_republik/screens/auth/login.dart';
import 'package:kids_republik/screens/widgets/auth_field.dart';
import 'package:kids_republik/screens/widgets/circle_button.dart';
import 'package:kids_republik/utils/const.dart';

import '../../main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool oldPVisible = false;
  bool newPVisible = false;
  String selectedCampus = 'KRDC';
  List <String> campuses = ['KRDC', 'TSN' ];

  SignUpController signUpController = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: signUpController.formKey,
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
                  child: Text("SignUp", style: kMediumTitle),
                ),
                SizedBox(height: mQ.height * 0.008),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    "Welcome",
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
                            controller: signUpController.nameController,
                            inputType: TextInputType.text,
                            labelText: "Full Name",
                            hintText: "Ali",
                            validators: (String? value) {
                              if (value!.isEmpty) {
                                return 'Full name required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mQ.height * 0.035),
                          AuthTextField(
                            controller: signUpController.emailController,
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
                          SizedBox(height: mQ.height * 0.035),
                          AuthTextField(
                            controller: signUpController.phoneController,
                            inputType: TextInputType.number,
                            labelText: "Phone Number",
                            hintText: "0092xxxxxxxxxx",
                            validators: (String? value) {
                              if (value!.isEmpty) {
                                return 'Phone number required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mQ.height * 0.035),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "******",
                              isDense: true,
                              labelText: "Password",
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 15),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle: kLabelStyle,
                              border: const OutlineInputBorder(),
                              suffixIcon: InkWell(
                                onTap: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable
                                  setState(() {
                                    oldPVisible = !oldPVisible;
                                  });
                                },
                                child: Icon(
                                  // Based on passwordVisible state choose the icon
                                  !oldPVisible
                                      ? Icons.visibility_off
                                      : Icons.remove_red_eye,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey[300]!, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey[300]!, width: 1.0),
                              ),
                            ),
                            obscureText: !oldPVisible,
                            controller: signUpController.passwordController,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'Password required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mQ.height * 0.035),
                          AuthTextField(
                            controller: signUpController.invitationCodeController,
                            inputType: TextInputType.text,
                            labelText: "Invitation Code",
                            hintText: "Enter Invitation Code",
                            validators: (String? value) {
                              if (value!.isEmpty) {
                                return 'Obtain Invitation Code from Manager';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mQ.height * 0.035),
                          Container(
                            width: 150,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField(
                                value: selectedCampus, // Replace with your initial selected currency
                                decoration: InputDecoration(labelText: 'Select Campus',border: InputBorder.none),
                                items: campuses.map((String campus) {
                                  return DropdownMenuItem<String>(
                                    value: campus,
                                    child: Text(campus),
                                  );
                                }).toList(),
                                onChanged: (String? newCampus) async {
                                    selectedCampus = newCampus!;
                                    table_ = (newCampus == 'TSN')?'tsn_':'';
                                    await setcollectionnames(table_);
                                  setState(() {
                                    signUpController.selectedCampus.text = selectedCampus;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a Campus.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: mQ.height * 0.035),
                          Obx(
                            () => signUpController.isLoading.value
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
                                            onPressed: () async {
                                              table_ = signUpController.selectedCampus.text == 'KRDC'?'': 'tsn_';
                                            await setcollectionnames(table_);
                                              signUpController
                                                  .signupUser(context);
                                            },
                                            child: const Text("Signup",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.3,
                                                    fontSize: 16,
                                                    color: kWhite)),
                                          )),

                                      SizedBox(
                                        height: mQ.height * 0.05,
                                      ),
                                      //if don't have an account then go to sign up
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Already have an account? ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: kBlack54),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(50, 30),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                alignment:
                                                    Alignment.centerLeft),
                                            child: Text(
                                              "Login",
                                              style: kPrimaryBold.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();

                                              Get.off(const LoginScreen());
                                            },
                                          ),
                                        ],
                                      ),
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
      ),
    );
  }
}
