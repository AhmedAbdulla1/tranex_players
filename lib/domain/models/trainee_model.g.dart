// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TraineeDataAdapter extends TypeAdapter<TraineeData> {
  @override
  final int typeId = 0;

  @override
  TraineeData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TraineeData(
      traineeName: fields[0] as String,
      traineeId: fields[7] as String,
      country: fields[1] as String?,
      age: fields[4] as int?,
      isActive: fields[5] as bool,
      weaponType: fields[3] as String?,
      isFencer: fields[8] as bool,
      photo: fields[6] as String,
      exercise: (fields[9] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, TraineeData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.traineeName)
      ..writeByte(1)
      ..write(obj.country)
      ..writeByte(3)
      ..write(obj.weaponType)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.photo)
      ..writeByte(7)
      ..write(obj.traineeId)
      ..writeByte(8)
      ..write(obj.isFencer)
      ..writeByte(9)
      ..write(obj.exercise);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraineeDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
