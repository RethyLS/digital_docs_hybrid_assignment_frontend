import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/widgets/document_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/category.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock Data
    final mockDocuments = [
      Document(
        id: 1,
        organizationId: 1,
        title: 'Employee Handbook 2024',
        documentCode: 'HR-DOC-001',
        status: 'Active',
        fileType: 'pdf',
        fileSize: 2048,
        category: Category(id: 1, name: 'Policy'),
        expirationDate: DateTime(2025, 12, 31),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 1,
      ),
      Document(
        id: 2,
        organizationId: 1,
        title: 'Q3 Financial Report',
        documentCode: 'FIN-2023-Q3',
        status: 'Pending',
        fileType: 'xlsx',
        fileSize: 5120,
        category: Category(id: 2, name: 'Finance'),
        expirationDate: DateTime(2024, 06, 30),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 1,
      ),
      Document(
        id: 3,
        organizationId: 1,
        title: 'Project Alpha Requirements',
        documentCode: 'PROJ-ALP-01',
        status: 'Approved',
        fileType: 'docx',
        fileSize: 1024,
        category: Category(id: 3, name: 'Project'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 2,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.funnel, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const HeroIcon(HeroIcons.plus, size: 24),
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
                hintText: 'Search documents...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: HeroIcon(HeroIcons.magnifyingGlass, size: 20),
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const HeroIcon(
                    HeroIcons.commandLine,
                    size: 14,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: mockDocuments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return DocumentCard(document: mockDocuments[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
