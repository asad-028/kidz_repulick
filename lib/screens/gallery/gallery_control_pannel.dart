import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kids_republik/screens/gallery/image_view_screen.dart';

class GalleryControllPannelPage extends StatefulWidget {
  @override
  _GalleryControllPannelPageState createState() =>
      _GalleryControllPannelPageState();
}

class _GalleryControllPannelPageState extends State<GalleryControllPannelPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  int _from = 0;
  int _to = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Storage File List', style: TextStyle(fontSize: 14)),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('From:'),
              Container(
                width: 50,
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _from = int.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
              Text('To'),
              Container(
                width: 50,
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _to = int.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _from += 50;
                    _to += 50;
                  });
                },
                child: Text('Next'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _from -= 50;
                    _to -= 50;
                  });
                },
                child: Text('Previous'),
              ),
            ],
          ),
          Expanded(
            child: _buildFileList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchFileList(_from, _to),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Map<String, dynamic>> fileList = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Number of Files: ${fileList.length}'),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: fileList.length,
                  separatorBuilder: (context, index) {
                    // Check if the next item has a different date (assuming 'date' is in 'dd-mm-yyyy' format)
                    final currentDateFormat = fileList[index]['date'].toString().split(' ')[0];
                    final nextDateFormat = fileList[index + 1]['date'].toString().split(' ')[0];

                    if (currentDateFormat != nextDateFormat) {
                      return
                        Column(
                          children: [
                            Text('$currentDateFormat',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 12)),
                            Divider(),
                          ],
                        ); // You can customize the separator as needed
                    } else {
                      return SizedBox.shrink(); // Return an empty container if no separator is needed
                    }
                  },
                  itemBuilder: (context, index) {
                    final fileName = fileList[index]['name'];
                    final fileSize = fileList[index]['size'];
                    final fileSizeInKB = (fileSize / 1024).toStringAsFixed(2);
                    final fileDate = fileList[index]['date'];

                    return ListTile(
                      title:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${fileList[index]['date'].toString().split(' ')[0]}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                              ),
                            ),
                          SizedBox(height: 4), // Add some space between date and file info
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$fileName',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4), // Add some space between file name and size
                                Text(
                                  'Size: $fileSizeInKB KB',
                                  style: TextStyle(fontSize: 8),
                                ),
                                SizedBox(height: 4), // Add some space between size and activity data
                                // ...
                                // displayActivityData(fileList[index]['activities']),
                              ],
                            ),
                          ),
                        ],
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewScreen(
                              fileList: fileList,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchFileList(int from, int to) async {
    List<Map<String, dynamic>> fileList = [];

    try {
      ListResult result = await _storage.ref('images').list();

      int count = 0;
      await Future.forEach(result.items, (Reference ref) async {
        if (count >= from && count <= to) {
          final metadata = await ref.getMetadata();
          DateTime fileDate = metadata.timeCreated ?? DateTime.now();

          // QuerySnapshot<Map<String, dynamic>> activitySnapshot = await FirebaseFirestore.instance
          //     .collection('Activity')
          //     .where('image_', isEqualTo: ref.fullPath)
          //     .get();

          // List<Map<String, dynamic>> activities = activitySnapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
          //   Map<String, dynamic> data = doc.data()!;
          //   return data;
          // }).toList();
          checkFileActivityAssociation(ref.fullPath);

          fileList.add({
            'name': ref.name,
            'size': metadata.size,
            'date': fileDate,
            // 'activities': activities,
          });
        }
        count++;
      });

      fileList.sort((a, b) => b['date'].compareTo(a['date']));
    } catch (e) {
      print('Error fetching and sorting file list: $e');
    }

    return fileList;
  }

  // List<Widget> displayActivityData(List<Map<String, dynamic>> activityData) {
  //   List<Widget> widgets = [];
  //
  //   activityData.forEach((data) {
  //     String rowData =
  //         'Activity: ${data['Activity']}, Subject: ${data['Subject']}, Date: ${data['date_']}, Photo Status: ${data['photostatus_']}';
  //     widgets.add(Text(rowData));
  //   });
  //
  //   return widgets;
  // }
}

Future<void> checkFileActivityAssociation(String imagePath) async {
  try {
    // Get the reference to the image in Cloud Storage
    Reference imageRef = FirebaseStorage.instance.ref(imagePath);

    // Get the metadata of the image
    FullMetadata metadata = await imageRef.getMetadata();

    // Check if the image exists
    // Query the Activity collection for documents with matching image_
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('Activity')
        .where('image_', isEqualTo: imagePath)
        .get();

    // Print the results
    querySnapshot.docs.forEach((doc) {
      print('File $imagePath is associated with Activity: ${doc.data()}');
    });
    } catch (e) {
    print('Error: $e');
  }
}

