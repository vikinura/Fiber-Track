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

  const TicketDetailLoaded({required this.ticket, required this.histories});

  @override
  List<Object?> get props => [ticket, histories];
}

class TicketDetailError extends TicketDetailState {
  final String message;

  const TicketDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
