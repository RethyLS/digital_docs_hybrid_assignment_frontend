import 'package:json_annotation/json_annotation.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/branch.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/category.dart';

part 'document.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Document {
  final int id;
  final int organizationId;
  final int? branchId;
  final int? documentCategoryId;
  final int? documentPrefixId;
  final int createdBy;
  final int? updatedBy;
  final String? documentCode;
  final String? verificationToken;
  final String? title;
  final String? description;
  final DateTime? expirationDate;
  final String? status;
  final String? visibility;
  final String? fileName;
  final String? fileType;
  final int fileSize;
  final String? mimeType;
  final String? filePath;
  final String? fileUrl;
  final String? qrToken;
  final String? qrCodePath;
  final String? qrCodeUrl;
  final bool isExpired;
  final Category? category;
  final Branch? branch;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Document({
    required this.id,
    required this.organizationId,
    this.branchId,
    this.documentCategoryId,
    this.documentPrefixId,
    required this.createdBy,
    this.updatedBy,
    this.documentCode,
    this.verificationToken,
    this.title,
    this.description,
    this.expirationDate,
    this.status,
    this.visibility,
    this.fileName,
    this.fileType,
    required this.fileSize,
    this.mimeType,
    this.filePath,
    this.fileUrl,
    this.qrToken,
    this.qrCodePath,
    this.qrCodeUrl,
    this.isExpired = false,
    this.category,
    this.branch,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentToJson(this);
}
