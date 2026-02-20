import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:kids_republik/main.dart';
import 'package:kids_republik/screens/gallery/zoomable_image.dart';
import 'package:kids_republik/utils/const.dart';

class ParentPhotoSlideshow2 extends StatefulWidget {
  String? fatherEmail;
  String? babyId;
  String? ActivityId;
  String? activity_;
  String? description_;
  String? activitydate_;
  String? subject_;
  String? image_;
  ParentPhotoSlideshow2({
    required this.fatherEmail,required this.babyId,
    this. ActivityId, this.activity_, this.description_, this.subject_, this.image_, this.activitydate_
  });

  @override
  _ParentPhotoSlideshowState createState() => _ParentPhotoSlideshowState();
}

class _ParentPhotoSlideshowState extends State<ParentPhotoSlideshow2> {
  List<Map<String, dynamic>>? activityPhotos;
  bool deleteionLoading = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // fetchApprovedActivityPhotos(widget.fatherEmail).then((photos) {
if(role_ == "Parent")
  setState(() {
widget.fatherEmail = useremail;
fetchChildrenForUser().then((photos) {
  setState(() {
    activityPhotos = photos;
  });
});
  });
    if(role_ != "Parent")
fetchChildrenForSchool().then((photos) {
  setState(() {
    activityPhotos = photos;
  });
});
  }

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return
      (role_ == 'Parent')?
      Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Activities',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          backgroundColor: kprimary,
          elevation: 0,
          centerTitle: true,
        ),
        body: (activityPhotos != null)?
          CarouselSlider(
            items: activityPhotos!.map((photo) {
              final String description = (photo['description'] ?? '').toString().trim();
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Slide Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      color: Colors.indigo.shade50.withOpacity(0.5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  photo['Activity'] ?? 'Activity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E1B4B),
                                  ),
                                ),
                                if (((photo['childFullName'] ?? '').toString().trim()).isNotEmpty)
                                  Text(
                                    "${photo['childFullName']}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.indigo.shade300,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            photo['date_'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Image Section
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final index = activityPhotos!.indexWhere((element) => element['image_'] == photo['image_']);
                          if (index != -1) {
                            Get.to(ZoomableImageGallery(imageUrls: activityPhotos ?? [], initialIndex: index));
                          }
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: photo['image_'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(color: Colors.indigo.shade200),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.fullscreen_rounded, color: Colors.indigo),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Description Section
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.blueGrey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: mQ.height * 0.85,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              viewportFraction: 0.9,
            ),
          )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 64, color: Colors.blueGrey.shade200),
                  const SizedBox(height: 16),
                  Text(
                    'No Photos Available',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
      ) :
      (activityPhotos == null)?
      Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No Photos',
            style: TextStyle(color: Colors.blueGrey.shade300, fontWeight: FontWeight.w500),
          ),
        ),
      ) :
      CarouselSlider(
        items: activityPhotos!.map((photo) {
          final String description = (photo['description'] ?? '').toString().trim();
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mini Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.indigo.shade50.withOpacity(0.3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          photo['Activity'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ),
                      StatusIndicatorMini(status: photo['photostatus_']),
                    ],
                  ),
                ),
                // Image
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final index = activityPhotos!.indexWhere((element) => element['image_'] == photo['image_']);
                      if (index != -1) {
                        Get.to(ZoomableImageGallery(imageUrls: activityPhotos ?? [], initialIndex: index));
                      }
                    },
                    child: CachedNetworkImage(
                      imageUrl: photo['image_'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                    ),
                  ),
                ),
                // Description
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade600),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        options: CarouselOptions(
          height: mQ.height * 0.45,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.easeInOut,
          viewportFraction: 0.85,
        ),
      );

  }

  Future<List<Map<String, dynamic>>?> fetchChildrenForUser() async {
    try {
      // First, query the "babyData" collection to get the "babyId" for the user's children.
      final babyDataSnapshot = await FirebaseFirestore.instance
          .collection(BabyData)
          .where('fathersEmail', isEqualTo: widget.fatherEmail)
          .get();

      final babyIds = babyDataSnapshot.docs.map((doc) => doc.id).toList();

      // Now, query the "activity" collection using the babyIds to get the children's activities.
      final activitySnapshot = await FirebaseFirestore.instance
          .collection(Activity)
          .where('photostatus_', isEqualTo: 'Approved')
          .where('id', whereIn: babyIds).orderBy('date_', descending: true)
          .get();

      if (activitySnapshot.docs.isNotEmpty) {
        return activitySnapshot.docs.map((doc) {
          final data = doc.data();
          // Add 'childFullName' to the data before returning
          data['childFullName'] =
          babyDataSnapshot.docs.firstWhere((babyDoc) => babyDoc.id == data['id'])
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
          .collection(Activity)
          .where('photostatus_', whereIn: ['Forwarded','Approved'])
          // .where('date_', isEqualTo: getCurrentDate())
          .where('id', isEqualTo: widget.babyId)
          .orderBy('date_', descending: true)
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

class StatusIndicatorMini extends StatelessWidget {
  final String? status;

  const StatusIndicatorMini({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case 'Approved':
        color = Colors.green.shade600;
        icon = Icons.done_all_rounded;
        break;
      case 'Forwarded':
        color = Colors.blue.shade600;
        icon = Icons.forward_rounded;
        break;
      default:
        color = Colors.blueGrey.shade300;
        icon = Icons.edit_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}



