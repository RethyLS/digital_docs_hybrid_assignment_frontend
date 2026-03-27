import 'package:json_annotation/json_annotation.dart';

part 'document_prefix.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DocumentPrefix {
  final int id;
  final String? name;
  final String? prefix;
  final String? separator;
  final String? format;
  final String? description;
  final String? status;
  final bool? isDefault;

  DocumentPrefix({
    required this.id,
    this.name,
    this.prefix,
    this.separator,
    this.format,
    this.description,
    this.status,
    this.isDefault,
  });

  factory DocumentPrefix.fromJson(Map<String, dynamic> json) => _$DocumentPrefixFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentPrefixToJson(this);
}
