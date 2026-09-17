sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message);
}

class BusinessRuleException extends AppException {
  const BusinessRuleException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

class IntegrityException extends AppException {
  const IntegrityException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}
