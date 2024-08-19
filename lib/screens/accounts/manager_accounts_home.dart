import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/screens/accounts/reports/reports.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/accounts/rates/manage_rates.dart';
import 'package:kids_republik/screens/accounts/select_child_for_generate_slip.dart';
import 'package:kids_republik/utils/const.dart';

import '../../main.dart';
import '../accounts/fees/fees_update.dart';
import '../accounts/fees/fees_form.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final String _currentMonth = DateFormat('MMM yyyy').format(DateTime.now());
  var mQ;
String bankName = "${table_ == '_tsn' ? "JS BANK LIMITED":"HABIB BANK LIMITED"}"; // Replace with actual data fetching
String accountNumber = "${table_ == '_tsn' ?"0002381047" :"22697930612103"}"; // Replace with actual data fetching
String IBANNumber = "${table_ == '_tsn' ?"PK90JSBL9004000002381047":"PK13HABB0022697930612103"}"; // Replace with actual data fetching
String creditTo = "${table_ == '_tsn' ?"SECOND NEST SMC PVT LTD":"KIDZ REPUBLIKE (PVT) LTD"}"; // Replace with actual data fetching

class ManagerAccountsHomeScreen extends StatefulWidget {
  const ManagerAccountsHomeScreen({Key? key}) : super(key: key);

  @override
  _ManagerAccountsHomeScreenState createState() => _ManagerAccountsHomeScreenState();
}

class _ManagerAccountsHomeScreenState extends State<ManagerAccountsHomeScreen> {

  final collectionReferenceClass = FirebaseFirestore.instance.collection(ClassRoom).orderBy('sort_');
  final CollectionReference feesCollection = FirebaseFirestore.instance.collection(accounts);

  @override
  void initState() {
    super.initState();
        () async {
      await updateAccountsDashboard('Infant');
      await updateAccountsDashboard('Toddler');
      await updateAccountsDashboard('Play Group - I');
      await updateAccountsDashboard('Kinder Garten - I');
      await updateAccountsDashboard('Kinder Garten - II');
    };
  }

  @override
  Widget build(BuildContext context) {
    mQ = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kprimary,
        foregroundColor: kWhite,
        title: Text('Account Dashboard', style: TextStyle(fontSize: 14)),
      ),
      body:
      Container(
        height: mQ.height*0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 14,),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      Icons.stacked_line_chart,
                      color: Colors.red, size: mQ.shortestSide * 0.04),
                  SizedBox(width: 8.0),
                  Text(
                    'Account Statement',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.0, color: Colors.black,fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            FutureBuilder<QuerySnapshot>(
              future: collectionReferenceClass.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No class data available.'));
                }

                final classDocs = snapshot.data!.docs;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: constraints.maxWidth),
                        child: DataTable(
                          columnSpacing: 10.0,
                          dataRowHeight: 30,
                          columns: [
                            DataColumn(
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Class',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataColumn(
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.money_off, color: Colors.red,size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Not Paid',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataColumn(
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.attach_money, color: Colors.blue,size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Paid',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataColumn(
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified, color: Colors.green,size: 16,),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          rows: classDocs.map((classData) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  MouseRegion(
                                    onEnter: (_) {
                                      setState(() {});
                                    },
                                    onExit: (_) {
                                      setState(() {});
                                    },
                                    child: InkWell(
                                      onTap: () async {
                                        await updateAccountsDashboard(
                                            classData.id);
                                        setState(() {

                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          '${(classData.id == 'Kinder Garten - I') ? 'KG-I' : (classData.id == 'Kinder Garten - II') ? 'KG-II' : (classData.id == 'Play Group - I') ? 'PG-I' : classData.id}',
                                          // classData.id,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.deepPurple[900],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  MouseRegion(
                                    onEnter: (_) {
                                      setState(() {});
                                    },
                                    onExit: (_) {
                                      setState(() {});
                                    },
                                    child: InkWell(
                                      onTap: () { _viewClassWiseDetailsdatewise(classData.id,'Not Paid');},
                                      // onTap: () { _viewClassWiseDetails(classData.id,'Not Paid');},
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          '${classData['NotPaid_']} (Rs. ${classData['amountNotPaid']})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: Colors.red[900],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  MouseRegion(
                                    onEnter: (_) {
                                      setState(() {});
                                    },
                                    onExit: (_) {
                                      setState(() {});
                                    },
                                    child: InkWell(
                                      onTap: (){_viewClassWiseDetailsdatewise(classData.id,'Paid');},
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          '${classData['Paid_']} (Rs. ${classData['amountPaid']})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: Colors.blue[900],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  MouseRegion(
                                    onEnter: (_) {
                                      setState(() {});
                                    },
                                    onExit: (_) {
                                      setState(() {});
                                    },
                                    child: InkWell(
                                      onTap: (){_viewClassWiseDetailsdatewise(classData.id,'Verified');},
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Text(
                                          '${classData['Verified_']} (Rs. ${classData['amountVerified']})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: Colors.green[900],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                "To view fees details of a particular class, click on the 'Not Paid,' 'Paid,' or 'Verified' value in its corresponding row",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    MyButton(
                      icon:
                      Icons.add,
                      label: 'Add Fees',
                      onPressed: () =>
                          Get.to(FeesEntryForm(babyId: 'No Baby Selected')),
                      backgroundColor: Colors.indigo,
                      textColor: Colors.white,
                    ),
                    MyButton(
                      icon: Icons.update,
                      label: 'Update',
                      onPressed: () => Get.to(FeesDataUpdateScreen(babyId: 'No Baby Selected',)),
                      backgroundColor: Colors.cyan,
                      textColor: Colors.white,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    MyButton(
                      icon: Icons.receipt,
                      label: 'Fees Slip',
                      onPressed: () => {
                        isLoading.value = true,

                                Get.to(SelectChildForGenerateSlip(
                                  babyId: 'No Baby Selected',
                                ))
                              },
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    ),
                    MyButton(
                      icon: Icons.verified,
                      label: 'Verify',
                      onPressed: () =>
                          Get.to(ViewReports(selectedIndex: 1,)),
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyButton(
                      icon: Icons.price_check,
                      label: 'Rates',
                      onPressed: () => Get.to(ManagerRates()),
                      backgroundColor: Colors.purple,
                      textColor: Colors.white,
                    ),
                    MyButton(
                      icon: Icons.report,
                      label: 'Reports',
                      onPressed: () =>
                          Get.to(ViewReports(selectedIndex: 0,))
                      ,
                      backgroundColor: Colors.teal,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      )
    );
  }
  Future<List<Map<String, dynamic>>> _fetchData() async {
    QuerySnapshot querySnapshot = await _firestore.collection(accounts)
    .where('status', isEqualTo: 'Not Paid')
        .where('month', isEqualTo: _currentMonth)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> _generatePdf() async {
    List<Map<String, dynamic>> data = await _fetchData();
    List<String> columns = [
      "Name", "Registration", "Security", "AnnualRecource", "Uniform", "AdmissionForm",
      "Tuition", "Meals", "Late_Sat", "FieldTrips", "AfterSchool", "DropIncare", "Misc"
    ];

    // Calculate the totals for each column
    Map<String, int> totals = {
      for (var column in columns.skip(1)) column: 0
     };

    for (var doc in data) {
      for (String column in columns.skip(1)) {
        totals[column] = (totals[column] ?? 0) + (doc['fees']?.firstWhere(
              (fee) => fee['name'] == column,
          orElse: () => {'amount': 0},
        ) ['amount'] ?? 0) as int;
      }
    }

    // Append the totals row to the data
    Map<String, dynamic> totalsRow = {
      "Name": "Total",
      ...totals
    };
    data.add(totalsRow);
    final imageDatakrdc = await rootBundle.load('assets/${table_}app_icon.png');
    final imageByteskrdc = imageDatakrdc.buffer.asUint8List();
    final imagekrdc = pw.MemoryImage(imageByteskrdc);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        orientation: pw.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Container(
                width: 25,
                height: 25,
                child: pw.Image(
                  imagekrdc,
                  fit: pw.BoxFit.fitWidth, // Adjust fit as needed (cover, contain, etc.)
                ),
              ),
              pw.Text('${table_ == 'tsn_'?'The Second Nest':'Kidz Republik'} Pre School & Day Care Center', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              // Payee Information
              pw.Text('Detail of Fees for the month of $_currentMonth', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.Divider(),


              pw.TableHelper.fromTextArray(
                headers: columns,
                data: data.map((doc) {
                  Map<String, dynamic> row = {
                    "Name": doc['childFullName'] ?? doc['Name'],
                  };
                  for (String column in columns.skip(1)) {
                    row[column] = doc[column]?.toString() ?? (doc['fees']?.firstWhere(
                          (fee) => fee['name'] == column,
                      orElse: () => {'amount': 0},
                    )['amount'] ?? 0).toString();
                  }
                  return columns.map((column) {
                    String value = row[column].toString();
                    // Wrap data in container with specific width
                    return pw.Container(
                        width: column == "Name" ? 150 : 50, // Set width based on column name
                        child: pw.Text(value, style: pw.TextStyle(fontSize: 10),textAlign: column == "Name" ? pw.TextAlign.left:pw.TextAlign.center)); // Existing data and style
                  }).toList();
                  // return columns.map((column) => row[column].toString()).toList();
                }).toList(),
                headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Reduced font size for headers
                cellStyle: pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
  Future<List<Map<String, dynamic>>> _fetchClassWiseDatadatewise(className, status_) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(accounts)
        .where('status', isEqualTo: status_)
        .where('studentClass', isEqualTo: className)
        .where('month', isEqualTo: _currentMonth)
        .get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
  Future<void> _viewClassWiseDetailsdatewise(className, status_) async {
    List<Map<String, dynamic>> data = await _fetchClassWiseDatadatewise(className, status_);

    List<String> columns = [
      "Name",
      status_ == 'Not Paid' ? "Due Date" : "Payment Date", // Conditional column header

      // "Due Date", // Added "Last Date"
      "Registration",
      "Security",
      "AnnualRecource",
      "Uniform",
      "AdmissionForm",
      "Tuition",
      "Meals",
      "Late_Sat",
      "FieldTrips",
      "AfterSchool",
      "DropIncare",
      "Misc",
      "amountPayable"
    ];

    // Calculate the totals for each column
    Map<String, int> totals = {
      for (var column in columns.skip(2)) column: 0
    };

    var totalAmountPayable;

    for (var doc in data) {
      for (String column in columns.skip(2)) {
        totals[column] = (totals[column] ?? 0) + (doc['fees']?.firstWhere(
              (fee) => fee['name'] == column,
          orElse: () => {'amount': 0},
        ) ['amount'] ?? 0) as int;
      }
      totalAmountPayable =( totalAmountPayable ?? 0 )+doc['amountPayable'] ?? 0; // Calculate total amountPayable
    }

    // Append the totals row to the data
    Map<String, dynamic> totalsRow = {
      "Name": "Total",
      ...totals,
      "amountPayable": totalAmountPayable, // Add total amountPayable to totalsRow
    };
    data.add(totalsRow);

    final imageDatakrdc = await rootBundle.load('assets/app_icon.png');
    final imageByteskrdc = imageDatakrdc.buffer.asUint8List();
    final imagekrdc = pw.MemoryImage(imageByteskrdc);

    final pdf = pw.Document();

    pdf.addPage(
        pw.Page(
        orientation: pw.PageOrientation.landscape,
        margin: pw.EdgeInsets.symmetric(horizontal: 30),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // Add footer text
      return pw.Column(
        children: [
        pw.Container(
        width: 25,
        height: 25,
        child: pw.Image(
          imagekrdc,
          fit: pw.BoxFit.fitWidth, // Adjust fit as needed (cover, contain, etc.)
        ),
      ),
    pw.Text('${table_ == 'tsn_'?'The Second Nest':'Kidz Republik'} Pre School & Day Care Center', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
    // Payee Information
          pw.Row(children: [
    pw.Text('Detail of Fees $status_ for the month of $_currentMonth - ($className)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
           pw.Spacer(),
            pw.Text(
              "Report Generated by App on ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey ),
              textAlign: pw.TextAlign.right,
            )
          ]),
    pw.Divider(),

    pw.TableHelper.
    fromTextArray(
    headers:
    [
      "Name",
      status_ == 'Not Paid' ? "Due Date" : "Payment Date", // Conditional column header

      // "Due Date", // Added "Last Date"
      "Regn",
      "Security",
      "Annual",
      "Uniform",
      "Admission Form",
      "Tuition",
      "Meals",
      "Late / Sat",
      "Field Trips",
      "After School",
      "Drop In care",
      "Misc",
      "Total"
    ],
    data: data.map((doc) {
    Map<String, dynamic> row = {
    "Name": doc['childFullName'] ?? doc['Name'],
    if (status_ == 'Not Paid') "Due Date": doc['lastDate']?.toString() ?? '' else "Payment Date": doc['dateOfPayment']?.toString() ?? '', // Added for "Last Date"
    };
    for (String column in columns.skip(2)) { // Skip first two ("Name" and "Last Date")
    row[column] = doc[column]?.toString() ?? (doc['fees']?.firstWhere(
    (fee) => fee['name'] == column,
    orElse: () => {'amount': 0},
    )['amount'] ?? 0).toString();
    }
    return columns.map((column) {
    String value = row[column].toString();
        return pw.Container(
        width: column == "Name" ? 130 : column == "amountPayable" ? 70 :
        (column == "Due Date"||column == "Payment Date" ? 87 : 50), // Set width based on column name
        child: pw.Text(value, style: pw.TextStyle(fontSize: 10),textAlign: column == "Name" ? pw.TextAlign.left:pw.TextAlign.center)); // Existing data and style
    }).toList();
      // return columns.map((column) => row[column].toString()).toList();
    }).toList(),
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Reduced font size for headers
      cellStyle: pw.TextStyle(fontSize: 9),
    ),
        ],
      );
        },

        ),

    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }


}

Widget MyButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
  Color backgroundColor = Colors.blue,  // Default color
  Color textColor = Colors.white,      // Default color
  double width = 0.45,                   // Customizable width (0.0 - 1.0)
  double height = 0.09,                 // Customizable height (0.0 - 1.0)
  double borderRadius = 10.0,           // Customizable border radius
  double iconSize = 24.0,               // Customizable icon size
  double fontSize = 16.0,               // Customizable font size
}) {
  return Container(
    padding: EdgeInsets.all(8),
    // color: backgroundColor,
    width: mQ.width* width,
    height: mQ.height * height,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(

        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) // Display icon only if provided
            Icon(icon, color: Colors.white, size: iconSize),
          if (icon != null && label.isNotEmpty) SizedBox(width: 8.0), // Spacing between icon and label
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

Future<void> updateAccountsDashboard(String classId) async {
  // Create a reference to the accounts collection
  final accountsCollection = FirebaseFirestore.instance.collection(accounts);

  // Query accounts for the specified class
  final querySnapshot = await accountsCollection
      .where('studentClass', isEqualTo: classId)
      .where('month', isEqualTo: _currentMonth)
      .get();

  // Initialize counters for each status
  int notPaidCount = 0;
  int paidCount = 0;
  int verifiedCount = 0;
  int notPaidAmount = 0;
  int paidAmount = 0;
  int verifiedAmount = 0;

  // Loop through each document in the query results
  for (final doc in querySnapshot.docs) {
    final status = doc.get('status');
    int amount = (doc.get('amountPayable') ?? 0.0).toInt();

    // Increment counters based on status
    if (status == 'Not Paid') {
      notPaidCount++;
      notPaidAmount = notPaidAmount + amount;
    } else if (status == 'Paid') {
      paidCount++;
      paidAmount = paidAmount + amount;
    } else if (status == 'Verified') {
      verifiedCount++;
      verifiedAmount = verifiedAmount + amount;
    } else {
      // Handle unexpected status values (optional)
      print('Warning: Unexpected status found: $status');
    }
  }

  // Create a reference to the ClassRoom document
  final classRef = FirebaseFirestore.instance.collection(ClassRoom).doc(classId);

  // Update ClassRoom document with calculated counts
  await classRef.update({
    'NotPaid_': notPaidCount,
    'amountNotPaid': notPaidAmount,
    'Paid_': paidCount,
    'amountPaid': paidAmount,
    'Verified_': verifiedCount,
    'amountVerified': verifiedAmount,
  });

  // snack('Dashboard reloaded.');

}
