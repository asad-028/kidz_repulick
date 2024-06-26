import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class GalleryManagementScreen extends StatefulWidget {
  GalleryManagementScreen({Key? key}) : super(key: key);

  @override
  State<GalleryManagementScreen> createState() =>
      _GalleryManagementScreenState();
}

class _GalleryManagementScreenState extends State<GalleryManagementScreen> {
  final CollectionReference _collectionReference = FirebaseFirestore.instance.collection('Activity');

  List<String> _imageUrls = [];
  List<String> _allImageUrls = [];
  List<String> _missingUrls = [];
  bool _deletionLoading = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot = await _collectionReference
          .where('photostatus_', whereIn: ['New', 'Approved', 'Forwarded'])
          .get();
      setState(() {
        _imageUrls = _extractImageUrls(querySnapshot);
        _isLoading = false;
      });

      // Fetch URLs from BabyData collection
      QuerySnapshot babyDataSnapshot = await FirebaseFirestore.instance.collection('BabyData').get();
      List<String> babyDataUrls = _extractBabyDataImageUrls(babyDataSnapshot);
      setState(() {
        _imageUrls.addAll(babyDataUrls);
      });

      // Show the count of fetched images in the app bar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_imageUrls.length} images are used in the Activity and BabyData records'),
        ),
      );
    } catch (error) {
      print('Error fetching images: $error');
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  List<String> _extractBabyDataImageUrls(QuerySnapshot snapshot) {
    List<String> urls = [];
    snapshot.docs.forEach((doc) {
      final babyData = doc.data() as Map<String, dynamic>;
      final imageUrl = babyData['picture'] as String?;
      if (imageUrl != null) {
        urls.add(imageUrl);
      }
    });
    return urls;
  }

  List<String> _extractImageUrls(QuerySnapshot snapshot) {
    List<String> urls = [];
    snapshot.docs.forEach((doc) {
      final activityData = doc.data() as Map<String, dynamic>;
      final imageUrl = activityData['image_'] as String?;
      if (imageUrl != null) {
        urls.add(imageUrl);
      }
    });
    return urls;
  }

  Future<void> _deleteUnusedFile(String fileUrl) async {
    try {
      // Parse the file path from the URL
      final Uri uri = Uri.parse(fileUrl);
      final filePath = uri.path;

      // Create a reference to the file in Firebase Storage
      final Reference fileRef = FirebaseStorage.instance.refFromURL(fileUrl);

      // Delete the file
      await fileRef.delete();

      print('File deleted successfully: $filePath');

      // Remove the deleted URL from the appropriate lists
      setState(() {
        _allImageUrls.remove(fileUrl);
        _imageUrls.remove(fileUrl);
        _missingUrls.remove(fileUrl);
      });
    } catch (error) {
      print('Error deleting file: $error');
      // Handle error
    }
  }

  Future<void> _handleShowAllImages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch the list of files in the "images" folder in Firebase Storage
      ListResult result = await FirebaseStorage.instance.ref('images').listAll();
      List<String> allImageUrls = [];
      for (Reference ref in result.items) {
        String downloadURL = await ref.getDownloadURL();
        allImageUrls.add(downloadURL);
      }
      setState(() {
        _allImageUrls = allImageUrls;
        _isLoading = false;
      });

      // Identify and process missing URLs
      await identifyActivityImages(_imageUrls, _allImageUrls);

      // Show the count of images fetched in the app bar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${allImageUrls.length} images stored in Storage'),
        ),
      );
    } catch (error) {
      print('Error fetching all images: $error');
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> identifyActivityImages( List<String> storageUrls,List<String> firestoreUrls) async {
    // Identify images in Activity collection but not in Firebase Storage
    List<String> missingUrls = [];
    for (String url in firestoreUrls) {
      if (!storageUrls.contains(url)) {
        missingUrls.add(url);
      }
    }

    setState(() {
      _missingUrls = missingUrls;
    });

    // Show the count of missing images in the app bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${missingUrls.length} unused image(s), out of ${_allImageUrls.length}'),
      ),
    );
  }

  Widget _buildBody() {
    List<String> displayUrls = _missingUrls.isNotEmpty
        ? _missingUrls
        : (_allImageUrls.isNotEmpty ? _allImageUrls : _imageUrls);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _missingUrls.isNotEmpty
                ? 'Unused Images'
                : (_allImageUrls.isNotEmpty ? 'All Images' : 'Activity Images'),
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: displayUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = displayUrls[index];
              return ListTile(
                title: Text(imageUrl),
                trailing: IconButton(
                  icon: _deletionLoading
                      ? CircularProgressIndicator()
                      : Icon(Icons.delete),
                  onPressed: () async {
                    bool confirmDelete = await confirm(context,
                        title: Text('Confirm'),
                        content: Text(
                            'Are you sure you want to delete this image?'));
                    if (confirmDelete) {
                      setState(() {
                        _deletionLoading = true;
                      });
                      await _deleteUnusedFile(imageUrl);
                      setState(() {
                        _deletionLoading = false;
                        // Update displayUrls after deletion
                        displayUrls.remove(imageUrl);
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showMissingImages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch the list of files in the "images" folder in Firebase Storage
      ListResult result = await FirebaseStorage.instance.ref('images').listAll();
      List<String> storageUrls = [];
      for (Reference ref in result.items) {
        String downloadURL = await ref.getDownloadURL();
        storageUrls.add(downloadURL);
      }

      // Identify and process missing URLs
      await identifyActivityImages(_imageUrls, storageUrls);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching missing images: $error');
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gallery Management',
          style: TextStyle(fontSize: 12), // Set font size to 12
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _handleShowAllImages,
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showMissingImages,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
