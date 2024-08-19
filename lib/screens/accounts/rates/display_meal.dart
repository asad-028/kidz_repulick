import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'meals_form.dart';
import 'package:kids_republik/main.dart';

class DisplayMealScreen extends StatefulWidget {
  @override
  _DisplayMealScreenState createState() => _DisplayMealScreenState();
}

class _DisplayMealScreenState extends State<DisplayMealScreen> {
  final CollectionReference meals = FirebaseFirestore.instance.collection(accounts);
  String selectedCurrency = 'PKR';
  List <String> currencies = ['PKR', '\$', '€', '¥','SAR','AED' ];

  // Get all meals (consider pagination for large datasets)
  Future<List<Meal>> getMeals() async {
    List<Meal> mealsList = [];
    QuerySnapshot snapshot = await meals.where('type', isEqualTo: 'Meals').get();
    for (var doc in snapshot.docs) {
      mealsList.add(Meal(
        id: doc.id,
        mealName: doc['mealName'] as String,
        mealFor: doc['mealFor'] as String,
        mealPrice: doc['mealPrice'].toString(),
        currency: doc['currency'],
      ));
    }
    return mealsList;
  }

  // Get a specific meal by ID
  Future<Meal?> getMeal(String mealId) async {
    DocumentSnapshot snapshot = await meals.doc(mealId).get();
    if (snapshot.exists) {
      return Meal(
          id: snapshot.id,
          mealName: snapshot['mealName'] as String,
          mealFor: snapshot['mealFor'] as String,
          mealPrice: snapshot['mealPrice'].toString(),
        currency: snapshot['currency'],

    );
    } else {
    return null;
    }
  }

  // Update a meal
  Future<void> updateMeal(String mealId, String newMealName, String newMealFor, int newMealPrice, currency) async {
    await meals.doc(mealId).update({
      'mealName': newMealName,
      'mealFor': newMealFor,
      'mealPrice': newMealPrice,
      'currency': currency,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(child: Text('+',style: TextStyle(fontSize: 24),),onPressed: () {Get.to(NewMealForm()); },),
      body: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
          child: Column(
            children: [
            Text(
            'Meals',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]), // Adjusted font size and primary color
          ),
          Divider(
            height: 1,
            color: Colors.grey[400],
          ),
          Row(
            children: [
              Text('Meal Name', style: TextStyle(fontSize: 12)),
              Spacer(),
              Text("Meal For", style: TextStyle(fontSize: 12)),
              Spacer(),
              Text('Meal Price', style: TextStyle(fontSize: 12)),
              Spacer(),
              Text('Action', style: TextStyle(fontSize: 12)),
            ],
          ),
          Divider(
            height: 1,
            color: Colors.grey[400],
          ),

          // Display existing meals
          FutureBuilder<List<Meal>>(
          future: getMeals(),
      builder: (context, snapshot) {
      if (snapshot.hasError) {
      return Text('Error: {snapshot.error}');
      }
      if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator()); // Loading indicator
      }
      final meals = snapshot.data!;
      return Expanded(
      child: ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: meals.length,
      itemBuilder: (context, index) {
      final meal = meals[index];
      return Dismissible( // Enable swipe to dismiss for delete
      key: Key(meal.id),
      confirmDismiss: (direction) => confirm(context, content: Text('Are you sure you want to delete this meal?')),
      onDismissed: (direction) => deleteMeal(meal.id),
      child: ListTile(
      title: Row(
      children: [
      Text(meal.mealName, style: TextStyle(fontSize: 12)),
      Spacer(),
      Text(meal.mealFor, style: TextStyle(fontSize: 12)),
      Spacer(),
      Text('${meal.mealPrice.toString()} ${meal.currency}', style: TextStyle(fontSize: 12)),
      ],
      ),
      trailing: Row(
      mainAxisSize: MainAxisSize.min, // Center icons horizontally
        children: [
        IconButton(
        icon: Icon(Icons.edit, color: Colors.blue[900], size: 18), // Use primary color for icon
        onPressed: () => editMeal(meal.id),
        ),
        ],
        ),
        ),
        );
        },
        ),
        );
      },
          ),
            ],
          ),
      ),
    );
  }

  void editMeal(String mealId) async {
    // Get the meal details to pre-populate the form
    final meal = await getMeal(mealId);
    if (meal == null) {
      return; // Handle error if meal not found
    }

    // Form controllers for user input
    final _mealNameController = TextEditingController(text: meal.mealName);
    final _mealForController = TextEditingController(text: meal.mealFor);
    final _mealPriceController = TextEditingController(text: meal.mealPrice.toString());
    final _currencyController = TextEditingController(text: meal.currency);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow form to scroll if content overflows
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content vertically
          children: [
            Text('Edit Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _mealNameController,
              decoration: InputDecoration(labelText: 'Meal Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _mealForController,
              decoration: InputDecoration(labelText: 'Meal For'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _mealPriceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true), // Allow decimal input
              decoration: InputDecoration(labelText: 'Meal Price'),
            ),
            Row(
              children: [
                Container(
                    width: 180,
                    child:TextField(
                      controller: _mealPriceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Amount',border: InputBorder.none),
                    )),
                SizedBox(width: 10),
                Container(
                  width: 150,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField(
                      value: selectedCurrency, // Replace with your initial selected currency
                      // hint: Text('Select Currency'),
                      decoration: InputDecoration(labelText: 'Select Currency',border: InputBorder.none),
                      items: currencies.map((String currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (String? newCurrency) {
                        setState(() {
                          selectedCurrency = newCurrency!;
                          _currencyController.text = selectedCurrency;
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

            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final newMealName = _mealNameController.text;
                    final newMealFor = _mealForController.text;
                    final newMealPrice = int.parse(_mealPriceController.text);
                    final currency = _currencyController.text;
                    await updateMeal(mealId, newMealName, newMealFor, newMealPrice,currency);
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void deleteMeal(String mealId) async {
    await confirm(context, content: Text('Are you sure you want to delete this meal?'));
    await meals.doc(mealId).delete();
  }
}

class Meal {
  final String id;
  final String mealName;
  final String mealFor;
  final String mealPrice;
  final String currency;

  Meal({
    required this.id,
    required this.mealName,
    required this.mealFor,
    required this.mealPrice,
    required this.currency,
  });
}
