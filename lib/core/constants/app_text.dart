import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppText {
  static TextStyle get title => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
        fontSize: 24,
        height: 1.0,
        letterSpacing: 0,
        color: AppColors.text,
      );
}
