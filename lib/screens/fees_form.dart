import 'package:flutter/material.dart';

class FeesForm extends StatelessWidget {
  final bool isLoading;
  final TextEditingController childFullNameController;
  final TextEditingController registrationFeesController;
  final TextEditingController securityFeesController;
  final TextEditingController annualRecourceFeesController;
  final TextEditingController uniformFeesController;
  final TextEditingController admissionFormFeesController;
  final TextEditingController tuitionFeesController;
  final TextEditingController mealsFeesController;
  final TextEditingController lateSatFeesController;
  final TextEditingController fieldTripsFeesController;
  final TextEditingController afterSchoolFeesController;
  final TextEditingController dropIncareFeesController;
  final TextEditingController miscFeesController;
  final TextEditingController fathersEmailController;
  final Function(BuildContext) updateFeesEntryForm;

  FeesForm({
    required this.isLoading,
    required this.childFullNameController,
    required this.registrationFeesController,
    required this.securityFeesController,
    required this.annualRecourceFeesController,
    required this.uniformFeesController,
    required this.admissionFormFeesController,
    required this.tuitionFeesController,
    required this.mealsFeesController,
    required this.lateSatFeesController,
    required this.fieldTripsFeesController,
    required this.afterSchoolFeesController,
    required this.dropIncareFeesController,
    required this.miscFeesController,
    required this.fathersEmailController,
    required this.updateFeesEntryForm,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: childFullNameController,
            decoration: InputDecoration(labelText: 'Child Full Name'),
          ),
          TextField(
            controller: registrationFeesController,
            decoration: InputDecoration(labelText: 'Registration Fees'),
          ),
          TextField(
            controller: securityFeesController,
            decoration: InputDecoration(labelText: 'Security Fees'),
          ),
          TextField(
            controller: annualRecourceFeesController,
            decoration: InputDecoration(labelText: 'Annual Resource Fees'),
          ),
          TextField(
            controller: uniformFeesController,
            decoration: InputDecoration(labelText: 'Uniform Fees'),
          ),
          TextField(
            controller: admissionFormFeesController,
            decoration: InputDecoration(labelText: 'Admission Form Fees'),
          ),
          TextField(
            controller: tuitionFeesController,
            decoration: InputDecoration(labelText: 'Tuition Fees'),
          ),
          TextField(
            controller: mealsFeesController,
            decoration: InputDecoration(labelText: 'Meals Fees'),
          ),
          TextField(
            controller: lateSatFeesController,
            decoration: InputDecoration(labelText: 'Late Sat Fees'),
          ),
          TextField(
            controller: fieldTripsFeesController,
            decoration: InputDecoration(labelText: 'Field Trips Fees'),
          ),
          TextField(
            controller: afterSchoolFeesController,
            decoration: InputDecoration(labelText: 'After School Fees'),
          ),
          TextField(
            controller: dropIncareFeesController,
            decoration: InputDecoration(labelText: 'Drop In Care Fees'),
          ),
          TextField(
            controller: miscFeesController,
            decoration: InputDecoration(labelText: 'Miscellaneous Fees'),
          ),
          TextField(
            controller: fathersEmailController,
            decoration: InputDecoration(labelText: 'Father\'s Email'),
          ),
          ElevatedButton(
            onPressed: () => updateFeesEntryForm(context),
            child: isLoading ? CircularProgressIndicator() : Text('Update Fees'),
          ),
        ],
      ),
    );
  }
}
