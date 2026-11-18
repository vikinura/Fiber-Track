import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/area_crud_usecases.dart';
import '../../domain/usecases/get_areas.dart';
import 'area_event.dart';
import 'area_state.dart';

class AreaBloc extends Bloc<AreaEvent, AreaState> {
  final GetAreas getAreas;
  final CreateArea createArea;
  final UpdateArea updateArea;
  final DeleteArea deleteArea;

  AreaBloc({
    required this.getAreas,
    required this.createArea,
    required this.updateArea,
    required this.deleteArea,
  }) : super(const AreaInitial()) {
    on<LoadAreasEvent>(_onLoadAreas);
    on<CreateAreaEvent>(_onCreateArea);
    on<UpdateAreaEvent>(_onUpdateArea);
    on<DeleteAreaEvent>(_onDeleteArea);
  }

  Future<void> _onLoadAreas(
    LoadAreasEvent event,
    Emitter<AreaState> emit,
  ) async {
    emit(const AreaLoading());
    final result = await getAreas();
    result.fold(
      (failure) => emit(AreaError(failure.message)),
      (areas) => emit(AreaLoaded(areas)),
    );
  }

  Future<void> _onCreateArea(
    CreateAreaEvent event,
    Emitter<AreaState> emit,
  ) async {
    emit(const AreaLoading());
    final result = await createArea(
      name: event.name,
      description: event.description,
    );
    result.fold(
      (failure) => emit(AreaError(failure.message)),
      (area) => emit(const AreaActionSuccess('Area berhasil ditambahkan')),
    );
  }

  Future<void> _onUpdateArea(
    UpdateAreaEvent event,
    Emitter<AreaState> emit,
  ) async {
    emit(const AreaLoading());
    final result = await updateArea(
      id: event.id,
      name: event.name,
      description: event.description,
    );
    result.fold(
      (failure) => emit(AreaError(failure.message)),
      (area) => emit(const AreaActionSuccess('Area berhasil diperbarui')),
    );
  }

  Future<void> _onDeleteArea(
    DeleteAreaEvent event,
    Emitter<AreaState> emit,
  ) async {
    emit(const AreaLoading());
    final result = await deleteArea(event.id);
    result.fold(
      (failure) => emit(AreaError(failure.message)),
      (_) => emit(const AreaActionSuccess('Area berhasil dihapus')),
    );
  }
}
