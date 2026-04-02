import 'package:flutter/material.dart';

import '../../../utils/const.dart';
import '../verify_payment.dart';

class ViewReports extends StatefulWidget {
  final int selectedIndex;
  const ViewReports({required this.selectedIndex, super.key});

  @override
  State<ViewReports> createState() => _ViewReportsState();
}

class _ViewReportsState extends State<ViewReports> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.selectedIndex,
      child: Scaffold(
        backgroundColor: grey100,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: kWhite),
          backgroundColor: kprimary,
          title: const Text(
            'Accounts & Reports',
            style: TextStyle(color: kWhite, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelStyle: const TextStyle(
                color: kWhite, fontSize: 14, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(
                color: kWhite.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),
            labelColor: kWhite,
            unselectedLabelColor: kWhite.withOpacity(0.7),
            indicatorColor: kWhite,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            isScrollable: false,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(
                text: 'Dues',
                icon: Icon(Icons.account_balance_wallet_outlined, size: 20),
              ),
              Tab(
                text: 'Paid',
                icon: Icon(Icons.payments_outlined, size: 20),
              ),
              Tab(
                text: 'Verified',
                icon: Icon(Icons.verified_outlined, size: 20),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DocumentListVerify(paystatus: 'Not Paid'),
            DocumentListVerify(paystatus: 'Paid'),
            DocumentListVerify(paystatus: 'Verified'),
          ],
        ),
      ),
    );
  }
}
