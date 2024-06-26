// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

var images = [
  'assets/swiper_photo_1.jpeg',
  'assets/swiper_photo_2.jpeg',
  'assets/swiper_photo_3.jpeg',
  'assets/swiper_photo_4.jpeg',
  'assets/swiper_photo_5.jpeg',
  'assets/swiper_photo_6.jpeg',
  'assets/swiper_photo_7.jpeg',
  'assets/swiper_photo_8.jpeg',
  'assets/swiper_photo_9.jpeg',
  'assets/swiper_photo_10.jpeg',
  // 'assets/swiper_photo_11.jpeg',
  // 'assets/swiper_photo_12.jpeg',
  // 'assets/swiper_photo_13.jpeg',
  // 'assets/swiper_photo_14.jpeg',
  // 'assets/swiper_photo_15.jpeg',
  // 'assets/swiper_photo_16.jpeg',
  // 'assets/swiper_photo_17.jpeg',
  // 'assets/swiper_photo_18.jpeg',
];
ImageSlideShowfunction(context){
   // final context = BuildContext;
  final mQ = MediaQuery.of(context).size;
  return ImageSlideshow(

/// Width of the [ImageSlideshow].
// indicatorPadding: LinearBorder.top(10),

      width: double.infinity,

/// Height of the [ImageSlideshow].
height: mQ.height*0.2500,

/// The page to show when first creating the [ImageSlideshow].
initialPage: 0,

/// The color to paint the indicator.
indicatorColor: Colors.blue,

/// The color to paint behind th indicator.
indicatorBackgroundColor: Colors.grey,

/// The widgets to display in the [ImageSlideshow].
/// Add the sample image file into the images folder
children: [
Image.asset(images[0],
fit: BoxFit.fill,
),
Image.asset(
  images[1],
fit: BoxFit.fill,
),
Image.asset(
  images[2],
fit: BoxFit.fill,
),

Image.asset(
  images[3],
fit: BoxFit.fill,
),

Image.asset(
  images[4],
fit: BoxFit.fill,
),

Image.asset(
  images[5],
fit: BoxFit.fill,
),

Image.asset(
  images[6],
fit: BoxFit.fill,
),

Image.asset(
  images[7],
fit: BoxFit.fill,
),
Image.asset(
  images[8],
fit: BoxFit.fill,
),
Image.asset(
  images[9],
fit: BoxFit.fill,
),

// Image.asset(
//   images[10],
// fit: BoxFit.fill,
// ),

  ],

/// Called whenever the page in the center of the viewport changes.
onPageChanged: (value) {

  // Image.asset(images[value],
  //   fit: BoxFit.fitWidth,
  // );
  // // print('Page changed: $value');
},

/// Auto scroll interval.
/// Do not auto scroll with null or 0.
autoPlayInterval: 3000,

/// Loops back to first slide.
isLoop: true,
);

}
// var listOfStrings = ['#0', for (var i in listOfInts) '#$i'];
// assert(listOfStrings[1] == '#1');