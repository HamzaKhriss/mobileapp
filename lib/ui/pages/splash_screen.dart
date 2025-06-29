import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/theme_provider.dart';
import '../widgets/animated_bubble_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late AnimationController _fadeController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade out controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Loading animation
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    // Fade out animation
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Wait a bit then start text animation
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Start loading animation
    await Future.delayed(const Duration(milliseconds: 300));
    _loadingController.repeat();

    // Wait for splash duration then fade out and navigate
    await Future.delayed(const Duration(milliseconds: 2500));
    _fadeController.forward();

    // Navigate to welcome screen
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: AnimatedBubbleBackground(
        isDark: isDark,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _logoController,
            _textController,
            _loadingController,
            _fadeController,
          ]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeOutAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.kBrandDark,
                            AppColors.kBrandDark.withOpacity(0.8),
                            AppColors.kAccentMint.withOpacity(0.1),
                          ]
                        : [
                            AppColors.kSurfaceLight,
                            AppColors.kSurfaceLight.withOpacity(0.9),
                            AppColors.kAccentMint.withOpacity(0.05),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo
                        Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _logoRotateAnimation.value * 0.2,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.kAccentMint.withOpacity(0.15),
                                border: Border.all(
                                  color: AppColors.kAccentMint.withOpacity(0.4),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.kAccentMint.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                width: 80,
                                height: 80,
                                color: AppColors.kAccentMint,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.location_city,
                                  size: 80,
                                  color: AppColors.kAccentMint,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Animated App Title
                        Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: FadeTransition(
                            opacity: _textFadeAnimation,
                            child: Text(
                              'CasaWonders',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor(isDark),
                                letterSpacing: 1.2,
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
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Animated Subtitle
                        Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: FadeTransition(
                            opacity: _textFadeAnimation,
                            child: Text(
                              'Discover the wonders of Casablanca',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondaryColor(isDark),
                                fontSize: 16,
                                letterSpacing: 0.5,
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
                          ),
                        ),

                        const SizedBox(height: 80),

                        // Loading Animation
                        FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              // Custom loading dots
                              SizedBox(
                                width: 60,
                                height: 20,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(3, (index) {
                                    return AnimatedBuilder(
                                      animation: _loadingAnimation,
                                      builder: (context, child) {
                                        final delay = index * 0.3;
                                        final progress =
                                            (_loadingAnimation.value + delay) %
                                                1.0;
                                        final scale = 0.5 +
                                            (0.5 *
                                                (1 - (progress - 0.5).abs() * 2)
                                                    .clamp(0.0, 1.0));

                                        return Transform.scale(
                                          scale: scale,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.kAccentMint
                                                  .withOpacity(0.8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.kAccentMint
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Loading text
                              Text(
                                'Loading...',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondaryColor(isDark),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
