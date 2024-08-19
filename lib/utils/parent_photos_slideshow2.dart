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
        appBar: AppBar(title: Text('Activities',style: TextStyle(fontSize: 14,color: Colors.white),),backgroundColor: kprimary),
body:
(activityPhotos != null)?
CarouselSlider(
  items: activityPhotos!
      .map((photo)
  {   return Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.start,
    children: [
      SizedBox(height: mQ.height*0.003,),
      Container(
        width: mQ.width,
        height: mQ.height*0.035,
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(5), // Apply rounded corners if desired
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              spreadRadius: 0.7,
              blurRadius: 0.9,
              offset: Offset(0, 3), // Add a shadow effect
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: Text(photo['Activity'],style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.indigo),)),
            (role_ != 'Parent')
                ?
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Expanded(child:
                photo['photostatus_']=='Approved'? Icon(Icons.done_all_sharp,color: Colors.blue[900],):photo['photostatus_']=='Forwarded'? Icon(Icons.done_all,color: Colors.grey,):Icon(Icons.done_outlined,color: Colors.grey,)
              // Text(
              //   "",style: TextStyle(
              //   color:
              //   (photo["photostatus_"]== "Approved")?Colors.green:(photo["photostatus_"]== "Forwarded")?Colors.blue[150]:Colors.blue[200],
              // ),textAlign: TextAlign.right,)
              ),
            ):
                // Text('asasa')
            Expanded(child: Text(photo['date_'],textAlign: TextAlign.right,style: TextStyle(color: Colors.grey,fontSize: 10),)),
          ],
        ),
      ),
            Text(
              "${photo['childFullName']}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
      SizedBox(height: mQ.height*0.003,),
      InkWell(
  onTap: () {
  final index = activityPhotos!.indexWhere((element) => element['image_'] == photo['image_']);
  if (index != -1) {
  Get.to(ZoomableImageGallery(imageUrls: activityPhotos ?? [], initialIndex: index));
  }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            imageUrl: photo['image_'],
            height: mQ.height*0.55,
            // width: mQ.width,
            fit: BoxFit.fitWidth,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
      SizedBox(height: mQ.height*0.003,),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        width: mQ.width,
        // height: mQ.height*0.15,
        decoration: BoxDecoration(
          color:
          Colors.grey.shade50,
          borderRadius: BorderRadius.circular(5), // Apply rounded corners if desired
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              spreadRadius: 0.2,
              blurRadius: 0.5,
              offset: Offset(0, 3), // Add a shadow effect
            ),
          ],
        ),

        child:
      Text(photo['description'],textAlign: TextAlign.justify,style: TextStyle(color: Colors.grey,fontSize: 12)),
      ),
      SizedBox(height: mQ.height*0.003,),
    ],
  );}
  )
      .toList(),
  options: CarouselOptions(
    height:
    (role_ == 'Parent')?
    mQ.height*0.75:   mQ.height*0.3,
    // aspectRatio: 16 / 9,
    enlargeCenterPage: true,
    enableInfiniteScroll: false,
  ),
)
:Container(
  alignment: Alignment.center,
  height: mQ.height*0.4,
  child: Text('No Photos'),
    )


      ):
      (activityPhotos == null)?Container(alignment: Alignment.center,
        height: mQ.height*0.3,
          child: Text('No Photos')):
      CarouselSlider(
        items: activityPhotos!
            .map((photo)
        {   return Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // SizedBox(height: mQ.height*0.003,),
            Container(
              width: mQ.width,
              height: mQ.height*0.035,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(5), // Apply rounded corners if desired
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: 0.7,
                    blurRadius: 0.9,
                    offset: Offset(0, 3), // Add a shadow effect
                  ),
                ],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(photo['Activity'],style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.indigo),)),
                  (role_ != 'Parent')?
                  photo['photostatus_']=='Approved'? Icon(Icons.done_all_sharp,color: Colors.blue[900],):photo['photostatus_']=='Forwarded'? Icon(Icons.done_all,color: Colors.grey,):Icon(Icons.done_outlined,color: Colors.grey,)
                      :Text(photo['date_'],textAlign: TextAlign.right,style: TextStyle(color: Colors.grey,fontSize: 10),),
                ],
              ),
            ),
            InkWell(
            onTap: () {
        final index = activityPhotos!.indexWhere((element) => element['image_'] == photo['image_']);
        if (index != -1) {
        Get.to(ZoomableImageGallery(imageUrls: activityPhotos ?? [], initialIndex: index));
        }
              },
              child:
              Container(
                height: mQ.height*0.25,
                width: mQ.width*0.8,
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
                    imageUrl: photo['image_'],
                    width: mQ.width*0.7,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Container(
              width: mQ.width,
              // height: mQ.height*0.04,
              decoration: BoxDecoration(
                color:
                Colors.grey.shade50,
                borderRadius: BorderRadius.circular(5), // Apply rounded corners if desired
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 0.2,
                    blurRadius: 0.5,
                    offset: Offset(0, 3), // Add a shadow effect
                  ),
                ],
              ),
              child:
              Text(photo['description'],textAlign: TextAlign.justify,style: TextStyle(color: Colors.grey,fontSize: 12)),
            ),
          ],
        );}
        )
            .toList(),
        options: CarouselOptions(
          height: mQ.height*0.4,
          // aspectRatio: 16 / 9,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
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



