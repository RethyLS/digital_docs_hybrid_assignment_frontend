import 'package:json_annotation/json_annotation.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/meta.dart';

part 'user_list_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserListResponse {
  final List<User> data;
  final Meta? meta;

  UserListResponse({
    required this.data,
    this.meta,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) => _$UserListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserListResponseToJson(this);
}
