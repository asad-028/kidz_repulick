
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/splash_controller.dart';
import 'package:kids_republik/utils/const.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    controller.pickInitialdata();
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Container(
        height: mQ.height,
        width: mQ.width,
        decoration: BoxDecoration(

          image: DecorationImage(
          alignment: Alignment.bottomCenter,
            image: AssetImage(
                'assets/splash_screen.png'), // Replace with your image path
            fit: BoxFit.fitWidth, // Adjust the fit as needed
          ),
        ),
        child: Column(children: [
          SizedBox(
            height: mQ.height * 0.237,
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(400),
              child: Container(
                height: 180,
                width: 180,
                //  height: mQ.height * 0.2,
                // width: mQ.width * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/app_icon.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          SizedBox( height: mQ.height * 0.2),
          CupertinoActivityIndicator(color: kBlackColor,radius: 18),
        ]),
      ),
    );
  }


}
