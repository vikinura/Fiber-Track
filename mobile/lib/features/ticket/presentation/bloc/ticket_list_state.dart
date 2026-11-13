import 'package:equatable/equatable.dart';

import '../../domain/entities/ticket.dart';

abstract class TicketListState extends Equatable {
  const TicketListState();

  @override
  List<Object?> get props => [];
}

class TicketListInitial extends TicketListState {
  const TicketListInitial();
}

class TicketListLoading extends TicketListState {
  const TicketListLoading();
}

class TicketListLoaded extends TicketListState {
  final List<Ticket> tickets;
  final int page;
  final int limit;
  final int total;
  final bool hasReachedMax;
  final bool isLoadingMore;

  // Active filter state
  final String? status;
  final int? areaId;
  final int? vendorId;
  final String? sla;
  final String? search;

  const TicketListLoaded({
    required this.tickets,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.status,
    this.areaId,
    this.vendorId,
    this.sla,
    this.search,
  });

  TicketListLoaded copyWith({
    List<Ticket>? tickets,
    int? page,
    int? limit,
    int? total,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? status,
    int? areaId,
    int? vendorId,
    String? sla,
    String? search,
  }) {
    return TicketListLoaded(
      tickets: tickets ?? this.tickets,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      status: status ?? this.status,
      areaId: areaId ?? this.areaId,
      vendorId: vendorId ?? this.vendorId,
      sla: sla ?? this.sla,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
    tickets,
    page,
    limit,
    total,
    hasReachedMax,
    isLoadingMore,
    status,
    areaId,
    vendorId,
    sla,
    search,
  ];
}

class TicketListError extends TicketListState {
  final String message;

  const TicketListError(this.message);

  @override
  List<Object?> get props => [message];
}
