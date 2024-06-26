import 'package:flutter/material.dart';
import 'package:kids_republik/utils/const.dart';

class PrimaryButton extends MaterialButton {
  PrimaryButton({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Widget? icon,
    bool isPrimary = true,
    Color? bgColor,
    double? elevation,
    TextStyle? labelStyle,
     BorderRadius? borderRadius,
  }) : super(
          key: key,
          onPressed: onPressed,
          shape:  RoundedRectangleBorder(borderRadius: borderRadius ?? kBorderRadius),
          elevation: elevation ?? 0,
          height: 60,
          highlightElevation: 0,
          disabledColor: kSecondaryBtn,
          highlightColor: Colors.transparent,
          color: bgColor ?? (isPrimary ? kprimary : kWhite),
          textColor: isPrimary ? kWhite : kBlackColor,
          animationDuration: const Duration(milliseconds: 300),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: labelStyle,
              ),
              const SizedBox(width: 6.0),
              icon ?? const SizedBox(),
            ],
          ),
        );
}
