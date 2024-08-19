
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/record/record.dart';
import 'package:kids_republik/screens/widgets/primary_button.dart';

import '../../utils/const.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  final collectionRefrence = FirebaseFirestore.instance.collection('crops');
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? fromDate_;
  DateTime? toDate_;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
    appBar: AppBar(
    iconTheme: IconThemeData(color: kWhite),
    backgroundColor: kprimary,
    title: Text(
    'Fees Record',
    style: TextStyle(color: kWhite,fontSize: 14),
    ),
    ),
    body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // All Sections

            _buildSection('Overall Summary', getAllSummary),
SizedBox(height: 10,),
            Container(height: 40,
              child: PrimaryButton(onPressed: (){
                Get.to(
                  RecordScreen(),
                );
              },
                  label: "View Details",
                elevation: 3,

                bgColor: kprimary,
                labelStyle: kTextPrimaryButton.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                borderRadius: BorderRadius.circular(22.0),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildSection(String title, Future<Map<String, dynamic>> Function() fetchData) {
    return Card(
      elevation: 2.0,
      // margin: EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.0),
          FutureBuilder(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Display the data in a DataTable
                return
                  DataTable(
                    // dataRowHeight: 30.0,
                  // headingRowHeight: 30,
                  columns: <DataColumn>[
                    DataColumn(label: Text('Fees'
                      ,style: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold,color: Colors.blue),
                    )),
                    DataColumn(label: Text('Amount'
                      ,style: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold),
                    )),
                  ],
                  rows: [
                    DataRow(
                        cells: [
                      DataCell(Text('Total Fees'
                ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text('Rs. ${snapshot.data?['totalExpenditure']}'
                        ,style: TextStyle(fontSize: 12.0),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Received'
                        ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text('Rs. ${snapshot.data?['totalIncome']}'
                        ,style: TextStyle(fontSize: 12.0),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Ballance'
                        ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      )),
                      DataCell(
                        Text(
                          'Rs. ${snapshot.data?['totalProfit']}',
                          style: TextStyle(fontSize: 12,
                            color: (snapshot.data?['totalProfit'] ?? 0) > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ]),

                    DataRow(cells: [
                      DataCell(Text('Expenditures'
                        ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold,color: Colors.blue[900]),
                      )),
                      DataCell(Text(''
                        ,style: TextStyle(fontSize: 12.0),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Salaries'
                        ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text('Rs. ${snapshot.data?['totalSalary']}'
                        ,style: TextStyle(fontSize: 12.0),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Routine'
                        ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text('Rs. ${snapshot.data?['totalMachineryPrice']}'
                        ,style: TextStyle(fontSize: 12.0),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Maintenance'
                        ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text('Rs. ${snapshot.data?['totalMaintenanceCost']}'
                        ,style: TextStyle(fontSize: 12.0),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Over all Profit/ Loss'
                        ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      )),
                      DataCell(
                        Text(
                          'Rs. ${snapshot.data?['totalProfit'] - snapshot.data?['totalMachineryPrice'] - snapshot.data?['totalMaintenanceCost']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: (snapshot.data?['totalProfit'] - snapshot.data?['totalMachineryPrice'] - snapshot.data?['totalMaintenanceCost'] ?? 0) > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ]),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> getAllSummary() async {
    // Fetch crops data
    QuerySnapshot cropsSnapshot = await _firestore
        .collection('crops')
        .where('user_id', isEqualTo: _currentUser.email)
        .get();

    int expenditure = 0;
    int income = 0;

    cropsSnapshot.docs.forEach((crop) {
      int cropExpenditure = crop['total_expenditure'] ?? 0;
      int cropIncome = crop['sold_in'] ?? 0;

      expenditure += cropExpenditure;
      income += cropIncome;
    });

    int profit = income - expenditure;

    // Fetch labor data
    QuerySnapshot laborSnapshot = await _firestore
        .collection('labour')
        .where('user_id', isEqualTo: _currentUser.email)
        .get();

    int salary = 0;
    int machineryPrice = 0;
    int maintenanceCost = 0;

    laborSnapshot.docs.forEach((labor) {
if (labor['type'] == 'Employee') {
  String hireDateStr = labor['hire_date'] ?? "";
  DateTime? hireDate;
  try {
    List<String> dateParts = hireDateStr.split('/');
    if (dateParts.length == 3) {
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);

      hireDate = DateTime(year, month, day);
    }
  } catch (e) {
    print("Error parsing hire_date: $e");
  }

  if (hireDate != null) {
    DateTime currentDate = DateTime.now();
    int numberOfMonths = currentDate.difference(hireDate).inDays ~/ 30;

    int monthlySalary = labor['salary'] ?? 0;
    int totalSalary = monthlySalary * numberOfMonths;

    salary += totalSalary;
  }
} else if (labor['type'] == 'Machinery') {
        int price = labor['price'] ?? 0;
        machineryPrice += price;
        int maintenanceCostValue = labor['maintenance_cost'] ?? 0;
        maintenanceCost += maintenanceCostValue;
      }
      // else if (labor['type'] == 'Maintenance') {
      // }
    });

    return {
      'totalIncome': income,
      'totalExpenditure': expenditure,
      'totalProfit': profit,
      'totalSalary': salary,
      'totalMachineryPrice': machineryPrice,
      'totalMaintenanceCost': maintenanceCost,
    };
  }


}

