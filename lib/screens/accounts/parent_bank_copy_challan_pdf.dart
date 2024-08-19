import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/accounts/payment_proof.dart';
import 'package:kids_republik/screens/accounts/verify_proof.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'manager_accounts_home.dart';

class DocumentList extends StatefulWidget {

  // Pass the document ID to fetch data

  @override
  _DocumentListState createState() => _DocumentListState();
}
  String _selectedCategory =  role_ ==  'Manager'?'Paid':'Not Paid';

class _DocumentListState extends State<DocumentList> {
  final Map<String, Color> _categoryColors = {
    'Paid': Colors.green,
    'Not Paid': Colors.red,
    'Verified': Colors.brown ,
  }; // Map for category and corresponding color
  final _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _documents = [];

  @override
  void initState() {
    super.initState();
    // _fetchDocuments( role_ == 'Manager'?'Paid':'Not Paid');
  }

  Future<void> _fetchDocuments(condition2) async {
    try {
    String? condition;
    (role_ == 'Manager')? condition = '' : condition  = "'fathersemail',isEqualTo: ${user!.email}";
      final querySnapshot = await _firestore.collection(accounts).where('status', isEqualTo: condition2!).where(condition).get();
        _documents = querySnapshot.docs;
      setState(() {
      });
    } catch (e) {
      // Handle errors gracefully, e.g., show a snackbar
      print(e);
    }
  }
  Widget buildCategoryButton(String category) {
    final isSelected = _selectedCategory == category;
    final color = isSelected ? _categoryColors[category]! : Colors.black;
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
          _fetchDocuments(category);
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.2) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      child: Text(category, style: TextStyle(color: color,fontSize: 14)),
    );
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
      appBar: AppBar(
        foregroundColor: Colors.white,
          backgroundColor: kprimary,
          title: Text('Account Reports', style: TextStyle(fontSize: 14),)),
      body:
      Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reports:',style: TextStyle(color: Colors.blue[900],fontWeight: FontWeight.bold),),
                  buildCategoryButton('Paid'),
                  buildCategoryButton('Not Paid'),
                  buildCategoryButton('Verified'),
                ],
              ),
            ),
      Container(
        height: mq.height*0.8,
        child:
            ListView.builder(
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final document = _documents[index];
                final documentName = document.id;

                return
                  ListTile(
                    title:
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(document['childFullName']
                                  ,
                                    style: TextStyle(
                                      color: _categoryColors[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                    ],
                                  ),
                                  Text(
                                    "Slip#:$documentName, ${document['status']} (Rs. ${document['amountPayable'].toString()}) ${document['status']=='Not Paid'?' last date is ': ' on '} ${document['status']=='Not Paid' ? document['lastDate']:formatTimestamp(document['dateOfPayment'])}",
                                    style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(width: 10.0), // Spacing between content and divider
                            (_selectedCategory != 'Not Paid')?Container(width: mq.width*0.10, child: CachedNetworkImage(imageUrl: document['paymentProof'])):Container()
                          ],
                        ),
                        Container(width: 400,height: 1,color: Colors.grey,)
                      ],
                    ),
                    onTap: () => _handleDocumentClick(document.id),
                  );
              },
            ),
        ),
          ],
      ),
    );
  }
}
String formatTimestamp(timestamp ) {
  // Timestamp = document.get('paymentDate');
  final formatter = DateFormat('dd-MM-yyyy');
  String formattedDate = formatter.format(timestamp.toDate());
  return formattedDate;
}
// Replace with your actual PDF generation logic

class PrepareBankCopyFromFirebasePDF extends StatefulWidget {
  final String documentId; // Pass the document ID to fetch data

  const PrepareBankCopyFromFirebasePDF({Key? key, required this.documentId}) : super(key: key);

  @override
  _PrepareBankCopyFromFirebasePDFState createState() => _PrepareBankCopyFromFirebasePDFState();
}

class _PrepareBankCopyFromFirebasePDFState extends State<PrepareBankCopyFromFirebasePDF> {
  final CollectionReference feesCollection = FirebaseFirestore.instance.collection(accounts);
  // final CollectionReference babyCollection = FirebaseFirestore.instance.collection(BabyData);
  // DocumentSnapshot? _accountData; // Store fetched data
  // DocumentSnapshot? _babyData; // Store fetched data
  String slipNumber = '';
  List<dynamic> _feesData = [] ;
  int decreaseindex = 0;
  bool isChecked = false; // Flag to track checkbox state
  var amountPayable ;
  String? dated  ; // Convert Timestamp to DateTime
  String fullName = '';
  String? studentClass ;
  String registrationNumber = '';
  String month = '';
  String status = '';
  String? issueDate ;
  String? lastDate ;
  // DateTime? issueDate ;
  // DateTime? lastDate ;


  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data on widget initialization
  }

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
      print(_feesData);
      // _generatePdf();

    } catch (error) {
      print("Error fetching data: $error");
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
      backgroundColor: Colors.blue[50],
      floatingActionButton:
      (role_ ==  'Parent')?
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
          // Print/Save as PDF Button
          ElevatedButton.icon(
            onPressed: () => _generatePdf(),
            icon: Icon(Icons.print),
            label: Text('Print/Save',style: TextStyle(fontSize: 10),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50], // Customize button color
            ),
          ),

          // Pay Online Button (copies account number and shows snackbar)
          ElevatedButton.icon(
            onPressed: () async {
              // Replace with your actual account number retrieval
              await Clipboard.setData(ClipboardData(text: accountNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.green[50],
                  content: Text('Account Number $accountNumber Copied to clip board',style: TextStyle(color: Colors.black),),
                ),
              );
            },
            icon: Icon(Icons.payment),
            label: Text('Pay Online',style: TextStyle(fontSize: 10),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[50], // Customize button color
            ),
          ),

          // Upload Payment Proof Button
          ElevatedButton.icon(
            onPressed: () =>
            Get.to(()=> MyUploadPaymentProof(documentId: slipNumber))
            // uploadPaymentProof(context,slipNumber)
            ,
            icon: Icon(Icons.upload_file,size: 14,),
            label: Text('Upload Proof',style: TextStyle(fontSize: 10),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[50], // Customize button color
            ),
          ),
        ],
      ):
      Row(
        mainAxisAlignment: MainAxisAlignment.center ,
        children: [
          Spacer(),
          // Print/Save as PDF Button
          ElevatedButton.icon(
            onPressed: () => _generatePdf(),
            icon: Icon(Icons.print,size: 14,),
            label: Text('Print/Save',style: TextStyle(fontSize: 10),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50], // Customize button color
            ),
          ),

          Spacer(),
          ElevatedButton.icon(
            onPressed: () =>
            (status=='Paid')?Get.to(()=> ManagerVerifyProof(documentId: slipNumber)):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.red[50],
                    content: Wrap(children: [Icon(Icons.error_outline_sharp), SizedBox(width: 12,),Text('Payment proof not uploaded, Unable to verify',style: TextStyle(color: Colors.black),)]),
                  ),
                 ),
            icon: Icon(Icons.upload_file),
            label: Text('Verify',style: TextStyle(fontSize: 10),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[50], // Customize button color
            ),
          ),
          Spacer(),
        ],
      ),
      // Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
      //   children: [
      //     IconButton(icon: Icon(Icons.print_outlined), onPressed: () {_generatePdf();}, ),
      //     IconButton(icon: Icon(Icons.payments_outlined ),onPressed: () {
      //     },),
      //     FloatingActionButton(child: Icon(Icons.print_outlined ),onPressed: () {
      //       _generatePdf();
      //     },),
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25.0,bottom: 10,left: 5,right: 5),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5), // Add border here
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text('Fees Voucher', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Image on the left
                  Container(width: 50,
                    child: Image(
                      image: AssetImage('assets/bank_icon.png' ),
                      fit: BoxFit.cover, // Adjust fit as needed (cover, contain, etc.)
                    ),
                  ),
                  // Text in the center
                  Expanded(
                    child: Column(
                      children: [
                        Text(bankName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        Text("Any Branch within Pakistan"),
                      ],
                    ),
                  ),
                  // Image on the right
                  Container(width: 050,
                    child: Image(
                      image: AssetImage('assets/app_icon.png'),
                      fit: BoxFit.cover, // Adjust fit as needed (cover, contain, etc.)
                    ),
                  ),
                ],
              ),

              // Payee Information
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('AC No: $accountNumber', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
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
                  Text("Credit:              $creditTo"),
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
                  Text("Sr#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(width: 20),
                  Text("Type of Fee", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Spacer(),
                  Text("Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              // Fees breakdown
              if (_feesData.isNotEmpty)
                ListView.builder(
                  padding: EdgeInsets.only(top: 5,bottom: 10),
                  shrinkWrap: true, // Prevent the list from expanding unnecessarily
                  itemCount: _feesData.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    final fee = _feesData[index];
                    return Column(
                      children: [
                        (fee['name'] == 'childFullName' || fee['name'] == 'fathersEmail')? Container():
                        Row(
                          children: [
                            Text("${index + 1}.        ${fee['name']}"), // Display fee type
                            Spacer(),
                            Text('${fee['amount']}.00'.toString()),
                          ],
                        ),
                        const Divider(height: 1, color: Colors.grey), // Add divider after each ListTile
                      ],
                    );
                  },
                ),
              // Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Amount Payable:",
                      style: TextStyle(fontWeight: FontWeight.bold,)),
                  Text(amountPayable.toStringAsFixed(2)),
                ],
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("1. Tuition Fee is payable in advance and once paid is Non- Refundable",style: TextStyle(fontSize: 11),),
                  Text("2. Tuition Fee must be paid before the last date of payment stated on the Fee Bill. A fine of Rs. 100/- per day will be charged after lapse of last date of payment.",style: TextStyle(fontSize: 11)),
                  Text("3. If a student fails to pay tuition fee within 5 days after the last date of payment. He/ She will not be permitted to sit in the class.",style: TextStyle(fontSize: 11)),
                  Text("4. Tuition Fee for the month(s) of June August Quarter must be paid before the beginning of Summer Vacation",style: TextStyle(fontSize: 11)),
                  Text("5. If a student is to be withdrawn, A notice of one month must be given in writing or one month's fee is payment on lieu of the notice",style: TextStyle(fontSize: 11)),
                  Text("6. If a student fails to give fee bill to his/her parents. It is the responsibility of the parents to bring it to the notice of the school account officer Rs. 100/- will be charged if a fee bill is reported lost and duplicate copy asked for.",style: TextStyle(fontSize: 11)),
                ],
              ),
              SizedBox(height: 10),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Issue Date: ${issueDate}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                  Text("Last Date: ${lastDate}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                ],
              ),
Spacer(),
              Row(
                children: [
                   Text("Accounts Office",textAlign: TextAlign.right,),
                ],
              ),
Spacer(),

            ],
          ),
        ),
      )
    );
  }

  pw.Widget _buildContent(title,imagebank,imagekrdc) {

    return
      pw.Container(
        width: 250,// Use pw.Container for PDF-specific containers
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black, width: 1.5), // Add border here
      ),
      child: pw.Column( // Use pw.Column for PDF layout
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
      // Header
      pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
      // Image on the left

        pw.Container(
          width: 25,
          height: 25,
          child: pw.Image(
            imagebank,
            fit: pw.BoxFit.fitWidth, // Adjust fit as needed (cover, contain, etc.)
          ),
        ),
        // Text in the center
        pw.Expanded(
      child: pw.Column( // Use pw.Column again for inner layout
      children: [
      pw.Text(bankName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.Text("Any Branch within Pakistan", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal)),
      ],
      ),
      ),
        pw.Container(
          width: 25,
          height: 25,
          child: pw.Image(
            imagekrdc,
            fit: pw.BoxFit.fitWidth, // Adjust fit as needed (cover, contain, etc.)
          ),
        ),
      ],
      ),
      // Payee Information
      pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
      pw.Text('AC No: $accountNumber', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
      ],
      ),
      // Slip Information
      pw.Row(
      children: [
      pw.Text("NO:                   $slipNumber", style: pw.TextStyle(fontSize: 10)),
      ],
      ),
      pw.Row(
      children: [
      pw.Text("Credit:              $creditTo", style: pw.TextStyle(fontSize: 10)),
      ],
      ),
      pw.Row(
      children: [
      pw.Text("Dated:              ${dated}", style: pw.TextStyle(fontSize: 10)),
      ],
      ),
      pw.Row(
      children: [
      pw.Text("Full Name:       $fullName", style: pw.TextStyle(fontSize: 10)),
      ],
      ),
      // Student Information
      pw.Row(
      children: [
      pw.Text("Class:              $studentClass", style: pw.TextStyle(fontSize: 10)),
        pw.Spacer(),
      pw.Text("Reg #:     $registrationNumber", style: pw.TextStyle(fontSize: 10)),
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
      pw.Text("Sr#", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
      pw.SizedBox(width: 20),
      pw.Text("Type of Fee", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
      pw.Spacer(),
      pw.Text("Amount", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
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
                    pw.Text('${index + 1}.      ${fee['name']}', style: pw.TextStyle(fontSize: 10)),
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
            pw.Text("Amount Payable:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
            pw.Text("Issue Date: ${issueDate}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text("Last Date: ${lastDate}", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Row(
          children: [
            pw.Spacer(),
            pw.Text("Accounts Office", textAlign: pw.TextAlign.left, style: pw.TextStyle(fontSize: 10)),
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
    final imageData = await rootBundle.load('assets/bank_icon.png');
    final imageDatakrdc = await rootBundle.load('assets/app_icon.png');

    final imageBytes = imageData.buffer.asUint8List();
    final imageByteskrdc = imageDatakrdc.buffer.asUint8List();

    final imagebank = pw.MemoryImage(imageBytes);
    final imagekrdc = pw.MemoryImage(imageByteskrdc);

      pdf.addPage(
        pw.Page(
          orientation: pw.PageOrientation.landscape,
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return
              pw.Container
            (child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                _buildContent('Bank Copy',imagebank,imagekrdc),
                pw.SizedBox(width: 5),
                _buildContent('School Copy',imagebank,imagekrdc),
                pw.SizedBox(width: 5),
                _buildContent('Parents Copy',imagebank,imagekrdc),
              ],
            ));
          },
        ),
      );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> uploadPaymentProof(BuildContext context, String documentId) async {
    final _formKey = GlobalKey<FormState>(); // For form validation
    double amountPaid = 0.0; // Initialize amountPaid
    String paymentId = ''; // Initialize paymentId

    XFile? pickedImage; // Store picked image

    Future<void> _pickImage() async {
      pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {}); // Update UI to show preview
    }

    Widget _buildImagePreview() {
      if (pickedImage != null) {
        return
          Center(child: Image.file(File(pickedImage!.path)));
      } else {
        return Center(child: Text('No image selected'));
      }
    }

    return await showDialog(
      context: context,
      builder: (context) => Form(
        key: _formKey,
        child: Material(
          child: SingleChildScrollView( // Allow scrolling for long content
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Prevent dialog from expanding
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
                    onSaved: (newValue) => amountPaid = double.parse(newValue!),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Payment ID'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter payment ID';
                      }
                      return null;
                    },
                    onSaved: (newValue) => paymentId = newValue!,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text('Select Image'),
                      ),
                    ],
                  ),
                      Container(width: 300,height:400, child: _buildImagePreview()),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save(); // Save form data
                        await uploadPaymentProofDetails(context, documentId, amountPaid, paymentId, pickedImage);
                      }
                    },
                    icon: Icon(Icons.upload),
                    label: Text('Upload Slip'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> uploadPaymentProofDetails(BuildContext context, String documentId, double amountPaid, String paymentId, XFile? pickedImage) async {
    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

      showDialog(
        context: context,
        barrierDismissible: false, // Prevent user from closing dialog while uploading
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {


        // Create a unique file name for the image
        final fileName = '${documentId}.jpg';

        // Create a reference to the storage location
        final storageRef = FirebaseStorage.instance.ref().child('paymentproofs/$fileName');

        // Upload the image to Firebase Storage
        final uploadTask = storageRef.putFile(File(pickedImage.path));
        final snapshot = await uploadTask.whenComplete(() => null); // Wait for upload to complete

        // Get the download URL for the uploaded image
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Update the "accounts" collection document with payment details
        final docRef = FirebaseFirestore.instance.collection(accounts).doc(documentId);
        await docRef.update({
        'status': 'Paid', // Update status to "Paid"
        'paymentProof': downloadUrl, // Store the download URL for proof
        'amountPaid': amountPaid,
        // Add input field to capture amount paid (replace)

        'dateOfPayment': DateTime.now(), // Set date of payment
        'paymentId': paymentId
        });

        Navigator.pop(context); // Hide the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment proof uploaded successfully!')),
        );
      } on FirebaseException catch (e) {
        Navigator.pop(context); // Hide the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading proof: ${e.message}')),
        );
      } catch (e) {
        Navigator.pop(context); // Hide the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }

  }

  // Future<void> uploadPaymentProof(BuildContext context, String documentId) async {
  //   final amountPaid =
  //   // Add input field to capture amount paid (replace)
  //   await showDialog<double>( // Example for user input
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Enter Amount Paid'),
  //       content: TextField(
  //         keyboardType: TextInputType.number,
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, // Replace with actual value capture
  //             // captured amount from TextField
  //           ),
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   final paymentId =
  //   // Add input field to capture payment ID (replace)
  //   await showDialog<String>( // Example for user input
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Enter Payment ID'),
  //       content: TextField(),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, // Replace with actual value capture
  //             // captured payment ID from TextField
  //           ),
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   final imagePicker = ImagePicker();
  //
  //   // Get image from user (camera or gallery)
  //   final XFile? pickedImage = await imagePicker.pickImage(
  //     source: ImageSource.gallery, // Can allow camera source as well (ImageSource.camera)
  //   );
  //
  //   if (pickedImage == null) {
  //     return; // User canceled or failed to pick image
  //   }
  //
  //   // Show a loading indicator while uploading
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // Prevent user from closing dialog while uploading
  //     builder: (context) => Center(child: CircularProgressIndicator()),
  //   );
  //
  //   try {
  //
  //
  //     // Create a unique file name for the image
  //     final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  //
  //     // Create a reference to the storage location
  //     final storageRef = FirebaseStorage.instance.ref().child('paymentproofs/$fileName');
  //
  //     // Upload the image to Firebase Storage
  //     final uploadTask = storageRef.putFile(File(pickedImage.path));
  //     final snapshot = await uploadTask.whenComplete(() => null); // Wait for upload to complete
  //
  //     // Get the download URL for the uploaded image
  //     final downloadUrl = await snapshot.ref.getDownloadURL();
  //
  //     // Update the "accounts" collection document with payment details
  //     final docRef = FirebaseFirestore.instance.collection(accounts).doc(documentId);
  //     await docRef.update({
  //     'status': 'Paid', // Update status to "Paid"
  //     'paymentProof': downloadUrl, // Store the download URL for proof
  //     'amountPaid': amountPaid,
  //     // Add input field to capture amount paid (replace)
  //
  //     'dateOfPayment': DateTime.now(), // Set date of payment
  //     'paymentId': paymentId
  //     });
  //
  //     Navigator.pop(context); // Hide the loading indicator
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Payment proof uploaded successfully!')),
  //     );
  //   } on FirebaseException catch (e) {
  //     Navigator.pop(context); // Hide the loading indicator
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error uploading proof: ${e.message}')),
  //     );
  //   } catch (e) {
  //     Navigator.pop(context); // Hide the loading indicator
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('An error occurred: ${e.toString()}')),
  //     );
  //   }
  // }

}
