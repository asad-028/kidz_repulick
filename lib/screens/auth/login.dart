import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/auth_controllers/login_controller.dart';
import 'package:kids_republik/screens/auth/forgot_password.dart';
import 'package:kids_republik/screens/auth/signup.dart';
import 'package:kids_republik/screens/widgets/auth_field.dart';
import 'package:kids_republik/utils/const.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool oldPVisible = false;
  bool newPVisible = false;

  LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: loginController.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: mQ.height * 0.045),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text("Login", style: kMediumTitle),
                ),
                SizedBox(height: mQ.height * 0.008),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    "Welcome back to Kidz Republik",
                    style: kGrey15500,
                  ),
                ),
                SizedBox(height: mQ.height * 0.04),
                Container(
                  width: double.infinity,
                  height: mQ.height * 0.77,
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
                            controller: loginController.emailController,
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
                          SizedBox(height: mQ.height * 0.032),
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
                            controller: loginController.passwordController,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'Password required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: mQ.height * 0.01),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                              style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: const Size(50, 30),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  alignment:
                                                      Alignment.centerLeft),
                                              child: Text(
                                                "Forgot Password?",
                                                style: kPrimaryBold.copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                              onPressed: () {
                                                FocusScope.of(context).unfocus();
                              
                                                Get.to(const ForgotPassword());
                                              },
                                            ),
                              ),
                          SizedBox(height: mQ.height * 0.06),
                          Obx(
                            () => loginController.isLoading.value
                                ? const CircularProgressIndicator()
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
                                            loginController.signInUser(context);
                                          },
                                          child: const Text("Login",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.3,
                                                  fontSize: 16,
                                                  color: kWhite)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: mQ.height * 0.045,
                                      ),
                                      //if don't have an account then go to sign up
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Don't have an account? ",
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
                                              "Sign up",
                                              style: kPrimaryBold.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();

                                              Get.to(const SignUpScreen());
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: mQ.height * 0.03,
                                      ),
                                    ],
                                  ),
                          ),
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
