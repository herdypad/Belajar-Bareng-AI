import 'package:flutter/material.dart';

/// Breakpoint acuan untuk tampilan responsif mobile vs tablet vs desktop.
class ResponsiveBreakpoints {
  static const double tablet = 600;
  static const double tabletLandscape = 900;
  static const double desktop = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= tablet && w < desktop;
  }

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  static bool isTabletLandscapeOrDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletLandscape;
}

/// Shell tata letak responsif.
/// Pada ponsel (lebar < 600px), membatasi lebar konten maks ~480px.
/// Pada tablet portrait (lebar 600-899px), memperluas konten hingga maks ~860px.
/// Pada tablet landscape / desktop (lebar >= 900px), memperluas konten hingga maks ~1040px.
class MobileShell extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const MobileShell({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isTab = ResponsiveBreakpoints.isTabletOrLarger(context);
    final isWide = ResponsiveBreakpoints.isTabletLandscapeOrDesktop(context);
    final defaultMaxWidth = isWide ? 1040.0 : (isTab ? 860.0 : 480.0);
    final effectiveMaxWidth = maxWidth ?? defaultMaxWidth;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
