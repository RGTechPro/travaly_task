import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isSignedIn();
  }
}
