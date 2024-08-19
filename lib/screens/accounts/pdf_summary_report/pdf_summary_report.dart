import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:kids_republik/main.dart';


class GeneratePdfSummary extends StatefulWidget {
  // CallbackAction showpdf;
  // GeneratePdfSummary({required this.showpdf});
  @override
  _GeneratePdfSummaryState createState() => _GeneratePdfSummaryState();
}
class _GeneratePdfSummaryState extends State<GeneratePdfSummary> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentMonth = DateFormat('MMM yyyy').format(DateTime.now());

  @override
  void initState()
{
  super.initState();
  _generatePdf();
}

  Future<List<Map<String, dynamic>>> _fetchData() async {
    QuerySnapshot querySnapshot = await _firestore.collection(accounts)
        // .where('status', isEqualTo: 'Not Paid')
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
        )['amount'] ?? 0) as int;
      }
    }

    // Append the totals row to the data
    Map<String, dynamic> totalsRow = {
      "Name": "Total",
      ...totals
    };
    data.add(totalsRow);
    final imageDatakrdc = await rootBundle.load('assets/app_icon.png');
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


              pw.Table.fromTextArray(
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate PDF'),
      ),
      body: Center(
        child: CircularProgressIndicator()
        // ElevatedButton(
        //   onPressed: _generatePdf,
        //   child: Text('Generate PDF'),
        // ),
      ),
    );
  }
}
