import 'dart:io';

import 'package:tranex_users/data/network/failure.dart';
import 'package:dartz/dartz.dart';

abstract class Repository {
  Future<Either<Failure, String>> uploadImage(File image , String folderName);
}

