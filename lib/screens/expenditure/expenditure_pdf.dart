import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/controllers/splash_controller.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:printing/printing.dart';

import '../../main.dart';
import '../kids/widgets/empty_background.dart';

class ExpendituresScreen extends StatefulWidget {
  const ExpendituresScreen({super.key});

  @override
  State<ExpendituresScreen> createState() => _ExpendituresScreenState();
}

class _ExpendituresScreenState extends State<ExpendituresScreen> {
  late List<Map<String, dynamic>> activityData;

  final collectionRefrence = FirebaseFirestore.instance.collection('crops');
  bool deleteionLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  final SplashController controller = Get.put(SplashController());
  DateTime? fromDate_;
  DateTime? toDate_;

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(backgroundColor: kprimary,foregroundColor: kWhite),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                child: StreamBuilder<QuerySnapshot>(
                   stream: collectionRefrence
                      .where('type', isEqualTo: 'crop')
                      .where('user_id', isEqualTo: user!.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: CircularProgressIndicator(),
                        ),
                      ); // Show loading indicator
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Center(child: Text('Error: ${snapshot.error}')),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return EmptyBackground(
                        title: 'No Records Found',
                      ); // No data
                    }

                    // Data is available, build the list
                    return ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final recordData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!)),
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: mQ.height * 0.06,
                                  width: mQ.width,
                                  padding:
                                  const EdgeInsets.only(bottom: 8.0, top: 8,left: 12,right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                    ),
                                    color: kprimary,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          recordData['sowing_date'],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),

                                      Text('View Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          final data = await fetchActivities(snapshot.data!.docs[index].id);

                                          final pdfBytes = await generatePDF(
                                            snapshot.data!.docs[index].id,
                                            data['activityData'],
                                            mQ,
                                            recordData,
                                            data['costSummary'],
                                          );

                                          displayPDF(pdfBytes);
                                        },
                                        icon: Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    showDetailsDialog(documentId: snapshot.data!.docs[index].id,title: recordData['plot_no'],currency: recordData['currency'],fertilizer_expenses: 1022,irrigation_expenses: 1232,labor_expenses: 1233,land_prep_expenses: 432,seed_expenses: 321);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${recordData['plot_no']}",
                                              style: TextStyle(),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Crop: ${recordData['seed_name']}/${recordData['seed_variety']}",
                                                style: TextStyle(),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              "Product: ${recordData['productivity']} kg",
                                              style: TextStyle(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Expenditure: Rs.${recordData['total_expenditure']}",
                                              style: TextStyle(),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              "Income: Rs.${recordData['sold_in']}",
                                              style: TextStyle(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        recordData['total_expenditure'] >
                                            recordData['sold_in']
                                            ? Text(
                                          "Loss: Rs.${recordData['total_expenditure'] - recordData['sold_in']}",
                                          style: TextStyle(color: Colors.red),
                                        )
                                            : Text(
                                          "Profit: Rs.${recordData['sold_in'] - recordData['total_expenditure']}",
                                          style: TextStyle(color: Colors.green[900]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: mQ.height * 0.05,
              ),
            ],
          )),
    );
  }


  showDetailsDialog({
    String? documentId,
    String? title,
    num? seed_expenses,
    num? labor_expenses,
    num? fertilizer_expenses,
    num? land_prep_expenses,
    num? irrigation_expenses,
    String? currency,
  }) async {
    // Fetch the data
    Map<String, int> sumOfCostByCategory = {};
    try {
      CollectionReference activityCollection = FirebaseFirestore.instance.collection(Activity);

      QuerySnapshot querySnapshot = await activityCollection.where('land_id', isEqualTo: documentId).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Create a map to store the sum of cost for each category

        // Iterate through each document and update the sum for its category
        querySnapshot.docs.forEach((doc) {
          String category = doc['category_'] ?? 'Uncategorized';
          int cost = doc['cost'] ?? 0;

          sumOfCostByCategory.update(category, (value) => value + cost, ifAbsent: () => cost);
        });

        // Now you can use the sumOfCostByCategory map for further processing or display
        // sumOfCostByCategory.forEach((category, sum) {
        //   print('Sum of cost for category $category: $sum');
        // });
      } else {
        print('No matching documents found for land_id: $documentId');
      }
    } catch (e) {
      print('Error fetching sum of cost grouped by category: $e');
    }

    // Map<String, int>? sumOfCostByCategory = await fetchSumOfCostGroupedByCategory(documentId!);

    // Display the fetched data in a dialog
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text('$title'),
          ),
          content: Column(
            children: sumOfCostByCategory.entries.map((entry) {
              return showDetailsRow(
                '${entry.key}: ',
                '${entry.value} $currency',
              );
            }).toList() ?? [],
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: false,
              child: const Column(
                children: <Widget>[
                  Text('Okay'),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Padding showDetailsRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> fetchActivities(String land_id) async {
    final activityData = <Map<String, dynamic>>[];
    final costSummary = <String, double>{};

    final querySnapshot = await FirebaseFirestore.instance
        .collection(Activity)
        .where('user_id', isEqualTo: user!.email)
        .where('land_id', isEqualTo: land_id)
        .get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final activity_date = data['activity_date'];
      final activity_name = data['activity_name'];
      final cost = data['cost'];
      final category = data['category_'];

      activityData.add({
        'activity_date': activity_date,
        'activity_name': activity_name,
        'category': category,
        'cost': cost,
      });

      // Update the cost summary for the category
      if (category != null) {
        costSummary[category] = (costSummary[category] ?? 0.0) + cost;
      }
    }

    // Return both detailed activity data and cost summary
    return {'activityData': activityData, 'costSummary': costSummary};
  }

  Future<Uint8List> generatePDF(String land_id, List<Map<String, dynamic>> data, mQ, recordData, Map<String, double> costSummary) async {
    final ByteData bytes = await rootBundle.load('assets/logo.jpeg');
    final Uint8List byteList = bytes.buffer.asUint8List();

    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [

                      pw.Container(
                          height: 30,
                          width: mQ.width,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.green900,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                                "${recordData['plot_no']}"
                                ,

                                // "Land Record of Farmer ${landSummery}"
                                // $totalLand - Farmer: Mr, $farmerName",

                                style: pw.TextStyle(
                                    fontSize: 16, color: PdfColors.white)),
                          )),
                      pw.Container(
                        width: 40,
                        height: 40,
                        child: pw.ClipOval(
                          child: pw.Image(pw.MemoryImage(byteList),
                              fit: pw.BoxFit.fitHeight),
                        ),
                      ),
                      // pw.Image(pw.MemoryImage(byteList),
                      //     fit: pw.BoxFit.fitHeight, height: 100, width: 100)
                    ]
                ),
                // pw.Container(height: 10),
                pw.Container(height: 10),
                pw.Container(
                    height: 50,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                    ),
                    child: pw.Center(
                        child: pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                            children: [
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                children: [
                                  pw.Text("Crop Name:",
                                      style: pw.TextStyle(fontSize: 14)),
                                  pw.Text(
                                      "${recordData['seed_name']} / ${recordData['seed_variety']}",
                                      style: pw.TextStyle(fontSize: 14)),
                                ],
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                children: [
                                  pw.Text("Sowing Date:",
                                      style: pw.TextStyle(fontSize: 14)),
                                  pw.Text("${recordData['sowing_date']}",
                                      style: pw.TextStyle(fontSize: 14)),
                                ],
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                children: [
                                  pw.Text("Harvesting Date:",
                                      style: pw.TextStyle(fontSize: 14)),
                                  pw.Text("${recordData['harvesting_date']}",
                                      // pw.Text("$harvestingDate",
                                      style: pw.TextStyle(fontSize: 14)),
                                ],
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                children: [
                                  pw.Text("Total Expenditure",
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                      )),
                                  pw.Text(
                                      "${recordData['total_expenditure']}",
                                      style: pw.TextStyle(fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ))),
                pw.Container(height: 5),
                pw.Container(
                    height: 50,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    child: pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                            children: [
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                children: [
                                  pw.Text("Production",
                                      style: pw.TextStyle(fontSize: 14)),
                                  pw.Text(
                                      "${recordData['productivity']}",
                                      style: pw.TextStyle(fontSize: 14)),
                                ],
                              ),
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                children: [
                                  pw.Text("Total Income",
                                      style: pw.TextStyle(fontSize: 14)),
                                  pw.Text(
                                      "${recordData['sold_in']}",
                                      style: pw.TextStyle(fontSize: 14)),
                                ],
                              ),
                              pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                                  children: [
                                    pw.Text(
                                      // "Summary of Expenditures",
                                        "${
                                            (recordData['total_expenditure'] > recordData['sold_in'])
                                                ?
                                            "You Beard loss of: Rs. ${recordData['total_expenditure'] - recordData['sold_in']}"
                                                : "You Earned Profit of: Rs. ${recordData['sold_in'] - recordData['total_expenditure']}"}",
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            color:
                                            (recordData['total_expenditure'] > recordData['sold_in'])? PdfColors.red: PdfColors.green,
                                            fontWeight: pw.FontWeight.bold))]),

                            ],
                          ),
                        ))),
                pw.Container(height: 5),
              ]),

          pw.Container(height: 10),
          pw.Container(
            height: 10,
            child: pw.Center(
              child: pw.Text(
                "Cost Summary",
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.black,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.Divider(borderStyle: pw.BorderStyle.dashed),
          pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.TableHelper.fromTextArray(
              context: context,
              data: <List<dynamic>>[
                ['Category', 'Total Cost'],
                for (var entry in costSummary.entries)
                  [entry.key, entry.value.toString()],
              ],
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontSize: 14,
              ),
              cellStyle: pw.TextStyle(
                fontSize: 14,
              ),
              cellAlignment: pw.Alignment.center,
              headerAlignment: pw.Alignment.center,
            ),
          ),
          pw.Container(
              height: 10,
              child: pw.Center(
                child: pw.Text("Detail of Expenditures",
                    style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold)),
              )),
          pw.Divider(borderStyle: pw.BorderStyle.dashed),
          pw.Container(
            // width: 400,
              padding: const pw.EdgeInsets.all(1.0),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              child: pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  ['Date', 'Activity', 'Cost'],
                  for (var entry in data)
                    [
                      entry['activity_date'],
                      entry['activity_name'],
                      entry['cost'].toString()
                    ],
                ],
                border: pw.TableBorder.all(),
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerRight,
                },
                columnWidths: {
                  0: const pw.FixedColumnWidth(80), // Date column width
                  1: const pw.FlexColumnWidth(2), // Activity column width
                  2: const pw.FixedColumnWidth(70), // Cost column width
                },
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(5),
                cellStyle: pw.TextStyle(
                  // padding: pw.EdgeInsets.all(10), // Adjust padding as needed
                  color: PdfColors.black,
                  // fromHex('#FF5733'), // Background color
                  // textColor: PdfColors.white, // Text color
                ),
                // cellStyle: pw.TextStyle(
                //   color: PdfColors.black,
                //   background: pw.Paint()..color = PdfColors.grey300, // Background color
                // ),
              )),
        ];
      },
    ));

    return pdf.save();
  }
  void displayPDF(Uint8List pdfBytes) {
    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }


}
