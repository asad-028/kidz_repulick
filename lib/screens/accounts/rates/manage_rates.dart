import 'package:flutter/material.dart';
import 'package:kids_republik/screens/accounts/rates/display_meal.dart';
import 'package:kids_republik/screens/accounts/rates/display_packages.dart';
import 'package:kids_republik/utils/const.dart';

class ManagerRates extends StatefulWidget {
  const ManagerRates({super.key});

  @override
  State<ManagerRates> createState() => _ManagerRatesState();
}

class _ManagerRatesState extends State<ManagerRates> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // drawer: BaseDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: kWhite),
          backgroundColor: kprimary,
          title: Text(
            'Rates',
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
                text: 'Packages',
                icon: Icon(Icons.account_balance_sharp),
                // icon: Image.asset('assets/tractor.png',color: kWhite, width: mQ.width * 0.06, fit: BoxFit.contain,),
              ),
              Tab(
                text: 'Meals',
                icon: Icon(Icons.payments),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DisplayPackagesScreen(),
            DisplayMealScreen()// EquipmentScreen()
          ],
        ),
      ),
    );
  }
}
