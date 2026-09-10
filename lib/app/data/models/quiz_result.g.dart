// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizResultAdapter extends TypeAdapter<QuizResult> {
  @override
  final int typeId = 2;

  @override
  QuizResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizResult(
      quizId: fields[0] as String,
      userAnswers: (fields[1] as List).cast<int>(),
      score: fields[2] as int,
      timeUsedSec: fields[3] as int,
      completedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuizResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.quizId)
      ..writeByte(1)
      ..write(obj.userAnswers)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.timeUsedSec)
      ..writeByte(4)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
