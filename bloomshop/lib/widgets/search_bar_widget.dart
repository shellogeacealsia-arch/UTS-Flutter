import 'package:flutter/material.dart';

import 'package:bloomshop/core/constants/app_colors.dart';
import 'package:bloomshop/core/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search your favorite products...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.card(radius: 16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hint,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.mutedRose),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
