import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/hotel_cubit.dart';
import 'widgets/loading_state.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';
import '../../../../../widgets/hotel_card.dart';
import '../../../../../utils/app_theme.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Trigger initial search
    context.read<HotelCubit>().searchForHotels(widget.searchQuery, page: 1);

    // Setup scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = context.read<HotelCubit>().state;
        if (state is HotelSearchResults &&
            !state.isLoadingMore &&
            state.hasMore) {
          context.read<HotelCubit>().searchForHotels(
                widget.searchQuery,
                page: state.currentPage + 1,
              );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBackNavigation() {
    // Reload popular hotels after navigation completes
    Future.microtask(() {
      if (context.mounted) {
        context.read<HotelCubit>().loadPopularHotels(
              city: 'Mumbai',
              state: 'Maharashtra',
              country: 'India',
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _handleBackNavigation();
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.searchQuery,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<HotelCubit, HotelState>(
          builder: (context, state) {
            return switch (state) {
              HotelLoading() => const SearchLoadingState(),
              HotelSearchResults(:final hotels)
                  when hotels.isEmpty && !state.isLoadingMore =>
                SearchEmptyState(searchQuery: widget.searchQuery),
              HotelSearchResults() => _buildResultsList(state),
              HotelError(:final message) => SearchErrorState(
                  message: message,
                  searchQuery: widget.searchQuery,
                ),
              _ => SearchEmptyState(searchQuery: widget.searchQuery),
            };
          },
        ),
      ),
    );
  }

  Widget _buildResultsList(HotelSearchResults state) {
    return Column(
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.hotels.length} hotel${state.hotels.length != 1 ? 's' : ''} found',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (state.hasMore)
                Text(
                  'Showing page ${state.currentPage}',
                  style: AppTextStyles.bodySmall,
                ),
            ],
          ),
        ),

        // Results List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // Retry search on pull-to-refresh
              context.read<HotelCubit>().searchForHotels(
                    widget.searchQuery,
                    page: 1,
                  );
            },
            color: AppColors.primary,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.hotels.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.hotels.length) {
                  return _buildLoadingIndicator(state.isLoadingMore);
                }
                return HotelCard(hotel: state.hotels[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isLoadingMore) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: isLoadingMore
          ? const Column(
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 8),
                Text(
                  'Loading more hotels...',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
