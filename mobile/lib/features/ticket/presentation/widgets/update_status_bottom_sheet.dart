import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class UpdateStatusBottomSheet extends StatefulWidget {
  final String currentStatus;
  final String nextStatus;
  final ValueChanged<String?> onConfirmed;

  const UpdateStatusBottomSheet({
    super.key,
    required this.currentStatus,
    required this.nextStatus,
    required this.onConfirmed,
  });

  static Future<String?> show({
    required BuildContext context,
    required String currentStatus,
    required String nextStatus,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (context) {
        return UpdateStatusBottomSheet(
          currentStatus: currentStatus,
          nextStatus: nextStatus,
          onConfirmed: (note) => Navigator.of(context).pop(note ?? ''),
        );
      },
    );
  }

  @override
  State<UpdateStatusBottomSheet> createState() =>
      _UpdateStatusBottomSheetState();
}

class _UpdateStatusBottomSheetState extends State<UpdateStatusBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _isResolving => widget.nextStatus == 'resolved';

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onConfirmed(_noteController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final actionTitle = _isResolving
        ? 'Selesaikan Tiket Gangguan'
        : 'Mulai Pengerjaan Tiket';

    return Padding(
      padding: EdgeInsets.only(
        top: AppSizes.p20,
        left: AppSizes.p16,
        right: AppSizes.p16,
        bottom: bottomInset + AppSizes.p20,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  actionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              _isResolving
                  ? 'Harap sertakan catatan tindakan perbaikan yang telah dilakukan untuk menyelesaikan tiket ini.'
                  : 'Status tiket akan diubah menjadi Sedang Dikerjakan (In Progress).',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            AppTextField(
              label: _isResolving
                  ? 'Catatan Perbaikan (Wajib)'
                  : 'Catatan Tambahan (Opsional)',
              hint: _isResolving
                  ? 'Contoh: Kabel fiber putus telah disambung dan redaman optik kembali normal (min. 5 karakter)...'
                  : 'Catatan teknisi...',
              controller: _noteController,
              maxLines: 3,
              validator: (val) {
                if (_isResolving) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Catatan wajib diisi saat tiket diselesaikan';
                  }
                  if (val.trim().length < 5) {
                    return 'Catatan minimal 5 karakter';
                  }
                }
                if (val != null && val.trim().length > 500) {
                  return 'Catatan maksimal 500 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.p20),
            AppButton(
              text: _isResolving
                  ? 'Konfirmasi Tiket Selesai'
                  : 'Mulai Sekarang',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
