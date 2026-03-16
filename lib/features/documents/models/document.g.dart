// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
      id: (json['id'] as num).toInt(),
      organizationId: (json['organization_id'] as num).toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      documentCategoryId: (json['document_category_id'] as num?)?.toInt(),
      documentPrefixId: (json['document_prefix_id'] as num?)?.toInt(),
      createdBy: (json['created_by'] as num).toInt(),
      updatedBy: (json['updated_by'] as num?)?.toInt(),
      documentCode: json['document_code'] as String?,
      verificationToken: json['verification_token'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      expirationDate: json['expiration_date'] == null
          ? null
          : DateTime.parse(json['expiration_date'] as String),
      status: json['status'] as String?,
      visibility: json['visibility'] as String?,
      fileName: json['file_name'] as String?,
      fileType: json['file_type'] as String?,
      fileSize: (json['file_size'] as num).toInt(),
      mimeType: json['mime_type'] as String?,
      filePath: json['file_path'] as String?,
      fileUrl: json['file_url'] as String?,
      qrToken: json['qr_token'] as String?,
      qrCodePath: json['qr_code_path'] as String?,
      qrCodeUrl: json['qr_code_url'] as String?,
      isExpired: json['is_expired'] as bool? ?? false,
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      branch: json['branch'] == null
          ? null
          : Branch.fromJson(json['branch'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'branch_id': instance.branchId,
      'document_category_id': instance.documentCategoryId,
      'document_prefix_id': instance.documentPrefixId,
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy,
      'document_code': instance.documentCode,
      'verification_token': instance.verificationToken,
      'title': instance.title,
      'description': instance.description,
      'expiration_date': instance.expirationDate?.toIso8601String(),
      'status': instance.status,
      'visibility': instance.visibility,
      'file_name': instance.fileName,
      'file_type': instance.fileType,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'file_path': instance.filePath,
      'file_url': instance.fileUrl,
      'qr_token': instance.qrToken,
      'qr_code_path': instance.qrCodePath,
      'qr_code_url': instance.qrCodeUrl,
      'is_expired': instance.isExpired,
      'category': instance.category,
      'branch': instance.branch,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
