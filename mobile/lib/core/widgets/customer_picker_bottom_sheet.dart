import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import 'app_button.dart';
import 'app_text_field.dart';

class CustomerPickerBottomSheet<T> extends StatefulWidget {
  final String title;
  final Future<List<T>> Function(String query) onSearch;
  final String Function(T) itemTitle;
  final String? Function(T)? itemSubtitle;
  final ValueChanged<T> onSelected;

  const CustomerPickerBottomSheet({
    super.key,
    required this.title,
    required this.onSearch,
    required this.itemTitle,
    this.itemSubtitle,
    required this.onSelected,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Future<List<T>> Function(String query) onSearch,
    required String Function(T) itemTitle,
    String? Function(T)? itemSubtitle,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (context) {
        return CustomerPickerBottomSheet<T>(
          title: title,
          onSearch: onSearch,
          itemTitle: itemTitle,
          itemSubtitle: itemSubtitle,
          onSelected: (item) => Navigator.of(context).pop(item),
        );
      },
    );
  }

  @override
  State<CustomerPickerBottomSheet<T>> createState() =>
      _CustomerPickerBottomSheetState<T>();
}

class _CustomerPickerBottomSheetState<T>
    extends State<CustomerPickerBottomSheet<T>> {
  final _searchController = TextEditingController();
  List<T> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await widget.onSearch(query);
      if (mounted) {
        setState(() {
          _items = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        top: AppSizes.p16,
        left: AppSizes.p16,
        right: AppSizes.p16,
        bottom: bottomInset + AppSizes.p16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
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
          const SizedBox(height: AppSizes.p8),
          AppTextField(
            controller: _searchController,
            hint: 'Cari berdasarkan nama, telepon, atau alamat...',
            prefixIcon: const Icon(Icons.search_rounded),
            textInputAction: TextInputAction.search,
            onChanged: (val) {
              _performSearch(val);
            },
          ),
          const SizedBox(height: AppSizes.p12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.p12),
                        AppButton(
                          text: AppStrings.retry,
                          onPressed: () =>
                              _performSearch(_searchController.text),
                          width: 120,
                        ),
                      ],
                    ),
                  )
                : _items.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.emptyData,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final title = widget.itemTitle(item);
                      final subtitle = widget.itemSubtitle?.call(item);

                      return ListTile(
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: subtitle != null
                            ? Text(subtitle, style: theme.textTheme.bodySmall)
                            : null,
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: AppSizes.iconSm,
                        ),
                        onTap: () => widget.onSelected(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
