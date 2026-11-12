import 'package:equatable/equatable.dart';

class PaginatedResult<T> extends Equatable {
  final List<T> data;
  final int page;
  final int limit;
  final int total;

  const PaginatedResult({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
  });

  bool get hasMore => page * limit < total;

  @override
  List<Object?> get props => [data, page, limit, total];
}
