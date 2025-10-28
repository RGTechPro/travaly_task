import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';

class SearchLoadingState extends StatelessWidget {
  const SearchLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Searching for hotels...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
