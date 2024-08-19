import 'package:kids_republik/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:snackbar/snackbar.dart';

class ManagerVerifyProof extends StatefulWidget {
  final String documentId;

  const ManagerVerifyProof({required this.documentId});

  @override
  _ManagerVerifyProofState createState() => _ManagerVerifyProofState();
}

class _ManagerVerifyProofState extends State<ManagerVerifyProof> {
  final _formKey = GlobalKey<FormState>();
  double amountPaid = 0.0;
  String paymentId = '';
  XFile? pickedImage;
  DateTime? selectedPaymentDate;
  // Add a new variable to store document data
  Map<String, dynamic> documentData = {};

  // Fetch document data on initState
  @override
  void initState() {
    super.initState();
     _fetchDocumentData(widget.documentId);
  }

  Future<void> _fetchDocumentData(String documentId) async {
    final docRef = FirebaseFirestore.instance.collection(accounts).doc(documentId);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      setState(() {
        documentData = snapshot.data()!;
      });
    } else {
      // Handle document not found scenario (e.g., show error message)
      print("Document not found!");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kprimary,
        foregroundColor: Colors.white,
        title: Text('Verify Proof', style: TextStyle(fontSize: 18)), // Increased font size
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView for scrollable content
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
          children: [
            // Information section with clear labels
            Text('Name:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${documentData['childFullName'] ?? 'Unknown'}'),
            SizedBox(height: 10), // Add spacing between sections
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount Payable:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${documentData['amountPayable']?.toStringAsFixed(2) ?? 'Unknown'}'), // Format currency
                SizedBox(height: 10),
                Text('Last Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${documentData['lastDate'] ?? 'Unknown'}'),
              ],
            ),
            SizedBox(height: 10), // Add spacing between sections
            Row(
              children: [
                Expanded(
                  child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
                    children: [
                      Text('Amount Paid:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${documentData['amountPaid']?.toStringAsFixed(2) ?? 'Unknown'}'),
                      SizedBox(height: 10),
                      Text('Payment Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${documentData['dateOfPayment'] ?? 'Unknown'}'),
                      SizedBox(height: 20),
                      Text('Payment Status:', style: TextStyle(fontWeight: FontWeight.bold)),
           (documentData['status'] == 'Verified')?
     Text('Verified', style: TextStyle(color: Colors.green))
    :
     Text('Not Verified', style: TextStyle(color: Colors.red)),

        // getStatusText(documentData['status']), // Use a separate function for status display
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                    Container (height: 300, width: MediaQuery.of(context).size.width*0.5, child: Center(child: CachedNetworkImage(imageUrl:documentData['paymentProof']))),
              ],
            ), // Adjust image container size based on screen width
                SizedBox(height: 20),


            // Improved button layout with clear indication of verification state
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Center buttons horizontally
              children: [
                Visibility(
                  visible: documentData['status'] != 'Verified',
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await confirm(context)?_updateDocumentStatus(widget.documentId, 'Verified'):null;
                    },
                    label: Text('Verify Payment'),
                    icon: Icon(Icons.verified_user),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context), // Close screen on any button press
                  child: Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Function to display status text based on value
  Text getStatusText(String status) {
    if (status == 'Verified') {
      return Text('Verified', style: TextStyle(color: Colors.green));
    } else {
      return Text('Not Verified', style: TextStyle(color: Colors.red));
    }
  }

  // ... existing code for _buildImagePreview, _pickImage, etc.


  Future<void> _updateDocumentStatus(String documentId, String newStatus) async {
    final docRef = FirebaseFirestore.instance.collection(accounts).doc(documentId);
    await docRef.update({'status': newStatus});
      // Fetch data from accounts collection
      // final docRef = FirebaseFirestore.instance.collection(accounts).doc(documentID);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final studentClass = data?['class']; // Access 'class' field
        final amountPayable = data?['amountPayable']; // Access 'amountPayable' field

        if (studentClass != null && amountPayable != null) {
          // Update ClassData collection
          final docRef2 = FirebaseFirestore.instance.collection('ClassData').doc(studentClass);
          final transaction = await FirebaseFirestore.instance.runTransaction((transaction) async {
            final doc = await transaction.get(docRef2);
            if (doc.exists) {
              final existingAmountPaid = doc.data()!['amountPaid'] ?? 0; // Handle potential null value
              final existingVerified = doc.data()!['amountVerified'] ?? 0; // Handle potential null value

              final updatedAmountPaid = existingAmountPaid - amountPayable;
              final updatedVerified = existingVerified + amountPayable;

              transaction.update(docRef2, {
                'Verified_': FieldValue.increment(1),
                'Paid_': FieldValue.increment(-1),
                'amountPaid': updatedAmountPaid,
                'amountVerified': updatedVerified,
              });
            } else {
              // Handle case where document in ClassData doesn't exist (optional)
              print('Document in ClassData collection does not exist.');
            }
          });

          if (transaction != null) {
            snack('Payment updated successfully!');
          } else {
            snack('Failed to update payment.');
          }
        } else {
          snack('Missing required fields in accounts document.');
        }
      } else {
        snack('Document in accounts collection does not exist.');
      }
      Get.back();

  }

}
