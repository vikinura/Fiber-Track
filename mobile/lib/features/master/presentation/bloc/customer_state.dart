import 'package:equatable/equatable.dart';

import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/customer.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

class CustomerLoaded extends CustomerState {
  final PaginatedResult<Customer> result;
  final String searchQuery;

  const CustomerLoaded({required this.result, this.searchQuery = ''});

  @override
  List<Object?> get props => [result, searchQuery];
}

class CustomerActionSuccess extends CustomerState {
  final String message;

  const CustomerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
