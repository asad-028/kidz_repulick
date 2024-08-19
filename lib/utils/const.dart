import 'package:flutter/material.dart';

// *** Colors

//app general theme
var kprimary4 = Color(0xFF45BEC0);
var kprimary = Color(0xFF269A9D);
var kprimary6 = Colors.teal[600];
var kprimary5 = Colors.teal[400];
var kprimary3 = Colors.teal[800];
var kprimary2 = Colors.blue[900];
var kSecondaryColor = Color(0xFF003F9E);

//restaurant side theme
var kprimaryRestauant =  Color(0xFF41acff);
var kSecondaryColorRestauant = Color(0xFF003F9E);

const kGrey = Color(0xFF808080);
const kAppGreyColor = Color(0xFF808080);
const kGreenColor = Color(0xFF6AC259);
const kRedColor = Color(0xFFD10016);
const kGreyColor = Color(0xFFC1C1C1);
const kWhite = Color(0xFFFFFFFF);
const kBlackColor = Color(0xFF101010);
const kBlack54 = Colors.black54;
const kBlack45 = Colors.black45;

const kBgColor = Color(0xFF0F3F2D2);
const kSecondaryBtn = Color(0xFFE0E0E0);
const kInputBorderColor = Color(0xFFBDBDBD);

// Blue Color
const kInfoColor = Color(0xFF3080ED);
const kInfoLightColor = Color(0xFFE5F4FF);
// Green Color
const kSuccessColor = Color(0xFF3C934D);
const kSuccessLightColor = Color(0xFFE2FFEE);
// Orange Color
const kWarningColor = Color(0xFFF2994A);
const kWarningLightColor = Color(0xFFFFF6E5);
// Red Color
const kDangerColor = Color(0xFFEB5757);

///
const BlueOpacity = Color(0xFFE5F8FF);
const textColor = Color(0xFF333333);
const profileBg = Color(0xFF808080);

//////
var grey100 = Colors.grey[100];

const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF46A0AE), Color(0xFF00FFCB)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
var drawerkPrimaryGradient = LinearGradient(
  colors: [ Colors.green[400]!, Colors.green[900]!],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const double kDefaultPadding = 20.0;

// *** Spacing
const kPadding = 16;
const defaultSpacing = 16.0;

const kSlidingUpPanelSpacing =
    EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0);

const kBorderRadius = BorderRadius.all(Radius.circular(8.0));
const kBorderRadius10 = BorderRadius.all(Radius.circular(10.0));

// *** Text Styling

//Header Center Title Style
var headerTitle = TextStyle(
    fontWeight: FontWeight.w500, color: kSecondaryColor, fontSize: 16.0);
var kTitle = TextStyle(
    color: Colors.black.withOpacity(0.9),
    fontSize: 15.3,
    letterSpacing: 0.3,
    fontWeight: FontWeight.bold);

const kSubTitle = TextStyle(color: Color(0xFF828282));
const kHeading =
    TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w500);
const k17bold = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
const k16bold = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
const k16500 = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500);
const k15500 = TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500);
const k14500 = TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500);
const k13500 = TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500);
const k12500 = TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500);

const kTextFieldTitle =
    TextStyle(color: kBlackColor, fontWeight: FontWeight.bold);
var kTextPrimaryButton =
    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3, fontSize: 16, color: kWhite);

const kBigTitle =
    TextStyle(color: kBlackColor, fontSize: 26, fontWeight: FontWeight.bold);

const kMediumTitle =
    TextStyle(color: kBlackColor, fontSize: 22, fontWeight: FontWeight.bold);


const kLabelStyle = TextStyle(color: Colors.black, fontSize: 15.5);

const kGrey15500 = TextStyle(
  color: Color.fromRGBO(158, 158, 158, 1),
  fontSize: 15,
  fontWeight: FontWeight.w500,
);
var kPrimaryBold = TextStyle(color: kprimary, fontWeight: FontWeight.bold);


