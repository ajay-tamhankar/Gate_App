import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'controllers/gate_entry_form_controller.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../domain/models/gate_entry.dart';

class GateEntryFormPage extends ConsumerStatefulWidget {
  const GateEntryFormPage({super.key});

  @override
  ConsumerState<GateEntryFormPage> createState() => _GateEntryFormPageState();
}

class _GateEntryFormPageState extends ConsumerState<GateEntryFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _challanCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _poCtrl = TextEditingController();
  final _transporterCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();

  GateMovement _gateDirection = GateMovement.inMovement;
  String _materialCode = 'MAT-A123';
  PlatformFile? _attachmentFile;

  @override
  void dispose() {
    _challanCtrl.dispose();
    _vendorCtrl.dispose();
    _vehicleCtrl.dispose();
    _poCtrl.dispose();
    _transporterCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      setState(() {
        _attachmentFile = result.files.single;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final qty = int.tryParse(_quantityCtrl.text) ?? 0;

      final Map<String, dynamic> params = {
        'challan_no': _challanCtrl.text,
        'vendor_name': _vendorCtrl.text,
        'vehicle_no': _vehicleCtrl.text,
        'transporter_name': _transporterCtrl.text,
        'gate_movement':
            _gateDirection == GateMovement.inMovement ? 'in' : 'out',
        'items': [
          {
            'material_code': _materialCode,
            'po_number': _poCtrl.text,
            'challan_qty': qty,
          }
        ]
      };

      try {
        await ref.read(gateEntryFormControllerProvider.notifier).submit(
          params,
          attachmentFileName: _attachmentFile?.name,
          attachmentPath: kIsWeb ? null : _attachmentFile?.path,
          bytes: _attachmentFile?.bytes,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gate Entry successfully created!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 32.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopOrMobileRow(Widget child1, Widget child2) {
    if (isMobile(context)) {
      return Column(
        children: [
          child1,
          if (child2 is! SizedBox) const SizedBox(height: 16),
          child2,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child1),
        const SizedBox(width: 24),
        Expanded(child: child2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gateEntryFormControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Gate Entry'),
        actions: const [
          LogoutAction(),
          SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
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
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Entry Details',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Provide accurate information for warehouse tracing and GRN matching.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildSectionHeader(
                          '1. Gate Information', Icons.info_outline),
                      _buildDesktopOrMobileRow(
                          DropdownButtonFormField<GateMovement>(
                            isExpanded: true,
                            initialValue: _gateDirection,
                            decoration: const InputDecoration(
                                labelText: 'Gate Status',
                                prefixIcon: Icon(Icons.swap_horiz)),
                            items: const [
                              DropdownMenuItem(
                                  value: GateMovement.inMovement,
                                  child: Text('Gate In')),
                              DropdownMenuItem(
                                  value: GateMovement.outMovement,
                                  child: Text('Gate Out')),
                            ],
                            onChanged: (val) =>
                                setState(() => _gateDirection = val!),
                          ),
                          TextFormField(
                            controller: _challanCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Challan Number',
                                prefixIcon: Icon(Icons.receipt_long)),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Challan is required for tracking'
                                : null,
                          )),
                      _buildSectionHeader('2. Vendor & Transport',
                          Icons.local_shipping_outlined),
                      _buildDesktopOrMobileRow(
                          TextFormField(
                            controller: _vendorCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Vendor Name',
                                prefixIcon: Icon(Icons.storefront)),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Vendor name is required'
                                : null,
                          ),
                          TextFormField(
                            controller: _transporterCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Transporter Name',
                                prefixIcon: Icon(Icons.directions_car)),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Transporter is required'
                                : null,
                          )),
                      const SizedBox(height: 16),
                      _buildDesktopOrMobileRow(
                          TextFormField(
                            controller: _vehicleCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Vehicle Number',
                                prefixIcon: Icon(Icons.numbers)),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Vehicle number required'
                                : null,
                          ),
                          const SizedBox.shrink()),
                      _buildSectionHeader(
                          '3. Material Details', Icons.inventory_2_outlined),
                      _buildDesktopOrMobileRow(
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _materialCode,
                          decoration: const InputDecoration(
                              labelText: 'Material Code',
                              prefixIcon: Icon(Icons.category)),
                          items: const [
                            DropdownMenuItem(
                                value: 'MAT-A123',
                                child: Text(
                                  'MAT-A123 Base Resin',
                                  overflow: TextOverflow.ellipsis,
                                )),
                            DropdownMenuItem(
                                value: 'MAT-B456',
                                child: Text(
                                  'MAT-B456 Corrugated Box',
                                  overflow: TextOverflow.ellipsis,
                                )),
                            DropdownMenuItem(
                                value: 'MAT-C789',
                                child: Text(
                                  'MAT-C789 Shrink Wrap',
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                          onChanged: (val) =>
                              setState(() => _materialCode = val!),
                        ),
                        TextFormField(
                          controller: _poCtrl,
                          decoration: const InputDecoration(
                              labelText: 'PO Number',
                              prefixIcon: Icon(Icons.request_quote)),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Purchase Order number required'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDesktopOrMobileRow(
                        TextFormField(
                          controller: _quantityCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Quantity',
                              prefixIcon:
                                  Icon(Icons.production_quantity_limits),
                              helperText: 'Enter exact numerical quantity.'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Quantity required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Must be a valid integer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox.shrink(),
                      ),
                      _buildSectionHeader('4. Attachments', Icons.attachment),
                      Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _pickAttachment,
                                  icon: const Icon(Icons.cloud_upload),
                                  label: const Text('Browse Files'),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Text(
                                    _attachmentFile?.name ??
                                        'No file selected. Drag and drop tracking slip.',
                                    style: TextStyle(
                                      color: _attachmentFile != null
                                          ? Colors.green
                                          : Colors.grey.shade600,
                                      fontWeight: _attachmentFile != null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ])),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: isLoading ? null : _submit,
                          icon: isLoading
                              ? const SizedBox.shrink()
                              : const Icon(Icons.save),
                          label: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Confirm Gate Entry',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
