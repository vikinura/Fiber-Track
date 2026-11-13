import 'package:equatable/equatable.dart';

abstract class TicketListEvent extends Equatable {
  const TicketListEvent();

  @override
  List<Object?> get props => [];
}

class LoadTicketList extends TicketListEvent {
  final bool isRefresh;
  final String? status;
  final int? areaId;
  final int? vendorId;
  final String? sla;
  final String? search;

  const LoadTicketList({
    this.isRefresh = false,
    this.status,
    this.areaId,
    this.vendorId,
    this.sla,
    this.search,
  });

  @override
  List<Object?> get props => [isRefresh, status, areaId, vendorId, sla, search];
}

class LoadMoreTickets extends TicketListEvent {
  const LoadMoreTickets();
}
