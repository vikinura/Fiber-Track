import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/forward_ticket.dart';
import '../../domain/usecases/get_ticket_detail.dart';
import '../../domain/usecases/get_ticket_histories.dart';
import 'ticket_detail_event.dart';
import 'ticket_detail_state.dart';

class TicketDetailBloc extends Bloc<TicketDetailEvent, TicketDetailState> {
  final GetTicketDetail getTicketDetail;
  final GetTicketHistories getTicketHistories;
  final ForwardTicket forwardTicket;

  TicketDetailBloc({
    required this.getTicketDetail,
    required this.getTicketHistories,
    required this.forwardTicket,
  }) : super(const TicketDetailInitial()) {
    on<LoadTicketDetail>(_onLoadTicketDetail);
    on<ForwardTicketEvent>(_onForwardTicket);
  }

  Future<void> _onLoadTicketDetail(
    LoadTicketDetail event,
    Emitter<TicketDetailState> emit,
  ) async {
    emit(const TicketDetailLoading());

    final detailResult = await getTicketDetail(event.ticketId);

    await detailResult.fold(
      (failure) async => emit(TicketDetailError(failure.message)),
      (ticket) async {
        final historiesResult = await getTicketHistories(event.ticketId);
        historiesResult.fold(
          (failure) {
            emit(TicketDetailLoaded(ticket: ticket, histories: const []));
          },
          (histories) {
            emit(TicketDetailLoaded(ticket: ticket, histories: histories));
          },
        );
      },
    );
  }

  Future<void> _onForwardTicket(
    ForwardTicketEvent event,
    Emitter<TicketDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TicketDetailLoaded) return;

    emit(currentState.copyWith(isUpdating: true));

    final result = await forwardTicket(event.ticketId, event.vendorId);

    await result.fold(
      (failure) async {
        emit(
          currentState.copyWith(
            isUpdating: false,
            actionErrorMessage: failure.message,
          ),
        );
      },
      (updatedTicket) async {
        final historiesResult = await getTicketHistories(event.ticketId);
        final newHistories = historiesResult.fold(
          (_) => currentState.histories,
          (h) => h,
        );
        emit(
          TicketDetailLoaded(
            ticket: updatedTicket,
            histories: newHistories,
            isUpdating: false,
            actionSuccessMessage: 'Tiket berhasil diteruskan ke vendor',
          ),
        );
      },
    );
  }
}
