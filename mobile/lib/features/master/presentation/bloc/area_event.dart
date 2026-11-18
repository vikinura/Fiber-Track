import 'package:equatable/equatable.dart';

abstract class AreaEvent extends Equatable {
  const AreaEvent();

  @override
  List<Object?> get props => [];
}

class LoadAreasEvent extends AreaEvent {
  const LoadAreasEvent();
}

class CreateAreaEvent extends AreaEvent {
  final String name;
  final String? description;

  const CreateAreaEvent({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class UpdateAreaEvent extends AreaEvent {
  final int id;
  final String name;
  final String? description;

  const UpdateAreaEvent({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

class DeleteAreaEvent extends AreaEvent {
  final int id;

  const DeleteAreaEvent(this.id);

  @override
  List<Object?> get props => [id];
}
