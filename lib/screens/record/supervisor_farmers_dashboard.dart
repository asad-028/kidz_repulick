import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_republik/utils/const.dart';
import '../../main.dart';
import '../main_tabs.dart';

var userlist;

class ViewParentsAccountSummarisedScreen extends StatefulWidget {
  ViewParentsAccountSummarisedScreen({Key? key}) : super(key: key);

  @override
  _ViewParentsAccountSummarisedScreenState createState() => _ViewParentsAccountSummarisedScreenState();
}

class _ViewParentsAccountSummarisedScreenState extends State<ViewParentsAccountSummarisedScreen> {
  final CollectionReference userCollection = FirebaseFirestore.instance.collection(users);
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    userlist = userCollection
        .where('role', isEqualTo: 'Parent')
        // .where('supervisor_', isEqualTo: user!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    var selectedUserEmail;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        title: UserDropdownButton(
          selectedUserEmail: selectedUserEmail,
          onUserSelected: (String userEmail) {
            userlist = userCollection
                // .where('role', isEqualTo: 'Parent')
                .where('email', isEqualTo: userEmail)
                .get();
            setState(() {
              selectedUserEmail = userEmail;
            });
          },
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: userlist,
        builder: (context, usersSnapshot) {
          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (usersSnapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          final List<DocumentSnapshot> users = usersSnapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: EdgeInsets.all(5.0),
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(color: Colors.green[50],
                      child: Row(
                        children: [
                          Text(
                            '${user['full_name']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Spacer(),
                          // Text(' ${user['contact_number']}'),
                        ],
                      ),
                    ),
                    SupervisorFarmerDashboardScreen(userEmail: user['email']),
                    // SupervisorStaffInfo(userEmail: user['email'], type_: widget.category_),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SupervisorFarmerDashboardScreen extends StatefulWidget {
  String userEmail;
  SupervisorFarmerDashboardScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _SupervisorFarmerDashboardScreenState createState() => _SupervisorFarmerDashboardScreenState();
}
class _SupervisorFarmerDashboardScreenState extends State<SupervisorFarmerDashboardScreen> {
  final collectionRefrence = FirebaseFirestore.instance.collection('crops');
  bool deleteionLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? fromDate_;
  DateTime? toDate_;

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // All Sections

            _buildSection('Account Summary', getAllSummary),
            SizedBox(height: 10,),
          ],
        ),

    );
  }
  Widget _buildSection(String title, Future<Map<String, dynamic>> Function() fetchData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 4.0),
        FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Display the data in a DataTable
              return
                DataTable(
                  // dataRowHeight: 40.0,
                  // headingRowHeight: 40,
                  // columnSpacing: 10,
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.grey[300]!),
                  //   borderRadius: BorderRadius.circular(4.0),
                  // ),
                  dataRowHeight: 30.0,
                  headingRowHeight: 30,
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
                          DataCell(Text('Total'
                            ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text('Rs. ${snapshot.data?['totalExpenditure']}'
                            ,style: TextStyle(fontSize: 12.0),
                          )),
                        ]),
                    DataRow(cells: [
                      DataCell(Text('Paid'
                        ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text('Rs. ${snapshot.data?['totalIncome']}'
                        ,style: TextStyle(fontSize: 12.0),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Arears/ Ballance'
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

                    // DataRow(cells: [
                    //   DataCell(Text('Other Expenditures'
                    //     ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold,color: Colors.blue[900]),
                    //   )),
                    //   DataCell(Text(''
                    //     ,style: TextStyle(fontSize: 12.0),
                    //   )),
                    // ]),
                    // DataRow(cells: [
                    //   DataCell(Text('Salaries'
                    //     ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                    //   )),
                    //   DataCell(Text('Rs. ${snapshot.data?['totalSalary']}'
                    //     ,style: TextStyle(fontSize: 12.0),
                    //   )),
                    // ]),
                    // DataRow(cells: [
                    //   DataCell(Text('Machinery Purchased'
                    //     ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                    //   )),
                    //   DataCell(Text('Rs. ${snapshot.data?['totalMachineryPrice']}'
                    //     ,style: TextStyle(fontSize: 12.0),
                    //   )),
                    // ]),
                    // DataRow(cells: [
                    //   DataCell(Text('Maintenance Cost'
                    //     ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                    //   )),
                    //   DataCell(Text('Rs. ${snapshot.data?['totalMaintenanceCost']}'
                    //     ,style: TextStyle(fontSize: 12.0),
                    //   )),
                    // ]),
                    // DataRow(cells: [
                    //   DataCell(Text('Over all Profit/ Loss'
                    //     ,style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                    //   )),
                    //   DataCell(
                    //     Text(
                    //       'Rs. ${snapshot.data?['totalProfit'] - snapshot.data?['totalMachineryPrice'] - snapshot.data?['totalMaintenanceCost']}',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: (snapshot.data?['totalProfit'] - snapshot.data?['totalMachineryPrice'] - snapshot.data?['totalMaintenanceCost'] ?? 0) >= 0
                    //             ? Colors.green
                    //             : Colors.red,
                    //       ),
                    //     ),
                    //   ),
                    // ]),
                  ],
                );
            }
          },
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> getAllSummary() async {
    // Fetch crops data
    QuerySnapshot cropsSnapshot = await _firestore
        .collection('crops')
        .where('user_id', isEqualTo: widget.userEmail)
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
        .where('user_id', isEqualTo: widget.userEmail)
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

