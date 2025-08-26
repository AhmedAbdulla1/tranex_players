import 'package:dartz/dartz.dart';
import 'package:firesport_users/data/network/failure.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/domain/repository/trainees_repo.dart';
import 'package:firesport_users/domain/usecase/base_usecase.dart';



class GetTraineesUseCase extends BaseUseCase <void, List<TraineeData>> {
  final TraineesRepository _repository;

  GetTraineesUseCase(this._repository);

  @override
  Future<Either<Failure, List<TraineeData>>> execute(input) {
    return _repository.getTrainees();
  }
}
