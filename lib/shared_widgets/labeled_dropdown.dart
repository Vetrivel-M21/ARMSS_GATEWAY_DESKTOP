import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A single selectable item: value + its displayed text.
typedef LabeledDropdownItem<T> = ({T value, String text});

/// A dropdown that opens its menu anchored directly below the field (a
/// typical combobox layout), built on Material 3's `DropdownMenu`.
///
/// `DropdownButtonFormField`'s classic menu instead vertically centers
/// itself so the *currently selected* item lines up with the button — which
/// is why it can appear to float away from the field and over unrelated
/// content instead of opening cleanly underneath it. `DropdownMenu` anchors
/// below by default, which is what was asked for here.
///
/// `DropdownMenu.initialSelection` is otherwise only applied once (like
/// `initState`) and won't follow an externally-changed `value` on a normal
/// rebuild — several screens here change the selected department/user/year
/// programmatically (e.g. defaulting to the first loaded department), so
/// this widget is keyed by `ValueKey(value)`: when `value` changes from
/// outside, Flutter remounts a fresh `DropdownMenu` with the new
/// `initialSelection` instead of reusing stale internal state.
class LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<LabeledDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double width;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 220,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      key: ValueKey(value),
      initialSelection: value,
      width: width,
      label: Text(label),
      onSelected: onChanged,
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkPrimary),
      trailingIcon: const Icon(Icons.keyboard_arrow_down, color: AppColors.accentLedger),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfacePanel,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        labelStyle: TextStyle(fontSize: 12, color: AppColors.inkSecondary, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.lineHairline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.lineHairline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: AppColors.accentLedger, width: 2)),
      ),
      menuStyle: MenuStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        elevation: const WidgetStatePropertyAll(3),
        backgroundColor: const WidgetStatePropertyAll(AppColors.surfacePanel),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      dropdownMenuEntries: [for (final item in items) DropdownMenuEntry(value: item.value, label: item.text)],
    );
  }
}
