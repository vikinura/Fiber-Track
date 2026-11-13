import 'package:equatable/equatable.dart';

import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_history.dart';

abstract class TicketDetailState extends Equatable {
  const TicketDetailState();

  @override
  List<Object?> get props => [];
}

class TicketDetailInitial extends TicketDetailState {
  const TicketDetailInitial();
}

class TicketDetailLoading extends TicketDetailState {
  const TicketDetailLoading();
}

class TicketDetailLoaded extends TicketDetailState {
  final Ticket ticket;
  final List<TicketHistory> histories;
  final bool isUpdating;
  final String? actionSuccessMessage;
  final String? actionErrorMessage;

  const TicketDetailLoaded({
    required this.ticket,
    required this.histories,
    this.isUpdating = false,
    this.actionSuccessMessage,
    this.actionErrorMessage,
  });

  TicketDetailLoaded copyWith({
    Ticket? ticket,
    List<TicketHistory>? histories,
    bool? isUpdating,
    String? actionSuccessMessage,
    String? actionErrorMessage,
  }) {
    return TicketDetailLoaded(
      ticket: ticket ?? this.ticket,
      histories: histories ?? this.histories,
      isUpdating: isUpdating ?? this.isUpdating,
      actionSuccessMessage: actionSuccessMessage,
      actionErrorMessage: actionErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    ticket,
    histories,
    isUpdating,
    actionSuccessMessage,
    actionErrorMessage,
  ];
}

class TicketDetailError extends TicketDetailState {
  final String message;

  const TicketDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
