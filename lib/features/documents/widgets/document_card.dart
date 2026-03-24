import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/utils/image_utils.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/repositories/document_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/widgets/custom_card.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';

class DocumentCard extends ConsumerStatefulWidget {
  final Document document;
  final VoidCallback? onTap;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
  });

  @override
  ConsumerState<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends ConsumerState<DocumentCard> {
  bool _isDownloading = false;

  Future<void> _handleView() async {
    if (widget.document.fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document URL is missing')),
      );
      return;
    }
    
    final url = Uri.parse(getFullImageUrl(widget.document.fileUrl));
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document in external browser')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open document: $e')),
        );
      }
    }
  }

  Future<void> _handleDownload() async {
    if (widget.document.fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document URL is missing')),
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final repo = ref.read(documentRepositoryProvider);
      final fileName = widget.document.fileName ?? 'document_${widget.document.id}.pdf';
      
      final filePath = await repo.downloadDocument(widget.document.id, fileName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded to $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  final result = await OpenFilex.open(filePath);
                  if (result.type != ResultType.done) {
                    if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Could not open file: ${result.message}')),
                       );
                    }
                  }
                } catch (e) {
                   if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Could not open file: $e')),
                       );
                    }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final document = widget.document;
    
    return CustomCard(
      onTap: widget.onTap ?? () => context.push('/documents/detail', extra: document),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HeroIcon(
                  _getFileIcon(document.fileType),
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title ?? 'Untitled Document',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      document.documentCode ?? 'NO-CODE',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isDownloading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                PopupMenuButton<String>(
                  icon: HeroIcon(
                    HeroIcons.ellipsisVertical,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onSelected: (value) {
                    if (value == 'view') _handleView();
                    if (value == 'download') _handleDownload();
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          HeroIcon(HeroIcons.eye, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          const SizedBox(width: 8),
                          const Text('View'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          HeroIcon(HeroIcons.arrowDownTray, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          const SizedBox(width: 8),
                          const Text('Download'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: _buildInfoItem(
                        context, 
                        HeroIcons.calendar, 
                        document.expirationDate != null 
                          ? DateFormat('MMM dd, yyyy').format(document.expirationDate!)
                          : 'No Expiry'
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: _buildInfoItem(
                        context, 
                        HeroIcons.tag, 
                        document.category?.name ?? 'Uncategorized'
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(context, document.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, HeroIcons icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeroIcon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    final theme = Theme.of(context);
    Color color;
    switch (status?.toLowerCase()) {
      case 'active':
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'expired':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status?.toUpperCase() ?? 'UNKNOWN',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  HeroIcons _getFileIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return HeroIcons.documentText;
      case 'doc':
      case 'docx':
        return HeroIcons.documentText;
      case 'xls':
      case 'xlsx':
        return HeroIcons.tableCells;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return HeroIcons.photo;
      default:
        return HeroIcons.document;
    }
  }
}

