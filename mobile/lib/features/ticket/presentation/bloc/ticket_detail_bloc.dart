import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_ticket_detail.dart';
import '../../domain/usecases/get_ticket_histories.dart';
import 'ticket_detail_event.dart';
import 'ticket_detail_state.dart';

class TicketDetailBloc extends Bloc<TicketDetailEvent, TicketDetailState> {
  final GetTicketDetail getTicketDetail;
  final GetTicketHistories getTicketHistories;

  TicketDetailBloc({
    required this.getTicketDetail,
    required this.getTicketHistories,
  }) : super(const TicketDetailInitial()) {
    on<LoadTicketDetail>(_onLoadTicketDetail);
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
            // Jika gagal load riwayat, tetap tampilkan tiket dengan riwayat kosong
            emit(TicketDetailLoaded(ticket: ticket, histories: const []));
          },
          (histories) {
            emit(TicketDetailLoaded(ticket: ticket, histories: histories));
          },
        );
      },
    );
  }
}
