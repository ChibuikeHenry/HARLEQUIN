import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../constants/app_colors.dart';

class HqTextField extends StatelessWidget {
  const HqTextField({
    super.key,
    required this.hint,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.errorText,
    this.suffix,
    this.radius = 10,
    this.controller,
  });

  final String hint;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final Widget? suffix;
  final double radius;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
        errorText: errorText,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.2),
        ),
      ),
    );

    if (label == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}

class HqButton extends StatelessWidget {
  const HqButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background = AppColors.navy,
    this.foreground = AppColors.white,
    this.outlined = false,
    this.busy = false,
    this.icon,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final bool outlined;
  final bool busy;
  final Widget? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: foreground,
                ),
              ),
            ],
          );

    if (outlined) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: busy ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
            side: const BorderSide(color: Color(0xFFD0D5DD)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background.withValues(alpha: 0.7),
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: child,
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class BusinessAvatar extends StatelessWidget {
  const BusinessAvatar({
    super.key,
    required this.business,
    this.radius = 16,
    this.backgroundColor = AppColors.orange,
    this.foregroundColor = AppColors.white,
    this.previewBytes,
  });

  final Business business;
  final double radius;
  final Color backgroundColor;
  final Color foregroundColor;
  final Uint8List? previewBytes;

  @override
  Widget build(BuildContext context) {
    if (previewBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(previewBytes!),
      );
    }

    if (business.logoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: ClipOval(
          child: Image.network(
            business.logoUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Text(
              business.initial,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.9,
              ),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        business.initial,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.9,
        ),
      ),
    );
  }
}

class BusinessBadge extends StatelessWidget {
  const BusinessBadge({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BusinessAvatar(business: business),
          const SizedBox(width: 10),
          Text(
            business.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
        ],
      ),
    );
  }
}

class AuthBlobs extends StatelessWidget {
  const AuthBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(top: 28, right: -28, child: _Blob(108, AppColors.blobNavy)),
          Positioned(top: 92, right: 78, child: _Blob(46, AppColors.blobGreen)),
          Positioned(top: 118, right: 42, child: _Blob(22, AppColors.blobRed)),
          Positioned(top: 138, right: 78, child: _Blob(12, AppColors.blobPurple)),
          Positioned(bottom: 36, left: 28, child: _Blob(92, AppColors.blobRed)),
          Positioned(bottom: 88, left: 108, child: _Blob(28, AppColors.blobPurple)),
          Positioned(bottom: 42, left: 112, child: _Blob(48, AppColors.blobNavy)),
          Positioned(bottom: 118, left: 132, child: _Blob(14, AppColors.blobGreen)),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob(this.size, this.color);

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.status,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
