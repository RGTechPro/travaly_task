import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hotel.dart';
import '../repositories/hotel_repository.dart';

class SearchHotels implements UseCase<List<Hotel>, SearchHotelsParams> {
  final HotelRepository repository;

  SearchHotels(this.repository);

  @override
  Future<Either<Failure, List<Hotel>>> call(SearchHotelsParams params) async {
    return await repository.searchHotels(params.query, params.page);
  }
}

class SearchHotelsParams extends Equatable {
  final String query;
  final int page;

  const SearchHotelsParams({
    required this.query,
    required this.page,
  });

  @override
  List<Object> get props => [query, page];
}
