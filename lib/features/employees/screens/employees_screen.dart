import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/widgets/employee_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/branch.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/department.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final mockEmployees = [
      Employee(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        position: 'Software Engineer',
        employeeCode: 'EMP-001',
        department: Department(id: 1, name: 'IT Department'),
        branch: Branch(id: 1, name: 'Main Office'),
      ),
      Employee(
        id: 2,
        firstName: 'Jane',
        lastName: 'Smith',
        position: 'HR Manager',
        employeeCode: 'EMP-002',
        department: Department(id: 2, name: 'Human Resources'),
        branch: Branch(id: 1, name: 'Main Office'),
      ),
      Employee(
        id: 3,
        firstName: 'Alice',
        lastName: 'Johnson',
        position: 'UI/UX Designer',
        employeeCode: 'EMP-003',
        department: Department(id: 3, name: 'Design'),
        branch: Branch(id: 2, name: 'Development Center'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.userPlus, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: HeroIcon(HeroIcons.magnifyingGlass, size: 20),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: mockEmployees.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return EmployeeCard(employee: mockEmployees[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
