import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import 'controllers/reco_exception_detail_controller.dart';
import '../domain/entities/reco_exception.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/widgets/logout_action.dart';
import 'controllers/reco_list_controller.dart';

class RecoExceptionDetailPage extends ConsumerWidget {
  final String exceptionId;

  const RecoExceptionDetailPage({super.key, required this.exceptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(recoExceptionDetailProvider(exceptionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exception Details'),
        actions: const [
          LogoutAction(),
          SizedBox(width: 8),
        ],
      ),
      body: detailAsync.when(
        data: (exception) => _buildContent(context, ref, exception),
        loading: () => ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            SkeletonLoader(width: 200, height: 28),
            SizedBox(height: 16),
            SkeletonLoader(width: double.infinity, height: 180),
          ],
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, RecoException exc) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canResolve =
        role == UserRole.warehouseManager || role == UserRole.admin;

    final createdAt =
        DateFormat('MMM dd, yyyy • hh:mm a').format(exc.createdAt.toLocal());
    final resolvedAt =
        exc.resolvedAt != null ? exc.resolvedAt! : 'Not resolved';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SectionHeader(
          title: 'Exception ${exc.id}',
          subtitle: 'Gate Entry: ${exc.gateEntryId}',
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Status', exc.status),
                const SizedBox(height: 12),
                _infoRow('PO Number', exc.poNumber),
                const SizedBox(height: 12),
                _infoRow('Created', createdAt),
                const SizedBox(height: 12),
                _infoRow('Resolved At', resolvedAt),
                const SizedBox(height: 16),
                Text('Description',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(exc.description),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (canResolve)
          FilledButton.icon(
            onPressed: () async {
              final notes = await _showResolveDialog(context);
              if (notes == null) return;
              await ref
                  .read(recoListControllerProvider.notifier)
                  .resolveException(exc.id, notes);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exception resolved'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Resolve Exception'),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Future<String?> _showResolveDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Exception'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Resolution Notes',
            hintText: 'Provide resolution details',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
    return result != null && result.isNotEmpty ? result : null;
  }
}
