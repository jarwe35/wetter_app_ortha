import 'package:flutter/material.dart';

enum OrthaDeviceClass {
  compactPhone,
  phone,
  largePhone,
  tablet,
  desktop,
  wideDesktop,
}

class OrthaResponsiveData {
  final OrthaDeviceClass deviceClass;
  final Size screenSize;
  final Orientation orientation;
  final double horizontalPadding;
  final double verticalPadding;
  final double cardSpacing;
  final double cardPadding;
  final double cardRadius;
  final double iconSize;
  final double sectionIconSize;
  final double maxContentWidth;
  final int preferredColumnCount;

  const OrthaResponsiveData({
    required this.deviceClass,
    required this.screenSize,
    required this.orientation,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.cardSpacing,
    required this.cardPadding,
    required this.cardRadius,
    required this.iconSize,
    required this.sectionIconSize,
    required this.maxContentWidth,
    required this.preferredColumnCount,
  });

  bool get isPhone =>
      deviceClass == OrthaDeviceClass.compactPhone ||
      deviceClass == OrthaDeviceClass.phone ||
      deviceClass == OrthaDeviceClass.largePhone;

  bool get isTablet => deviceClass == OrthaDeviceClass.tablet;

  bool get isDesktop =>
      deviceClass == OrthaDeviceClass.desktop ||
      deviceClass == OrthaDeviceClass.wideDesktop;

  bool get isLandscape => orientation == Orientation.landscape;
}

class OrthaResponsive {
  static const double compactPhoneBreakpoint = 360;
  static const double phoneBreakpoint = 480;
  static const double largePhoneBreakpoint = 700;
  static const double tabletBreakpoint = 1100;
  static const double desktopBreakpoint = 1600;

  const OrthaResponsive._();

  static OrthaResponsiveData of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final shortestSide = size.shortestSide;
    final width = size.width;
    final orientation = mediaQuery.orientation;

    final deviceClass = _resolveDeviceClass(
      width: width,
      shortestSide: shortestSide,
    );

    switch (deviceClass) {
      case OrthaDeviceClass.compactPhone:
        return OrthaResponsiveData(
          deviceClass: deviceClass,
          screenSize: size,
          orientation: orientation,
          horizontalPadding: 12,
          verticalPadding: 14,
          cardSpacing: 12,
          cardPadding: 16,
          cardRadius: 20,
          iconSize: 22,
          sectionIconSize: 40,
          maxContentWidth: 520,
          preferredColumnCount: 1,
        );

      case OrthaDeviceClass.phone:
        return OrthaResponsiveData(
          deviceClass: deviceClass,
          screenSize: size,
          orientation: orientation,
          horizontalPadding: 16,
          verticalPadding: 18,
          cardSpacing: 14,
          cardPadding: 18,
          cardRadius: 22,
          iconSize: 24,
          sectionIconSize: 42,
          maxContentWidth: 620,
          preferredColumnCount: 1,
        );

      case OrthaDeviceClass.largePhone:
        return OrthaResponsiveData(
          deviceClass: deviceClass,
          screenSize: size,
          orientation: orientation,
          horizontalPadding: 20,
          verticalPadding: 22,
          cardSpacing: 16,
          cardPadding: 22,
          cardRadius: 24,
          iconSize: 26,
          sectionIconSize: 44,
          maxContentWidth: 760,
          preferredColumnCount: orientation == Orientation.landscape ? 2 : 1,
        );

      case OrthaDeviceClass.tablet:
        return OrthaResponsiveData(
          deviceClass: deviceClass,
          screenSize: size,
          orientation: orientation,
          horizontalPadding: 28,
          verticalPadding: 26,
          cardSpacing: 20,
          cardPadding: 24,
          cardRadius: 26,
          iconSize: 28,
          sectionIconSize: 48,
          maxContentWidth: 1180,
          preferredColumnCount: 2,
        );

      case OrthaDeviceClass.desktop:
        return OrthaResponsiveData(
          deviceClass: deviceClass,
          screenSize: size,
          orientation: orientation,
          horizontalPadding: 36,
          verticalPadding: 30,
          cardSpacing: 22,
          cardPadding: 26,
          cardRadius: 28,
          iconSize: 30,
          sectionIconSize: 50,
          maxContentWidth: 1380,
          preferredColumnCount: 2,
        );

      case OrthaDeviceClass.wideDesktop:
        return OrthaResponsiveData(
          deviceClass: deviceClass,
          screenSize: size,
          orientation: orientation,
          horizontalPadding: 44,
          verticalPadding: 34,
          cardSpacing: 24,
          cardPadding: 28,
          cardRadius: 30,
          iconSize: 32,
          sectionIconSize: 52,
          maxContentWidth: 1560,
          preferredColumnCount: 3,
        );
    }
  }

  static OrthaDeviceClass _resolveDeviceClass({
    required double width,
    required double shortestSide,
  }) {
    if (shortestSide < compactPhoneBreakpoint) {
      return OrthaDeviceClass.compactPhone;
    }

    if (shortestSide < phoneBreakpoint) {
      return OrthaDeviceClass.phone;
    }

    if (shortestSide < largePhoneBreakpoint) {
      return OrthaDeviceClass.largePhone;
    }

    if (width < tabletBreakpoint) {
      return OrthaDeviceClass.tablet;
    }

    if (width < desktopBreakpoint) {
      return OrthaDeviceClass.desktop;
    }

    return OrthaDeviceClass.wideDesktop;
  }
}
