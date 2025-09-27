import 'package:dartz/dartz.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/data/data_source/remote_data_source.dart';
import 'package:tranex_users/data/network/error_handler.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/data/network/network_info.dart';
import 'package:tranex_users/data/network/requests.dart';
import 'package:tranex_users/domain/repository/match_repo.dart';

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
