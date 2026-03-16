import 'package:json_annotation/json_annotation.dart';

part 'department.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Department {
  final int id;
  final String? name;
  final String? description;

  Department({
    required this.id,
    this.name,
    this.description,
  });

  factory Department.fromJson(Map<String, dynamic> json) => _$DepartmentFromJson(json);
  Map<String, dynamic> toJson() => _$DepartmentToJson(this);
}
