import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/controllers/bank_account_controller.dart';
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
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import '../../main.dart';
import '../accounts/fees/fees_update.dart';
import '../accounts/fees/fees_form.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final String _currentMonth = DateFormat('MMM yyyy').format(DateTime.now());
var mQ;

class ManagerAccountsHomeScreen extends StatefulWidget {
  const ManagerAccountsHomeScreen({Key? key}) : super(key: key);

  @override
  _ManagerAccountsHomeScreenState createState() =>
      _ManagerAccountsHomeScreenState();
}

class _ManagerAccountsHomeScreenState extends State<ManagerAccountsHomeScreen> {
  final collectionReferenceClass =
      FirebaseFirestore.instance.collection(ClassRoom).orderBy('sort_');
  final CollectionReference feesCollection =
      FirebaseFirestore.instance.collection(accounts);
  final BankAccountController bankController = Get.put(BankAccountController());

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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kBlackColor,
          centerTitle: true,
          title: Text('Account Dashboard',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kBlackColor)),
          iconTheme: IconThemeData(color: kBlackColor),
        ),
        body: Container(
          height: mQ.height,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4))
                        ]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, color: kprimary, size: 16),
                        SizedBox(width: 8.0),
                        Text(
                          'Statement for $_currentMonth',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                // DataTable
                FutureBuilder<QuerySnapshot>(
                  future: collectionReferenceClass.get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(color: kprimary));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No class data available.'));
                    }

                    final classDocs = snapshot.data!.docs;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 10,
                                offset: Offset(0, 5))
                          ]),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: DataTable(
                          columnSpacing: 20.0,
                          horizontalMargin: 20,
                          headingRowHeight: 50,
                          dataRowHeight: 60,
                          columns: [
                            DataColumn(
                                label: Text('Class',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kprimary))),
                            DataColumn(
                                label: Text('Not Paid',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kRedColor))),
                            DataColumn(
                                label: Text('Paid',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kInfoColor))),
                            DataColumn(
                                label: Text('Verified',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kGreenColor))),
                          ],
                          rows: classDocs.map((classData) {
                            // Display Name Logic
                            String displayName = classData.id;
                            if (classData.id == 'Kinder Garten - I')
                              displayName = 'KG-I';
                            else if (classData.id == 'Kinder Garten - II')
                              displayName = 'KG-II';
                            else if (classData.id == 'Play Group - I')
                              displayName = 'PG-I';

                            return DataRow(
                              cells: [
                                DataCell(
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 80),
                                    child: Text(
                                      displayName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87),
                                    ),
                                  ),
                                  onTap: () async {
                                    await updateAccountsDashboard(classData.id);
                                    setState(() {});
                                  },
                                ),
                                DataCell(
                                  _buildCellContent(
                                      '${classData['NotPaid_']}',
                                      'Rs. ${classData['amountNotPaid']}',
                                      kRedColor),
                                  onTap: () => _viewClassWiseDetailsdatewise(
                                      classData.id, 'Not Paid'),
                                ),
                                DataCell(
                                  _buildCellContent(
                                      '${classData['Paid_']}',
                                      'Rs. ${classData['amountPaid']}',
                                      kInfoColor),
                                  onTap: () => _viewClassWiseDetailsdatewise(
                                      classData.id, 'Paid'),
                                ),
                                DataCell(
                                  _buildCellContent(
                                      '${classData['Verified_']}',
                                      'Rs. ${classData['amountVerified']}',
                                      kGreenColor),
                                  onTap: () => _viewClassWiseDetailsdatewise(
                                      classData.id, 'Verified'),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16),
                  child: Text(
                    "Tap on stats to view details",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[500]),
                  ),
                ),

                // Action Buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _buildActionButton(
                                  icon: Icons.add,
                                  label: 'Add Fees',
                                  color: Colors.indigo,
                                  onTap: () => Get.to(FeesEntryForm(
                                      babyId: 'No Baby Selected')))),
                          SizedBox(width: 12),
                          Expanded(
                              child: _buildActionButton(
                                  icon: Icons.update,
                                  label: 'Update',
                                  color: Colors.cyan,
                                  onTap: () => Get.to(FeesDataUpdateScreen(
                                        babyId: 'No Baby Selected',
                                      )))),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _buildActionButton(
                                  icon: Icons.receipt,
                                  label: 'Fees Slip',
                                  color: Colors.green,
                                  onTap: () {
                                    isLoading.value = true;
                                    Get.to(SelectChildForGenerateSlip(
                                        babyId: 'No Baby Selected'));
                                  })),
                          SizedBox(width: 12),
                          Expanded(
                              child: _buildActionButton(
                                  icon: Icons.verified,
                                  label: 'Verify',
                                  color: Colors.blue,
                                  onTap: () => Get.to(ViewReports(
                                        selectedIndex: 1,
                                      )))),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _buildActionButton(
                                  icon: Icons.price_check,
                                  label: 'Rates',
                                  color: Colors.purple,
                                  onTap: () => Get.to(ManagerRates()))),
                          SizedBox(width: 12),
                          Expanded(
                              child: _buildActionButton(
                                  icon: Icons.report,
                                  label: 'Reports',
                                  color: Colors.teal,
                                  onTap: () => Get.to(ViewReports(
                                        selectedIndex: 0,
                                      )))),
                        ],
                      ),
                      if (role_ == 'Director') ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: _buildActionButton(
                                    icon: Icons.account_balance,
                                    label: 'Bank Account',
                                    color: Colors.brown,
                                    onTap: () =>
                                        _showBankDetailsDialog(context))),
                            SizedBox(width: 12),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ));
  }

  Widget _buildCellContent(String count, String amount, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(count,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        Text(amount, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4))
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14))
          ],
        ),
      ),
    );
  }

  void _showBankDetailsDialog(BuildContext context) {
    final nameController =
        TextEditingController(text: bankController.bankName.value);
    final accountController =
        TextEditingController(text: bankController.accountNumber.value);
    final ibanController =
        TextEditingController(text: bankController.iban.value);
    final creditController =
        TextEditingController(text: bankController.creditTo.value);
    
    // Local state for image picking
    Rx<XFile?> pickedImage = Rx<XFile?>(null);
    RxBool isUpdating = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, offset: Offset(0, 10), blurRadius: 10),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                          pickedImage.value = image;
                      }
                  },
                  child: Obx(() {
                       if (pickedImage.value != null) {
                           return Container(
                               height: 80,
                               width: 80,
                               decoration: BoxDecoration(
                                   shape: BoxShape.circle,
                                   image: DecorationImage(
                                       image: FileImage(File(pickedImage.value!.path)),
                                       fit: BoxFit.cover
                                   )
                               ),
                           );
                       } else if (bankController.bankImage.value.isNotEmpty) {
                           return Container(
                               height: 80,
                               width: 80,
                               decoration: BoxDecoration(
                                   shape: BoxShape.circle,
                                   image: DecorationImage(
                                       image: NetworkImage(bankController.bankImage.value),
                                       fit: BoxFit.cover
                                   )
                               ),
                           );
                       } else {
                           return Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: kprimary.withOpacity(0.1)),
                              child: Icon(Icons.add_a_photo, size: 40, color: kprimary),
                            );
                       }
                  }),
                ),
                SizedBox(height: 15),
                Text("Update Bank Details",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                SizedBox(height: 20),
                _buildTextField(nameController, 'Bank Name', Icons.business),
                SizedBox(height: 12),
                _buildTextField(
                    creditController, 'Beneficiary Name', Icons.person),
                SizedBox(height: 12),
                _buildTextField(
                    accountController, 'Account Number', Icons.numbers),
                SizedBox(height: 12),
                _buildTextField(ibanController, 'IBAN', Icons.qr_code),
                SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text("Cancel",
                            style: TextStyle(color: Colors.grey[600])),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kprimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                        ),
                        onPressed: isUpdating.value ? null : () async {
                          isUpdating.value = true;
                          String? imageUrl;
                          try {
                              if (pickedImage.value != null) {
                                  // Upload image
                                 try {
                                      imageUrl = await bankController.uploadBankImage(pickedImage.value);
                                 } catch(e) {
                                      isUpdating.value = false;
                                      Get.snackbar("Error", "Failed to upload image",
                                          backgroundColor: Colors.red[50],
                                          colorText: Colors.red[900]);
                                      return;
                                 }
                              }
                            
                              await bankController.updateDetails(
                                nameController.text,
                                accountController.text,
                                ibanController.text,
                                creditController.text,
                                newBankImage: imageUrl
                              );
                              Get.back();
                          } finally {
                              isUpdating.value = false;
                          }
                          
                        },
                        child: isUpdating.value 
                            ? SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : Text("Update",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        prefixIcon: Icon(icon, color: kprimary, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kprimary.withOpacity(0.5))),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(accounts)
        .where('status', isEqualTo: 'Not Paid')
        .where('month', isEqualTo: _currentMonth)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> _generatePdf() async {
    List<Map<String, dynamic>> data = await _fetchData();
    List<String> columns = [
      "Name",
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
      "Misc"
    ];

    // Calculate the totals for each column
    Map<String, int> totals = {for (var column in columns.skip(1)) column: 0};

    for (var doc in data) {
      for (String column in columns.skip(1)) {
        totals[column] = (totals[column] ?? 0) +
            (doc['fees']?.firstWhere(
                  (fee) => fee['name'] == column,
                  orElse: () => {'amount': 0},
                )['amount'] ??
                0) as int;
      }
    }

    // Append the totals row to the data
    Map<String, dynamic> totalsRow = {"Name": "Total", ...totals};
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
                  fit: pw.BoxFit
                      .fitWidth, // Adjust fit as needed (cover, contain, etc.)
                ),
              ),
              pw.Text(
                  '${table_ == 'tsn_' ? 'The Second Nest' : 'Kidz Republik'} Pre School & Day Care Center',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
              // Payee Information
              pw.Text('Detail of Fees for the month of $_currentMonth',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.Divider(),

              pw.TableHelper.fromTextArray(
                headers: columns,
                data: data.map((doc) {
                  Map<String, dynamic> row = {
                    "Name": doc['childFullName'] ?? doc['Name'],
                  };
                  for (String column in columns.skip(1)) {
                    row[column] = doc[column]?.toString() ??
                        (doc['fees']?.firstWhere(
                                  (fee) => fee['name'] == column,
                                  orElse: () => {'amount': 0},
                                )['amount'] ??
                                0)
                            .toString();
                  }
                  return columns.map((column) {
                    String value = row[column].toString();
                    // Wrap data in container with specific width
                    return pw.Container(
                        width: column == "Name"
                            ? 150
                            : 50, // Set width based on column name
                        child: pw.Text(value,
                            style: pw.TextStyle(fontSize: 10),
                            textAlign: column == "Name"
                                ? pw.TextAlign.left
                                : pw.TextAlign
                                    .center)); // Existing data and style
                  }).toList();
                  // return columns.map((column) => row[column].toString()).toList();
                }).toList(),
                headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight:
                        pw.FontWeight.bold), // Reduced font size for headers
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

  Future<List<Map<String, dynamic>>> _fetchClassWiseDatadatewise(
      className, status_) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(accounts)
        .where('status', isEqualTo: status_)
        .where('studentClass', isEqualTo: className)
        .where('month', isEqualTo: _currentMonth)
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> _viewClassWiseDetailsdatewise(className, status_) async {
    List<Map<String, dynamic>> data =
        await _fetchClassWiseDatadatewise(className, status_);

    List<String> columns = [
      "Name",
      status_ == 'Not Paid'
          ? "Due Date"
          : "Payment Date", // Conditional column header

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
    Map<String, int> totals = {for (var column in columns.skip(2)) column: 0};

    var totalAmountPayable;

    for (var doc in data) {
      for (String column in columns.skip(2)) {
        totals[column] = (totals[column] ?? 0) +
            (doc['fees']?.firstWhere(
                  (fee) => fee['name'] == column,
                  orElse: () => {'amount': 0},
                )['amount'] ??
                0) as int;
      }
      totalAmountPayable = (totalAmountPayable ?? 0) + doc['amountPayable'] ??
          0; // Calculate total amountPayable
    }

    // Append the totals row to the data
    Map<String, dynamic> totalsRow = {
      "Name": "Total",
      ...totals,
      "amountPayable":
          totalAmountPayable, // Add total amountPayable to totalsRow
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
                  fit: pw.BoxFit
                      .fitWidth, // Adjust fit as needed (cover, contain, etc.)
                ),
              ),
              pw.Text(
                  '${table_ == 'tsn_' ? 'The Second Nest' : 'Kidz Republik'} Pre School & Day Care Center',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
              // Payee Information
              pw.Row(children: [
                pw.Text(
                    'Detail of Fees $status_ for the month of $_currentMonth - ($className)',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Spacer(),
                pw.Text(
                  "Report Generated by App on ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}",
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  textAlign: pw.TextAlign.right,
                )
              ]),
              pw.Divider(),
              // The user didn't ask to put bank details in this specific PDF report (it's "Detail of Fees").
              // But I should check if I missed any bank details usage in this file.
              // The grep showed no usage of bankName in this file except declaration.
              // Wait, I grepped and it said:
              // {"File":".../manager_accounts_home.dart","LineNumber":23,"LineContent":"String bankName ="}
              // It seems bankName is defined but NOT used in this file?
              // I will double check the view_file of lines 380-600.
              // I don't see bankName used in _generatePdf or _viewClassWiseDetailsdatewise.
              // So I don't need to change the PDF generation logic in THIS file if it doesn't use it.
              // But I MUST remove the global variables from the top of the file as per my plan.

              pw.TableHelper.fromTextArray(
                headers: [
                  "Name",
                  status_ == 'Not Paid'
                      ? "Due Date"
                      : "Payment Date", // Conditional column header

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
                    if (status_ == 'Not Paid')
                      "Due Date": doc['lastDate']?.toString() ?? ''
                    else
                      "Payment Date": doc['dateOfPayment']?.toString() ??
                          '', // Added for "Last Date"
                  };
                  for (String column in columns.skip(2)) {
                    // Skip first two ("Name" and "Last Date")
                    row[column] = doc[column]?.toString() ??
                        (doc['fees']?.firstWhere(
                                  (fee) => fee['name'] == column,
                                  orElse: () => {'amount': 0},
                                )['amount'] ??
                                0)
                            .toString();
                  }
                  return columns.map((column) {
                    String value = row[column].toString();
                    return pw.Container(
                        width: column == "Name"
                            ? 130
                            : column == "amountPayable"
                                ? 70
                                : (column == "Due Date" ||
                                        column == "Payment Date"
                                    ? 87
                                    : 50), // Set width based on column name
                        child: pw.Text(value,
                            style: pw.TextStyle(fontSize: 10),
                            textAlign: column == "Name"
                                ? pw.TextAlign.left
                                : pw.TextAlign
                                    .center)); // Existing data and style
                  }).toList();
                  // return columns.map((column) => row[column].toString()).toList();
                }).toList(),
                headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight:
                        pw.FontWeight.bold), // Reduced font size for headers
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
  final classRef =
      FirebaseFirestore.instance.collection(ClassRoom).doc(classId);

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
