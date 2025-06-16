import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed != null && !isLoading
            ? AppColors.mintGradient
            : LinearGradient(
                colors: [Colors.grey.shade600, Colors.grey.shade700],
              ),
        borderRadius: BorderRadius.circular(39),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(39),
        child: InkWell(
          onTap: onPressed != null && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(39),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(text, style: AppTextStyles.buttonText),
          ),
        ),
      ),
    );
  }
}
