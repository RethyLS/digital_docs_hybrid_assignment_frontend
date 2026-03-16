// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      id: (json['id'] as num).toInt(),
      employeeCode: json['employee_code'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      position: json['position'] as String?,
      departmentId: (json['department_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      organizationId: (json['organization_id'] as num?)?.toInt(),
      joinDate: json['join_date'] as String?,
      status: json['status'] as String?,
      branch: json['branch'] == null
          ? null
          : Branch.fromJson(json['branch'] as Map<String, dynamic>),
      department: json['department'] == null
          ? null
          : Department.fromJson(json['department'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'id': instance.id,
      'employee_code': instance.employeeCode,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'position': instance.position,
      'department_id': instance.departmentId,
      'branch_id': instance.branchId,
      'organization_id': instance.organizationId,
      'join_date': instance.joinDate,
      'status': instance.status,
      'branch': instance.branch,
      'department': instance.department,
    };
