import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Organization {
  final int id;
  final String? name;
  final String? code;
  final String? type;

  Organization({
    required this.id,
    this.name,
    this.code,
    this.type,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizationToJson(this);
}
