import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/domain/entities/user.dart';

class TechnicianPickerBottomSheet extends StatefulWidget {
  final List<User> technicians;
  final ValueChanged<User> onSelected;

  const TechnicianPickerBottomSheet({
    super.key,
    required this.technicians,
    required this.onSelected,
  });

  static Future<User?> show({
    required BuildContext context,
    required List<User> technicians,
  }) {
    return showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (context) {
        return TechnicianPickerBottomSheet(
          technicians: technicians,
          onSelected: (tech) => Navigator.of(context).pop(tech),
        );
      },
    );
  }

  @override
  State<TechnicianPickerBottomSheet> createState() =>
      _TechnicianPickerBottomSheetState();
}

class _TechnicianPickerBottomSheetState
    extends State<TechnicianPickerBottomSheet> {
  final _searchController = TextEditingController();
  late List<User> _filteredTechnicians;

  @override
  void initState() {
    super.initState();
    _filteredTechnicians = widget.technicians;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredTechnicians = widget.technicians;
      } else {
        _filteredTechnicians = widget.technicians
            .where(
              (t) =>
                  t.name.toLowerCase().contains(query.toLowerCase()) ||
                  (t.email.toLowerCase().contains(query.toLowerCase())),
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
                'Tugaskan Teknisi',
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
              hintText: 'Cari teknisi...',
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
            child: _filteredTechnicians.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.emptyData,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredTechnicians.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tech = _filteredTechnicians[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          child: Icon(
                            Icons.engineering_outlined,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        title: Text(
                          tech.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(tech.email),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: AppSizes.iconSm,
                        ),
                        onTap: () => widget.onSelected(tech),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
