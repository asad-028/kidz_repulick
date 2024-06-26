import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:kids_republik/main.dart';

import 'login.dart';

final user = FirebaseAuth.instance.currentUser;

Future<bool> deleteUserData() async {
  try {
    if (user == null) return false;

    // Deleting the document with the user's email
    final userDocRefByEmail = FirebaseFirestore.instance.collection('users').doc(user!.email);
    await userDocRefByEmail.delete();

    // Deleting the user from Firebase Authentication
    await user!.delete();
    return true;
  } catch (e) {
    print('Error deleting user data: $e');
    return false;
  }
}

class DataDeletionPage extends StatefulWidget {
  const DataDeletionPage({Key? key}) : super(key: key);

  @override
  State<DataDeletionPage> createState() => _DataDeletionPageState();
}

class _DataDeletionPageState extends State<DataDeletionPage> {
  bool _isLoading = false;

  Future<void> _handleDataDeletion() async {
    bool confirmDeletion = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to permanently delete all your data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (!confirmDeletion) return;

    setState(() {
      _isLoading = true;
    });

    bool deletionSuccess = await deleteUserData();

    setState(() {
      _isLoading = false;
    });

    if (deletionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your data has been deleted successfully.'),
        ),
      );
      useremail = '';
      teachersClass_ = '';
      role_ = '';
      signOut();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while deleting data. Please try again later.'),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Deletion'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.account_circle),
                  Text('${user!.uid}'),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.email),
                  Text('${user!.email}'),
                ],
              ),
              SizedBox(height: 20),
              Spacer(),
              Text(
                'This action will permanently delete all your data from this device and our servers.',
                style: TextStyle(fontSize: 16, color: Colors.red[800], fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleDataDeletion,
                child: _isLoading ? CircularProgressIndicator() : Text('Delete Data'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Navigate to the login screen or any other screen you desire
      Get.offAll(LoginScreen());
    } catch (e) {
      print("Error logging out: $e");
    }
  }

}

