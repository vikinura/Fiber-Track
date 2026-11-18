import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/area.dart';

class AreaFormDialog extends StatefulWidget {
  final Area? area;
  final Function(String name, String? description) onSubmit;

  const AreaFormDialog({super.key, this.area, required this.onSubmit});

  @override
  State<AreaFormDialog> createState() => _AreaFormDialogState();
}

class _AreaFormDialogState extends State<AreaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.area?.name ?? '');
    _descController = TextEditingController(
      text: widget.area?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final desc = _descController.text.trim();
      widget.onSubmit(name, desc.isEmpty ? null : desc);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.area != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Area Jaringan' : 'Tambah Area Jaringan'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Nama Area',
                hint: 'mis. Surabaya Barat',
                validator: (val) {
                  final requiredErr = FormValidators.required(
                    val,
                    message: 'Nama area wajib diisi',
                  );
                  if (requiredErr != null) return requiredErr;
                  return FormValidators.minLength(
                    val,
                    2,
                    message: 'Nama area minimal 2 karakter',
                  );
                },
              ),
              const SizedBox(height: AppSizes.p16),
              AppTextField(
                controller: _descController,
                label: 'Deskripsi (Opsional)',
                hint: 'Keterangan cakupan area...',
                maxLines: 3,
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
