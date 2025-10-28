part of 'hotel_cubit.dart';

abstract class HotelState extends Equatable {
  const HotelState();

  @override
  List<Object?> get props => [];
}

class HotelInitial extends HotelState {}

class HotelLoading extends HotelState {}

class HotelLoaded extends HotelState {
  final List<Hotel> hotels;

  const HotelLoaded(this.hotels);

  @override
  List<Object?> get props => [hotels];
}

class HotelSearchResults extends HotelState {
  final List<Hotel> hotels;
  final String query;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const HotelSearchResults({
    required this.hotels,
    required this.query,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  HotelSearchResults copyWith({
    List<Hotel>? hotels,
    String? query,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HotelSearchResults(
      hotels: hotels ?? this.hotels,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [hotels, query, currentPage, hasMore, isLoadingMore];
}

class HotelError extends HotelState {
  final String message;

  const HotelError(this.message);

  @override
  List<Object?> get props => [message];
}
