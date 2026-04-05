import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/providers/document_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/repositories/document_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/utils/dialog_utils.dart';
import 'package:intl/intl.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {


  Future<void> _deleteDocument() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      DialogUtils.showLoadingDialog(context, message: 'Deleting...');
      try {
        final repo = ref.read(documentRepositoryProvider);
        final success = await repo.deleteDocument(widget.document.id);
        
        if (mounted) DialogUtils.hideLoadingDialog(context);

        if (success && mounted) {
          ref.invalidate(documentsProvider);
          DialogUtils.showSuccessDialog(
            context,
            message: 'Document deleted successfully',
            onDismiss: () => context.pop(),
          );
        }
      } catch (e) {
        if (mounted) DialogUtils.hideLoadingDialog(context);
        if (mounted) {
          DialogUtils.showErrorDialog(
            context,
            message: e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final document = widget.document;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
        actions: [
          IconButton(
            icon: HeroIcon(HeroIcons.trash, size: 24, color: Colors.redAccent.withValues(alpha: 0.8)),
            onPressed: _deleteDocument,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title ?? 'Untitled Document',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    document.documentCode ?? 'NO-CODE',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        HeroIcons.folder,
                        document.category?.name ?? 'Uncategorized',
                      ),
                      const SizedBox(width: 16),
                      _buildStatusBadge(context, document.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'File Information',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildDetailRow(context, HeroIcons.document, 'File Name', document.fileName ?? 'N/A'),
                  const Divider(),
                  _buildDetailRow(context, HeroIcons.cpuChip, 'File Size', _formatFileSize(document.fileSize)),
                  const Divider(),
                  _buildDetailRow(context, HeroIcons.documentText, 'File Type', document.fileType?.toUpperCase() ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Document Lifecycle',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildDetailRow(context, HeroIcons.buildingOffice, 'Branch', document.branch?.name ?? 'N/A'),
                  const Divider(),
                  _buildDetailRow(context, HeroIcons.calendar, 'Created At', document.createdAt != null ? DateFormat('MMM dd, yyyy HH:mm').format(document.createdAt!) : 'N/A'),
                  const Divider(),
                  _buildDetailRow(
                    context, 
                    HeroIcons.calendarDays, 
                    'Expiration Date', 
                    document.expirationDate != null ? DateFormat('MMM dd, yyyy').format(document.expirationDate!) : 'No Expiry'
                  ),
                ],
              ),
            ),
            if (document.description != null && document.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: Text(
                  document.description!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'N/A';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Widget _buildInfoChip(BuildContext context, HeroIcons icon, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeroIcon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, HeroIcons icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroIcon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    final theme = Theme.of(context);
    Color color;
    switch (status?.toLowerCase()) {
      case 'active':
      case 'published':
        color = Colors.green;
        break;
      case 'pending':
      case 'draft':
        color = Colors.orange;
        break;
      case 'expired':
      case 'archived':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status?.toUpperCase() ?? 'UNKNOWN',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

