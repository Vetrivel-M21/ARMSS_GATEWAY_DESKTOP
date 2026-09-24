import 'package:flutter/material.dart';

/// Standardized ARMSS INFO TECH footer shown at the bottom of every screen.
/// "ARMSS INFO TECH" is rendered in bold blue to highlight the brand.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        color: Color(0xFFFAFAFC),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
          children: [
            const TextSpan(text: 'Software designed and developed by '),
            TextSpan(
              text: 'ARMSS INFO TECH',
              style: const TextStyle(
                color: Color(0xFF0284C7),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
