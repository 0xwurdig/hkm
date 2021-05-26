import 'package:get/get.dart';

// Get the proportionate height as per screen size
double getHeight(double inputHeight) {
  double screenHeight = Get.size.shortestSide / 392.7;
  // 812 is the layout height that designer use
  return inputHeight * screenHeight;
}

// Get the proportionate height as per screen size
double getWidth(double inputWidth) {
  double screenWidth = Get.size.longestSide / 759.3;
  // 375 is the layout width that designer use
  return inputWidth * screenWidth;
}

double getText(double inputWidth) {
  double textFactor = Get.textScaleFactor;
  // 375 is the layout width that designer use
  return inputWidth * textFactor;
}
