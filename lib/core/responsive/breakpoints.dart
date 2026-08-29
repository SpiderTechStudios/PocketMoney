import 'package:flutter/widgets.dart';

enum Breakpoint { mobile, tablet, desktop }

class Breakpoints {
  Breakpoints._();

  static const double mobileMax = 700;
  static const double tabletMax = 1100;

  static Breakpoint fromWidth(double width) {
    if (width >= tabletMax) return Breakpoint.desktop;
    if (width >= mobileMax) return Breakpoint.tablet;
    return Breakpoint.mobile;
  }

  static Breakpoint of(BuildContext context) {
    return fromWidth(MediaQuery.sizeOf(context).width);
  }

  static bool isMobile(BuildContext context) =>
      of(context) == Breakpoint.mobile;

  static bool isTablet(BuildContext context) =>
      of(context) == Breakpoint.tablet;

  static bool isDesktop(BuildContext context) =>
      of(context) == Breakpoint.desktop;

  static bool isCompactHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 740;
}

class Responsive {
  Responsive._();

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return switch (Breakpoints.of(context)) {
      Breakpoint.desktop => desktop ?? tablet ?? mobile,
      Breakpoint.tablet => tablet ?? mobile,
      Breakpoint.mobile => mobile,
    };
  }
}
