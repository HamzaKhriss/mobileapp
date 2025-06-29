import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/theme_provider.dart';

class TextInputField extends ConsumerStatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool showValidationIcon;

  const TextInputField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.showValidationIcon = true,
  });

  @override
  ConsumerState<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends ConsumerState<TextInputField> {
  bool _isValid = false;
  bool _hasStartedTyping = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  void _validateInput() {
    if (!_hasStartedTyping && widget.controller.text.isNotEmpty) {
      setState(() {
        _hasStartedTyping = true;
      });
    }

    if (widget.validator != null) {
      final validation = widget.validator!(widget.controller.text);
      setState(() {
        _isValid = validation == null && widget.controller.text.isNotEmpty;
      });
    } else {
      setState(() {
        _isValid = widget.controller.text.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textColor(isDark).withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _hasStartedTyping && _isValid
                  ? AppColors.kAccentMint
                  : AppColors.textColor(isDark).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textColor(isDark),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textColor(isDark).withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              suffixIcon:
                  widget.showValidationIcon && _hasStartedTyping && _isValid
                      ? const Icon(
                          LucideIcons.check,
                          color: AppColors.kAccentMint,
                          size: 20,
                        )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
