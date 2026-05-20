import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/loading_overlay.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../domain/models/warehouse_gate_entry.dart';
import '../domain/models/warehouse_grn.dart';
import 'controllers/warehouse_providers.dart';

class WarehouseGrnCreatePage extends ConsumerStatefulWidget {
  final WarehouseGateEntryDetail entry;

  const WarehouseGrnCreatePage({super.key, required this.entry});

  @override
  ConsumerState<WarehouseGrnCreatePage> createState() =>
      _WarehouseGrnCreatePageState();
}

class _WarehouseGrnCreatePageState
    extends ConsumerState<WarehouseGrnCreatePage> {
  final _remarksController = TextEditingController();
  final List<_GrnItemForm> _items = [];

  @override
  void initState() {
    super.initState();
    for (final item in widget.entry.items) {
      _items.add(_GrnItemForm(
        materialController: TextEditingController(text: item.materialCode),
        receivedController:
            TextEditingController(text: item.challanQty.toString()),
        acceptedController:
            TextEditingController(text: item.challanQty.toString()),
        rejectedController: TextEditingController(text: '0'),
      ));
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final parsedItems = <WarehouseGrnItem>[];
    for (final item in _items) {
      final material = item.materialController.text.trim();
      final received = num.tryParse(item.receivedController.text.trim());
      final accepted = num.tryParse(item.acceptedController.text.trim());
      final rejected = num.tryParse(item.rejectedController.text.trim());

      if (material.isEmpty || received == null || accepted == null || rejected == null) {
        _showError('Please fill all GRN item fields with valid numbers.');
        return;
      }
      if (accepted + rejected != received) {
        _showError('Accepted + Rejected must equal Received for $material.');
        return;
      }

      parsedItems.add(WarehouseGrnItem(
        materialName: material,
        receivedQty: received,
        acceptedQty: accepted,
        rejectedQty: rejected,
      ));
    }

    final request = WarehouseGrnRequest(
      gateEntryId: widget.entry.id,
      items: parsedItems,
      remarks: _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim(),
    );

    final controller = ref.read(warehouseGrnControllerProvider.notifier);
    final success = await controller.submitGrn(request);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GRN submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit GRN'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMob = isMobile(context);
    final state = ref.watch(warehouseGrnControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create GRN'),
        actions: const [
          LogoutAction(),
          SizedBox(width: 8),
        ],
      ),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        message: 'Submitting GRN...',
        child: ListView(
        padding: EdgeInsets.symmetric(horizontal: isMob ? 16 : 24, vertical: 16),
        children: [
          const SectionHeader(
            title: 'GRN Details',
            subtitle: 'Capture received quantities and submit GRN.',
          ),
          const SizedBox(height: 12),
          ..._items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Item $index',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildField(
                          isMob: isMob,
                          label: 'Material Name',
                          controller: item.materialController,
                        ),
                        _buildField(
                          isMob: isMob,
                          label: 'Received Qty',
                          controller: item.receivedController,
                          isNumeric: true,
                        ),
                        _buildField(
                          isMob: isMob,
                          label: 'Accepted Qty',
                          controller: item.acceptedController,
                          isNumeric: true,
                        ),
                        _buildField(
                          isMob: isMob,
                          label: 'Rejected Qty',
                          controller: item.rejectedController,
                          isNumeric: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          TextField(
            controller: _remarksController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Remarks (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isLoading ? null : _submit,
              icon: const Icon(Icons.send),
              label: Text(state.isLoading ? 'Submitting...' : 'Submit GRN'),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildField({
    required bool isMob,
    required String label,
    required TextEditingController controller,
    bool isNumeric = false,
  }) {
    return SizedBox(
      width: isMob ? double.infinity : 220,
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _GrnItemForm {
  final TextEditingController materialController;
  final TextEditingController receivedController;
  final TextEditingController acceptedController;
  final TextEditingController rejectedController;

  _GrnItemForm({
    required this.materialController,
    required this.receivedController,
    required this.acceptedController,
    required this.rejectedController,
  });

  void dispose() {
    materialController.dispose();
    receivedController.dispose();
    acceptedController.dispose();
    rejectedController.dispose();
  }
}
