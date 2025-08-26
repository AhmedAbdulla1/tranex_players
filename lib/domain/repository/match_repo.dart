import 'package:dartz/dartz.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/requests.dart';

abstract class MatchRepository {

  Future<Either<Failure, void>> addMatch(MatchRequest getMatchesRequest);

}