import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;
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

import '../../utils/const.dart';
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
              .where('fathersEmail', isEqualTo: useremail)
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
      backgroundColor: grey100,
      floatingActionButton: (role_ != 'Parent' &&
              widget.paystatus == 'Not Paid')
          ? FloatingActionButton.extended(
              onPressed: () async => await sendReminders(context),
              backgroundColor: kprimary,
              icon: const Icon(Icons.notifications_active_outlined,
                  color: kWhite),
              label:
                  const Text('Send Reminders', style: TextStyle(color: kWhite)),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final document = _documents[index];
                    final documentId = document.id;
                    return _buildPaymentCard(document, documentId);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: grey100),
          const SizedBox(height: 16),
          Text(
            'No payment records found',
            style: k14500.copyWith(color: kGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(DocumentSnapshot document, String documentId) {
    final String status = document['status'];
    final String childName = document['childFullName'];
    final String amount = document['amountPayable'].toString();
    final String month = document['month'];
    final String date =
        status == 'Not Paid' ? document['lastDate'] : document['dateOfPayment'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key(documentId),
          direction: role_ == 'Parent'
              ? DismissDirection.none
              : DismissDirection.endToStart,
          confirmDismiss: (direction) => confirm(context,
              title: const Text('Delete Slip'),
              content: const Text(
                  'Are you sure you want to delete this fees slip?')),
          onDismissed: (direction) => deleteSlip(documentId),
          background: Container(
            color: kRedColor,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: kWhite, size: 28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        childName,
                        style: k16bold.copyWith(color: kBlackColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Month', style: k10500.copyWith(color: kGrey)),
                        Text(month, style: k12500.copyWith(color: kBlackColor)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Amount', style: k10500.copyWith(color: kGrey)),
                        Text('Rs. $amount',
                            style: k14bold.copyWith(color: kprimary)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status == 'Not Paid' ? 'Due Date' : 'Paid Date',
                            style: k10500.copyWith(color: kGrey)),
                        Text(date, style: k12500.copyWith(color: kBlackColor)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _handleDocumentClick(documentId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kprimary.withOpacity(0.1),
                        foregroundColor: kprimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('Proceed',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Slip #: $documentId',
                    style: k10500.copyWith(color: kGrey.withOpacity(0.6))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label = status == 'Not Paid' ? 'DUE' : status.toUpperCase();

    switch (status) {
      case 'Paid':
        color = Colors.blue;
        break;
      case 'Verified':
        color = kSuccessColor;
        break;
      default:
        color = kRedColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void deleteSlip(String documentId) async {
    await confirm(context,
            content: Text('Are you sure you want to delete this Slip?'))
        ? await _firestore.collection(accounts).doc(documentId).delete()
        : null;
  }

  Future<List<DocumentSnapshot>> getStudentsForReminder() async {
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance
        .collection(accounts)
        .where('status', isEqualTo: 'Not Paid')
        .get();

    List<DocumentSnapshot> validDocuments = [];
    // DateTime now = DateTime.now();
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (var doc in querySnapshot.docs) {
      String lastDateStr = doc['lastDate'];
      DateTime lastDate = DateFormat('dd-MMM-yyyy').parse(lastDateStr);
      if (lastDate.isBefore(now)) {
        validDocuments.add(doc);
      }
    }
    setState(() {
      _documents = validDocuments;
    });
    return validDocuments;
  }

  Future<void> sendReminders(BuildContext context) async {
    List<DocumentSnapshot> students = await getStudentsForReminder();
    CollectionReference consentCollection =
        FirebaseFirestore.instance.collection(Activity);
    await confirm(context,
            title: Text(
              'Send Fees Reminder',
              style: TextStyle(fontSize: 14),
            ),
            content: Text(
                'Are you sure you want to send fee/slip submission reminders to all parents whose payments/uploads are overdue? This action will send a reminder to parents.',
                style: TextStyle(fontSize: 12)),
            textOK: Text('Send'),
            textCancel: Text('Not Now'))
        ? () async {
            for (var student in students) {
              String studentId = student['child_'];
              voucherid = student.id;
              String fathersEmail = student['fathersEmail'];

              await consentCollection.add({
                'child_': studentId,
                'parentid_': fathersEmail,
                'title_': 'Fees Reminder',
                'description_':
                    "Dear Parents, \n \n This is a friendly reminder that the due date for fee submission/slip upload has passed. We kindly request you to submit the outstanding amount/upload the missing slip as soon as possible. Your cooperation is greatly appreciated. \n \n If you have any questions or need assistance, please contact Manager at KidzRepublik Islamabad.\n \n Thank you for your prompt attention to this matter.",
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
          }
        : null;
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
  final BankAccountController bankController =
      Get.find<BankAccountController>();
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
    return Scaffold(
      backgroundColor: grey100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kprimary,
        iconTheme: const IconThemeData(color: kWhite),
        title: const Text('Fees Voucher Preview',
            style: TextStyle(
                color: kWhite, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: _buildBottomActions(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              _buildVoucherHeader(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountInfo(),
                    const Divider(height: 32),
                    _buildStudentInfo(),
                    const SizedBox(height: 24),
                    _buildFeesTable(),
                    const SizedBox(height: 24),
                    _buildTotalSection(),
                    const SizedBox(height: 32),
                    _buildInstructions(),
                    const SizedBox(height: 32),
                    _buildVoucherFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            if (status == 'Not Paid') ...[
              if (role_ == 'Parent')
                _buildActionButton('Pay Online', Icons.payment, Colors.green,
                    () => Get.to(AddCashBankTransfer())),
              _buildActionButton(
                  'Save/Print', Icons.print, Colors.blue, _generatePdf),
              _buildActionButton(
                  'Upload Slip',
                  Icons.upload_file,
                  Colors.orange,
                  () => Get.to(
                      () => MyUploadPaymentProof(documentId: slipNumber))),
            ] else if (status == 'Paid' &&
                (role_ == 'Manager' || role_ == 'Director'))
              _buildActionButton(
                  'Verify',
                  Icons.verified_user,
                  Colors.orange,
                  () =>
                      Get.to(() => ManagerVerifyProof(documentId: slipNumber))),
            _buildActionButton('Close', Icons.close, kGrey, () => Get.back()),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildVoucherHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: kprimary,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50, // Added fixed height
            child: Obx(() {
              if (bankController.bankImage.value.isNotEmpty) {
                return CachedNetworkImage(
                  imageUrl: bankController.bankImage.value,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      Image.asset('assets/bank_icon.png'),
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/bank_icon.png'),
                );
              } else {
                return Image(
                  image: AssetImage('assets/bank_icon.png'),
                  fit: BoxFit.cover,
                );
              }
            }),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bankController.bankName.value,
                    style: const TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const Text("Any Branch within Pakistan",
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          Image.asset('assets/${table_}app_icon.png', height: 40, width: 40),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Slip Number', style: k10500.copyWith(color: kGrey)),
              Text(slipNumber, style: k10bold, overflow: TextOverflow.visible),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Account Number', style: k10500.copyWith(color: kGrey)),
              Text(bankController.accountNumber.value,
                  style: k10500, overflow: TextOverflow.visible),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoRow('Full Name', fullName),
            _buildInfoRow('Account Holder', bankController.creditTo.value),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoRow('Class', studentClass ?? '-'),
            _buildInfoRow('Reg #', registrationNumber),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInfoRow('Month', month)),
            Expanded(child: _buildInfoRow('Date', dated ?? '-')),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: k10500.copyWith(color: kGrey)),
        Text(value, style: k12500.copyWith(color: kBlackColor)),
      ],
    );
  }

  Widget _buildFeesTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fees Breakdown', style: k14bold),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _feesData.length,
            itemBuilder: (context, index) {
              final fee = _feesData[index];
              if (fee['name'] == 'childFullName' ||
                  fee['name'] == 'fathersEmail') return const SizedBox.shrink();
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: index < _feesData.length - 1
                      ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                      : null,
                ),
                child: Row(
                  children: [
                    Text('${index + 1}.', style: k12500.copyWith(color: kGrey)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(fee['name'], style: k12500)),
                    Text('Rs. ${fee['amount']}.00',
                        style: k12500.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kprimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Amount Payable', style: k14bold),
          const SizedBox(width: 12),
          Flexible(
            child: Text('Rs. ${amountPayable?.toStringAsFixed(2)}',
                style: k16bold.copyWith(color: kprimary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    final instructions = [
      "1. Tuition Fee is payable in advance and once paid is Non-Refundable.",
      "2. Tuition Fee must be paid before the last date of payment stated on the Fee Bill. A fine of Rs. 100/- per day will be charged after lapse of last date of payment.",
      "3. If a student fails to pay tuition fee within 5 days after the last date of payment. He/She will not be permitted to sit in the class.",
      "4. Tuition Fee for the month(s) of June August Quarter must be paid before the beginning of Summer Vacation.",
      "5. If a student is to be withdrawn, A notice of one month must be given in writing or one month's fee is payment on lieu of the notice.",
      "6. If a student fails to receive fee bill, it is the responsibility of the parents to notify the school. Rs. 100/- will be charged for duplicate copy."
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Important Instructions',
            style: k12500.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...instructions.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(text,
                  style:
                      TextStyle(fontSize: 10, color: kGrey.withOpacity(0.8))),
            )),
      ],
    );
  }

  Widget _buildVoucherFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Issue Date', style: k10500.copyWith(color: kGrey)),
                  Text(issueDate ?? '-',
                      style: k12500.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Last Date', style: k10500.copyWith(color: kGrey)),
                  Text(lastDate ?? '-',
                      style: k12bold.copyWith(color: kRedColor),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 150,
              padding: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: kBlackColor))),
              child: const Text('Accounts Office',
                  textAlign: TextAlign.center, style: k10500),
            ),
          ],
        ),
      ],
    );
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
