import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/sla_badge.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/ticket.dart';
import '../bloc/ticket_list_bloc.dart';
import '../bloc/ticket_list_event.dart';
import '../bloc/ticket_list_state.dart';

class TicketListPage extends StatelessWidget {
  const TicketListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TicketListBloc>(
      create: (context) => getIt<TicketListBloc>()..add(const LoadTicketList()),
      child: const _TicketListView(),
    );
  }
}

class _TicketListView extends StatefulWidget {
  const _TicketListView();

  @override
  State<_TicketListView> createState() => _TicketListViewState();
}

class _TicketListViewState extends State<_TicketListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TicketListBloc>().add(const LoadMoreTickets());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tiket Gangguan')),
      body: BlocBuilder<TicketListBloc, TicketListState>(
        builder: (context, state) {
          if (state is TicketListLoading) {
            return const LoadingView(message: 'Memuat daftar tiket...');
          }

          if (state is TicketListError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<TicketListBloc>().add(const LoadTicketList());
              },
            );
          }

          if (state is TicketListLoaded) {
            if (state.tickets.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TicketListBloc>().add(
                    LoadTicketList(
                      isRefresh: true,
                      status: state.status,
                      areaId: state.areaId,
                      vendorId: state.vendorId,
                      sla: state.sla,
                      search: state.search,
                    ),
                  );
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: EmptyView(
                        message: 'Belum ada tiket gangguan',
                        action: TextButton.icon(
                          onPressed: () {
                            context.read<TicketListBloc>().add(
                              const LoadTicketList(),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Muat Ulang'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TicketListBloc>().add(
                  LoadTicketList(
                    isRefresh: true,
                    status: state.status,
                    areaId: state.areaId,
                    vendorId: state.vendorId,
                    sla: state.sla,
                    search: state.search,
                  ),
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: state.hasReachedMax
                    ? state.tickets.length
                    : state.tickets.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.tickets.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final ticket = state.tickets[index];
                  return _TicketCard(ticket: ticket);
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

class _TicketCard extends StatelessWidget {
  final Ticket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigasi ke detail tiket (disiapkan untuk T50)
        },
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  StatusChip(status: ticket.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.customerName ?? 'Pelanggan tidak diketahui',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (ticket.areaName != null)
                    Chip(
                      label: Text(ticket.areaName!),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  if (ticket.priorityName != null)
                    Chip(
                      label: Text(ticket.priorityName!),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  SlaBadge(
                    slaStatus: ticket.slaStatus,
                    remainingSeconds: ticket.slaRemainingSeconds,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
