import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

var saveurl;

class ZoomableImageGallery extends StatefulWidget {
  final List<Map<String, dynamic>> imageUrls;
  final int initialIndex;

  ZoomableImageGallery({required this.imageUrls, required this.initialIndex});

  @override
  _ZoomableImageGalleryState createState() => _ZoomableImageGalleryState();
}

class _ZoomableImageGalleryState extends State<ZoomableImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> saveImageToGallery(BuildContext context, String imageUrl,
      String subfoldername, String filename) async {
    try {
      // Check for storage permission
      var status = await Permission.storage.status;
      AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;

      // For Android 11 and above
      if (build.version.sdkInt >= 30) {
        var re = await Permission.manageExternalStorage.request();
        if (re.isGranted) {
          await _saveImage(context, imageUrl, subfoldername, filename);
        } else {
          _showPermissionError(context, status);
        }
      } else {
        // For Android 10 and below
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        if (status.isGranted) {
          await _saveImage(context, imageUrl, subfoldername, filename);
        } else {
          _showPermissionError(context, status);
        }
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  Future<void> _saveImage(BuildContext context, String imageUrl,
      String subfoldername, String filename) async {
    try {
      // Fetch the image from the network
      var response = await http.get(Uri.parse(imageUrl));
      final imageSaver = ImageGallerySaver();
      if (response.statusCode == 200) {
        // Save image to gallery
        final result = await imageSaver.saveImage(
          response.bodyBytes,
          // name: "$subfoldername/$filename",
          // isReturnImagePathOfIOS: true,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download image.'),
          ),
        );
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  void _showPermissionError(BuildContext context, PermissionStatus status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue,
        content: Text(
          'Storage permission is required to save images. \n error: $status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Future<void> saveImageToGallery(BuildContext context, String imageUrl, String subfoldername, String filename) async {
  //   try {
  //   var status = await Permission.storage.status;
  //     AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
  //     if (build.version.sdkInt >= 30) {
  //       var re = await Permission.manageExternalStorage.request();
  //       if (re.isGranted) {
  //         _saveImage(context, imageUrl, subfoldername, filename);
  //         // saveImageToGallery(context, imageUrl, subfoldername, filename);
  //       }
  //     } else {
  //       if (!status.isGranted) {
  //         status = await Permission.storage.request();
  //       }
  //
  //       if (status.isGranted) {
  //         _saveImage(context, imageUrl, subfoldername, filename);
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             backgroundColor: Colors.blue,
  //             content: Text(
  //               'Storage permission is required to save images. \n error: $status',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 12,
  //               ),
  //             ),
  //             duration: Duration(seconds: 3),
  //           ),
  //         );
  //       }
  //     }} catch (e) {
  //     print(e); // Error handling code...
  //   }
  // }

  // Future<void> _saveImage(BuildContext context, String imageUrl, String subfoldername, String filename) async {
  //   try {
  //     // Request permission to access external storage
  //     var status = await Permission.storage.request();
  //     if (!status.isGranted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.blue,
  //           content: Text(
  //             'Permission denied to access external storage',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 12,
  //             ),
  //           ),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     // Get the directory using the Storage Access Framework
  //     final directory = await getExternalStorageDirectory();
  //     if (directory == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.blue,
  //           content: Text(
  //             'Error saving image: Directory not found',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 12,
  //             ),
  //           ),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     // Continue with folder creation and image saving...
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.blue,
  //         content: Text(
  //           'Error saving image: $e',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 12,
  //           ),
  //         ),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //     print('Error saving image: $e');
  //   }
  // }

  // Future<void> _saveImage(BuildContext context, String imageUrl, String subfoldername, String filename) async {
  //   try {
  //     final directory = await getExternalStorageDirectory();
  //     if (directory == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.blue,
  //           content: Text(
  //             'Error saving image: Directory not found',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 12,
  //             ),
  //           ),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     final parentDirectory = directory.parent.parent.parent.parent;
  //     final folderPath = '${parentDirectory.path}/krdc/$subfoldername';
  //     final imagePath = '$folderPath/$filename.jpg';
  //     final imageFile = File(imagePath);
  //
  //     if (await imageFile.exists()) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.blue,
  //           content: Text(
  //             'The image has already been saved to your gallery.',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 12,
  //             ),
  //           ),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     final response = await http.get(Uri.parse(imageUrl));
  //     if (response.statusCode == 200) {
  //       final folder1 = Directory('${parentDirectory.path}/krdc');
  //       if (!await folder1.exists()) {
  //         await folder1.create(recursive: true);
  //       }
  //
  //       final folder = Directory(folderPath);
  //       if (!await folder.exists()) {
  //         await folder.create(recursive: true);
  //       }
  //
  //       final imageBytes = response.bodyBytes;
  //       await imageFile.writeAsBytes(imageBytes);
  //
  //       final savedFile = await GallerySaver.saveImage(imagePath);
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.blue,
  //           content: Text(
  //             'The image has been saved to your gallery. $savedFile ',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 12,
  //             ),
  //           ),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.blue,
  //           content: Text(
  //             'Failed to fetch image from URL: ${response.statusCode}',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 12,
  //             ),
  //           ),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //       print('Failed to fetch image from URL: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.blue,
  //         content: Text('Error saving image: $e', style: TextStyle(color: Colors.white, fontSize: 12,),),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //     print('Error saving image: $e');
  //   }
  // }

  void nextImage() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                    widget.imageUrls[index]['image_']),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              // saveImageToGallery(context, widget.imageUrls[_currentIndex]['image_'],'${widget.imageUrls[_currentIndex]['childFullName']}','${widget.imageUrls[_currentIndex]['date_']} - ${widget.imageUrls[_currentIndex]['Activity']} - $_currentIndex');
              setState(() {
                _currentIndex = index;
                saveurl = widget.imageUrls[index]['image_'];
              });
            },
          ),

          // role_ == 'Parent' ? Positioned(
          //   bottom: 16,
          //   right: 16,
          //   child: FloatingActionButton(
          //     backgroundColor: Colors.transparent,
          //     onPressed: () => saveImageToGallery(
          //         context,
          //         widget.imageUrls[_currentIndex]['image_'],
          //         '${widget.imageUrls[_currentIndex]['childFullName']}',
          //         '${widget.imageUrls[_currentIndex]['date_']} - ${widget.imageUrls[_currentIndex]['Activity']} - $_currentIndex'
          //     ),
          //     child: Icon(Icons.file_download_sharp, color: Colors.white,),
          //   ),
          // ) : Container(),
// role_=='Parent'?Positioned(
          //   bottom: 16,
          //   right: 16,
          //   child: FloatingActionButton(
          //     backgroundColor: Colors.transparent,
          //     onPressed: () =>
          //         saveImageToGallery(context, widget.imageUrls[_currentIndex]['image_'],'${widget.imageUrls[_currentIndex]['childFullName']}','${widget.imageUrls[_currentIndex]['date_']} - ${widget.imageUrls[_currentIndex]['Activity']} - $_currentIndex'),
          //     child: Icon(Icons.file_download_sharp,color: Colors.white,),
          //   ),
          // ):Container(),
        ],
      ),
    );
  }
}

class ZoomableImage extends StatelessWidget {
  final String imageUrl;
  ZoomableImage({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZoomableImageView(imageUrl: imageUrl),
          ),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.indigo.shade100,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              spreadRadius: 0.7,
              blurRadius: 0.9,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: MediaQuery.of(context).size.width * 0.7,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}

class ZoomableImageView extends StatelessWidget {
  final String imageUrl;
  ZoomableImageView({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}
