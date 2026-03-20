import 'package:json_annotation/json_annotation.dart';

part 'role.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Role {
  final int id;
  final String? name;
  final String? guardName;
  final String? description;
  final int? permissionsCount;
  final int? usersCount;

  Role({
    required this.id,
    this.name,
    this.guardName,
    this.description,
    this.permissionsCount,
    this.usersCount,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
