import '../../../../core/constants/permission_keys.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/chart_of_accounts_repository.dart';

/// Unlike ledger entries, deleting a title/sub-title follows the normal
/// granular permission (titles.delete) — the hard admin-only gate in the old
/// app applies only to balance_entries edit/delete, not to the chart of
/// accounts itself.
class DeleteTitleUseCase {
  final ChartOfAccountsRepository _repository;
  DeleteTitleUseCase(this._repository);

  Future<Result<void>> call({required AppUser actor, required int id}) async {
    if (!actor.has(PermissionCode.titlesDelete)) {
      return const Failure(PermissionDeniedException('You do not have permission to delete titles.'));
    }
    return _repository.deleteTitle(id);
  }
}
