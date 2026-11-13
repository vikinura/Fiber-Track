import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_tickets.dart';
import 'ticket_list_event.dart';
import 'ticket_list_state.dart';

class TicketListBloc extends Bloc<TicketListEvent, TicketListState> {
  final GetTickets getTickets;

  TicketListBloc({required this.getTickets})
    : super(const TicketListInitial()) {
    on<LoadTicketList>(_onLoadTicketList);
    on<LoadMoreTickets>(_onLoadMoreTickets);
  }

  Future<void> _onLoadTicketList(
    LoadTicketList event,
    Emitter<TicketListState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const TicketListLoading());
    }

    final result = await getTickets(
      GetTicketsParams(
        page: 1,
        limit: 10,
        status: event.status,
        areaId: event.areaId,
        vendorId: event.vendorId,
        sla: event.sla,
        q: event.search,
      ),
    );

    result.fold((failure) => emit(TicketListError(failure.message)), (
      paginated,
    ) {
      emit(
        TicketListLoaded(
          tickets: paginated.data,
          page: 1,
          limit: paginated.limit,
          total: paginated.total,
          hasReachedMax: paginated.data.length >= paginated.total,
          status: event.status,
          areaId: event.areaId,
          vendorId: event.vendorId,
          sla: event.sla,
          search: event.search,
        ),
      );
    });
  }

  Future<void> _onLoadMoreTickets(
    LoadMoreTickets event,
    Emitter<TicketListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TicketListLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.page + 1;
    final result = await getTickets(
      GetTicketsParams(
        page: nextPage,
        limit: currentState.limit,
        status: currentState.status,
        areaId: currentState.areaId,
        vendorId: currentState.vendorId,
        sla: currentState.sla,
        q: currentState.search,
      ),
    );

    result.fold(
      (failure) {
        // Tetap di loaded state tapi set isLoadingMore false
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (paginated) {
        final combinedTickets = List.of(currentState.tickets)
          ..addAll(paginated.data);
        emit(
          currentState.copyWith(
            tickets: combinedTickets,
            page: nextPage,
            total: paginated.total,
            hasReachedMax: combinedTickets.length >= paginated.total,
            isLoadingMore: false,
          ),
        );
      },
    );
  }
}
