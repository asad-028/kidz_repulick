import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kids_republik/screens/gallery/image_view_screen.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
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
      future: fetchFileListWithSize(_from, _to),
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

  Future<List<Map<String, dynamic>>> fetchFileListWithSize(int from, int to) async {
    List<Map<String, dynamic>> fileList = [];

    try {
      ListResult result = await _storage.ref('images').list();

      // Fetch only the items within the specified range
      int count = 0;
      await Future.forEach(result.items, (Reference ref) async {
        if (count >= from && count <= to) {
          final metadata = await ref.getMetadata();
          DateTime fileDate = metadata.timeCreated ?? DateTime.now();

          fileList.add({
            'name': ref.name,
            'size': metadata.size,
            'date': fileDate,
          });
        }
        count++;
      });

      // Sort the list based on the date in descending order
      // fileList.sort((a, b) => b['date'].compareTo(a['date']));
    } catch (e) {
      print('Error fetching and sorting file list: $e');
    }

    return fileList;
  }
}
