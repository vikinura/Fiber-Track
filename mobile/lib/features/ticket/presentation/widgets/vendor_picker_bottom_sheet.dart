import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../master/domain/entities/vendor.dart';

class VendorPickerBottomSheet extends StatefulWidget {
  final List<Vendor> vendors;
  final ValueChanged<Vendor> onSelected;

  const VendorPickerBottomSheet({
    super.key,
    required this.vendors,
    required this.onSelected,
  });

  static Future<Vendor?> show({
    required BuildContext context,
    required List<Vendor> vendors,
  }) {
    return showModalBottomSheet<Vendor>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (context) {
        return VendorPickerBottomSheet(
          vendors: vendors,
          onSelected: (vendor) => Navigator.of(context).pop(vendor),
        );
      },
    );
  }

  @override
  State<VendorPickerBottomSheet> createState() =>
      _VendorPickerBottomSheetState();
}

class _VendorPickerBottomSheetState extends State<VendorPickerBottomSheet> {
  final _searchController = TextEditingController();
  late List<Vendor> _filteredVendors;

  @override
  void initState() {
    super.initState();
    _filteredVendors = widget.vendors;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredVendors = widget.vendors;
      } else {
        _filteredVendors = widget.vendors
            .where(
              (v) =>
                  v.name.toLowerCase().contains(query.toLowerCase()) ||
                  (v.contactPerson?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                'Teruskan ke Vendor',
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
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari vendor...',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filter('');
                      },
                    )
                  : null,
            ),
            onChanged: _filter,
          ),
          const SizedBox(height: AppSizes.p12),
          Expanded(
            child: _filteredVendors.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.emptyData,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredVendors.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final vendor = _filteredVendors[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.business_outlined,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          vendor.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: vendor.contactPerson != null
                            ? Text('PIC: ${vendor.contactPerson}')
                            : null,
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: AppSizes.iconSm,
                        ),
                        onTap: () => widget.onSelected(vendor),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
