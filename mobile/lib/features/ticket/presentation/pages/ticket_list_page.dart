import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/sla_badge.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/sla_status.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_status.dart';
import '../bloc/ticket_list_bloc.dart';
import '../bloc/ticket_list_event.dart';
import '../bloc/ticket_list_state.dart';

class TicketListPage extends StatelessWidget {
  final String? customTitle;
  final bool showAppBar;

  const TicketListPage({super.key, this.customTitle, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TicketListBloc>(
      create: (context) => getIt<TicketListBloc>()..add(const LoadTicketList()),
      child: _TicketListView(customTitle: customTitle, showAppBar: showAppBar),
    );
  }
}

class _TicketListView extends StatefulWidget {
  final String? customTitle;
  final bool showAppBar;

  const _TicketListView({this.customTitle, this.showAppBar = true});

  @override
  State<_TicketListView> createState() => _TicketListViewState();
}

class _TicketListViewState extends State<_TicketListView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedStatus;
  String? _selectedSla;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TicketListBloc>().add(const LoadMoreTickets());
    }
  }

  void _applyFilters() {
    context.read<TicketListBloc>().add(
      LoadTicketList(
        status: _selectedStatus,
        sla: _selectedSla,
        search: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.customTitle ?? 'Daftar Tiket Gangguan'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Buat Tiket',
                  onPressed: () async {
                    final result = await context.push('/tickets/create');
                    if (result == true && context.mounted) {
                      _applyFilters();
                    }
                  },
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Bar Pencarian & Filter
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nomor tiket atau nama pelanggan...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filter Status
                      PopupMenuButton<String?>(
                        initialValue: _selectedStatus,
                        onSelected: (val) {
                          setState(() {
                            _selectedStatus = val;
                          });
                          _applyFilters();
                        },
                        child: Chip(
                          avatar: const Icon(Icons.filter_list, size: 16),
                          label: Text(
                            _selectedStatus == null
                                ? 'Status: Semua'
                                : 'Status: ${TicketStatus.fromString(_selectedStatus).label}',
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem<String?>(
                            value: null,
                            child: Text('Semua Status'),
                          ),
                          ...TicketStatus.values.map(
                            (s) => PopupMenuItem<String?>(
                              value: s.value,
                              child: Text(s.label),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Filter SLA
                      PopupMenuButton<String?>(
                        initialValue: _selectedSla,
                        onSelected: (val) {
                          setState(() {
                            _selectedSla = val;
                          });
                          _applyFilters();
                        },
                        child: Chip(
                          avatar: const Icon(Icons.timer_outlined, size: 16),
                          label: Text(
                            _selectedSla == null
                                ? 'SLA: Semua'
                                : 'SLA: ${SlaStatus.fromString(_selectedSla).label}',
                          ),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem<String?>(
                            value: null,
                            child: Text('Semua SLA'),
                          ),
                          ...SlaStatus.values.map(
                            (s) => PopupMenuItem<String?>(
                              value: s.value,
                              child: Text(s.label),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedStatus != null ||
                          _selectedSla != null ||
                          _searchController.text.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedStatus = null;
                              _selectedSla = null;
                              _searchController.clear();
                            });
                            _applyFilters();
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Daftar Tiket
          Expanded(
            child: BlocBuilder<TicketListBloc, TicketListState>(
              builder: (context, state) {
                if (state is TicketListLoading) {
                  return const LoadingView(message: 'Memuat daftar tiket...');
                }

                if (state is TicketListError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: _applyFilters,
                  );
                }

                if (state is TicketListLoaded) {
                  if (state.tickets.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async => _applyFilters(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: EmptyView(
                              message: 'Belum ada tiket yang cocok',
                              action: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedStatus = null;
                                    _selectedSla = null;
                                    _searchController.clear();
                                  });
                                  _applyFilters();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset Filter'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _applyFilters(),
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
          ),
        ],
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
          context.push('/tickets/${ticket.id}');
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
