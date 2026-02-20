import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/accounts/pay_online.dart';
import 'package:kids_republik/screens/accounts/payment_proof.dart';
import 'package:kids_republik/screens/accounts/verify_proof.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:snackbar/snackbar.dart';
import 'package:toast/toast.dart';
import 'package:kids_republik/controllers/bank_account_controller.dart'; // Added import

import 'manager_accounts_home.dart';

class DocumentListVerify extends StatefulWidget {
  String paystatus; // Add status parameter to constructor

  DocumentListVerify({required this.paystatus});

  @override
  _DocumentListVerifyState createState() => _DocumentListVerifyState();
}
// String _selectedCategory =  role_ ==  'Manager'?'Paid':'Not Paid';

class _DocumentListVerifyState extends State<DocumentListVerify> {
String? voucherid;
List<DocumentSnapshot> _documents = [];
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDocuments(widget.paystatus);
  }

  Future<void> _fetchDocuments(condition2) async {
    setState(() {
      _isLoading = true; // Set loading to true before fetching data
    });
    try {
      final querySnapshot = role_ == 'Parent'
          ? await _firestore
              .collection(accounts)
              .where('status', isEqualTo: condition2!)
              .where('fathersEmail', isEqualTo: useremail )
              // .where('fathersEmail', isEqualTo: user!.email)
              .get()
          : await _firestore
              .collection(accounts)
              .where('status', isEqualTo: condition2!)
              .get();
      _documents = querySnapshot.docs;
      setState(() {});
    } catch (e) {
      // Handle errors gracefully, e.g., show a snackbar
      print(e);
    } finally {
      setState(() {
        _isLoading = false; // Set loading to true before fetching data
      });
    }
  }

  void _handleDocumentClick(String documentId) async {
    // Consider security: validate document ID or use server-side PDF generation
    Get.to(PrepareBankCopyFromFirebasePDF(documentId: documentId));
    // await GeneratePDF(documentId); // Replace with your PDF generation logic
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton:
         (role_ != 'Parent' && widget.paystatus == 'Not Paid') ?
      ElevatedButton.icon(
        onPressed: () async {
          await sendReminders(context);
        },
        icon: Icon(Icons.notifications_on_outlined),
        label: Text('Fees Reminder'),
      ):Container()
      ,
      body: Column(
        children: [
          _isLoading // Check loading state
              ? Container(
                  height: mq.height * 0.6,
                  child: Center(
                      child: CircularProgressIndicator())) // Show progress bar
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (_documents.length < 1)
                      ? Center(
                          child: Text('Payment record will be displayed here'),
                        )
                      : Container(
                          height: mq.height * 0.70,
                          width: mq.width * 0.98,
                          color:
                      Colors.blue[50],
                          child: ListView.builder(
                              itemCount: _documents.length,
                              itemBuilder: (context, index) {
                                final document = _documents[index];
                                final documentName = document.id;
                                return Dismissible( // Enable swipe to dismiss for delete
                                  key: Key(document.id),
                                confirmDismiss: (direction) => confirm(context, content: Text('Are you sure you want to delete this Fees Slip?')),
                                onDismissed: (direction) => role_ != 'Parent'? deleteSlip(document.id):null,
                                  child: ListTile(
                                    title: Column(
                                      children: [
                                        Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                document[
                                                                    'childFullName'],
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .blue[900],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Text(
                                                                "Rs.${document['amountPayable'].toString()}", // Replace with fetched price data if applicable
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "${document['month']}", // Replace with fetched price data if applicable
                                                                style: TextStyle(
                                                                  color: widget
                                                                              .paystatus ==
                                                                          "Not Paid"
                                                                      ? Colors
                                                                          .brown
                                                                      : widget.paystatus ==
                                                                              "Paid"
                                                                          ? Colors.blue[
                                                                              900]
                                                                          : widget.paystatus ==
                                                                                  "Verified"
                                                                              ? Colors.green[900]
                                                                              : Colors.grey,
                                                                  // Colors.deepOrange,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Text(
                                                                "Slip#:$documentName", // Replace with fetched price data if applicable
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors.grey,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Status :",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors.black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                              SizedBox(width: 10,),
                                                              Text(
                                                                "${document['status'] == "Not Paid" ? "Due" : document['status']}",
                                                                // "Status",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors.grey,
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Text(
                                                                "${document['status'] == 'Not Paid' ? ' Due Date ' : ' Paid on '}:",
                                                                // "100 GBs",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                              SizedBox(width: 10,),
                                                              // Spacer(),
                                                              Text(
                                                                "${document['status'] == 'Not Paid' ? document['lastDate'] : document['dateOfPayment']}",
                                                                // "${document['status'] == 'Not Paid' ? ' Due Date ' : ' Paid on '}",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors.grey,
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          _handleDocumentClick(
                                                              document.id),
                                                      child: Text(
                                                        'Proceed',
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.white,
                                                        backgroundColor:
                                                            Colors.blue,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                                horizontal: 10.0,
                                                                vertical: 2.0),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })),
                )
        ],
      ),
    );
  }
void deleteSlip(String documentId) async {
  await confirm(context, content: Text('Are you sure you want to delete this Slip?'))?
  await _firestore.collection(accounts).doc(documentId).delete():null;
}

  Future<List<DocumentSnapshot>> getStudentsForReminder() async {
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(accounts)
        .where('status', isEqualTo: 'Not Paid')
        .get();

    List<DocumentSnapshot> validDocuments = [];
    // DateTime now = DateTime.now();
    DateTime now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (var doc in querySnapshot.docs) {
      String lastDateStr = doc['lastDate'];
      DateTime lastDate = DateFormat('dd-MMM-yyyy').parse(lastDateStr);
      if (lastDate.isBefore(now)) {validDocuments.add(doc);}
    }
    setState(() {
      _documents = validDocuments;
    });
    return validDocuments;
  }

  Future<void> sendReminders(BuildContext context) async {
    List<DocumentSnapshot> students = await getStudentsForReminder();
    CollectionReference consentCollection = FirebaseFirestore.instance.collection(Activity);
    await confirm(context,title: Text('Send Fees Reminder',style: TextStyle(fontSize: 14),),content:
    Text('Are you sure you want to send fee/slip submission reminders to all parents whose payments/uploads are overdue? This action will send a reminder to parents.',style: TextStyle(fontSize: 12)),textOK: Text('Send'),textCancel: Text('Not Now'))?

    () async {
      for (var student in students) {
        String studentId = student['child_'];
        voucherid = student.id;
        String fathersEmail = student['fathersEmail'];

        await consentCollection.add({
          'child_': studentId,
          'parentid_': fathersEmail,
          'title_': 'Fees Reminder',
          'description_': "Dear Parents, \n \n This is a friendly reminder that the due date for fee submission/slip upload has passed. We kindly request you to submit the outstanding amount/upload the missing slip as soon as possible. Your cooperation is greatly appreciated. \n \n If you have any questions or need assistance, please contact Manager at KidzRepublik Islamabad.\n \n Thank you for your prompt attention to this matter.",
          'date_': DateFormat('dd-MM-yyyy').format(DateTime.now()),
          'result_': 'Waiting',
          'category_': 'Reminder'
        });
      }
    ToastContext().init(context);
    Toast.show(
      'Fees Reminders sent to Parents successfully',
      backgroundRadius: 5,
    );
    }: null;

  }

}

String formatTimestamp(timestamp) {
  // Timestamp = document.get('paymentDate');
  final formatter = DateFormat('dd-MM-yyyy');
  String formattedDate = formatter.format(timestamp.toDate());
  return formattedDate;
}
// Replace with your actual PDF generation logic

class PrepareBankCopyFromFirebasePDF extends StatefulWidget {
  final String documentId; // Pass the document ID to fetch data

  const PrepareBankCopyFromFirebasePDF({Key? key, required this.documentId})
      : super(key: key);

  @override
  _PrepareBankCopyFromFirebasePDFState createState() =>
      _PrepareBankCopyFromFirebasePDFState();
}

class _PrepareBankCopyFromFirebasePDFState
    extends State<PrepareBankCopyFromFirebasePDF> {
  final BankAccountController bankController = Get.find<BankAccountController>();
  final CollectionReference feesCollection =
      FirebaseFirestore.instance.collection(accounts);
  String slipNumber = '';
  List<dynamic> _feesData = [];
  int decreaseindex = 0;
  bool isChecked = false; // Flag to track checkbox state
  var amountPayable;
  String? dated; // Convert Timestamp to DateTime
  String fullName = '';
  String? studentClass;
  String registrationNumber = '';
  String month = '';
  String status = '';
  String? issueDate;
  String? lastDate;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data on widget initialization

  }
// ... (lines 393-616 skipped in replacement for brevity, but I need to target the build method specifically or the whole class if I want to be safe. 
// The file is large. I will target chunks.
// First chunk: State class start and fields.


  Future<void> _fetchData() async {
    try {
      final doc = await feesCollection.doc(widget.documentId).get();
      // final fees = doc.data()?['fees'];
      slipNumber = doc.id;
      fullName = doc.get('childFullName');
      studentClass = doc.get('studentClass');
      registrationNumber = doc.get('registrationNumber');
      month = doc.get('month');
      status = doc.get('status');

      dated = doc.get('dated');
      issueDate = doc.get('issueDate');
      lastDate = doc.get('lastDate');

      final feess = doc.get('fees') as List<dynamic>;
      _feesData = feess.map((fee) {
        return {
          'serialNumber': _incrementSerialNumber(),
          'name': fee['name'],
          'amount': fee['amount'],
        };
      }).toList();
      amountPayable = doc.get('amountPayable');

      setState(() {
        _feesData = feess;
      });
    } catch (error) {
      snack("Error fetching data: $error");
      // Handle errors appropriately (e.g., show a snackbar)
    }
  }

  int _serialNumber = 0; // Variable to track serial number

  int _incrementSerialNumber() {
    _serialNumber++;
    return _serialNumber;
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.blue[50],
        floatingActionButton: Container(
          height: mQ.height*0.25,
          width: mQ.width*0.55,
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.symmetric(horizontal: mQ.width*0.01),
          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Spacer(), // Remove unused Spacer
                status == 'Not Paid'?
                    Column(crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
             role_ == 'Parent'? ElevatedButton.icon(
                  onPressed: () async {Get.to(AddCashBankTransfer());},
                  icon: Icon(
                    Icons.payment,
                    size: 14,
                  ),
                  label: Text(
                    'Pay Online',
                    style: TextStyle(fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[50], // Customize button color
                  ),
                ):Container(),
                          ElevatedButton.icon(
                  onPressed: () => _generatePdf(),
                  icon: Icon(
                    Icons.print,
                    size: 14,
                  ),
                  label: Text(
                    'Save/ Print',
                    style: TextStyle(fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50], // Customize button color
                  ),
                ),
                          ElevatedButton.icon(
                        onPressed: () => Get.to(
                                () => MyUploadPaymentProof(documentId: slipNumber)),
                        icon: Icon(
                          Icons.upload_file,
                          size: 14,
                        ),
                        label: Text(
                          'Upload Slip',
                          style: TextStyle(fontSize: 10),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[50], // Customize button color
                        ),
                      ),
                          ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            icon: Icon(
                              Icons.close,
                              size: 14,
                            ),
                            label: Text(
                              'Close',
                              style: TextStyle(fontSize: 10),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.blue[50], // Customize button color
                            ),
                          )

                ]):
                // SizedBox(width: 10), // Add another gap between buttons
                status == 'Paid' && (role_ == 'Manager'||role_ == 'Director')?
                ElevatedButton.icon(
    onPressed: () =>
     Get.to(() =>
    ManagerVerifyProof(documentId: slipNumber))
    //     :
    // ScaffoldMessenger.of(context).showSnackBar(
    // SnackBar(
    // backgroundColor: Colors.blue[50],
    // content: Wrap(children: [
    // Icon(Icons.error_outline_sharp),
    // SizedBox(
    // width: 12,
    // ),
    // Text(
    // 'Payment slip not uploaded, Unable to verify',
    // style: TextStyle(color: Colors.black),
    // )
    // ]),
    // ),
    // ),
    ,icon: Icon(
    Icons.verified_user_outlined,
    size: 14,
    ),
    label: Text(
    'Verify',
    style: TextStyle(fontSize: 10),
    ),
    style: ElevatedButton.styleFrom(
    backgroundColor:
    Colors.orange[50], // Customize button color
    ),
    ):
                status == 'Verified' ?
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close,
                    size: 14,
                  ),
                  label: Text(
                    'Close',
                    style: TextStyle(fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.blue[50], // Customize button color
                  ),
                )
                    :
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close,
                    size: 14,
                  ),
                  label: Text(
                    'Close',
                    style: TextStyle(fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.blue[50], // Customize button color
                  ),
                )
              ],
            )
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 25.0, bottom: 10, left: 5, right: 5),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: Colors.black, width: 1.5), // Add border here
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Text(
                  'Fees Voucher',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Image on the left
                    Container(
                      width: 50,
                      child: Image(
                        image: AssetImage('assets/${table_}bank_icon.png'),
                        fit: BoxFit
                            .cover, // Adjust fit as needed (cover, contain, etc.)
                      ),
                    ),
                    // Text in the center
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            bankController.bankName.value,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text("Any Branch within Pakistan"),
                        ],
                      ),
                    ),
                    // Image on the right
                    Container(
                      width: 050,
                      child: Image(
                        image: AssetImage('assets/${table_}app_icon.png'),
                        fit: BoxFit
                            .cover, // Adjust fit as needed (cover, contain, etc.)
                      ),
                    ),
                  ],
                ),

                // Payee Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'AC No: ${bankController.accountNumber.value}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                // Slip Information
                Row(
                  children: [
                    Text("NO:                   $slipNumber"),
                  ],
                ),
                Row(
                  children: [
                    Text("Credit:              ${bankController.creditTo.value}"),
                  ],
                ),
                Row(
                  children: [
                    Text("Dated:              ${dated}"),
                  ],
                ),
                Row(
                  children: [
                    Text("Full Name:       $fullName"),
                  ],
                ),
                // Student Information
                Row(
                  children: [
                    Text("Class:              $studentClass"),
                    Spacer(),
                    Text("Reg #:     $registrationNumber"),
                    Spacer(),
                  ],
                ),
                Row(
                  children: [
                    Text("Month:            $month"),
                  ],
                ),
                // Fee Breakdown
                Row(
                  children: [
                    Text("Sr#",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(width: 20),
                    Text("Type of Fee",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    Spacer(),
                    Text("Amount",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                // Fees breakdown
                if (_feesData.isNotEmpty)
                  ListView.builder(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    shrinkWrap:
                        true, // Prevent the list from expanding unnecessarily
                    itemCount: _feesData.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      final fee = _feesData[index];
                      return Column(
                        children: [
                          (fee['name'] == 'childFullName' ||
                                  fee['name'] == 'fathersEmail')
                              ? Container()
                              : Row(
                                  children: [
                                    Text(
                                        "${index + 1}.        ${fee['name']}"), // Display fee type
                                    Spacer(),
                                    Text('${fee['amount']}.00'.toString()),
                                  ],
                                ),
                          const Divider(
                              height: 1,
                              color: Colors
                                  .grey), // Add divider after each ListTile
                        ],
                      );
                    },
                  ),
                // Totals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Amount Payable:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    Text(amountPayable!.toStringAsFixed(2)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "1. Tuition Fee is payable in advance and once paid is Non- Refundable",
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                        "2. Tuition Fee must be paid before the last date of payment stated on the Fee Bill. A fine of Rs. 100/- per day will be charged after lapse of last date of payment.",
                        style: TextStyle(fontSize: 10)),
                    Text(
                        "3. If a student fails to pay tuition fee within 5 days after the last date of payment. He/ She will not be permitted to sit in the class.",
                        style: TextStyle(fontSize: 10)),
                    Text(
                        "4. Tuition Fee for the month(s) of June August Quarter must be paid before the beginning of Summer Vacation",
                        style: TextStyle(fontSize: 10)),
                    Text(
                        "5. If a student is to be withdrawn, A notice of one month must be given in writing or one month's fee is payment on lieu of the notice",
                        style: TextStyle(fontSize: 10)),
                    Text(
                        "6. If a student fails to give fee bill to his/her parents. It is the responsibility of the parents to bring it to the notice of the school account officer Rs. 100/- will be charged if a fee bill is reported lost and duplicate copy asked for.",
                        style: TextStyle(fontSize: 10)),
                  ],
                ),
                SizedBox(height: 10),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Issue Date: ${issueDate}",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    Text("Last Date: ${lastDate}",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    Text(
                      "Accounts Office",
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
        ));
  }

  pw.Widget _buildContent(title, imagebank, imagekrdc) {
    return pw.Container(
      width: 250, // Use pw.Container for PDF-specific containers
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
            color: PdfColors.black, width: 1.5), // Add border here
      ),
      child: pw.Column(
        // Use pw.Column for PDF layout
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Header
          pw.Text(title,
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Image on the left

              pw.Container(
                width: 25,
                height: 25,
                child: pw.Image(
                  imagebank,
                  fit: pw.BoxFit
                      .fitWidth, // Adjust fit as needed (cover, contain, etc.)
                ),
              ),
              // Text in the center
              pw.Expanded(
                child: pw.Column(
                  // Use pw.Column again for inner layout
                  children: [
                    pw.Text(bankController.bankName.value,
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Any Branch within Pakistan",
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.normal)),
                  ],
                ),
              ),
              pw.Container(
                width: 25,
                height: 25,
                child: pw.Image(
                  imagekrdc,
                  fit: pw.BoxFit
                      .fitWidth, // Adjust fit as needed (cover, contain, etc.)
                ),
              ),
            ],
          ),
          // pw.Text(schoolName,
          //     style:
          //         pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          // Payee Information
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('AC No: ${bankController.accountNumber.value}',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 12)),
            ],
          ),
          // Slip Information
          pw.Row(
            children: [
              pw.Text("NO:                   $slipNumber",
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text("Credit:              ${bankController.creditTo.value}",
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text("Dated:              ${dated}",
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text("Full Name:       $fullName",
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),
          // Student Information
          pw.Row(
            children: [
              pw.Text("Class:              $studentClass",
                  style: pw.TextStyle(fontSize: 10)),
              pw.Spacer(),
              pw.Text("Reg #:     $registrationNumber",
                  style: pw.TextStyle(fontSize: 10)),
              pw.Spacer(),
            ],
          ),
          pw.Row(
            children: [
              pw.Text("Month:            $month"),
            ],
          ),
          // Fee Breakdown
          pw.Row(
            children: [
              pw.Text("Sr#",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.SizedBox(width: 20),
              pw.Text("Type of Fee",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Spacer(),
              pw.Text("Amount",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ],
          ),
          pw.ListView.builder(
            itemCount: _feesData.length,
            itemBuilder: (context, index) {
              final fee = _feesData[index];
              return pw.Column(
                children: [
                  pw.Row(
                    children: [
                      pw.Text('${index + 1}.      ${fee['name']}',
                          style: pw.TextStyle(fontSize: 10)),
                      pw.Spacer(),
                      pw.Text('${fee['amount']}.00'),
                    ],
                  ),
                  pw.Divider(height: 1, color: PdfColors.grey),
                ],
              );
            },
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Amount Payable:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(amountPayable.toStringAsFixed(2)),
            ],
          ),
          pw.Text(
            "1. Tuition Fee is payable in advance and once paid is Non-Refundable",
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            "2. Tuition Fee must be paid before the last date of payment stated on the Fee Bill. A fine of Rs. 100/- per day will be charged after lapse of last date of payment.",
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            "3. If a student fails to pay tuition fee within 5 days after the last date of payment. He/She will not be permitted to sit in the class.",
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            "4. Tuition Fee for the month(s) of June August Quarter must be paid before the beginning of Summer Vacation",
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            "5. If a student is to be withdrawn, A notice of one month must be given in writing or one month's fee is payment on lieu of the notice",
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            "6. If a student fails to give fee bill to his/her parents. It is the responsibility of the parents to bring it to the notice of the school account officer Rs. 100/- will be charged if a fee bill is reported lost and duplicate copy asked for.",
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          // Footer
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Issue Date: ${issueDate}",
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text("Last Date: ${lastDate}",
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Row(
            children: [
              pw.Spacer(),
              pw.Text("Accounts Office",
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  String formatDate(date) {
    return DateFormat('dd-MMM-yyyy').format(date); // Example formatting
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final imageData = await rootBundle.load('assets/${table_}bank_icon.png');
    final imageDatakrdc = await rootBundle.load('assets/${table_}app_icon.png');

    final imageBytes = imageData.buffer.asUint8List();
    final imageByteskrdc = imageDatakrdc.buffer.asUint8List();

    final imagebank = pw.MemoryImage(imageBytes);
    final imagekrdc = pw.MemoryImage(imageByteskrdc);

    pdf.addPage(
      pw.Page(
        orientation: pw.PageOrientation.landscape,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
              child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              _buildContent('Bank Copy', imagebank, imagekrdc),
              pw.SizedBox(width: 5),
              _buildContent('School Copy', imagebank, imagekrdc),
              pw.SizedBox(width: 5),
              _buildContent('Parents Copy', imagebank, imagekrdc),
            ],
          ));
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

}
