import 'package:json_annotation/json_annotation.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/models/permission.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/meta.dart';

part 'permission_list_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PermissionListResponse {
  final List<Permission> data;
  final Meta? meta;

  PermissionListResponse({
    required this.data,
    this.meta,
  });

  factory PermissionListResponse.fromJson(Map<String, dynamic> json) => _$PermissionListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionListResponseToJson(this);
}
