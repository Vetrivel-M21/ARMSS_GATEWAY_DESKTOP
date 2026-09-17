import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/rbac/current_user_provider.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/login_use_case.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(appDatabaseProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

class LoginController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<AppException?> login({required String username, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(loginUseCaseProvider).call(username: username, password: password);
    return result.fold(
      (user) {
        ref.read(currentUserIdProvider.notifier).setId(user.id);
        state = const AsyncData(null);
        return null;
      },
      (error) {
        state = AsyncData(null);
        return error;
      },
    );
  }
}

final loginControllerProvider = AsyncNotifierProvider<LoginController, void>(LoginController.new);
