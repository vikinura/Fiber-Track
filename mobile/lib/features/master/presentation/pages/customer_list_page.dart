import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/odp.dart';
import '../../domain/usecases/get_areas.dart';
import '../../domain/usecases/get_odps.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../widgets/customer_form_dialog.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Area> _areas = [];
  List<Odp> _odps = [];

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    final areasResult = await getIt<GetAreas>()();
    final odpsResult = await getIt<GetOdps>()();
    if (mounted) {
      setState(() {
        _areas = areasResult.getOrElse((_) => []);
        _odps = odpsResult.getOrElse((_) => []);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => CustomerFormDialog(
        areas: _areas,
        odps: _odps,
        onSubmit: (name, phone, address, areaId, odpId) {
          context.read<CustomerBloc>().add(
            CreateCustomerEvent(
              name: name,
              phone: phone,
              address: address,
              areaId: areaId,
              odpId: odpId,
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (dialogCtx) => CustomerFormDialog(
        customer: customer,
        areas: _areas,
        odps: _odps,
        onSubmit: (name, phone, address, areaId, odpId) {
          context.read<CustomerBloc>().add(
            UpdateCustomerEvent(
              id: customer.id,
              name: name,
              phone: phone,
              address: address,
              areaId: areaId,
              odpId: odpId,
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus pelanggan "${customer.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<CustomerBloc>().add(
                DeleteCustomerEvent(customer.id),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<CustomerBloc>()..add(const LoadCustomersEvent()),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Kelola Data Pelanggan'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Segarkan',
                  onPressed: () {
                    context.read<CustomerBloc>().add(
                      LoadCustomersEvent(search: _searchController.text.trim()),
                    );
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Tambah Pelanggan'),
            ),
            body: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama, telepon, atau alamat...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                context.read<CustomerBloc>().add(
                                  const LoadCustomersEvent(),
                                );
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                        vertical: AppSizes.p12,
                      ),
                    ),
                    onSubmitted: (val) {
                      context.read<CustomerBloc>().add(
                        LoadCustomersEvent(search: val.trim()),
                      );
                    },
                  ),
                ),

                // List content
                Expanded(
                  child: BlocConsumer<CustomerBloc, CustomerState>(
                    listener: (context, state) {
                      if (state is CustomerActionSuccess) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                        context.read<CustomerBloc>().add(
                          LoadCustomersEvent(
                            search: _searchController.text.trim(),
                          ),
                        );
                      } else if (state is CustomerError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is CustomerLoading) {
                        return const LoadingView(
                          message: 'Memuat data pelanggan...',
                        );
                      }

                      if (state is CustomerError) {
                        return ErrorView(
                          message: state.message,
                          onRetry: () {
                            context.read<CustomerBloc>().add(
                              LoadCustomersEvent(
                                search: _searchController.text.trim(),
                              ),
                            );
                          },
                        );
                      }

                      if (state is CustomerLoaded) {
                        final customers = state.result.data;

                        if (customers.isEmpty) {
                          return EmptyView(
                            message: 'Tidak ada data pelanggan',
                            icon: Icons.people_outline,
                            action: FilledButton.icon(
                              onPressed: () => _showAddDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Tambah Pelanggan Baru'),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<CustomerBloc>().add(
                              LoadCustomersEvent(
                                search: _searchController.text.trim(),
                              ),
                            );
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.p16,
                              vertical: AppSizes.p8,
                            ),
                            itemCount: customers.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSizes.p8),
                            itemBuilder: (context, index) {
                              final customer = customers[index];

                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.r12,
                                  ),
                                  side: BorderSide(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.p16,
                                    vertical: AppSizes.p8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        theme.colorScheme.secondaryContainer,
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                  title: Text(
                                    customer.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (customer.phone != null &&
                                          customer.phone!.isNotEmpty) ...[
                                        const SizedBox(height: AppSizes.p4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone_outlined,
                                              size: 14,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            const SizedBox(width: AppSizes.p4),
                                            Text(
                                              customer.phone!,
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (customer.address != null &&
                                          customer.address!.isNotEmpty) ...[
                                        const SizedBox(height: AppSizes.p4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            const SizedBox(width: AppSizes.p4),
                                            Expanded(
                                              child: Text(
                                                customer.address!,
                                                style:
                                                    theme.textTheme.bodySmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Edit',
                                        onPressed: () =>
                                            _showEditDialog(context, customer),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: theme.colorScheme.error,
                                        ),
                                        tooltip: 'Hapus',
                                        onPressed: () =>
                                            _confirmDelete(context, customer),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
