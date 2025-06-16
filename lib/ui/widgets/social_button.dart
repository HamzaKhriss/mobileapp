import 'package:flutter/material.dart';
import '../../theme/colors.dart';

enum SocialProvider { google, apple, facebook }

class SocialButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  LinearGradient get _backgroundGradient {
    // All social buttons now use the same mint gradient
    return AppColors.mintGradient;
  }

  Widget _buildIcon() {
    switch (provider) {
      case SocialProvider.google:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'G',
              style: TextStyle(
                color: Color(0xFF1ABC9C),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case SocialProvider.apple:
        return const Icon(
          Icons.apple,
          color: Colors.white,
          size: 24,
        );
      case SocialProvider.facebook:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'f',
              style: TextStyle(
                color: Color(0xFF1ABC9C),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: _backgroundGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: _buildIcon(),
          ),
        ),
      ),
    );
  }
}
