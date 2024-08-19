import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/record/record_tabs.dart';
import 'package:kids_republik/screens/widgets/base_drawer.dart';
import 'package:kids_republik/utils/const.dart';

class SupervisorHomewithDashboardScreen extends StatefulWidget {
  const SupervisorHomewithDashboardScreen({Key? key}) : super(key: key);

  @override
  _SupervisorHomewithDashboardScreenState createState() => _SupervisorHomewithDashboardScreenState();
}
class _SupervisorHomewithDashboardScreenState extends State<SupervisorHomewithDashboardScreen> {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection(users);
  final CollectionReference cropsCollection =   FirebaseFirestore.instance.collection('crops');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(backgroundColor: kprimary,foregroundColor: kWhite,title: Text('Dashboard',style: TextStyle(fontSize: 14),)),
      drawer: BaseDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            Container(
                width:mQ.width*0.95,
                color: Colors.green[100],
                child: Text("$role_'s Dashboard",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),)),
            // _buildSection('Farmer Name', getAllSummary),
            SizedBox(height: mQ.height*0.20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton(
                  Icons.person_add,
                  'Users',
                      () {
                    //     Get.to(SelectUserOrInvitation());
                        // Get.to(UserManagementScreen());

                  },
                  Colors.indigo, // Button color
                  Colors.white, // Text color
                ),
                MyButton(
                  Icons.grass,
                  'Crops',
                      () {
               // Get.to(SupervisorFarmersLandsScreen() );
                    // print('Crops button pressed');
                  },
                  Colors.green,
                  Colors.white,
                ),
                MyButton(
                  Icons.event,
                  // Icons.calendar_today,
                  'Agri Calendar',
                      () {
                    // Get.to(SupervisorFarmersCalendarScreen());
                  },
                  Colors.blue,
                  Colors.white,
                ),

              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton(
                  Icons.store,
                  'Store',
                      () {
               // Get.to(StoreScreen());
                  },
                  Colors.orange,
                  Colors.white,
                ),
                MyButton(
                  Icons.people,
                  'Staff',
                      () {
              // Get.to(StaffScreen());
                  },
                  Colors.brown,
                  Colors.white,
                ),
                MyButton(
                  Icons.account_balance,
                  'Assets',
                      () {
                    // Get.to(AssetsScreen());
                  },
                  Colors.teal,
                  Colors.white,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton(
                  Icons.attach_money,
                  'Income',
                      () {
                    Get.to(RecordTabScreen());
                  },
                  Colors.green,
                  Colors.white,
                ),
                MyButton(
                  Icons.attach_money,
                  'Expenditures',
                      () {
                    // Get.to(SupervisorFarmersExpenditureScreen());
                  },
                  Colors.red,
                  Colors.white,
                ),

              ],
            ),


          ],
        ),
      ),
    );
  }

  Widget MyButton(IconData icon, String label, Null Function() onPressed, Color backgroundColor, Color textColor) {
    final mQ = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(mQ.width*0.008),
      child: SizedBox(
        width: mQ.width*0.3,
        height: mQ.height*0.14,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[50],
            foregroundColor: textColor,
            padding: EdgeInsets.all(12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,color: backgroundColor, size: mQ.shortestSide*0.12),
              SizedBox(height: 8.0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0,color: kprimary),
              ),
            ],
          ),
        ),
      ),
    );
  }



}