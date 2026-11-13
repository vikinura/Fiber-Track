import 'package:equatable/equatable.dart';

import '../../../master/domain/entities/area.dart';
import '../../../master/domain/entities/issue_type.dart';
import '../../../master/domain/entities/odp.dart';
import '../../../master/domain/entities/priority.dart';
import '../../domain/entities/ticket.dart';

abstract class TicketFormState extends Equatable {
  const TicketFormState();

  @override
  List<Object?> get props => [];
}

class TicketFormInitial extends TicketFormState {
  const TicketFormInitial();
}

class TicketFormDataLoading extends TicketFormState {
  const TicketFormDataLoading();
}

class TicketFormDataLoaded extends TicketFormState {
  final List<Area> areas;
  final List<Odp> odps;
  final List<IssueType> issueTypes;
  final List<Priority> priorities;
  final bool isLoadingOdps;
  final bool isSubmitting;
  final Map<String, String>? fieldErrors;
  final String? submitErrorMessage;
  final Ticket? submittedTicket;

  const TicketFormDataLoaded({
    required this.areas,
    this.odps = const [],
    required this.issueTypes,
    required this.priorities,
    this.isLoadingOdps = false,
    this.isSubmitting = false,
    this.fieldErrors,
    this.submitErrorMessage,
    this.submittedTicket,
  });

  TicketFormDataLoaded copyWith({
    List<Area>? areas,
    List<Odp>? odps,
    List<IssueType>? issueTypes,
    List<Priority>? priorities,
    bool? isLoadingOdps,
    bool? isSubmitting,
    Map<String, String>? fieldErrors,
    String? submitErrorMessage,
    Ticket? submittedTicket,
  }) {
    return TicketFormDataLoaded(
      areas: areas ?? this.areas,
      odps: odps ?? this.odps,
      issueTypes: issueTypes ?? this.issueTypes,
      priorities: priorities ?? this.priorities,
      isLoadingOdps: isLoadingOdps ?? this.isLoadingOdps,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      fieldErrors: fieldErrors,
      submitErrorMessage: submitErrorMessage,
      submittedTicket: submittedTicket ?? this.submittedTicket,
    );
  }

  @override
  List<Object?> get props => [
    areas,
    odps,
    issueTypes,
    priorities,
    isLoadingOdps,
    isSubmitting,
    fieldErrors,
    submitErrorMessage,
    submittedTicket,
  ];
}

class TicketFormDataError extends TicketFormState {
  final String message;

  const TicketFormDataError(this.message);

  @override
  List<Object?> get props => [message];
}

class TicketFormSubmitSuccess extends TicketFormState {
  final Ticket ticket;
  final bool isUpdate;

  const TicketFormSubmitSuccess({required this.ticket, this.isUpdate = false});

  @override
  List<Object?> get props => [ticket, isUpdate];
}
