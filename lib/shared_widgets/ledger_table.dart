import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Shared table building blocks: a rounded, softly-shadowed panel containing
/// a header row on `surface-sunken`, hairline-divided body rows, and an
/// optional pinned footer with a heavier top rule. Built on Flutter's
/// `Table` (fixed-grid, per-cell alignment) rather than `DataTable`, which
/// is too Material-opinionated for this look — and rather than a new pub
/// dependency, since a plain `Table` already does everything needed,
/// including a dynamically expandable row list (rows are just conditionally
/// included in the `children` list based on expand/collapse state — a
/// `Table` rebuilds that like any other widget).
class LedgerColumn {
  final String label;
  final TextAlign align;
  final TableColumnWidth width;

  const LedgerColumn(this.label, {this.align = TextAlign.left, this.width = const FlexColumnWidth()});
}

/// A single cell's padding/alignment wrapper — use this inside every
/// `TableRow` cell so spacing and alignment stay consistent across screens.
class LedgerCell extends StatelessWidget {
  final Widget child;
  final TextAlign align;
  final EdgeInsetsGeometry padding;

  const LedgerCell({
    super.key,
    required this.child,
    this.align = TextAlign.left,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: switch (align) {
          TextAlign.right => Alignment.centerRight,
          TextAlign.center => Alignment.center,
          _ => Alignment.centerLeft,
        },
        child: child,
      ),
    );
  }
}

class LedgerTable extends StatelessWidget {
  final List<LedgerColumn> columns;
  final List<TableRow> rows;
  final TableRow? footer;

  const LedgerTable({super.key, required this.columns, required this.rows, this.footer});

  TableRow _headerRow() {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.accentLedgerTint),
      children: [
        for (final c in columns)
          LedgerCell(
            align: c.align,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
            child: Text(
              c.label,
              style: const TextStyle(fontSize: 12, color: AppColors.accentLedger, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.softShadow(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: {for (var i = 0; i < columns.length; i++) i: columns[i].width},
        border: const TableBorder(horizontalInside: BorderSide(color: AppColors.lineHairline)),
        children: [
          _headerRow(),
          ...rows,
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

/// Decoration for a footer/totals `TableRow` — heavier 2px top rule, the
/// ledger convention of a ruled-off subtotal.
const ledgerFooterDecoration = BoxDecoration(
  color: AppColors.surfacePanel,
  border: Border(top: BorderSide(color: AppColors.inkPrimary, width: 2)),
);

/// A tint wash for the currently-selected row only — zebra striping is
/// deliberately off everywhere else.
const ledgerSelectedRowDecoration = BoxDecoration(color: AppColors.accentLedgerTint);
