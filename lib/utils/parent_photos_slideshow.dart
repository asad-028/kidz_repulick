import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/screens/gallery/zoomable_image.dart';
import 'package:kids_republik/utils/const.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';

var index;

class ParentPhotoSlideshow extends StatefulWidget {
  String? fatherEmail;
  String? babyId;
  String? ActivityId;
  String? activity_;
  String? description_;
  String? activitydate_;
  String? subject_;
  String? image_;
  ParentPhotoSlideshow(
      {required this.fatherEmail,
      required this.babyId,
      this.ActivityId,
      this.activity_,
      this.description_,
      this.subject_,
      this.image_,
      this.activitydate_});

  @override
  _ParentPhotoSlideshowState createState() => _ParentPhotoSlideshowState();
}

class _ParentPhotoSlideshowState extends State<ParentPhotoSlideshow> {
  List<Map<String, dynamic>>? activityPhotos;
  bool deleteionLoading = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (role_ == "Parent") {
      widget.fatherEmail = useremail;
      fetchChildrenForUser().then((photos) {setState(() {activityPhotos = photos;});});
    } else {
      fetchChildrenForSchool().then((photos) {setState(() {activityPhotos = photos;});});
    }
  }

  getParentDirectory() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      return directory.parent.parent.parent.parent.path;
    }
    // return null;
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Activities', style: TextStyle(fontSize: 14, color: Colors.white)), backgroundColor: kprimary,),
      body: (activityPhotos != null)
          ? Center(
            child: CarouselSlider(
                items: activityPhotos!.map((photo) {
                  // final index = activityPhotos!.indexWhere((element) => element['image_'] == photo['image_']);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: mQ.height * 0.003,),
                      Container(width: mQ.width, height: mQ.height * 0.035,alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kprimary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              spreadRadius: 0.3,
                              blurRadius: 0.5,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child:
                      Text("${photo['childFullName']}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87.withOpacity(0.7), fontSize: 10,),),
                      ),
                      Container(width: mQ.width, height: mQ.height * 0.035,
                        padding:EdgeInsets.symmetric(horizontal: 5),decoration: BoxDecoration(

                          color: kprimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              spreadRadius: 0.3,
                              blurRadius: 0.5,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(photo['Activity'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo),),),
                            (role_ != 'Parent') ? Padding(padding: const EdgeInsets.all(2.0), child: Expanded(child: photo['photostatus_'] == 'Approved' ? Icon(Icons.done_all_sharp, color: Colors.blue[900]) : photo['photostatus_'] == 'Forwarded' ? Icon(Icons.done_all, color: Colors.grey) : Icon(Icons.done_outlined, color: Colors.grey),),) : Expanded(child: Text(photo['date_'], textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontSize: 10),),),
                          ],
                        ),
                      ),
                      // SizedBox(height: mQ.height * 0.003,),
                      Spacer(),
                      InkWell(
                        onTap: () async {
                          index = activityPhotos!.indexWhere((element) => element['image_'] == photo['image_']);
                          if (index != -1) {
                            Get.to(ZoomableImageGallery(imageUrls: activityPhotos ?? [], initialIndex: index));
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child:
                              File('${getParentDirectory()}/${photo['childFullName']}/${photo['date_']} - ${photo['Activity']} - $index.jpg')
                                      .existsSync()
                                  ? Image.file(
                                      File(
                                          '${getParentDirectory()}/${photo['childFullName']}/${photo['date_']} - ${photo['Activity']} - $index.jpg'),
                                      height: mQ.height * 0.45,
                                      fit: BoxFit.fill,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: photo['image_'],
                                      height: mQ.height * 0.45,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        width: mQ.width,
                        height: mQ.height * 0.15,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 0.2,
                              blurRadius: 0.5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(photo['description'],
                            textAlign: TextAlign.justify,
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      SizedBox(
                        height: mQ.height * 0.003,
                      ),
                    ],
                  );
                }).toList(),
                options: CarouselOptions(

                  height:
                      (role_ == 'Parent') ? mQ.height * 0.80 : mQ.height * 0.3,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                ),
              ),
          )
          : Container(
              alignment: Alignment.center,
              height: mQ.height * 0.4,
              child: Text('Images will be displayed here'),
            ),
    );
  }

  Future<List<Map<String, dynamic>>?> fetchChildrenForUser() async {
    try {
      final babyDataSnapshot = await FirebaseFirestore.instance
          .collection('BabyData')
          .where('fathersEmail', isEqualTo: widget.fatherEmail)
          .get();

      final babyIds = babyDataSnapshot.docs.map((doc) => doc.id).toList();

      final activitySnapshot = await FirebaseFirestore.instance
          .collection('Activity')
          .where('photostatus_', isEqualTo: 'Approved')
          .where('id', whereIn: babyIds)
          .get();

      if (activitySnapshot.docs.isNotEmpty) {
        return activitySnapshot.docs.map((doc) {
          final data = doc.data();
          data['childFullName'] = babyDataSnapshot.docs
              .firstWhere((babyDoc) => babyDoc.id == data['id'])
              .data()['childFullName'];
          return data;
        }).toList();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching children: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchChildrenForSchool() async {
    try {
      final activitySnapshot = await FirebaseFirestore.instance
          .collection('Activity')
          .where('photostatus_', whereIn: ['Forwarded', 'Approved'])
          .where('id', isEqualTo: widget.babyId)
          .get();

      if (activitySnapshot.docs.isNotEmpty) {
        return activitySnapshot.docs.map((doc) => doc.data()).toList();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching children: $e');
      return null;
    }
  }
}
