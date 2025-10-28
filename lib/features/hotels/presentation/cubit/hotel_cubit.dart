import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/usecases/get_popular_hotels.dart';
import '../../domain/usecases/search_hotels.dart';

part 'hotel_state.dart';

class HotelCubit extends Cubit<HotelState> {
  final GetPopularHotels getPopularHotels;
  final SearchHotels searchHotels;

  HotelCubit({
    required this.getPopularHotels,
    required this.searchHotels,
  }) : super(HotelInitial());

  Future<void> loadPopularHotels({
    String city = 'Mumbai',
    String state = 'Maharashtra',
    String country = 'India',
  }) async {
    emit(HotelLoading());

    final result = await getPopularHotels(
      PopularHotelsParams(
        city: city,
        state: state,
        country: country,
      ),
    );

    result.fold(
      (failure) => emit(HotelError(failure.message)),
      (hotels) => emit(HotelLoaded(hotels)),
    );
  }

  Future<void> searchForHotels(String query, {int page = 1}) async {
    if (page == 1) {
      emit(HotelLoading());
    } else {
      if (state is HotelSearchResults) {
        emit((state as HotelSearchResults).copyWith(isLoadingMore: true));
      }
    }

    final result = await searchHotels(
      SearchHotelsParams(query: query, page: page),
    );

    result.fold(
      (failure) => emit(HotelError(failure.message)),
      (hotels) {
        if (page == 1) {
          emit(HotelSearchResults(
            hotels: hotels,
            query: query,
            currentPage: page,
            hasMore: hotels.isNotEmpty,
          ));
        } else {
          if (state is HotelSearchResults) {
            final currentState = state as HotelSearchResults;
            emit(HotelSearchResults(
              hotels: [...currentState.hotels, ...hotels],
              query: query,
              currentPage: page,
              hasMore: hotels.isNotEmpty,
            ));
          }
        }
      },
    );
  }
}
