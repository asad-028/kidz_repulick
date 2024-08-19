import 'package:kids_republik/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kids_republik/utils/const.dart';

class NewPackageForm extends StatefulWidget {
  @override
  _NewPackageFormState createState() => _NewPackageFormState();
}

class _NewPackageFormState extends State<NewPackageForm> {
  final _formKey = GlobalKey<FormState>();
  final packageNameController = TextEditingController();
  final packageTypeController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final amountController = TextEditingController();
  String selectedClass = 'Infant';
  String selectedCurrency = 'PKR';
  List <String> currencies = ['PKR', '\$', '€', '¥','SAR','AED' ];
  final classes_  =<String> [ 'Infant', 'Toddler', 'Kinder Garten - I', 'Kinder Garten - II', 'Play Group - I'];


  // Initialize Firebase App
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp app = await Firebase.initializeApp();
    return app;
  }

  // Save form data to Firebase
  Future<void> _savePackage() async {
    if (_formKey.currentState!.validate()) {
      await _initializeFirebase();
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference packages = firestore.collection(accounts);

      await packages.add({
        'type': 'New Package',
        'packageName': packageNameController.text,
        'packageType': packageTypeController.text,
        'className': selectedClass,
        'startTime': startTimeController.text,
        'endTime': endTimeController.text,
        'amount': int.parse(amountController.text),
        'currency': selectedCurrency,
      });

      // Clear form after successful save
      _formKey.currentState!.reset();
      packageNameController.text = "";
      packageTypeController.text = "";
      selectedClass = "Infant";
      startTimeController.text = "";
      endTimeController.text = "";
      amountController.text = "";
      selectedCurrency = "PKR";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New package created successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kprimary, // Adjust based on primary color
        foregroundColor: Colors.white,
        title: Text(
          'Create New Package',
          style: TextStyle(fontSize: 14),
        ), systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Padding(
          padding: EdgeInsets.all(16.0), // Adjust padding for spacing
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: packageNameController,
                    decoration: InputDecoration(
                      labelText: 'Package Name',
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0), // Add padding
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a package name.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: packageTypeController,
                    decoration: InputDecoration(
                      labelText: 'Package Type (Enter like A1, A, B1, B etc.)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a class name.';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField(
                        value: selectedClass, // Replace with your initial selected currency
                        hint: Text('Select Class'),
                         items: classes_.map((String class_) {
                          return DropdownMenuItem<String>(
                            value: class_,
                            child: Text(class_),
                          );
                        }).toList(),
                        onChanged: (String? newClass) {
                          setState(() {
                            selectedClass = newClass!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a class.';
                          }
                          return null;
                        },
                      ),
                  Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () async {
                            final startTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (startTime != null) {
                              startTimeController.text = startTime.format(context);
                            }
                          },
                          child: TextFormField(
                            controller: startTimeController,
                            decoration: InputDecoration(
                              labelText: 'Start Time',
                              prefixIcon: Icon(Icons.access_time_rounded),
                            ),
                            enabled: false, // Disable text editing
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Flexible(
                        child: GestureDetector(
                          onTap: () async {
                            final endTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (endTime != null) {
                              endTimeController.text = endTime.format(context);
                            }
                          },
                          child: TextFormField(
                            controller: endTimeController,
                            decoration: InputDecoration(
                              labelText: 'End Time',
                              prefixIcon: Icon(Icons.access_time_rounded),
                            ),
                            enabled: false, // Disable text editing
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount.';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        width: 150,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField(
                            value: selectedCurrency, // Replace with your initial selected currency
                            hint: Text('Select Currency'),
                            items: currencies.map((String currency) {
                              return DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                            onChanged: (String? newCurrency) {
                              setState(() {
                                selectedCurrency = newCurrency!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a currency.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _savePackage,
                    child: Text('Create Package'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[100], // More muted teal for button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
