import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class OrphanedImageDeletionScreen extends StatelessWidget {
  final CollectionReference _collectionReference =
  FirebaseFirestore.instance.collection('Activity');

  final Reference _storageReference =
  FirebaseStorage.instance.ref('image'); // Reference to your Firebase Storage "image" folder

  Future<void> deleteOrphanedFiles(BuildContext context) async {
    try {
      // Retrieve list of files in Firebase Storage "image" folder
      ListResult listResult = await _storageReference.listAll();
      List<String> storageFileNames = listResult.items.map((item) => item.name).toList();

      // Retrieve list of image URLs from Firestore collection
      QuerySnapshot querySnapshot = await _collectionReference
          .where('photostatus_', whereIn: ['New', 'Forwarded', 'Approved'])
          .get();
      List<String> firestoreImageUrls = [];
      querySnapshot.docs.forEach((doc) {
        final Map<String, dynamic>? data =
        doc.data() as Map<String, dynamic>?; // Explicit type cast
        if (data != null) {
          final imageUrl = data['image_'] as String?;
          if (imageUrl != null) {
            firestoreImageUrls.add(imageUrl);
          }
        }
      });

      // Identify orphaned files (files in Firebase Storage that don't have corresponding URLs in Firestore)
      List<String> orphanedFiles = storageFileNames
          .where((fileName) => !firestoreImageUrls.contains(fileName))
          .toList();

      // Delete orphaned files from Firebase Storage one by one
      for (String fileName in orphanedFiles) {
        await _storageReference.child(fileName).delete();
        // Show success message for each file deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File $fileName deleted successfully.'),
          ),
        );
      }

      // Show overall success message after all files are deleted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orphaned files deleted successfully.'),
        ),
      );
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting orphaned files: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orphaned Image Deletion'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => deleteOrphanedFiles(context),
          child: Text('Delete Orphaned Files'),
        ),
      ),
    );
  }
}
