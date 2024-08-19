import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class UpdateActivityForm extends StatefulWidget {
  final String babyID;

  UpdateActivityForm({required this.babyID});

  @override
  _UpdateActivityFormState createState() => _UpdateActivityFormState();
}

class _UpdateActivityFormState extends State<UpdateActivityForm> {
  final _formKey = GlobalKey<FormState>();
  String selectedDateRange = '';
  int checkedInCount = 0;
  int absentCount = 0;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: selectedDateRange,
            onChanged: (newValue) {
              setState(() {
                selectedDateRange = newValue!;
              });
            },
            items: [], // Populate with available date ranges
            decoration: InputDecoration(labelText: 'Select Date Range'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date range';
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: checkedInCount.toString(),
            decoration: InputDecoration(labelText: 'Checked In Count'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid count';
              }
              return null;
            },
            onSaved: (newValue) {
              checkedInCount = int.parse(newValue!);
            },
          ),
          TextFormField(
            initialValue: absentCount.toString(),
            decoration: InputDecoration(labelText: 'Absent Count'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid count';
              }
              return null;
            },
            onSaved: (newValue) {
              absentCount = int.parse(newValue!);
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Call a method to update Firestore with the new data
                updateActivityData(selectedDateRange, checkedInCount, absentCount);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void updateActivityData(String dateRange, int checkedIn, int absent) {
    FirebaseFirestore.instance.collection(Activity)
        .where('child', isEqualTo: widget.babyID)
        .where('dateRange', isEqualTo: dateRange)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({
          'checkedin': checkedIn,
          'absent': absent,
        });
      });
    });
  }
}
