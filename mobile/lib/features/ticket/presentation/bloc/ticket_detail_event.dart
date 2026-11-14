import 'package:equatable/equatable.dart';

abstract class TicketDetailEvent extends Equatable {
  const TicketDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadTicketDetail extends TicketDetailEvent {
  final int ticketId;

  const LoadTicketDetail(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class ForwardTicketEvent extends TicketDetailEvent {
  final int ticketId;
  final int vendorId;

  const ForwardTicketEvent({required this.ticketId, required this.vendorId});

  @override
  List<Object?> get props => [ticketId, vendorId];
}

class AssignTicketEvent extends TicketDetailEvent {
  final int ticketId;
  final int technicianId;

  const AssignTicketEvent({required this.ticketId, required this.technicianId});

  @override
  List<Object?> get props => [ticketId, technicianId];
}
