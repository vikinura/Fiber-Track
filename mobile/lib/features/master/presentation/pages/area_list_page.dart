import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/area.dart';
import '../bloc/area_bloc.dart';
import '../bloc/area_event.dart';
import '../bloc/area_state.dart';
import '../widgets/area_form_dialog.dart';

class AreaListPage extends StatelessWidget {
  const AreaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AreaBloc>()..add(const LoadAreasEvent()),
      child: const AreaListView(),
    );
  }
}

class AreaListView extends StatelessWidget {
  const AreaListView({super.key});

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AreaFormDialog(
        onSubmit: (name, description) {
          context.read<AreaBloc>().add(
            CreateAreaEvent(name: name, description: description),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Area area) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AreaFormDialog(
        area: area,
        onSubmit: (name, description) {
          context.read<AreaBloc>().add(
            UpdateAreaEvent(id: area.id, name: name, description: description),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Area area) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Area'),
        content: Text('Apakah Anda yakin ingin menghapus area "${area.name}"?'),
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
              context.read<AreaBloc>().add(DeleteAreaEvent(area.id));
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Area Jaringan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () {
              context.read<AreaBloc>().add(const LoadAreasEvent());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Area'),
      ),
      body: BlocConsumer<AreaBloc, AreaState>(
        listener: (context, state) {
          if (state is AreaActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            context.read<AreaBloc>().add(const LoadAreasEvent());
          } else if (state is AreaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AreaLoading) {
            return const LoadingView(message: 'Memuat data area...');
          }

          if (state is AreaError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<AreaBloc>().add(const LoadAreasEvent());
              },
            );
          }

          if (state is AreaLoaded) {
            if (state.areas.isEmpty) {
              return EmptyView(
                message: 'Belum ada area jaringan',
                icon: Icons.map_outlined,
                action: FilledButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Area Pertama'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AreaBloc>().add(const LoadAreasEvent());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: state.areas.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSizes.p8),
                itemBuilder: (context, index) {
                  final area = state.areas[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                        vertical: AppSizes.p8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.location_on_rounded,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        area.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle:
                          area.description != null &&
                              area.description!.isNotEmpty
                          ? Text(
                              area.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                            onPressed: () => _showEditDialog(context, area),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: theme.colorScheme.error,
                            ),
                            tooltip: 'Hapus',
                            onPressed: () => _confirmDelete(context, area),
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
    );
  }
}
