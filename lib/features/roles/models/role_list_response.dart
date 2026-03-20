import 'package:json_annotation/json_annotation.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/role.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/meta.dart';

part 'role_list_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RoleListResponse {
  final List<Role> data;
  final Meta? meta;

  RoleListResponse({
    required this.data,
    this.meta,
  });

  factory RoleListResponse.fromJson(Map<String, dynamic> json) => _$RoleListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RoleListResponseToJson(this);
}
