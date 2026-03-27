import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/document_prefix.dart';

final documentPrefixesProvider = FutureProvider.autoDispose<List<DocumentPrefix>>((ref) async {
  final repo = ref.watch(documentPrefixRepositoryProvider);
  return repo.getPrefixes();
});
