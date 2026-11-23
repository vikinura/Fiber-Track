import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class UploadPhotoBottomSheet extends StatefulWidget {
  final int ticketId;
  final Function(String filePath, String? caption) onUpload;

  const UploadPhotoBottomSheet({
    super.key,
    required this.ticketId,
    required this.onUpload,
  });

  static Future<void> show({
    required BuildContext context,
    required int ticketId,
    required Function(String filePath, String? caption) onUpload,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (context) =>
          UploadPhotoBottomSheet(ticketId: ticketId, onUpload: onUpload),
    );
  }

  @override
  State<UploadPhotoBottomSheet> createState() => _UploadPhotoBottomSheetState();
}

class _UploadPhotoBottomSheetState extends State<UploadPhotoBottomSheet> {
  final _picker = ImagePicker();
  final _captionController = TextEditingController();
  XFile? _selectedImage;
  String? _errorMessage;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.length();
      final sizeInMb = bytes / (1024 * 1024);

      // Validasi ekstensi
      final lowerName =
          (pickedFile.name.isNotEmpty ? pickedFile.name : pickedFile.path)
              .toLowerCase();
      final isAllowedExt =
          lowerName.endsWith('.jpg') ||
          lowerName.endsWith('.jpeg') ||
          lowerName.endsWith('.png');

      if (!isAllowedExt) {
        setState(() {
          _errorMessage = 'Hanya format JPG, JPEG, dan PNG yang diizinkan';
        });
        return;
      }

      // Validasi ukuran maks 5 MB
      if (sizeInMb > 5) {
        setState(() {
          _errorMessage = 'Ukuran foto melebihi batas maksimal 5 MB';
        });
        return;
      }

      setState(() {
        _selectedImage = pickedFile;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memilih gambar: $e';
      });
    }
  }

  void _submit() {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Silakan pilih foto terlebih dahulu';
      });
      return;
    }

    final caption = _captionController.text.trim();
    widget.onUpload(_selectedImage!.path, caption.isNotEmpty ? caption : null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
        left: AppSizes.p16,
        right: AppSizes.p16,
        top: AppSizes.p16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              'Unggah Foto Bukti',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p4),
            Text(
              'Format JPG, JPEG, atau PNG (Maks. 5 MB)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.p16),

            // Tampilan preview atau tombol pemilih
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                    child: kIsWeb
                        ? Image.network(
                            _selectedImage!.path,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : FutureBuilder<Uint8List>(
                            future: _selectedImage!.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Container(
                                height: 180,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Kamera'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeri'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            if (_errorMessage != null) ...[
              const SizedBox(height: AppSizes.p8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: AppSizes.p16),
            AppTextField(
              controller: _captionController,
              label: 'Keterangan Foto (Opsional)',
              hint: 'Contoh: Kondisi kabel putus sebelum perbaikan',
              maxLength: 255,
            ),
            const SizedBox(height: AppSizes.p20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Batal',
                    isOutlined: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: AppButton(text: 'Unggah', onPressed: _submit),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
          ],
        ),
      ),
    );
  }
}
