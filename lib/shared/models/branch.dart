import 'package:json_annotation/json_annotation.dart';

part 'branch.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Branch {
  final int id;
  final String? name;
  final String? address;
  final String? phone;

  Branch({
    required this.id,
    this.name,
    this.address,
    this.phone,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);
  Map<String, dynamic> toJson() => _$BranchToJson(this);
}
