import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSlip extends StatelessWidget {
  final String voucherNumber;
  final DateTime date;
  final String payeeName;
  final String studentClass;
  final String registrationNumber;
  final String month;
  final String campus;
  final List<Fee> fees; // List of Fee objects with type and amount
  final double amountPayable;
  final double lateFee; // Optional late fee amount
  final List<String> instructions; // List of instruction strings
  final DateTime issueDate;
  final DateTime dueDate;

  const PaymentSlip({
    Key? key,
    required this.voucherNumber,
    required this.date,
    required this.payeeName,
    required this.studentClass,
    required this.registrationNumber,
    required this.month,
    required this.campus,
    required this.fees,
    required this.amountPayable,
    this.lateFee = 0.0,
    required this.instructions,
    required this.issueDate,
    required this.dueDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Voucher Number and Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Voucher Number: $voucherNumber"),
            Text(formatDate(date)), // Function to format date
          ],
        ),
        // Row 2: Payee Name
        Text("Payee Name: $payeeName"),
        // Row 3: Class and Registration Number
        Row(
          children: [
            Text("Class: $studentClass"),
            SizedBox(width: 20),
            Text("Registration #: $registrationNumber"),
          ],
        ),
        // Row 4: Month
        Text("Month: $month"),
        // Row 5: Campus
        Text("Campus: $campus"),
        // Row 6: Blank Space
        SizedBox(height: 10),
        // Row 7: Headings
        Row(
          children: [
            Text("Ser", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 20),
            Text("Type of Fees", style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        // Rows 8 (data) and repeated for each fee
        for (var fee in fees)
          buildFeeRow(fee.ser, fee.type, fee.amount),
        // Row 9: Amount Payable
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Amount Payable:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(amountPayable.toStringAsFixed(2)),
          ],
        ),
        // Row 10: Amount Payable After Due Date (optional)
        if (lateFee > 0.0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Amount Payable After Due Date:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text((amountPayable + lateFee).toStringAsFixed(2)),
            ],
          ),
        // Rows 11-17: Instructions
        for (var instruction in instructions)
          Text(instruction),
        // Row 18: Blank Space
        SizedBox(height: 10),
        // Row 19: Issue Date and Due Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Issue Date: ${formatDate(issueDate)}"),
            Text("Due Date: ${formatDate(dueDate)}"),
          ],
        ),
        // Row 20: Approvals Signature
        Row(
          children: [
            Text("Approvals Signature: "),
            SizedBox(width: 100),
            Text("(Sign Here)"),
          ],
        ),
      ],
    );
  }

  Widget buildFeeRow(String? ser, String type, double amount) {
    return Row(
        children: [
        Text(ser ?? ""), // Handle null ser value

          SizedBox(width: 20),
          Text(type),
          Spacer(),
          Text(amount.toStringAsFixed(2)),
        ],
    );
  }

  String formatDate(DateTime date) {
    // Implement your desired date formatting logic here
    // Example:
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

class Fee {
  final String? ser; // Optional serial number
  final String type;
  final double amount;

  const Fee({
    this.ser,
    required this.type,
    required this.amount,
  });
}
