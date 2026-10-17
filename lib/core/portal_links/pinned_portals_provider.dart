import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPinnedPortalsPrefKey = 'pinned_portal_keys';

class PinnedPortalsNotifier extends StateNotifier<Set<String>> {
  PinnedPortalsNotifier() : super(const <String>{}) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kPinnedPortalsPrefKey) ?? <String>[];
      state = list.toSet();
    } catch (_) {}
  }

  Future<void> togglePin(String portalKey) async {
    final next = Set<String>.from(state);
    if (next.contains(portalKey)) {
      next.remove(portalKey);
    } else {
      next.add(portalKey);
    }
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kPinnedPortalsPrefKey, next.toList());
    } catch (_) {}
  }

  bool isPinned(String portalKey) => state.contains(portalKey);
}

final pinnedPortalsProvider =
    StateNotifierProvider<PinnedPortalsNotifier, Set<String>>((ref) {
  return PinnedPortalsNotifier();
});
