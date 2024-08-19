import 'package:kids_republik/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:kids_republik/utils/const.dart';

class NewMealForm extends StatefulWidget {
  @override
  _NewMealFormState createState() => _NewMealFormState();
}

class _NewMealFormState extends State<NewMealForm> {
  final _formKey = GlobalKey<FormState>();
  final mealNameController = TextEditingController();
  final mealPriceController = TextEditingController();
  String selectedMealFor = 'Regular';
  final List<String> mealOptions = ['Regular', 'Saturday'];
  String selectedCurrency = 'PKR';
  List<String> currencies = ['PKR', '\$', '€', '¥', 'SAR', 'AED'];

  // Initialize Firebase App
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp app = await Firebase.initializeApp();
    return app;
  }

  // Save form data to Firebase
  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      await _initializeFirebase();
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference meals = firestore.collection(accounts);

      await meals.add({
        'type': 'Meals',
        'mealName': mealNameController.text,
        'mealFor': selectedMealFor,
        'currency': selectedCurrency,
        'mealPrice': double.parse(mealPriceController.text),
      });

      // Clear form after successful save
      _formKey.currentState!.reset();
      mealNameController.text = "";
      selectedMealFor = 'Regular';
      mealPriceController.text = "";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New meal created successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kprimary, // Vibrant Orange
          foregroundColor: Colors.white,
          title: const Text(
            'Create New Meal',
            style: TextStyle(fontSize: 14),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Padding(
        padding: const EdgeInsets.all(20.0),
    child: Form(
    key: _formKey,
    child: SingleChildScrollView(
    child: Column(
    children: [
    TextFormField(
    controller: mealNameController,
    decoration: InputDecoration(
    labelText: 'Meal Name',
    contentPadding: EdgeInsets.symmetric(vertical: 12.0),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(color: Colors.grey),
    ),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter a meal name.';
    }
    return null;
    },
    ),
    SizedBox(height: 10.0),
    DropdownButtonFormField(
    value: selectedMealFor,
    decoration: InputDecoration(
    labelText: "Meal for",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(color: Colors.grey),
    ),
    ),
    items: mealOptions.map((String option) {
    return DropdownMenuItem<String>(
    value: option,
    child: Text(option),
    );
    }).toList(),
    onChanged: (String? newOption) {
    setState(() {
    selectedMealFor = newOption!;
    });
    },
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please select a meal option.';
    }
    return null;
    },
    ),
    SizedBox(height: 10.0),
    Row(
    children: [
    Container(
    width: MediaQuery.of(context).size.width * 0.450,
    child: TextFormField(

      controller: mealPriceController,
      decoration: InputDecoration(
        labelText: 'Meal Price',
        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        prefixIcon: Text(selectedCurrency), // Vibrant Orange icon
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a meal price.';
        }
        return null;
      },
    ),),
      Container(
        width: 150,
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField(
            value: selectedCurrency,
            decoration: InputDecoration(
              labelText: "Select Currency",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
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
        onPressed: _saveMeal,
        child: Text('Create Meal',style: TextStyle(color: Colors.white),),
        style: ElevatedButton.styleFrom(
          backgroundColor: kprimary, // Vibrant Orange button
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
    );
  }
}

