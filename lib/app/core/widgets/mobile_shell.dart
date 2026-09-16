import 'package:flutter/material.dart';

/// Breakpoint acuan untuk tampilan responsif mobile vs tablet vs desktop.
class ResponsiveBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= tablet && w < desktop;
  }

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

/// Shell tata letak responsif.
/// Pada ponsel (lebar < 600px), membatasi lebar konten maks ~480px.
/// Pada tablet (lebar >= 600px), memperluas konten hingga maks ~860px (atau kustom).
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
    final effectiveMaxWidth = maxWidth ?? (isTab ? 860.0 : 480.0);

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
