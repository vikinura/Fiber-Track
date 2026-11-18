import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {
  final String? search;
  final int page;
  final int limit;

  const LoadCustomersEvent({this.search, this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [search, page, limit];
}

class CreateCustomerEvent extends CustomerEvent {
  final String name;
  final String? phone;
  final String? address;
  final int? areaId;
  final int? odpId;

  const CreateCustomerEvent({
    required this.name,
    this.phone,
    this.address,
    this.areaId,
    this.odpId,
  });

  @override
  List<Object?> get props => [name, phone, address, areaId, odpId];
}

class UpdateCustomerEvent extends CustomerEvent {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final int? areaId;
  final int? odpId;

  const UpdateCustomerEvent({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.areaId,
    this.odpId,
  });

  @override
  List<Object?> get props => [id, name, phone, address, areaId, odpId];
}

class DeleteCustomerEvent extends CustomerEvent {
  final int id;

  const DeleteCustomerEvent(this.id);

  @override
  List<Object?> get props => [id];
}
