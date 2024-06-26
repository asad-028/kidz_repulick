import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_republik/utils/const.dart';

//circular button, round card like shape with icon

class CircleButton extends RawMaterialButton {
  CircleButton({
    Key? key,
    required VoidCallback onPressed,
    required IconData icon,
    double elevation = 1.5,
    Color color = kWhite
  }) : super(
          key: key,
          constraints: BoxConstraints.tight(const Size(40, 40)),
          child: Icon(icon, color: kBlackColor, size: 20),
          elevation: elevation,
          fillColor: color,
          splashColor: Theme.of(Get.context!).primaryColor.withOpacity(0.2),
          highlightColor: Theme.of(Get.context!).primaryColor.withOpacity(0.2),
          highlightElevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          onPressed: onPressed,
        );
}
