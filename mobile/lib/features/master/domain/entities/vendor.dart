import 'package:equatable/equatable.dart';

class Vendor extends Equatable {
  final int id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String status;

  const Vendor({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, contactPerson, phone, status];
}
