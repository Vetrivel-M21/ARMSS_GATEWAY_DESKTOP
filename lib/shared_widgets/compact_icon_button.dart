import 'package:flutter/material.dart';

/// A small-footprint icon button for dense table action columns. Plain
/// `IconButton`s default to a 48x48 tap target, which overflows a narrow
/// Actions column once 2-3 of them sit in a row — this shrinks the tap
/// target to 32x32 while keeping the icon itself untouched.
class CompactIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  const CompactIconButton({super.key, required this.icon, required this.onPressed, this.tooltip, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      color: color,
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      splashRadius: 18,
    );
  }
}
