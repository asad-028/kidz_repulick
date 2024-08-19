import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/utils/const.dart';

class MyUploadPaymentProof extends StatefulWidget {
  final String documentId;

  const MyUploadPaymentProof({required this.documentId});

  @override
  _MyUploadPaymentProofState createState() => _MyUploadPaymentProofState();
}

class _MyUploadPaymentProofState extends State<MyUploadPaymentProof> {
  final _formKey = GlobalKey<FormState>();
  double amountPaid = 0.0;
  String paymentId = '';
  XFile? pickedImage;
  DateTime? selectedPaymentDate; // Added to store selected date
  bool _uploading = false;

  Future<void> _pickImage() async {
    pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {}); // Update UI to show preview
  }

  void _selectPaymentDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedPaymentDate ?? DateTime.now(),
      firstDate: DateTime(
          DateTime.now().year), // Allow selection from current year onwards
      lastDate:
          DateTime(DateTime.now().year + 5), // Allow selection for next 5 years
    );
    if (pickedDate != null) {
      setState(() {
        selectedPaymentDate = pickedDate;
      });
    }
  }
  String formatDate(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date); // Example formatting
  }

  Widget _buildImagePreview() {
    if (pickedImage != null) {
      return Center(child: Image.file(File(pickedImage!.path)));
    } else {
      return Center(child: Text('No image selected'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kprimary,
          foregroundColor: Colors.white,
          title: Text('Upload Payment Proof', style: TextStyle(fontSize: 14)),
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Amount Paid'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount paid';
                        }
                        return null;
                      },
                      onSaved: (newValue) =>
                          amountPaid = double.parse(newValue!),
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Payment/ Transaction ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter payment ID';
                        }
                        return null;
                      },
                      onSaved: (newValue) => paymentId = newValue!,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () =>
                          // null,
                          _selectPaymentDate(), // Call to open calendar
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(Icons.date_range_outlined,size: 18,),
                              SizedBox(width: 8,),
                              Text(selectedPaymentDate != null
                                  ? '${DateFormat('y MMMM d').format(selectedPaymentDate!)}' // Display selected date in a readable format
                                  : 'Select Payment Date'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey[500],),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image),
                      label: Text('Select Image'),
                    ),
                    Container(height: 300,color: Colors.teal[50], width: 400, child: _buildImagePreview()),
                    SizedBox(height: 20,),
                    Container(
                      height: 40,
                      width: 100,
                      color: kprimary,
                      child: TextButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              selectedPaymentDate != null) {
                            _formKey.currentState!.save(); // Save form data
                            await uploadPaymentProofDetails(
                                context,
                                widget.documentId,
                                amountPaid,
                                paymentId,
                                pickedImage,
                                selectedPaymentDate!);
                          } else if (selectedPaymentDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Please select a payment date')),
                            );
                          }
                        },
                        icon: Icon(Icons.upload,size: 14,color: Colors.white,),
                        label: Text('Upload',style: TextStyle(color: Colors.white)),
                      ),
                    ),

                  ],
                ),
              ),
            )));
  }

  Future<void> uploadPaymentProofDetails(
      BuildContext context,
      String documentId,
      double amountPaid,
      String paymentId,
      XFile? pickedImage,
      DateTime selectedPaymentDate) async {
    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      // Create a unique file name for the image
      final fileName = '${documentId}.jpg';

      // Create a reference to the storage location
      final storageRef =
          FirebaseStorage.instance.ref().child('${table_}paymentproofs/$fileName');

      // Upload the image to Firebase Storage
      final uploadTask = storageRef.putFile(File(pickedImage.path));
      final snapshot = await uploadTask.whenComplete(() => null); // Wait

      // Get the download URL for the uploaded image
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the "accounts" collection document with payment details
      final docRef =
          FirebaseFirestore.instance.collection(accounts).doc(documentId);
      await docRef.update({
        'status': 'Paid', // Update status
        'paymentProof': downloadUrl, // Store the download URL for proof
        'amountPaid': amountPaid,
        'dateOfPayment': formatDate(selectedPaymentDate), // Save the selected date
        'paymentId': paymentId
      });
      updateClassData();

      setState(() {
        _uploading =
            false; // Reset flag to hide progress indicator (if applicable)
      });

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Payment proof uploaded successfully!'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Navigate back to previous screen
                },
              ),
            ],
          );
        },
      );    //   Navigator.pop(context); // Hide the screen
    //
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Payment proof uploaded successfully!')),
    //   );
    // Get.back();
    } on FirebaseException catch (e) {
      setState(() {
        _uploading =
            false; // Reset flag to hide progress indicator (if applicable)
      });
      Navigator.pop(context); // Hide the screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading proof: ${e.message}')),
      );
    Get.back();
    } catch (e) {
      setState(() {
        _uploading =
            false; // Reset flag to hide progress indicator (if applicable)
      });
      Navigator.pop(context); // Hide the screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    Get.back();
    }
  }

  Future<void> updateClassData() async {
    // Fetch data from accounts collection
    final docRef = FirebaseFirestore.instance
        .collection(accounts)
        .doc(widget.documentId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      final studentClass = data?['class']; // Access 'class' field
      final amountPayable =
          data?['amountPayable']; // Access 'amountPayable' field

      if (studentClass != null && amountPayable != null) {
        // Update ClassData collection
        final docRef2 = FirebaseFirestore.instance
            .collection('ClassData')
            .doc(studentClass);
        final transaction = await FirebaseFirestore.instance
            .runTransaction((transaction) async {
          final doc = await transaction.get(docRef2);
          if (doc.exists) {
            final existingAmountPaid =
                doc.data()!['amountPaid'] ?? 0; // Handle potential null value
            final existingNotPaid = doc.data()!['amountNotPaid'] ??
                0; // Handle potential null value

            final updatedAmountPaid = existingAmountPaid + amountPayable;
            final updatedNotPaid = existingNotPaid - amountPayable;

            transaction.update(docRef2, {
              'Paid_': FieldValue.increment(1),
              'notPaid_': FieldValue.increment(-1),
              'amountPaid': updatedAmountPaid,
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
      }
    } else {
      print('Document in accounts collection does not exist.');
    }
Get.back();
  }
}

