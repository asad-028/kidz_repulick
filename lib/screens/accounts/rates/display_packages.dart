import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/accounts/rates/package_form.dart';
import 'package:kids_republik/main.dart';

class DisplayPackagesScreen extends StatefulWidget {
  @override
  _DisplayPackagesScreenState createState() => _DisplayPackagesScreenState();
}

class _DisplayPackagesScreenState extends State<DisplayPackagesScreen> {
  final CollectionReference packages = FirebaseFirestore.instance.collection(accounts);
  String selectedClass = 'Infant';
  String selectedCurrency = 'PKR';
  List <String> currencies = ['PKR', '\$', '€', '¥','SAR','AED' ];
  final classes_  =<String> [ 'Infant', 'Toddler', 'Kinder Garten - I', 'Kinder Garten - II', 'Play Group - I'];

  // Get all packages (consider pagination for large datasets)
  Future<List<Package>> getPackages() async {
    List<Package> packagesList = [];
    QuerySnapshot snapshot = await packages.where('type', isEqualTo: 'New Package').get();
    for (var doc in snapshot.docs) {
      packagesList.add(Package(
        id: doc.id,
        packageName: doc['packageName'] as String,
        packageType: doc['packageType'] as String,
        className: doc['className'] as String,
        startTime: doc['startTime'] as String,
        endTime: doc['endTime'] as String,
        amount: doc['amount'].toString() ,
        currency: doc['currency'] as String,
      ));
    }
    return packagesList;
  }

  // Get a specific package by ID
  Future<Package?> getPackage(String packageId) async {
    DocumentSnapshot snapshot = await packages.doc(packageId).get();
    if (snapshot.exists) {
      return Package(
        id: snapshot.id,
        packageName: snapshot['packageName'] as String,
        packageType: snapshot['packageType'] as String,
        className: snapshot['className'] as String,
        startTime: snapshot['startTime'] as String,
        endTime: snapshot['endTime'] as String,
        amount: snapshot['amount'].toString() ,
        currency: snapshot['currency'] as String,
      );
    } else {
      return null;
    }
  }

  // Update a package
  Future<void> updatePackage(String packageId, String newPackageName, String newPackageType, String newClassName, String newStartTime, String newEndTime, int newAmount, String newCurrency) async {
    await packages.doc(packageId).update({
      'packageName': newPackageName,
      'packageType': newPackageType,
      'className': newClassName,
      'startTime': newStartTime,
      'endTime': newEndTime,
      'amount': newAmount,
      'currency': newCurrency,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[200], // Changed background color
      floatingActionButton: FloatingActionButton(child: Text('+',style: TextStyle(fontSize: 24),),onPressed: () { Get.to(NewPackageForm()); },),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
        child: Column(
          children: [
            Text(
              'Packages',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[900]),
            ),
            Divider(height: 1, color: Colors.blue[400],),
            Row(
              children: [
                Spacer(),
                Text('Class', style: TextStyle(fontSize: 12)),
                Spacer(),
                Text('Start Time', style: TextStyle(fontSize: 12)),
                Spacer(),
                Text('End Time', style: TextStyle(fontSize: 12)),
                Spacer(),
                Text('Amount', style: TextStyle(fontSize: 12)),
                Spacer(),
                Text('Edit', style: TextStyle(fontSize: 12)),
                Spacer(),
              ],
            ),
            Divider(height: 1, color: Colors.blue[400],),

            // Display existing packages
            FutureBuilder<List<Package>>(
              future: getPackages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final packages = snapshot.data !;
                return Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return
                        Dismissible(
                        key: Key(package.id),
                        confirmDismiss: (direction) => confirm(context, content: Text('Are you sure you want to delete this package?')),
                        onDismissed: (direction) => deletePackage(package.id),
                        child: ListTile(
                          title: Column(
                            children: [
                              Row(
                                children: [
                                  Text("${package.packageName} - ${package.packageType}", style: TextStyle(fontSize: 12,color: Colors.blue[900],fontWeight: FontWeight.bold)),
                                  Spacer(),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(package.className, style: TextStyle(fontSize: 10)),
                                  Spacer(),
                                  Text(package.startTime, style: TextStyle(fontSize: 10)),
                                  Spacer(),
                                  Text(package.endTime, style: TextStyle(fontSize: 10)),
                                  Spacer(),
                                  Text('${package.amount} ${package.currency}', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                              Divider(height: 1, color: Colors.blue[200],),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue[900], size: 18),
                            onPressed: () => editPackage(package.id),
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

  void editPackage(String packageId) async {
    // Get the package details to pre-populate the form
    final package = await getPackage(packageId);
    if (package == null) {
      return; // Handle error if package not found
    }

    // Form controllers for user input
    final _packageNameController = TextEditingController(text: package.packageName);
    final _packageTypeController = TextEditingController(text: package.packageType);
    final _classNameController = TextEditingController(text: package.className);
    final _startTimeController = TextEditingController(text: package.startTime);
    final _endTimeController = TextEditingController(text: package.endTime);
    final _amountController = TextEditingController(text: package.amount.toString());
    final _currencyController = TextEditingController(text: package.currency);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Package', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.blue[900])),
            SizedBox(height: 10),
            TextField(
              controller: _packageNameController,
              decoration: InputDecoration(labelText: 'Package Name',border: InputBorder.none),
            ),
            Divider(color: Colors.blue[300],),

            // SizedBox(height: 10),
            TextField(
              controller: _packageTypeController,
              decoration: InputDecoration(labelText: 'Package Type',border: InputBorder.none),
            ),
            Divider(color: Colors.blue[300],),
            // SizedBox(height: 10),
            Row(
              children: [
                Container(
                    width: 160,
                    child:DropdownButtonFormField(
                  value: selectedClass, // Replace with your initial selected currency
                  hint: Text('Select Class'),
                  items: classes_.map((String class_) {
                    return DropdownMenuItem<String>(
                      value: class_,
                      child: Text(class_),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: "Select Class",     border: InputBorder.none,),
                  onChanged: (String? newClass) {
                    setState(() {
                      selectedClass = newClass!;
                      _classNameController.text = selectedClass;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a class.';
                    }
                    return null;
                  },
                )),
                SizedBox(width: 30),
                Container(
                  width: 150,
                  child:TextField(
                  controller: _classNameController,
                  decoration: InputDecoration(labelText: "Class Name",     border: InputBorder.none,),

                  // decoration: InputDecoration(labelText: 'Class Name'),
                )),
              ],
            ),
            Divider(color: Colors.blue[300],),
            Row(
              children: [
                Container(
                  width: 150,
                  child:TextField(
                  controller: _startTimeController,
                  decoration: InputDecoration(labelText: 'Start Time',border: InputBorder.none),
                )),
                SizedBox(width: 30),
                Container(
                  width: 150,
                  child:TextField(
                  controller: _endTimeController,
                  decoration: InputDecoration(labelText: 'End Time',border: InputBorder.none),
                )),
              ],
            ),
            // SizedBox(height: 10),
            Divider(color: Colors.blue[300],),
            Row(
              children: [
                Container(
                    width: 180,
                    child:TextField(
                      controller: _amountController,
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
            Divider(color: Colors.blue[300],),
            // TextField(
            //   controller: _currencyController,
            //   decoration: InputDecoration(labelText: 'Currency'),
            // ),
            // SizedBox(height: 10),
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
                    final newPackageName = _packageNameController.text;
                    final newPackageType = _packageTypeController.text;
                    final newClassName = _classNameController.text;
                    final newStartTime = _startTimeController.text;
                    final newEndTime = _endTimeController.text;
                    final newAmount = int.parse(_amountController.text);
                    final newCurrency = _currencyController.text;
                    await updatePackage(packageId, newPackageName, newPackageType, newClassName, newStartTime, newEndTime, newAmount, newCurrency);
                    Navigator.pop(context);
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

  void deletePackage(String packageId) async {
    await confirm(context, content: Text('Are you sure you want to delete this package?'));
    await packages.doc(packageId).delete();
  }
}

class Package {
  final String id;
  final String packageName;
  final String packageType;
  final String className;
  final String startTime;
  final String endTime;
  final String amount;
  final String currency;

  Package({
    required this.id,
    required this.packageName,
    required this.packageType,
    required this.className,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.currency,
  });
}
