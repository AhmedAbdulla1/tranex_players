import 'dart:io';

import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/domain/usecase/upload_image_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<Either<Failure, String>> uploadImage(
    File image, ImageDestination imageDestination) async {
  // Compress the image before uploading
  File? compressedImage = await compressImage(image);

  if (compressedImage == null) {
    print("Image compression failed");
    compressedImage = image;
    // return Left(Failure(code: 100, message: "Image compression failed"));
  }

  UploadImageUsecase uploadImageUsecase = UploadImageUsecase();
  Either<Failure, String> result = await uploadImageUsecase.execute(
      UploadImageInput(
          image: compressedImage, folderName: imageDestination.name));
  return result;
}

Future<File?> compressImage(File image) async {
  final result = await FlutterImageCompress.compressWithFile(
    image.absolute.path,
    minWidth: 1024,
    minHeight: 1024,
    quality: 20,
    rotate: 0,
  );

  if (result != null) {
    final compressedImage = File(image.path)..writeAsBytesSync(result);
    return compressedImage;
  } else {
    return null;
  }
}

enum ImageDestination { profile, exercise }
