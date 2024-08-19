import 'package:flutter/material.dart';

import '../../../utils/const.dart';
import '../verify_payment.dart';

class ViewReports extends StatefulWidget {
  int selectedIndex;
  ViewReports({required this.selectedIndex, super.key});

  @override
  State<ViewReports> createState() => _ViewReportsState();
}

class _ViewReportsState extends State<ViewReports> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // widget.selectedIndex = role_ == 'Parent' ? 0 : 1;
  }
  @override
  Widget build(BuildContext context) {
    return
      DefaultTabController(
      length: 3,
      initialIndex: widget.selectedIndex,
      child: Scaffold(
        // drawer: BaseDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          backgroundColor: kprimary,
          title: Text(
            'Accounts',
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
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(
                text: 'Dues',
                icon: Icon(Icons.account_balance_sharp),
                // icon: Image.asset('assets/tractor.png',color: kWhite, width: mQ.width * 0.06, fit: BoxFit.contain,),
              ),
              Tab(
                text: 'Paid',
                icon: Icon(Icons.payments),
              ),
              Tab(
                text: 'Verified',
                icon: Icon(Icons.verified_user_outlined),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
        DocumentListVerify(paystatus: 'Not Paid'),
        DocumentListVerify(paystatus: 'Paid'),
        DocumentListVerify(paystatus: 'Verified')
            // EquipmentScreen()
            //      MaintenanceScreen()

          ],
        ),
      ),
    );
  }
}
