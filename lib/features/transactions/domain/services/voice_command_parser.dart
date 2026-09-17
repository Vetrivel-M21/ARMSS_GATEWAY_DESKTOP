class VoiceEntryCommand {
  final int subTitleId;
  final bool isCredit;
  final double amount;

  const VoiceEntryCommand({required this.subTitleId, required this.isCredit, required this.amount});
}

/// One candidate row the parser can match against — deliberately a small
/// local shape (not importing the chart-of-accounts feature's `LedgerRow`)
/// so this domain service stays decoupled from another feature; the screen
/// maps its own rows into this shape when calling [VoiceCommandParser.parse].
typedef VoiceMatchRow = ({int subTitleId, String subTitleName, String titleName, String mainTitleName});

/// Fuzzy-matches a spoken phrase like `Deposit credit 100 <sub-title name>`
/// against the currently loaded rows for the selected department — the
/// Flutter-native replacement for the old app's in-browser
/// `webkitSpeechRecognition` matching (client-only, no server involvement
/// there either). Matches Category -> Title -> Sub-title hierarchically,
/// same as the old app's `processVoiceCommand`: it first narrows to rows
/// whose main-title (category) name is mentioned, then further narrows to
/// rows whose title name is mentioned, before picking the best sub-title
/// match — so a spoken category/title name disambiguates between
/// same-named sub-titles in different categories.
class VoiceCommandParser {
  static final _numberPattern = RegExp(r'(\d+(\.\d+)?)');
  static const _debitKeywords = ['debit', 'withdraw', 'paid', 'expense'];

  static VoiceEntryCommand? parse(String spokenText, List<VoiceMatchRow> rows) {
    final lower = spokenText.toLowerCase();

    final amountMatch = _numberPattern.firstMatch(lower);
    if (amountMatch == null) return null;
    final amount = double.tryParse(amountMatch.group(1)!);
    if (amount == null || amount <= 0) return null;

    // Defaults to credit ("deposit"-style) when ambiguous, matching the old
    // app's example phrase "Deposit credit 100".
    final isCredit = !_debitKeywords.any(lower.contains);

    final remainder = lower
        .replaceAll(_numberPattern, '')
        .replaceAll(RegExp(r'\bcredit\b'), '')
        .replaceAll(RegExp(r'\bdebit\b'), '')
        .trim();
    final words = remainder.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toSet();
    if (words.isEmpty) return null;

    // 1) Narrow to rows whose category is mentioned, if any word matches one.
    var scope = rows;
    final categoryMatches = rows.where((r) => words.any((w) => r.mainTitleName.toLowerCase().contains(w))).toList();
    if (categoryMatches.isNotEmpty) scope = categoryMatches;

    // 2) Within that scope, narrow further to rows whose title is mentioned.
    final titleMatches = scope.where((r) => words.any((w) => r.titleName.toLowerCase().contains(w))).toList();
    if (titleMatches.isNotEmpty) scope = titleMatches;

    // 3) Pick the best sub-title match within the narrowed scope.
    VoiceMatchRow? best;
    int bestScore = 0;
    for (final row in scope) {
      final subWords = row.subTitleName.toLowerCase().split(RegExp(r'\s+'));
      final score = subWords.where((w) => words.any((spoken) => spoken.contains(w) || w.contains(spoken))).length;
      if (score > bestScore) {
        bestScore = score;
        best = row;
      }
    }
    if (best == null) return null;

    return VoiceEntryCommand(subTitleId: best.subTitleId, isCredit: isCredit, amount: amount);
  }
}
