import 'package:get/get.dart';
import 'package:kids_republik/screens/main_tabs.dart';
import 'package:kids_republik/screens/widgets/base_drawer.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CampusSelectionScreen extends StatelessWidget {
  // Define asset paths for the logos
  static const String tsnLogoPath = 'assets/tsn_app_icon.png';
  static const String kidzLogoPath = 'assets/logo.png'; // Replace with your actual logo path


  Future<void> fetchStorageUsage() async {
    // Replace with your Firebase storage bucket URL
    final bucketUrl = 'https://firebasestorage.googleapis.com/v0/b/your-bucket-name.appspot.com';

    try {
      final response = await http.get(Uri.parse(bucketUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract storage usage data from the response
        final totalBytes = data['size'];
        // Display the total bytes in your Flutter app
        print('Total storage usage: $totalBytes bytes');
      } else {
        print('Failed to fetch storage usage data');
      }
    } catch (e) {
      print('Error fetching storage usage data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchStorageUsage();
    return Scaffold(
      drawer: BaseDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: kWhite),
        title: Text(
          'Home',
          style: TextStyle(color: kWhite,fontSize: 14),
        ),
        backgroundColor: kprimary,
      ),
      // appBar: AppBar(
      //
      // automaticallyImplyLeading: false,
      //   title: Text('Select Campus',style: TextStyle(fontSize: 14),),
      //   backgroundColor: kprimary,
      //   foregroundColor: kWhite,
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center buttons vertically
          children: [
            IconButton(
              onPressed: () {
                table_ = '';
                setcollectionnames(table_);
                Get.to(MainTabs());
              },
              icon: Container(
                // Set a fixed height and width for consistent button size
                height: 100,
                width: 350,
                decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20.0), ),
                child: Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10,),
                    Image.asset(kidzLogoPath, height: 100) , // Adjust image height as needed
                    SizedBox(width: 10,),
                    Text('Kidz Republik',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                    SizedBox(width: 10,),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                table_ = 'tsn_';
                setcollectionnames(table_);
                Get.to(MainTabs());
              },
              icon: Container(
                // Set a fixed height and width for consistent button size
                height: 100,
                width: 350,
                decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20.0), ),
                child: Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 10,),
                    Image.asset(tsnLogoPath, height: 100) , // Adjust image height as needed
                    SizedBox(width: 10,),
                    Text('The Second Nest',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                    SizedBox(width: 10,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusButton({required VoidCallback onPressed, required String imagePath, required String text,}) {
    return Container(
      // Set a fixed height and width for consistent button size
      height: 100,
      width: 350,
      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20.0), ),
      child: Row(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 10,),
          Image.asset(imagePath, height: 100) , // Adjust image height as needed
          SizedBox(width: 10,),
          Text(text,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          SizedBox(width: 10,),
        ],
      ),
    );
   }
}
