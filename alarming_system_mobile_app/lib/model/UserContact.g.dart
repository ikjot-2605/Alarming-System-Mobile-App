// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserContact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserContactAdapter extends TypeAdapter<UserContact> {
  @override
  final int typeId = 2;

  @override
  UserContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserContact(
      displayName: fields[0] as String,
      emails: (fields[1] as List)?.cast<String>(),
      phones: (fields[2] as List)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserContact obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.displayName)
      ..writeByte(1)
      ..write(obj.emails)
      ..writeByte(2)
      ..write(obj.phones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
