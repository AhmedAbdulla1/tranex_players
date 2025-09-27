import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/requests.dart';

abstract class MatchRepository {

  Future<Either<Failure, void>> addMatch(MatchRequest getMatchesRequest);

}