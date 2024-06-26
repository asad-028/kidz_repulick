import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/gallery/zoomable_image.dart';

class ImageViewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> fileList;
  final int initialIndex;

  const ImageViewScreen({
    required this.fileList,
    required this.initialIndex,
  });

  @override
  _ImageViewScreenState createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void nextImage() {
    if (currentIndex < widget.fileList.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void previousImage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  Future<void> confirmAndDeleteImage() async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User doesn't want to delete
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      deleteImage();
    }
  }

  void deleteImage() async {
    final storageRef = FirebaseStorage.instance.ref('images/${widget.fileList[currentIndex]['name']}');

    try {
      await storageRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Image deleted successfully'),
      ));

      // Navigate to the next image if it exists, or to the previous image if there is no next image
      if (currentIndex < widget.fileList.length - 1) {
        nextImage();
      } else if (currentIndex > 0) {
        previousImage();
      } else {
        // No more images, pop the screen
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error deleting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting image'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Image View'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'File: ${widget.fileList[currentIndex]['name']}',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Size: ${(widget.fileList[currentIndex]['size'] / 1024).toStringAsFixed(3)} KB',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
      InkWell(
        onTap:()
        {
          Get.to(ZoomableImageView(imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/kids-republik-e8265.appspot.com/o/images%2F${widget.fileList[currentIndex]['name']}?alt=media',
          ));
        },
        child: Container(
          height: mQ.height*0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Adjust the value as needed
            boxShadow: [
              BoxShadow(
                color: Colors.transparent, // Add your desired shadow color
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2), // Offset of the shadow
              ),
            ],
          ),
          child: CachedNetworkImage(
            imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/kids-republik-e8265.appspot.com/o/images%2F${widget.fileList[currentIndex]['name']}?alt=media',
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: previousImage,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {
                    confirmAndDeleteImage();
                  },
                  child: Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: nextImage,
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
