import '../../../../core/errors/result.dart';
import '../entities/device_token.dart';

abstract class DeviceAuthRepository {
  Future<Result<DeviceToken>> authenticate();
}
