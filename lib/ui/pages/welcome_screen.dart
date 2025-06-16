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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/casablanca.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Animated rounded rectangle overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height *
                      _rectangleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color.fromRGBO(40, 43, 43, 1)
                          : AppColors.kSurfaceLight,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            MediaQuery.of(context).size.width * 0.15),
                        topRight: Radius.circular(
                            MediaQuery.of(context).size.width * 0.15),
                      ),
                      border: !isDark
                          ? Border.all(
                              color: AppColors.kBorderLight,
                              width: 1,
                            )
                          : null,
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
              // Logo and title
              Text(
                'CasaWonders',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Discover the wonders of Casablanca',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white70,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Buttons positioned 15% from bottom of the rectangle
        Positioned(
          bottom: rectangleHeight * 0.15,
          left: 24,
          right: 24,
          child: Column(
            children: [
              GradientButton(
                text: 'Sign Up',
                onPressed: () => _showAuthForm(true),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(39),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(39),
                  child: InkWell(
                    onTap: () => _showAuthForm(false),
                    borderRadius: BorderRadius.circular(39),
                    child: Center(
                      child: Text(
                        'Log In',
                        style: AppTextStyles.buttonText,
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
                child: Icon(
                  LucideIcons.x,
                  color: AppColors.textColor(isDark),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            _isSignUp ? 'Get Started!' : 'Hello again!',
            style: AppTextStyles.h2,
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
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                              )
                          : await ref.read(authProvider.notifier).login(
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
                          // Handle Google auth
                        },
                      ),
                      const SizedBox(width: 16),
                      SocialButton(
                        provider: SocialProvider.apple,
                        onPressed: () {
                          // Handle Apple auth
                        },
                      ),
                      const SizedBox(width: 16),
                      SocialButton(
                        provider: SocialProvider.facebook,
                        onPressed: () {
                          // Handle Facebook auth
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Switch between sign up and login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp
                            ? 'Already have an account? '
                            : 'Don\'t have an account? ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                          });
                        },
                        child: Text(
                          _isSignUp ? 'Log In' : 'Sign Up',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.kAccentMint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
