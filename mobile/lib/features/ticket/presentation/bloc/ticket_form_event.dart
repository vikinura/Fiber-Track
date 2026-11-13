import 'package:equatable/equatable.dart';

abstract class TicketFormEvent extends Equatable {
  const TicketFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadMasterFormData extends TicketFormEvent {
  const LoadMasterFormData();
}

class AreaSelectedEvent extends TicketFormEvent {
  final int areaId;

  const AreaSelectedEvent(this.areaId);

  @override
  List<Object?> get props => [areaId];
}

class SubmitTicketForm extends TicketFormEvent {
  final int? ticketId; // null jika create, int jika update
  final int customerId;
  final int areaId;
  final int? odpId;
  final int issueTypeId;
  final int priorityId;
  final String description;
  final double? latitude;
  final double? longitude;

  const SubmitTicketForm({
    this.ticketId,
    required this.customerId,
    required this.areaId,
    this.odpId,
    required this.issueTypeId,
    required this.priorityId,
    required this.description,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    ticketId,
    customerId,
    areaId,
    odpId,
    issueTypeId,
    priorityId,
    description,
    latitude,
    longitude,
  ];
}
