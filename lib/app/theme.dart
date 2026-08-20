import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text.dart';

abstract final class HarlequinTheme {
  static ThemeData get light {
    final inter = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: AppColors.page,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        onPrimary: AppColors.white,
        secondary: AppColors.orange,
        surface: AppColors.white,
        onSurface: AppColors.text,
      ),
      textTheme: inter
          .apply(
            bodyColor: AppColors.text,
            displayColor: AppColors.text,
            fontFamily: GoogleFonts.inter().fontFamily,
          )
          .copyWith(
            headlineMedium: AppText.title,
            titleLarge: AppText.title,
          ),
      dividerColor: AppColors.line,
    );
  }
}
