import 'package:equatable/equatable.dart';

import '../../domain/entities/area.dart';

abstract class AreaState extends Equatable {
  const AreaState();

  @override
  List<Object?> get props => [];
}

class AreaInitial extends AreaState {
  const AreaInitial();
}

class AreaLoading extends AreaState {
  const AreaLoading();
}

class AreaLoaded extends AreaState {
  final List<Area> areas;

  const AreaLoaded(this.areas);

  @override
  List<Object?> get props => [areas];
}

class AreaActionSuccess extends AreaState {
  final String message;

  const AreaActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AreaError extends AreaState {
  final String message;

  const AreaError(this.message);

  @override
  List<Object?> get props => [message];
}
