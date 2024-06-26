import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseStorageList extends StatefulWidget {
  @override
  _FirebaseStorageListState createState() => _FirebaseStorageListState();
}

class _FirebaseStorageListState extends State<FirebaseStorageList> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<String> fileNames = [];

  @override
  void initState() {
    super.initState();
    listFilesInJanuary2024();
  }

  Future<void> listFilesInJanuary2024() async {
    try {
      // Reference to the root directory
      // ListResult result = await _storage.ref('images').list();

      Reference reference = storage.ref('images');

      // List all items in the root directory
      ListResult result = await reference.listAll();

      setState(() {
        // Extract file names from the list result
        fileNames = result.items
            .map((item) => item.name)
            .where((name) => name.contains('2024-01'))
            .toList();
      });
    } catch (e) {
      print('Error listing files: $e');
      // Handle error here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Storage Files - Jan 2024',style: TextStyle(fontSize: 14),),
      ),
      body: ListView.builder(
        itemCount: fileNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(fileNames[index]),
          );
        },
      ),
    );
  }
}

