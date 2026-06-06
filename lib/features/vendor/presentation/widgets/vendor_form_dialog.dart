import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/widgets/ribbon.dart';
import '../../domain/models/vendor.dart';
import '../controllers/vendor_providers.dart';

/// Shows the add/edit vendor dialog. Returns the created/updated [Vendor] when
/// the form is saved successfully, or `null` if the user cancelled.
Future<Vendor?> showVendorFormDialog(
  BuildContext context, {
  Vendor? existing,
}) {
  return showDialog<Vendor>(
    context: context,
    barrierDismissible: false,
    builder: (_) => VendorFormDialog(existing: existing),
  );
}

class VendorFormDialog extends ConsumerStatefulWidget {
  final Vendor? existing;

  const VendorFormDialog({super.key, this.existing});

  @override
  ConsumerState<VendorFormDialog> createState() => _VendorFormDialogState();
}

class _VendorFormDialogState extends ConsumerState<VendorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late VendorType _vendorType;
  late bool _isActive;
  bool _submitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.existing?.vendorCode ?? '');
    _nameCtrl = TextEditingController(text: widget.existing?.vendorName ?? '');
    _vendorType = widget.existing?.vendorType ?? VendorType.purchase;
    _isActive = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(vendorActionControllerProvider.notifier);

    setState(() => _submitting = true);
    Vendor? result;
    String? errorMessage;
    try {
      if (_isEdit) {
        final existing = widget.existing!;
        // For PATCH only send changed fields.
        final request = VendorWriteRequest(
          vendorCode: _codeCtrl.text.trim() != existing.vendorCode
              ? _codeCtrl.text.trim()
              : null,
          vendorName: _nameCtrl.text.trim() != existing.vendorName
              ? _nameCtrl.text.trim()
              : null,
          vendorType:
              _vendorType != existing.vendorType ? _vendorType : null,
          isActive: _isActive != existing.isActive ? _isActive : null,
        );
        // The backend requires at least one field; bail out early if nothing
        // changed so the user gets a clearer message than the server's 400.
        if (request.toJson().isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No changes to save.')),
            );
            setState(() => _submitting = false);
          }
          return;
        }
        result = await controller.update(existing.id, request);
      } else {
        result = await controller.create(VendorWriteRequest(
          vendorCode: _codeCtrl.text.trim(),
          vendorName: _nameCtrl.text.trim(),
          vendorType: _vendorType,
          isActive: _isActive,
        ));
      }
      if (result == null) {
        final lastErr = controller.lastError;
        errorMessage =
            lastErr != null ? lastErr.toString() : 'Could not save vendor.';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }

    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(result);
      return;
    }
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            _cleanError(errorMessage),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = mediaWidth < 520 ? mediaWidth - 32 : 460.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const RibbonAccentBar(height: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit Vendor' : 'Add Vendor',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeCtrl,
                  enabled: !_submitting,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Vendor Code *',
                    hintText: 'e.g. 376902915',
                    prefixIcon: Icon(Icons.qr_code_2),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vendor code is required';
                    }
                    if (v.trim().length > 64) {
                      return 'Vendor code is too long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  enabled: !_submitting,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Vendor Name *',
                    hintText: 'e.g. ASTRONIC TECHNOSYSTEMS LLP',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vendor name is required';
                    }
                    if (v.trim().length > 200) {
                      return 'Vendor name is too long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<VendorType>(
                  initialValue: _vendorType,
                  decoration: const InputDecoration(
                    labelText: 'Vendor Type *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: VendorType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ))
                      .toList(),
                  onChanged: _submitting
                      ? null
                      : (v) {
                          if (v != null) setState(() => _vendorType = v);
                        },
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: _submitting
                      ? null
                      : (v) => setState(() => _isActive = v),
                  title: Text(
                    'Active',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _isActive
                        ? 'Vendor is available for selection'
                        : 'Vendor is hidden from selection',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RibbonButton(
                        label: _isEdit ? 'Save Changes' : 'Add Vendor',
                        icon: _isEdit
                            ? Icons.save_rounded
                            : Icons.add_circle_outline,
                        loading: _submitting,
                        fullWidth: true,
                        onPressed: _submitting ? null : _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _cleanError(String raw) {
  // Strip noisy "Exception: " prefixes from thrown errors.
  return raw
      .replaceAll('Exception: ', '')
      .replaceAll('Exception:', '')
      .trim();
}
