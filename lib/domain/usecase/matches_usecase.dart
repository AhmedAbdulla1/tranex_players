import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/domain/models/matches_entity.dart';
import 'package:tranex_users/domain/repository/trainees_repo.dart';
import 'package:tranex_users/domain/usecase/base_usecase.dart';

class MatchesUseCase extends BaseUseCase<String, MatchesEntity> {
  final TraineesRepository _repository;

  MatchesUseCase(this._repository);

  @override
  Future<Either<Failure, MatchesEntity>> execute(input) {
    return _repository.getMatches(input);
  }
}
