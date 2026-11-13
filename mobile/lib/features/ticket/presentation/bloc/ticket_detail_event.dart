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
