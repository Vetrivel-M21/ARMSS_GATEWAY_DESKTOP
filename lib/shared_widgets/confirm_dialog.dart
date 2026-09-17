import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Shown before a destructive action (delete, deactivate). This is the "true
/// confirm-to-destroy" moment the design system calls out — filled red here
/// is correct even though destructive buttons elsewhere in the app (e.g. a
/// row's delete icon) stay outline-only.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// The design system's "dialogs for irreversible actions" pattern (§4) — used
/// for Save & Close, the highest-stakes routine action in this app (there is
/// no year-close in this app's model, so the typed-confirmation variant the
/// doc describes for that doesn't apply here; the amber-summary form does).
Future<bool> showHighStakesConfirmDialog(
  BuildContext context, {
  required String title,
  required List<(String label, String value)> summary,
  String confirmLabel = 'Confirm',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 380,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.signalAmber, width: 2)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final (label, value) in summary)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(color: AppColors.inkSecondary, fontSize: 12)),
                    Text(value, style: AppTextStyles.monoWith(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(confirmLabel)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
