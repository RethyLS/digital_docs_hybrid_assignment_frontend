import 'package:json_annotation/json_annotation.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/meta.dart';

part 'employee_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class EmployeeResponse {
  final List<Employee> data;
  final Meta? meta;

  EmployeeResponse({
    required this.data,
    this.meta,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) => _$EmployeeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeResponseToJson(this);
}
