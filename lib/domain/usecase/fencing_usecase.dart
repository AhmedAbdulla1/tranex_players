import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/data/repository/match_repo_impl.dart';
import 'package:tranex_users/domain/repository/match_repo.dart';

class FencingUsecase {
  final MatchRepository repository = MatchRepoImpl();

   FencingUsecase();

  Future<Either<Failure,void>> addMatch(
      MatchRequest addMatch
      ) {
    return repository.addMatch(addMatch);
  }
  // Future<void> deleteExercise(String categoryId, String exerciseId) {
  //   return repository.deleteExercise(categoryId, exerciseId);
  // }
}