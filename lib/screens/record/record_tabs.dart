import 'package:flutter/material.dart';
import 'package:kids_republik/screens/record/dashboard.dart';
import 'package:kids_republik/screens/record/record.dart';
import 'package:kids_republik/screens/record/supervisor_farmers_dashboard.dart';
import 'package:kids_republik/screens/record/supervisor_record.dart';
import 'package:kids_republik/utils/const.dart';

import '../../main.dart';


class RecordTabScreen extends StatefulWidget {
  const RecordTabScreen({super.key});

  @override
  State<RecordTabScreen> createState() => _RecordTabScreenState();
}

class _RecordTabScreenState extends State<RecordTabScreen> {
  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // drawer: BaseDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          backgroundColor: kprimary,
          title: Text(
            'Income',
            style: TextStyle(color: kWhite,fontSize: 14),
          ),
          bottom: TabBar(
            labelStyle: TextStyle(
                color: kWhite, fontSize: 14, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(color: kWhite, fontSize: 14),
            labelColor: kWhite,
            unselectedLabelColor: Colors.grey[300],
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 2,
            isScrollable: true,
            tabs: [
              Tab(
                text: 'Dashboard',
                icon: Icon(Icons.scale_outlined),
              ),
              Tab(
                text: 'Harvested',
                // icon: Icon(Icons.add_business_sharp),
                 icon: Image.asset('assets/harvesting_icon.png',color: kWhite, width: mQ.width * 0.06, fit: BoxFit.contain,),
              ),
              // Tab(
              //   text: 'Expenditure',
              //   icon: Icon(Icons.scale_outlined),
              // ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
             role_ != 'Supervisor'?DashboardScreen():ViewParentsAccountSummarisedScreen(),
             role_ != 'Supervisor'?RecordScreen():SupervisorRecordsScreen(),
             // ExpenditureScreen(),

            ],
        ),
      ),
    );
  }
}
