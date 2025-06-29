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

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  bool _showForm = false;
  bool _isSignUp = true;
  late AnimationController _animationController;
  late Animation<double> _rectangleAnimation;
  late Animation<double> _fadeAnimation;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rectangleAnimation = Tween<double>(
      begin: 0.6,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAuthForm(bool isSignUp) {
    setState(() {
      _showForm = true;
      _isSignUp = isSignUp;
    });
    _animationController.forward();
  }

  void _hideAuthForm() {
    _animationController.reverse().then((_) {
      setState(() {
        _showForm = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: AnimatedBubbleBackground(
        isDark: isDark,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                // Animated rounded rectangle overlay (keeping the grey box)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height *
                      _rectangleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.kBrandDark.withOpacity(0.95)
                          : AppColors.kSurfaceLight.withOpacity(0.95),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            MediaQuery.of(context).size.width * 0.15),
                        topRight: Radius.circular(
                            MediaQuery.of(context).size.width * 0.15),
                      ),
                      border: !isDark
                          ? Border.all(
                              color: AppColors.kBorderLight.withOpacity(0.3),
                              width: 1,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                  ),
                ),
                // Content
                _showForm
                    ? Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: SafeArea(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: _buildAuthForm(),
                            ),
                          ),
                        ),
                      )
                    : SafeArea(child: _buildWelcomeContent()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeContent() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final rectangleHeight = screenHeight * 0.6; // 60% of screen height

    return Stack(
      children: [
        // Title and subtitle positioned 15% from top of the rectangle
        Positioned(
          bottom: rectangleHeight * 0.85 - 100, // 15% from top of rectangle
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo and title with enhanced styling
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kAccentMint.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.kAccentMint.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 60,
                  height: 60,
                  color: AppColors.kAccentMint,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.location_city,
                    size: 60,
                    color: AppColors.kAccentMint,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'CasaWonders',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textColor(isDark),
                  shadows: [
                    Shadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.6),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Discover the wonders of Casablanca',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark
                      ? Colors.white.withOpacity(0.9)
                      : AppColors.textSecondaryColor(isDark),
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.4),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Enhanced buttons positioned 15% from bottom of the rectangle
        Positioned(
          bottom: rectangleHeight * 0.15,
          left: 24,
          right: 24,
          child: Column(
            children: [
              // Sign Up button with enhanced styling
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
                  onPressed: () => _showAuthForm(true),
                ),
              ),
              const SizedBox(height: 20),
              // Log In button with enhanced styling
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.4)
                        : AppColors.textColor(isDark).withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(39),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : AppColors.textColor(isDark).withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : AppColors.cardColor(isDark).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(39),
                  child: InkWell(
                    onTap: () => _showAuthForm(false),
                    borderRadius: BorderRadius.circular(39),
                    child: Center(
                      child: Text(
                        'Log In',
                        style: AppTextStyles.buttonText.copyWith(
                          color: isDark
                              ? Colors.white
                              : AppColors.textColor(isDark),
                          shadows: [
                            Shadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.4),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
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
                onTap: _hideAuthForm,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardColor(isDark).withOpacity(0.3),
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

          // Title
          Text(
            _isSignUp ? 'Get Started!' : 'Hello again!',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textColor(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Form fields
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_isSignUp) ...[
                    TextInputField(
                      label: 'Name',
                      controller: _nameController,
                      hint: 'Enter your name',
                    ),
                    const SizedBox(height: 20),
                  ],

                  TextInputField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  TextInputField(
                    label: 'Password',
                    controller: _passwordController,
                    hint: 'Enter your Password',
                    obscureText: true,
                  ),

                  if (_isSignUp) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Must be atleast 8 characters!',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Auth button
                  GradientButton(
                    text: _isSignUp ? 'Sign Up' : 'Log In',
                    isLoading: authState.isLoading,
                    onPressed: () async {
                      final success = _isSignUp
                          ? await ref.read(authProvider.notifier).signUp(
                                firstName:
                                    _nameController.text.split(' ').first,
                                lastName:
                                    _nameController.text.split(' ').length > 1
                                        ? _nameController.text
                                            .split(' ')
                                            .skip(1)
                                            .join(' ')
                                        : '',
                                email: _emailController.text,
                                password: _passwordController.text,
                              )
                          : await ref.read(authProvider.notifier).login(
                                _emailController.text,
                                _passwordController.text,
                              );

                      if (success && mounted) {
                        if (_isSignUp) {
                          // Show success message and switch to login mode
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Registration successful! Please log in with your new account.'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );
                          setState(() {
                            _isSignUp = false;
                            _nameController.clear();
                            _passwordController.clear();
                            // Keep email filled for convenience but clear any auth state
                          });
                          // Clear any error state
                          ref.read(authProvider.notifier).clearError();
                        } else {
                          context.goNamed('home');
                        }
                      }
                    },
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
                    _isSignUp ? 'Sign up with' : 'Log in with',
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

                  // Switch between sign up and log in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp
                            ? 'Already have an account? '
                            : "Don't have an account? ",
                        style: AppTextStyles.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                          });
                        },
                        child: Text(
                          _isSignUp ? 'Log In' : 'Sign Up',
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
        ],
      ),
    );
  }
}
