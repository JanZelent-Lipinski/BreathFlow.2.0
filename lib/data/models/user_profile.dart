import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2, defaultValue: false)
  final bool isChild;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4, defaultValue: false)
  final bool isPregnant;

  UserProfile({
    required this.id,
    required this.name,
    required this.isChild,
    required this.createdAt,
    this.isPregnant = false,
  });
}
