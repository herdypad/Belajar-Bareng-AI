import 'package:flutter/material.dart';

/// Membatasi konten ke lebar mobile (maks ~440px) & memusatkannya,
/// meniru layout `max-w-[440px]` pada mockup.
class MobileShell extends StatelessWidget {
  final Widget child;
  const MobileShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: child,
      ),
    );
  }
}
