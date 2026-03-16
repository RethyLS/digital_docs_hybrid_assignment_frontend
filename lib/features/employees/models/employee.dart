import 'package:json_annotation/json_annotation.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/branch.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/department.dart';

part 'employee.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Employee {
  final int id;
  final String? employeeCode;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? position;
  final int? departmentId;
  final int? branchId;
  final int? organizationId;
  final String? joinDate;
  final String? status;
  final Branch? branch;
  final Department? department;

  Employee({
    required this.id,
    this.employeeCode,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.position,
    this.departmentId,
    this.branchId,
    this.organizationId,
    this.joinDate,
    this.status,
    this.branch,
    this.department,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
}
