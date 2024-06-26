import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/activities/select_childs_for_activity.dart';
import 'package:kids_republik/screens/activities/view_bi_weekly_activities.dart';
import 'package:kids_republik/screens/widgets/base_drawer.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:kids_republik/utils/image_slide_show.dart';

import 'checkin_checkout_screen.dart';

class TeacherHomeSelectActivityScreen extends StatefulWidget {
  final teachersclass;
  const TeacherHomeSelectActivityScreen({required this.teachersclass, super.key});

  @override
  State<TeacherHomeSelectActivityScreen> createState() => _TeacherHomeSelectActivityScreenState();
}

class _TeacherHomeSelectActivityScreenState extends State<TeacherHomeSelectActivityScreen> {
  bool deleteionLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return
      Scaffold(
      backgroundColor: Colors.white,
      drawer: BaseDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Home',
          style: TextStyle(color: kWhite),
        ),
        backgroundColor: kprimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: mQ.width*0.03),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImageSlideShowfunction(context),
              SizedBox(height: mQ.height*0.041,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child:
          IconButton(
          padding: EdgeInsets.only(left: mQ.width*0.0, right: mQ.width*0.0, top: mQ.height*0.01),
    constraints: const BoxConstraints(),
    onPressed: () {
                      Get.to (CheckinCheckoutScreen(activityclass_: teachersClass_));
                    },
                    icon: Image.asset('assets/checkin.png', height: mQ.height*0.13, fit: BoxFit.contain,),
                  ),

      ),
                  Expanded(child: activityButtonFunction("Food", 'assets/food.png', mQ),),
                  Expanded(child: activityButtonFunction("Fluids", 'assets/fluids.png', mQ),),
                  Expanded(child: activityButtonFunction("Toilet", 'assets/toilet.png', mQ),)
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
               Expanded(child:
                  activityButtonFunction("Sleep", 'assets/sleep.png', mQ),
              ),Expanded(child:
                  activityButtonFunction("Health", 'assets/health.png', mQ),
              ),Expanded(child:
                  activityButtonFunction("Activity", 'assets/activity.png', mQ),
              ),Expanded(child:
                  activityButtonFunction("Notes", 'assets/notes.png', mQ),
              )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              // Expanded(
              // child:    activityButtonFunction("Mood", 'assets/mood.png', mQ),
              // ),
              //     Expanded(child:
              //     activityButtonFunction("BiWeekly", 'assets/biweekly.png', mQ),
              // ),
                  Expanded(
                    child:
    IconButton(
    padding: EdgeInsets.only(left: mQ.width*0.0, right: mQ.width*0.0, top: mQ.height*0.01),
    constraints: const BoxConstraints(),
    onPressed: () {

                        Get.to(SelectChildsForActivity(activityclass_: widget.teachersclass, selectedsubject_: "Mood"));

                        // Get.to(ActivityHomeChild(activityclass_: widget.teachersclass, selectedsubject_: "Checked Out",));
                      },
                      icon: Image.asset('assets/mood.png', height: mQ.height*0.13,width: mQ.width * 0.23, fit: BoxFit.contain,),
                    ),
                  ),
                  Expanded(
                    child:
                    IconButton(
    padding: EdgeInsets.only(left: mQ.width*0.00610,right: mQ.width*0.00610, top:  mQ.height*0.02, bottom:  mQ.height*0.02),
                      onPressed: () {
                        Get.to(ViewBiweeklyActivities());
                      },
                      icon: Image.asset('assets/addactivityteacher.png', fit: BoxFit.contain, ),
                      // child: const Text('Consent Statements'),
                    ),
                  ),
              Expanded(
                    child: IconButton(
padding: EdgeInsets.only(left: mQ.width*0.0, right: mQ.width*0.0, top: mQ.height*0.01),
    constraints: const BoxConstraints(),
    onPressed: () {
                        Get.to(SelectChildsForActivity(activityclass_: widget.teachersclass, selectedsubject_: "BiWeekly"));
                      },
                      icon: Image.asset('assets/biweekly.png', height: mQ.height*0.13,width: mQ.width * 0.23, fit: BoxFit.contain,),
                    ),
                  ),
    Expanded(
                    child: IconButton(
padding: EdgeInsets.only(left: mQ.width*0.0, right: mQ.width*0.0, top: mQ.height*0.01),
    constraints: const BoxConstraints(),
    onPressed: () {
                        Get.to (CheckinCheckoutScreen(activityclass_: teachersClass_));
                      },
                      icon: Image.asset('assets/checkout.png', height: mQ.height*0.13,width: mQ.width * 0.23, fit: BoxFit.contain,),
                    ),
                  ),

                ],
              ),
            ],

          )),
    );
  }



activityButtonFunction(subject_,icon_,mQ){
  return
    IconButton(
    padding: EdgeInsets.only(left: mQ.width*0.0, right: mQ.width*0.0, top: mQ.height*0.01),
    constraints: const BoxConstraints(),
    onPressed: () {
      Get.to(SelectChildsForActivity(activityclass_: widget.teachersclass, selectedsubject_: subject_,));
      // Get.to(ActivityHomeChild(activityclass_:  widget.teachersclass, selectedsubject_: subject_ ));
    },
    icon: Image.asset(icon_,height: mQ.height*0.13, fit: BoxFit.contain,),
  );

}

}


