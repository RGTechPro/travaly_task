import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../cubit/hotel_cubit.dart';

class SearchEmptyState extends StatelessWidget {
  final String searchQuery;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hotels found',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any hotels matching "$searchQuery"',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Future.microtask(() {
                  if (context.mounted) {
                    context.read<HotelCubit>().loadPopularHotels(
                          city: 'Mumbai',
                          state: 'Maharashtra',
                          country: 'India',
                        );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Another Search'),
            ),
          ],
        ),
      ),
    );
  }
}
