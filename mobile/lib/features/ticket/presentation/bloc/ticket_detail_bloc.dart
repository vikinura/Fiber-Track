import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/assign_ticket.dart';
import '../../domain/usecases/forward_ticket.dart';
import '../../domain/usecases/get_ticket_detail.dart';
import '../../domain/usecases/get_ticket_histories.dart';
import '../../domain/usecases/update_ticket_status.dart';
import '../../domain/usecases/upload_ticket_photo.dart';
import 'ticket_detail_event.dart';
import 'ticket_detail_state.dart';

class TicketDetailBloc extends Bloc<TicketDetailEvent, TicketDetailState> {
  final GetTicketDetail getTicketDetail;
  final GetTicketHistories getTicketHistories;
  final ForwardTicket forwardTicket;
  final AssignTicket assignTicket;
  final UpdateTicketStatus updateTicketStatus;
  final UploadTicketPhoto uploadTicketPhoto;

  TicketDetailBloc({
    required this.getTicketDetail,
    required this.getTicketHistories,
    required this.forwardTicket,
    required this.assignTicket,
    required this.updateTicketStatus,
    required this.uploadTicketPhoto,
  }) : super(const TicketDetailInitial()) {
    on<LoadTicketDetail>(_onLoadTicketDetail);
    on<ForwardTicketEvent>(_onForwardTicket);
    on<AssignTicketEvent>(_onAssignTicket);
    on<UpdateStatusEvent>(_onUpdateStatus);
    on<UploadPhotoEvent>(_onUploadPhoto);
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

  Future<void> _onAssignTicket(
    AssignTicketEvent event,
    Emitter<TicketDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TicketDetailLoaded) return;

    emit(currentState.copyWith(isUpdating: true));

    final result = await assignTicket(event.ticketId, event.technicianId);

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
            actionSuccessMessage: 'Tiket berhasil ditugaskan ke teknisi',
          ),
        );
      },
    );
  }

  Future<void> _onUpdateStatus(
    UpdateStatusEvent event,
    Emitter<TicketDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TicketDetailLoaded) return;

    emit(currentState.copyWith(isUpdating: true));

    final result = await updateTicketStatus(
      ticketId: event.ticketId,
      toStatus: event.toStatus,
      note: event.note,
    );

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
            actionSuccessMessage: event.toStatus == 'resolved'
                ? 'Tiket berhasil diselesaikan'
                : 'Pengerjaan tiket telah dimulai',
          ),
        );
      },
    );
  }

  Future<void> _onUploadPhoto(
    UploadPhotoEvent event,
    Emitter<TicketDetailState> emit,
  ) async {
    if (state is! TicketDetailLoaded) return;
    final currentState = state as TicketDetailLoaded;

    emit(currentState.copyWith(isUpdating: true));

    final result = await uploadTicketPhoto(
      ticketId: event.ticketId,
      filePath: event.filePath,
      caption: event.caption,
    );

    await result.fold(
      (failure) async {
        emit(
          currentState.copyWith(
            isUpdating: false,
            actionErrorMessage: failure.message,
          ),
        );
      },
      (newPhoto) async {
        // Muat ulang detail tiket agar daftar foto tersinkronisasi
        final detailResult = await getTicketDetail(event.ticketId);
        detailResult.fold(
          (failure) {
            emit(
              currentState.copyWith(
                isUpdating: false,
                actionSuccessMessage: 'Foto bukti berhasil diunggah',
              ),
            );
          },
          (refreshedTicket) {
            emit(
              TicketDetailLoaded(
                ticket: refreshedTicket,
                histories: currentState.histories,
                isUpdating: false,
                actionSuccessMessage: 'Foto bukti berhasil diunggah',
              ),
            );
          },
        );
      },
    );
  }
}
