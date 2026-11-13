import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/sla_badge.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../master/domain/entities/vendor.dart';
import '../../../master/domain/usecases/get_vendors.dart';
import '../../domain/entities/ticket.dart';
import '../widgets/vendor_picker_bottom_sheet.dart';
import '../../domain/entities/ticket_history.dart';
import '../../domain/entities/ticket_status.dart';
import '../bloc/ticket_detail_bloc.dart';
import '../bloc/ticket_detail_event.dart';
import '../bloc/ticket_detail_state.dart';

class TicketDetailPage extends StatelessWidget {
  final int ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TicketDetailBloc>(
      create: (context) =>
          getIt<TicketDetailBloc>()..add(LoadTicketDetail(ticketId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Tiket')),
        body: BlocConsumer<TicketDetailBloc, TicketDetailState>(
          listener: (context, state) {
            if (state is TicketDetailLoaded) {
              if (state.actionSuccessMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.actionSuccessMessage!),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state.actionErrorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.actionErrorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is TicketDetailLoading) {
              return const LoadingView(message: 'Memuat detail tiket...');
            }

            if (state is TicketDetailError) {
              return ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<TicketDetailBloc>().add(
                    LoadTicketDetail(ticketId),
                  );
                },
              );
            }

            if (state is TicketDetailLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TicketDetailBloc>().add(
                    LoadTicketDetail(ticketId),
                  );
                },
                child: _TicketDetailContent(
                  ticket: state.ticket,
                  histories: state.histories,
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TicketDetailContent extends StatelessWidget {
  final Ticket ticket;
  final List<TicketHistory> histories;

  const _TicketDetailContent({required this.ticket, required this.histories});

  String _formatDateTime(DateTime dt) {
    final yyyy = dt.year;
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Card (Nomor Tiket & Status)
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ticket.ticketNo,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    StatusChip(status: ticket.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Batas SLA: ${_formatDateTime(ticket.slaDueAt)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SlaBadge(
                  slaStatus: ticket.slaStatus,
                  remainingSeconds: ticket.slaRemainingSeconds,
                ),
                if (ticket.status == TicketStatus.newStatus) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            '/tickets/${ticket.id}/edit',
                            extra: ticket,
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Tiket'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () async {
                          final vendorsResult = await getIt<GetVendors>()
                              .call();
                          final vendorList = vendorsResult.fold(
                            (f) => <Vendor>[],
                            (v) => v,
                          );
                          if (!context.mounted) return;

                          if (vendorList.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tidak ada vendor aktif yang tersedia',
                                ),
                              ),
                            );
                            return;
                          }

                          final selected = await VendorPickerBottomSheet.show(
                            context: context,
                            vendors: vendorList,
                          );

                          if (selected != null && context.mounted) {
                            context.read<TicketDetailBloc>().add(
                              ForwardTicketEvent(
                                ticketId: ticket.id,
                                vendorId: selected.id,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Teruskan ke Vendor'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Info Pelanggan & Lokasi
        Text(
          'Informasi Pelanggan & Lokasi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Nama Pelanggan',
                  value: ticket.customerName ?? '-',
                ),
                if (ticket.customerAddress != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    value: ticket.customerAddress!,
                  ),
                ],
                if (ticket.customerPhone != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'No. Telepon',
                    value: ticket.customerPhone!,
                  ),
                ],
                const Divider(height: 16),
                _InfoRow(
                  icon: Icons.map_outlined,
                  label: 'Area Jaringan',
                  value: ticket.areaName ?? '-',
                ),
                if (ticket.odpCode != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.device_hub_outlined,
                    label: 'Titik ODP',
                    value: ticket.odpCode!,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Detail Gangguan
        Text(
          'Detail Gangguan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.warning_amber_outlined,
                  label: 'Jenis Gangguan',
                  value: ticket.issueTypeName ?? '-',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.flag_outlined,
                  label: 'Tingkat Prioritas',
                  value: ticket.priorityName ?? '-',
                ),
                const Divider(height: 16),
                Text(
                  'Deskripsi Keluhan:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(ticket.description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Info Penugasan
        Text(
          'Informasi Penugasan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.business_outlined,
                  label: 'Mitra Vendor',
                  value: ticket.vendorName ?? 'Belum diteruskan',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.engineering_outlined,
                  label: 'Teknisi Lapangan',
                  value: ticket.technicianName ?? 'Belum ditugaskan',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Linimasa Riwayat
        Text(
          'Linimasa Riwayat',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: histories.isEmpty
                ? const Text('Belum ada riwayat tercatat')
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: histories.length,
                    separatorBuilder: (_, _) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final history = histories[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      history.userName ?? 'Sistem',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      _formatDateTime(history.createdAt),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  history.note ??
                                      'Status diubah ke ${history.toStatus}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
