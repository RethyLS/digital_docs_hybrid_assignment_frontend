import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document.dart';

class DashboardData {
  final int totalDocuments;
  final int totalEmployees;
  final int activeEmployees;
  final int totalUsers;
  final List<Document> recentDocuments;

  DashboardData({
    required this.totalDocuments,
    required this.totalEmployees,
    required this.activeEmployees,
    required this.totalUsers,
    required this.recentDocuments,
  });
}
