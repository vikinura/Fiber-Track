import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/ticket_photo.dart';

class TicketPhotoGallery extends StatefulWidget {
  final List<TicketPhoto> photos;
  final VoidCallback? onAddPhotoPressed;
  final bool canUpload;

  const TicketPhotoGallery({
    super.key,
    required this.photos,
    this.onAddPhotoPressed,
    this.canUpload = false,
  });

  @override
  State<TicketPhotoGallery> createState() => _TicketPhotoGalleryState();
}

class _TicketPhotoGalleryState extends State<TicketPhotoGallery> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await getIt<TokenStorage>().getToken();
    if (mounted) {
      setState(() {
        _token = token;
      });
    }
  }

  String _getPhotoUrl(int photoId) {
    if (_token != null && _token!.isNotEmpty) {
      return '${AppConfig.apiBaseUrl}/tickets/photos/$photoId?token=$_token';
    }
    return '${AppConfig.apiBaseUrl}/tickets/photos/$photoId';
  }

  void _showImagePreview(BuildContext context, TicketPhoto photo) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.r12),
                child: CachedNetworkImage(
                  imageUrl: _getPhotoUrl(photo.id),
                  httpHeaders: {
                    if (_token != null) 'Authorization': 'Bearer $_token',
                  },
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: Colors.black26,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: Colors.white70,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Gagal memuat foto',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (photo.caption != null && photo.caption!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.p12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: Text(
                    photo.caption!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Foto Bukti Gangguan (${widget.photos.length}/10)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.canUpload && widget.photos.length < 10)
              TextButton.icon(
                onPressed: widget.onAddPhotoPressed,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text('Tambah Foto'),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.p8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: widget.photos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.p16,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Text(
                            'Belum ada foto bukti yang diunggah',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: AppSizes.p8,
                          mainAxisSpacing: AppSizes.p8,
                          childAspectRatio: 1,
                        ),
                    itemCount: widget.photos.length,
                    itemBuilder: (context, index) {
                      final photo = widget.photos[index];
                      return InkWell(
                        onTap: () => _showImagePreview(context, photo),
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.r8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: _getPhotoUrl(photo.id),
                                httpHeaders: {
                                  if (_token != null)
                                    'Authorization': 'Bearer $_token',
                                },
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                              if (photo.caption != null &&
                                  photo.caption!.isNotEmpty)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    color: Colors.black54,
                                    child: Text(
                                      photo.caption!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
