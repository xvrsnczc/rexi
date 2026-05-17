import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed),
        useMaterial3: true,
      );
}
