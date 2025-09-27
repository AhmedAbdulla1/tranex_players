import 'dart:io';

import 'package:tranex_users/app/di.dart';
import 'package:dartz/dartz.dart';
import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/domain/repository/repository.dart';
import 'package:tranex_users/domain/usecase/base_usecase.dart';



class UploadImageUsecase extends BaseUseCase <UploadImageInput, String> {
  final Repository _repository = instance<Repository>();

  @override
  Future<Either<Failure, String>> execute(input) {
    return _repository.uploadImage(input.image,input.folderName);
  }



}
class UploadImageInput {
  final File image;
  final String folderName;
  UploadImageInput({required this.image, required this.folderName});
}
