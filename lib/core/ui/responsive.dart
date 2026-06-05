import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double wide = 1440;
}

bool isMobile(BuildContext context) =>
    MediaQuery.sizeOf(context).width < Breakpoints.mobile;

bool isTablet(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w >= Breakpoints.mobile && w < Breakpoints.tablet;
}

bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

bool isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= Breakpoints.wide;

enum DeviceClass { mobile, tablet, desktop, wide }

DeviceClass deviceClass(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= Breakpoints.wide) return DeviceClass.wide;
  if (w >= Breakpoints.tablet) return DeviceClass.desktop;
  if (w >= Breakpoints.mobile) return DeviceClass.tablet;
  return DeviceClass.mobile;
}
