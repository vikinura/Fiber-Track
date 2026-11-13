import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class CreateTicketParams extends Equatable {
  final int customerId;
  final int areaId;
  final int? odpId;
  final int issueTypeId;
  final int priorityId;
  final String description;
  final double? latitude;
  final double? longitude;

  const CreateTicketParams({
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

class CreateTicket {
  final TicketRepository repository;

  CreateTicket(this.repository);

  Future<Either<Failure, Ticket>> call(CreateTicketParams params) {
    return repository.createTicket(
      customerId: params.customerId,
      areaId: params.areaId,
      odpId: params.odpId,
      issueTypeId: params.issueTypeId,
      priorityId: params.priorityId,
      description: params.description,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}
