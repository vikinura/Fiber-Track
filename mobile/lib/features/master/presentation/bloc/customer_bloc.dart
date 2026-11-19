import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/customer_crud_usecases.dart';
import '../../domain/usecases/get_customers.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomers getCustomers;
  final CreateCustomer createCustomer;
  final UpdateCustomer updateCustomer;
  final DeleteCustomer deleteCustomer;

  CustomerBloc({
    required this.getCustomers,
    required this.createCustomer,
    required this.updateCustomer,
    required this.deleteCustomer,
  }) : super(const CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<CreateCustomerEvent>(_onCreateCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await getCustomers(
      search: event.search,
      page: event.page,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (paginated) => emit(
        CustomerLoaded(result: paginated, searchQuery: event.search ?? ''),
      ),
    );
  }

  Future<void> _onCreateCustomer(
    CreateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await createCustomer(
      name: event.name,
      phone: event.phone,
      address: event.address,
      areaId: event.areaId,
      odpId: event.odpId,
    );
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) =>
          emit(const CustomerActionSuccess('Pelanggan berhasil ditambahkan')),
    );
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await updateCustomer(
      id: event.id,
      name: event.name,
      phone: event.phone,
      address: event.address,
      areaId: event.areaId,
      odpId: event.odpId,
    );
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(const CustomerActionSuccess('Pelanggan berhasil diperbarui')),
    );
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await deleteCustomer(event.id);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(const CustomerActionSuccess('Pelanggan berhasil dihapus')),
    );
  }
}
