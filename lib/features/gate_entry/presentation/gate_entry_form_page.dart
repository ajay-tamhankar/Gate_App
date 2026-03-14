import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/gate_entry_form_controller.dart';

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

  String _gateDirection = 'Gate In';
  String _materialCode = 'MAT-A123';
  String? _attachmentFileName;

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
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _attachmentFileName = result.files.single.name;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final qty = double.tryParse(_quantityCtrl.text) ?? 0.0;
      ref.read(gateEntryFormControllerProvider.notifier).submit(
            challanNumber: _challanCtrl.text,
            vendorName: _vendorCtrl.text,
            vehicleNumber: _vehicleCtrl.text,
            poNumber: _poCtrl.text,
            gateDirection: _gateDirection,
            materialCode: _materialCode,
            quantity: qty,
            transporterName: _transporterCtrl.text,
            attachmentFileName: _attachmentFileName,
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gateEntryFormControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Gate Entry')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _gateDirection,
                              decoration: const InputDecoration(
                                  labelText: 'Gate Status'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'Gate In', child: Text('Gate In')),
                                DropdownMenuItem(
                                    value: 'Gate Out', child: Text('Gate Out')),
                              ],
                              onChanged: (val) =>
                                  setState(() => _gateDirection = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _materialCode,
                              decoration: const InputDecoration(
                                  labelText: 'Material Code'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'MAT-A123', child: Text('MAT-A123')),
                                DropdownMenuItem(
                                    value: 'MAT-B456', child: Text('MAT-B456')),
                                DropdownMenuItem(
                                    value: 'MAT-C789', child: Text('MAT-C789')),
                              ],
                              onChanged: (val) =>
                                  setState(() => _materialCode = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _challanCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Challan Number'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _poCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'PO Number'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _vehicleCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Vehicle Number'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _transporterCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Transporter Name'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _vendorCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Vendor Name'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Quantity'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Must be a number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickAttachment,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Attachment'),
                          ),
                          const SizedBox(width: 16),
                          if (_attachmentFileName != null)
                            Expanded(
                              child: Text(
                                'File: $_attachmentFileName',
                                style: const TextStyle(color: Colors.green),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Submit Gate Entry'),
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
