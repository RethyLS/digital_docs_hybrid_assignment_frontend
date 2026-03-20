import 'package:json_annotation/json_annotation.dart';

part 'permission.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Permission {
  final int id;
  final String? name;
  final String? guardName;
  final int? rolesCount;
  final String? description;

  Permission({
    required this.id,
    this.name,
    this.guardName,
    this.rolesCount,
    this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionToJson(this);
}
