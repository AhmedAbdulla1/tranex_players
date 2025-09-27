import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/domain/repository/trainees_repo.dart';
import 'package:tranex_users/domain/usecase/base_usecase.dart';

class GetTraineesUseCase extends BaseUseCase<void, List<TraineeData>> {
  final TraineesRepository _repository;

  GetTraineesUseCase(this._repository);

  @override
  Future<Either<Failure, List<TraineeData>>> execute(input) {
    return _repository.getTrainees();
  }
}
