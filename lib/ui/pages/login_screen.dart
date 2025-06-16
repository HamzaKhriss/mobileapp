import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/auth_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/text_input_field.dart';
import '../widgets/social_button.dart';

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

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.kBrandDark,
            borderRadius: BorderRadius.circular(20),
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
                        child: const Icon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Hello again!',
                    style: AppTextStyles.h2,
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
                  const SizedBox(height: 24),

                  // Login button
                  GradientButton(
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

                  if (authState.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      authState.error!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.kAlertRed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey.shade600,
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
                        "You don't have an account? ",
                        style: AppTextStyles.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.pushReplacementNamed('signup'),
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.kAccentMint,
                            decoration: TextDecoration.underline,
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
    );
  }
}
