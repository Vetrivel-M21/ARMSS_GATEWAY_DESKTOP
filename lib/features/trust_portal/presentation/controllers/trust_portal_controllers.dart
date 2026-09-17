import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/device_auth_repository_impl.dart';
import '../../domain/entities/device_token.dart';
import '../../domain/repositories/device_auth_repository.dart';

final deviceAuthRepositoryProvider = Provider<DeviceAuthRepository>((ref) => DeviceAuthRepositoryImpl());

/// Authenticates once on first watch, then keeps refreshing well ahead of the
/// backend's 15-minute device-token TTL so the WebView's session never lapses
/// while the tab is open.
class TrustPortalTokenController extends AutoDisposeAsyncNotifier<DeviceToken> {
  Timer? _refreshTimer;

  @override
  Future<DeviceToken> build() async {
    ref.onDispose(() => _refreshTimer?.cancel());
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (_) => refresh());
    return _authenticate();
  }

  Future<void> refresh() async {
    final result = await ref.read(deviceAuthRepositoryProvider).authenticate();
    result.fold(
      (token) => state = AsyncData(token),
      (error) {}, // keep the last good token live in the WebView; a transient refresh failure shouldn't tear it down
    );
  }

  Future<DeviceToken> _authenticate() async {
    final result = await ref.read(deviceAuthRepositoryProvider).authenticate();
    return result.fold((token) => token, (error) => throw error);
  }
}

final trustPortalTokenControllerProvider =
    AutoDisposeAsyncNotifierProvider<TrustPortalTokenController, DeviceToken>(TrustPortalTokenController.new);
