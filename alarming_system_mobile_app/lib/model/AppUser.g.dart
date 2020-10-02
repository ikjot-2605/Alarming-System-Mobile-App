// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppUser.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 1;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      name: fields[0] as String,
      email: fields[1] as String,
      imageUrl: fields[2] as String,
      phoneNumber: fields[3] as String,
      googleLoggedIn: fields[5] as bool,
      firebaseId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.googleLoggedIn)
      ..writeByte(6)
      ..write(obj.firebaseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
