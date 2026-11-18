import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/odp.dart';

class CustomerFormDialog extends StatefulWidget {
  final Customer? customer;
  final List<Area> areas;
  final List<Odp> odps;
  final Function(
    String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  )
  onSubmit;

  const CustomerFormDialog({
    super.key,
    this.customer,
    required this.areas,
    required this.odps,
    required this.onSubmit,
  });

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  int? _selectedAreaId;
  int? _selectedOdpId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.customer?.address ?? '',
    );
    _selectedAreaId = widget.customer?.areaId;
    _selectedOdpId = widget.customer?.odpId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();

      widget.onSubmit(
        name,
        phone.isEmpty ? null : phone,
        address.isEmpty ? null : address,
        _selectedAreaId,
        _selectedOdpId,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    final filteredOdps = _selectedAreaId != null
        ? widget.odps.where((o) => o.areaId == _selectedAreaId).toList()
        : widget.odps;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Nama Pelanggan',
                hint: 'mis. Budi Santoso',
                validator: (val) {
                  final requiredErr = FormValidators.required(
                    val,
                    message: 'Nama pelanggan wajib diisi',
                  );
                  if (requiredErr != null) return requiredErr;
                  return FormValidators.minLength(
                    val,
                    2,
                    message: 'Nama pelanggan minimal 2 karakter',
                  );
                },
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                controller: _phoneController,
                label: 'Nomor Telepon (Opsional)',
                hint: 'mis. +6281234567890',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                controller: _addressController,
                label: 'Alamat (Opsional)',
                hint: 'Alamat lengkap pelanggan...',
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.p16),
              AppDropdownField<int>(
                value: _selectedAreaId,
                label: 'Area Jaringan (Opsional)',
                hint: 'Pilih area',
                items: widget.areas.map((a) => a.id).toList(),
                itemLabel: (id) =>
                    widget.areas.where((a) => a.id == id).firstOrNull?.name ??
                    '$id',
                onChanged: (val) {
                  setState(() {
                    _selectedAreaId = val;
                    // Reset ODP jika tidak sesuai area baru
                    if (_selectedOdpId != null) {
                      final odp = widget.odps
                          .where((o) => o.id == _selectedOdpId)
                          .firstOrNull;
                      if (odp != null && odp.areaId != val) {
                        _selectedOdpId = null;
                      }
                    }
                  });
                },
              ),
              const SizedBox(height: AppSizes.p16),
              AppDropdownField<int>(
                value: _selectedOdpId,
                label: 'Titik ODP (Opsional)',
                hint: 'Pilih ODP',
                items: filteredOdps.map((o) => o.id).toList(),
                itemLabel: (id) =>
                    filteredOdps.where((o) => o.id == id).firstOrNull?.code ??
                    '$id',
                onChanged: (val) {
                  setState(() {
                    _selectedOdpId = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(onPressed: _submit, child: const Text(AppStrings.save)),
      ],
    );
  }
}
