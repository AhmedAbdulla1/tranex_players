import 'package:dartz/dartz.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/data/data_source/remote_data_source.dart';
import 'package:firesport_users/data/network/error_handler.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/data/network/network_info.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/repository/match_repo.dart';

class MatchRepoImpl extends MatchRepository {
  final RemoteDataSource _remoteDataSource = instance<RemoteDataSource>();
  final NetworkInfo _networkInfo = instance<NetworkInfo>();

  @override
  Future<Either<Failure, void>> addMatch(MatchRequest addMatch) async {
    if (_networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.addMatch(
          addMatch,
        );
        return const Right(0);
      } catch (error) {
        return Left(
          ErrorHandler.handle(error).failure,
        );
      }
    } else {
      return Left(
        DataSource.noInternetConnection.getFailure(),
      );
    }
  }
}
