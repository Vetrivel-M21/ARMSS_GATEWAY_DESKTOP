import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> login(String username, String password);
}
