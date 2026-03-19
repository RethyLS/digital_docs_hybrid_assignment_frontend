import 'package:json_annotation/json_annotation.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/meta.dart';

part 'document_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DocumentResponse {
  final List<Document> data;
  final Meta? meta;

  DocumentResponse({
    required this.data,
    this.meta,
  });

  factory DocumentResponse.fromJson(Map<String, dynamic> json) => _$DocumentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentResponseToJson(this);
}
