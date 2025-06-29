import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/auth_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/text_input_field.dart';
import '../widgets/social_button.dart';
import '../widgets/animated_bubble_background.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: AnimatedBubbleBackground(
        isDark: isDark,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.kBrandDark.withOpacity(0.95)
                  : AppColors.kSurfaceLight.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.kAccentMint.withOpacity(0.2)
                    : AppColors.kBorderLight.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Later',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.kAccentMint,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppColors.cardColor(isDark).withOpacity(0.3),
                            ),
                            child: Icon(
                              LucideIcons.x,
                              color: AppColors.textColor(isDark),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.kAccentMint.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.kAccentMint.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person_add,
                        size: 40,
                        color: AppColors.kAccentMint,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Get Started!',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textColor(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to start exploring',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryColor(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Form fields
                    TextInputField(
                      label: 'First Name',
                      controller: _firstNameController,
                      hint: 'Enter your first name',
                    ),
                    const SizedBox(height: 20),

                    TextInputField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      hint: 'Enter your last name',
                    ),
                    const SizedBox(height: 20),

                    TextInputField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),

                    TextInputField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: 'Enter your Password',
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Must be atleast 8 characters!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextInputField(
                      label: 'Phone Number (Optional)',
                      controller: _phoneController,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),

                    // Sign up button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(39),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.kAccentMint.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: GradientButton(
                        text: 'Sign Up',
                        isLoading: authState.isLoading,
                        onPressed: () async {
                          final success =
                              await ref.read(authProvider.notifier).signUp(
                                    firstName: _firstNameController.text,
                                    lastName: _lastNameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    phoneNumber:
                                        _phoneController.text.isNotEmpty
                                            ? _phoneController.text
                                            : null,
                                  );

                          if (success && mounted) {
                            // Show success message and redirect to login
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Registration successful! Please log in.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.goNamed('login');
                          }
                        },
                      ),
                    ),

                    if (authState.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.kAlertRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.kAlertRed.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          authState.error!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.kAlertRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.textSecondaryColor(isDark)
                                      .withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryColor(isDark),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.textSecondaryColor(isDark)
                                      .withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social login text
                    Text(
                      'Sign up with',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Social buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialButton(
                          provider: SocialProvider.google,
                          onPressed: () {
                            // Handle Google login
                          },
                        ),
                        const SizedBox(width: 16),
                        SocialButton(
                          provider: SocialProvider.apple,
                          onPressed: () {
                            // Handle Apple login
                          },
                        ),
                        const SizedBox(width: 16),
                        SocialButton(
                          provider: SocialProvider.facebook,
                          onPressed: () {
                            // Handle Facebook login
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Log in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () => context.goNamed('login'),
                          child: Text(
                            'Log In',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.kAccentMint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
