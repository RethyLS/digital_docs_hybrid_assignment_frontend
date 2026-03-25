import 'package:json_annotation/json_annotation.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/role.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/organization.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? image;
  final String? email;
  final String? phone;
  final String? bio;
  final String? status;
  final Organization? organization;
  final List<Role>? roles;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    this.image,
    this.email,
    this.phone,
    this.bio,
    this.status,
    this.organization,
    this.roles,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get roleName => roles != null && roles!.isNotEmpty ? (roles!.first.name ?? 'N/A') : 'N/A';

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
