import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/controllers/bank_account_controller.dart';
import 'package:kids_republik/screens/accounts/fees/fees_form.dart';
import 'package:kids_republik/screens/accounts/update_accounts_dashboard.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:snackbar/snackbar.dart';

import '../../main.dart';
import 'manager_accounts_home.dart';

class GenerateFeesSlip extends StatefulWidget {
  final String documentId; // Pass the document ID to fetch data

  const GenerateFeesSlip({Key? key, required this.documentId})
      : super(key: key);

  @override
  _GenerateFeesSlipState createState() => _GenerateFeesSlipState();
}

class _GenerateFeesSlipState extends State<GenerateFeesSlip> {
  final BankAccountController bankController =
      Get.find<BankAccountController>();
  final CollectionReference feesCollection =
      FirebaseFirestore.instance.collection(accounts);
  final CollectionReference collectionReferenceClass =
      FirebaseFirestore.instance.collection(ClassRoom);
  final CollectionReference babyCollection =
      FirebaseFirestore.instance.collection(BabyData);
  DocumentSnapshot? _accountData; // Store fetched data
  DocumentSnapshot? _babyData; // Store fetched data
  String slipNumber = '';
  List<Map<String, dynamic>> _feesData = [];
  int decreaseindex = 0;
  bool isChecked = false; // Flag to track checkbox state
  double amountPayable = 0.0;
  DateTime dated = DateTime.now(); // Convert Timestamp to DateTime
  String fullName = '';
  String studentClass = '';
  String registrationNumber = '';
  String fathersemail = '';
  String month = DateFormat('MMM yyyy').format(DateTime.now());
  DateTime issueDate = DateTime.now();

  DateTime lastDate = DateTime.now().add(Duration(days: 15));
  DateTime selectedDate = DateTime.now();
  bool isExpanded = false;
  Future<DateTime?> _showCalendar(BuildContext context,
      {DateTime? initialDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    return picked;
  }

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data on widget initialization
  }

  Future<void> _fetchData() async {
    try {
      final doc = await feesCollection.doc(widget.documentId).get();
      final fees = doc.data();
      if (fees != null) {
        if (fees is Map<String, dynamic>) {
          _feesData = fees.entries
              .map((entry) => {
                    'name': entry.key,
                    'amount': entry.value,
                    'isSelected': false
                  })
              .toList();
          DocumentSnapshot document2 =
              await babyCollection.doc(widget.documentId).get();
          _babyData = document2;
          _accountData = doc;
          final docSnapshot = await feesCollection.doc('voucherID').get();
          if (docSnapshot.exists) {
            docSnapshot.get('voucherID');
            slipNumber =
                "${table_ == '' ? 'KR' : 'TSN'}-${docSnapshot.get('voucherID').toString().padLeft(6, '0')}"; // Format voucher number
            setState(() {});
          } else {
            snack("No document found with ID 'voucherID'");
          }
        } else {
          snack("Unexpected data type for fees: ${fees.runtimeType}");
          // Handle unexpected data type (e.g., show an error message)
        }
      } else {
        await confirm(context,
                title: Text('Record not added'),
                content: Text("Do you want to Add Fees Record?"),
                textOK: Text('Yes'),
                textCancel: Text("No"))
            ? Get.to(FeesEntryForm(
                babyId: widget.documentId,
              ))
            : Get.back();
      }
    } catch (error) {
      snack("Error fetching data: $error");
      Get.back();
      // Handle errors appropriately (e.g., show a snackbar)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      floatingActionButton: IconButton(
        onPressed: () async {
          await confirm(context,
                  title: Text('Confirm Fees Slip Generation for $fullName',
                      style: TextStyle(fontSize: 14)),
                  content: Text(
                    'Are you sure you want to finalize the fees slip for $fullName with a total amount of Rs. $amountPayable for the month of $month? \n\nThis action cannot be undone.',
                    style: TextStyle(fontSize: 12),
                  ))
              ? await _createAccountDocument()
              : null;
        },
        icon: Container(
            alignment: Alignment.center,
            width: 60,
            height: 28,
            color: kprimary,
            child: Text(
              'Generate',
              style: TextStyle(fontSize: 10, color: Colors.white),
              textAlign: TextAlign.center,
            )),
      ),

      body: _accountData != null
          ? Container(
              padding: EdgeInsets.only(left: 5, right: 5, top: 12, bottom: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildContent(),
            )
          : Center(
              child:
                  CircularProgressIndicator()), // Show loading indicator while fetching data
    );
  }

  Widget _buildContent() {
    if (_accountData == null) {
      return Center(
          child: Text(
              'No data found for this document ID.')); // Inform user of missing data
    }
    // Extract data from _accountData
    DateTime dated = DateTime.now(); // Convert Timestamp to DateTime
    fullName = _babyData!.get('childFullName');
    studentClass = _babyData!.get('class_');
    registrationNumber = _babyData!.get('RegistrationNumber');
    fathersemail = _babyData!.get('fathersEmail');

    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 10, left: 5, right: 5),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1), // Add border here
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Text(
              'Fees Voucher',
              style: TextStyle(
                  fontSize: responsiveFontSize(12),
                  fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Image on the left
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
                // Text in the center
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        bankController.bankName.value,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text("Any Branch within Pakistan",
                          style: TextStyle(fontSize: 10)),
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

            // Text(schoolName, style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
            // Payee Information
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'AC No: ${bankController.accountNumber.value}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveFontSize(12)),
                ),
              ],
            ),
            // Slip Information
            Row(
              children: [
                Text("NO:                   $slipNumber",
                    style: TextStyle(fontSize: responsiveFontSize(12))),
              ],
            ),
            Row(
              children: [
                Text("Credit:              ${bankController.creditTo.value}",
                    style: TextStyle(fontSize: responsiveFontSize(12))),
              ],
            ),
            Row(
              children: [
                Text("Dated:              ${formatDate(dated)}",
                    style: TextStyle(fontSize: responsiveFontSize(12))),
              ],
            ),
            Row(
              children: [
                Text("Full Name:       $fullName",
                    style: TextStyle(fontSize: responsiveFontSize(12))),
              ],
            ),
            // Student Information
            Row(
              children: [
                Text("Class:              $studentClass",
                    style: TextStyle(fontSize: responsiveFontSize(12))),
                Spacer(),
                Text("Reg #:     $registrationNumber",
                    style: TextStyle(fontSize: responsiveFontSize(12))),
                Spacer(),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                children: [
                  Text("Month:            $month",
                      style: TextStyle(fontSize: responsiveFontSize(12))),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Container(
                height: 200, // Adjust height as needed
                child: ListView.builder(
                  itemCount: 12,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 0),
                  itemBuilder: (BuildContext context, int index) {
                    DateTime monthDate = DateTime(selectedDate.year, index + 1);
                    String monthString =
                        DateFormat('MMM yyyy').format(monthDate);

                    return InkWell(
                      // Wrap each month text with InkWell
                      onTap: () {
                        setState(() {
                          selectedDate = monthDate;
                          month = monthString;
                          isExpanded = false;
                        });
                      },
                      child: Padding(
                        // Add padding for spacing
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                        child: Text(
                          monthString,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Row(
              children: [
                Text("Sr#",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveFontSize(12))),
                SizedBox(width: 20),
                Text("Type of Fee",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveFontSize(12))),
                Spacer(),
                Text("Amount",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveFontSize(12))),
              ],
            ),
            // Fees breakdown
            if (_feesData.isNotEmpty)
              Container(
                height: 150,
                color: Colors.blue[50],
                // padding: EdgeInsets.only(top: 0),
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 5),
                  shrinkWrap:
                      true, // Prevent the list from expanding unnecessarily
                  itemCount: _feesData.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    final fee = _feesData[index];

                    // (fee['name'] == 'childFullName' || fee['name'] == 'fathersEmail')? null:(fee['isSelected'] == true)? amountPayable = amountPayable + double.tryParse(fee['amount'])! : 0.0;
                    // print("$amountPayable ${fee['amount']} ${fee['isSelected']}");
                    // Update isSelected in the list

                    return Column(
                      children: [
                        (fee['name'] == 'childFullName' ||
                                fee['name'] == 'fathersEmail' ||
                                fee['name'] == 'child_')
                            ? Container()
                            : Row(
                                children: [
                                  Container(
                                    height: 12,
                                    child: Checkbox(
                                      value: fee['isSelected'],
                                      onChanged: (bool? value) {
                                        fee['isSelected'] = value!;
                                        if (fee['isSelected'] == true) {
                                          amountPayable = amountPayable +
                                              (fee['amount'] ?? 0);
                                        } else
                                          amountPayable =
                                              amountPayable - fee['amount'] ??
                                                  0;
                                        // Update isSelected in the list
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Text(fee['name'],
                                      style: TextStyle(
                                          fontSize: responsiveFontSize(
                                              12))), // Display fee type
                                  Spacer(),
                                  Text('${fee['amount']}.00'.toString(),
                                      style: TextStyle(
                                          fontSize: responsiveFontSize(12))),
                                ],
                              ),
                        const Divider(
                            height: 0.5,
                            color:
                                Colors.grey), // Add divider after each ListTile
                      ],
                    );
                  },
                ),
              ),
            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Amount Payable:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveFontSize(12))),
                Text(amountPayable.toStringAsFixed(2),
                    style: TextStyle(fontSize: responsiveFontSize(12))),
              ],
            ),
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
            SizedBox(height: 5),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Issue Date: ${formatDate(issueDate)}",
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () async {
                    final selectedDate =
                        await _showCalendar(context, initialDate: issueDate);
                    if (selectedDate != null) {
                      setState(() {
                        issueDate = selectedDate;
                        lastDate = selectedDate.add(Duration(days: 15));
                      });
                    }
                  },
                  child: Icon(
                    Icons.edit,
                    size: 18,
                  ),
                ),
                Spacer(),
                Text("Last Date: ${formatDate(lastDate)}",
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () async {
                    final selectedDate =
                        await _showCalendar(context, initialDate: issueDate);
                    if (selectedDate != null) {
                      setState(() {
                        lastDate = selectedDate;
                      });
                    }
                  },
                  // onTap: () => setState(() => _showCalendar(initialDate:  )),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                  ),
                  // child: Icon(Icons.calendar_today_outlined),
                ),
              ],
            ),

            Row(
              children: [
                Text("Accounts Office",
                    textAlign: TextAlign.left, style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date); // Example formatting
  }

  Future<void> _createAccountDocument() async {
    final selectedFees =
        _feesData.where((fee) => fee['isSelected'] == true).toList();
    final Map<String, dynamic> accountData = {
      'childFullName': fullName,
      'fathersEmail': fathersemail,
      'child_': widget.documentId,
      'studentClass': studentClass, // Added from _babyData
      'registrationNumber': registrationNumber, // Added
      'dated': formatDate(dated), // Added
      'month': month, // Added
      'issueDate': formatDate(issueDate), // Added
      'lastDate': formatDate(lastDate), // Added
      'fees': selectedFees,
      'amountPayable': amountPayable,
      'status': 'Not Paid'
    };

    try {
      // Create a new document with slipNumber as ID
      await feesCollection.doc(slipNumber).set(accountData);
      await feesCollection.doc('voucherID').update({
        'voucherID': FieldValue.increment(1), // Increment by 1 using FieldValue
      });
      await updateClassData();
      UpdateAccountsDashboardScreen(studentClass, context);

      snack("Fee slip generated & forwarded to parents successfully!");
      Get.back();
    } catch (error) {
      snack("Error generating slip: $error");
      // Handle errors appropriately (e.g., show a snackbar)
      Get.back();
    }
    // Navigator.pop(context);
  }

  double responsiveFontSize(double baseFontSize) {
    final height = MediaQuery.of(context).size.height;
    return baseFontSize * (height / 800); // Adjust 800 based on your design
  }

  Future<void> updateClassData() async {
    if (studentClass != null && amountPayable != null) {
      // Update ClassData collection
      final docRef2 =
          FirebaseFirestore.instance.collection(ClassRoom).doc(studentClass);
      final transaction =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(docRef2);
        if (doc.exists) {
          final existingNotPaid =
              doc.data()!['amountNotPaid'] ?? 0; // Handle potential null value

          final updatedNotPaid = existingNotPaid + amountPayable;

          transaction.update(docRef2, {
            'NotPaid_': FieldValue.increment(1),
            'amountNotPaid': updatedNotPaid,
          });
        } else {
          // Handle case where document in ClassData doesn't exist (optional)
          print('Document in ClassData collection does not exist.');
        }
      });

      if (transaction != null) {
        print('Payment updated successfully!');
      } else {
        print('Failed to update payment.');
      }
    } else {
      print('Missing required fields in accounts document.');
    }
  }
}

class Fee {
  final String type;
  final double amount;
  bool isSelected;

  Fee({
    required this.type,
    required this.amount,
    this.isSelected = false, // Set default value to false
  });
}
