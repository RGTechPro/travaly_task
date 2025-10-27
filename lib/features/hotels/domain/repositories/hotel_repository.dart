import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/hotel.dart';

abstract class HotelRepository {
  Future<Either<Failure, List<Hotel>>> searchHotels(String query, int page);
  Future<Either<Failure, List<Hotel>>> getPopularHotels({
    String city,
    String state,
    String country,
  });
}
