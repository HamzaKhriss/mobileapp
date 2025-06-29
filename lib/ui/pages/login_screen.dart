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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
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
                        Icons.login,
                        size: 40,
                        color: AppColors.kAccentMint,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Hello again!',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textColor(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back, you\'ve been missed!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryColor(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Form fields
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
                    ),
                    const SizedBox(height: 16),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Handle forgot password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.kAccentMint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login button
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
                        text: 'Log In',
                        isLoading: authState.isLoading,
                        onPressed: () async {
                          final success =
                              await ref.read(authProvider.notifier).login(
                                    _emailController.text,
                                    _passwordController.text,
                                  );

                          if (success && mounted) {
                            context.goNamed('home');
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
                      'Log in with',
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

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () => context.goNamed('signup'),
                          child: Text(
                            'Sign Up',
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
