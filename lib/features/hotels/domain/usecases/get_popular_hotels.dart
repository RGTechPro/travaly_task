import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hotel.dart';
import '../repositories/hotel_repository.dart';

class GetPopularHotels implements UseCase<List<Hotel>, PopularHotelsParams> {
  final HotelRepository repository;

  GetPopularHotels(this.repository);

  @override
  Future<Either<Failure, List<Hotel>>> call(PopularHotelsParams params) async {
    return await repository.getPopularHotels(
      city: params.city,
      state: params.state,
      country: params.country,
    );
  }
}

class PopularHotelsParams extends Equatable {
  final String city;
  final String state;
  final String country;

  const PopularHotelsParams({
    required this.city,
    required this.state,
    required this.country,
  });

  @override
  List<Object> get props => [city, state, country];
}
