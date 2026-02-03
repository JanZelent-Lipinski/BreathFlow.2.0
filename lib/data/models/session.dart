import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 1)
class Session extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int durationSeconds;

  @HiveField(3)
  final String methodType;

  @HiveField(4)
  final double? cpScore;

  Session({
    required this.id,
    required this.date,
    required this.durationSeconds,
    required this.methodType,
    this.cpScore,
  });
}
