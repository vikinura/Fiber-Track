import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../master/domain/usecases/get_areas.dart';
import '../../../master/domain/usecases/get_issue_types.dart';
import '../../../master/domain/usecases/get_odps.dart';
import '../../../master/domain/usecases/get_priorities.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../domain/usecases/create_ticket.dart';
import 'ticket_form_event.dart';
import 'ticket_form_state.dart';

class TicketFormBloc extends Bloc<TicketFormEvent, TicketFormState> {
  final GetAreas getAreas;
  final GetOdps getOdps;
  final GetIssueTypes getIssueTypes;
  final GetPriorities getPriorities;
  final CreateTicket createTicket;
  final TicketRepository ticketRepository;

  TicketFormBloc({
    required this.getAreas,
    required this.getOdps,
    required this.getIssueTypes,
    required this.getPriorities,
    required this.createTicket,
    required this.ticketRepository,
  }) : super(const TicketFormInitial()) {
    on<LoadMasterFormData>(_onLoadMasterFormData);
    on<AreaSelectedEvent>(_onAreaSelected);
    on<SubmitTicketForm>(_onSubmitTicketForm);
  }

  Future<void> _onLoadMasterFormData(
    LoadMasterFormData event,
    Emitter<TicketFormState> emit,
  ) async {
    emit(const TicketFormDataLoading());

    final areasRes = await getAreas();
    final issuesRes = await getIssueTypes();
    final prioritiesRes = await getPriorities();

    areasRes.fold((failure) => emit(TicketFormDataError(failure.message)), (
      areas,
    ) {
      issuesRes.fold((failure) => emit(TicketFormDataError(failure.message)), (
        issues,
      ) {
        prioritiesRes.fold(
          (failure) => emit(TicketFormDataError(failure.message)),
          (priorities) {
            emit(
              TicketFormDataLoaded(
                areas: areas,
                issueTypes: issues,
                priorities: priorities,
              ),
            );
          },
        );
      });
    });
  }

  Future<void> _onAreaSelected(
    AreaSelectedEvent event,
    Emitter<TicketFormState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TicketFormDataLoaded) return;

    emit(currentState.copyWith(isLoadingOdps: true, odps: []));

    final odpsRes = await getOdps(areaId: event.areaId);

    odpsRes.fold(
      (failure) => emit(currentState.copyWith(isLoadingOdps: false, odps: [])),
      (odps) => emit(currentState.copyWith(isLoadingOdps: false, odps: odps)),
    );
  }

  Future<void> _onSubmitTicketForm(
    SubmitTicketForm event,
    Emitter<TicketFormState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TicketFormDataLoaded) return;

    emit(
      currentState.copyWith(
        isSubmitting: true,
        fieldErrors: null,
        submitErrorMessage: null,
      ),
    );

    if (event.ticketId != null) {
      // Update Ticket
      final result = await ticketRepository.updateTicket(
        id: event.ticketId!,
        customerId: event.customerId,
        areaId: event.areaId,
        odpId: event.odpId,
        issueTypeId: event.issueTypeId,
        priorityId: event.priorityId,
        description: event.description,
        latitude: event.latitude,
        longitude: event.longitude,
      );

      result.fold(
        (failure) {
          if (failure is ValidationFailure) {
            final mappedErrors = <String, String>{};
            for (final err in failure.errors) {
              if (err['field'] != null && err['message'] != null) {
                mappedErrors[err['field'].toString()] = err['message']
                    .toString();
              }
            }
            emit(
              currentState.copyWith(
                isSubmitting: false,
                fieldErrors: mappedErrors,
                submitErrorMessage: failure.message,
              ),
            );
          } else {
            emit(
              currentState.copyWith(
                isSubmitting: false,
                submitErrorMessage: failure.message,
              ),
            );
          }
        },
        (ticket) {
          emit(TicketFormSubmitSuccess(ticket: ticket, isUpdate: true));
        },
      );
    } else {
      // Create Ticket
      final result = await createTicket(
        CreateTicketParams(
          customerId: event.customerId,
          areaId: event.areaId,
          odpId: event.odpId,
          issueTypeId: event.issueTypeId,
          priorityId: event.priorityId,
          description: event.description,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      );

      result.fold(
        (failure) {
          if (failure is ValidationFailure) {
            final mappedErrors = <String, String>{};
            for (final err in failure.errors) {
              if (err['field'] != null && err['message'] != null) {
                mappedErrors[err['field'].toString()] = err['message']
                    .toString();
              }
            }
            emit(
              currentState.copyWith(
                isSubmitting: false,
                fieldErrors: mappedErrors,
                submitErrorMessage: failure.message,
              ),
            );
          } else {
            emit(
              currentState.copyWith(
                isSubmitting: false,
                submitErrorMessage: failure.message,
              ),
            );
          }
        },
        (ticket) {
          emit(TicketFormSubmitSuccess(ticket: ticket, isUpdate: false));
        },
      );
    }
  }
}
