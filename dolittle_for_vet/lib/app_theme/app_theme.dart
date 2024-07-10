import 'package:dolittle_for_vet/utility_function.dart';
import 'package:flutter/material.dart';

class VetTheme {

  static const textWhite = TextStyle(color: Colors.white);
  static const textBlack = TextStyle(color: Colors.black);

  static const textGray = TextStyle(color: Colors.black54, fontWeight: FontWeight.bold);
  static Color mainIndigoColor = const Color(0xff2e3d80);
  static Color mainLightBlueColor = const Color(0xff4994ec);
  static Color hintColor = const Color(0xff9e9e9e);
  static AppBarTheme appbarColor = AppBarTheme(color: mainIndigoColor);

  static double diviceH(BuildContext context){
    return MediaQuery.of(context).size.height;
  }
  static double diviceW(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

  static double mediaHalfSize(BuildContext context){
    return MediaQuery.of( context).size.width/2;
  }

  static double monitorCardSizeByDeviceHeight(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    if (deviceHeight < 670) {
      return 75;
    } else if (deviceHeight < 730) {
      return 80;
    } else if(deviceHeight<815) {
      return 83;
    }else{
      return 87;
    }
  }

  static double titleTextSize(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    //UtilityFunction.log.e(deviceHeight);
    if (deviceHeight < 670) {
      return 14;
    } else if (deviceHeight < 730) {
      return 14.5;
    } else if(deviceHeight<815) {
      return 15;
    }else{
      return 15.5;
    }
  }
  static double textSize(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    //UtilityFunction.log.e(deviceHeight);
    if (deviceHeight < 670) {
      return 12;
    } else if (deviceHeight < 730) {
      return 12.5;
    } else if(deviceHeight<815) {
      return 13;
    }else{
      return 13.5;
    }
  }

  static double logotextSize(BuildContext context) {
    final logoWidth = MediaQuery.of(context).size.width;
    if (logoWidth > 450) {
      return 30;
    } else if (logoWidth > 370) {
      return 25;
    } else if(logoWidth > 340) {
      return 15;
    }else{
      return 10;
    }
  }


  static double smallIconSize(BuildContext context) {
    final logoWidth = MediaQuery.of(context).size.width;
    if (logoWidth > 450) {
      return 40;
    } else if (logoWidth > 370) {
      return 35;
    } else if(logoWidth > 340) {
      return 25;
    }else{
      return 20;
    }
  }

  static double logoWidth(BuildContext context) {
    final logoWidth = MediaQuery.of(context).size.width;
    //UtilityFunction.log.e(logoWidth);
    if (logoWidth > 400) {
      return 450;
    } else if (logoWidth > 370) {
      return 400;
    } else if(logoWidth > 340) {
      return 350;
    }else{
      return 300;
    }
  }

  static double logoHeight(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    if (deviceHeight > 835) {
      return 65;
    } else if (deviceHeight > 750) {
      return 60;
    } else if(deviceHeight>670) {
      return 55;
    }else{
      return 50;
    }
  }

}
