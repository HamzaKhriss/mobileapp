import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../state/auth_provider.dart';
import '../../state/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _currentIndex = 3;

  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {
              // Settings functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(authState, isDark),
            const SizedBox(height: 32),

            // Menu items
            _buildMenuItem(
              icon: LucideIcons.bookmark,
              title: 'My Bookings',
              subtitle: 'View your booking history',
              isDark: isDark,
              onTap: () {
                _showBookingsHistory(isDark);
              },
            ),
            const SizedBox(height: 16),

            _buildMenuItem(
              icon: LucideIcons.credit_card,
              title: 'Payment Methods',
              subtitle: 'Manage your payment options',
              isDark: isDark,
              onTap: () {
                // Payment methods functionality
              },
            ),
            const SizedBox(height: 16),

            _buildMenuItem(
              icon: LucideIcons.bell,
              title: 'Notifications',
              subtitle: 'Manage notification settings',
              isDark: isDark,
              onTap: () {
                // Notifications functionality
              },
            ),
            const SizedBox(height: 16),

            // Dark mode toggle
            Consumer(
              builder: (context, ref, child) {
                final themeMode = ref.watch(themeProvider);
                final isDark = themeMode == ThemeMode.dark;
                return _buildToggleItem(
                  icon: LucideIcons.moon,
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark/light theme',
                  value: isDark,
                  isDark: isDark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Language selector
            _buildMenuItem(
              icon: LucideIcons.globe,
              title: 'Language',
              subtitle: _selectedLanguage,
              isDark: isDark,
              onTap: () {
                _showLanguageSelector(isDark);
              },
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 16),

            _buildMenuItem(
              icon: LucideIcons.info,
              title: 'Help & Support',
              subtitle: 'Get help when you need it',
              isDark: isDark,
              onTap: () {
                // Help functionality
              },
            ),
            const SizedBox(height: 16),

            _buildMenuItem(
              icon: LucideIcons.shield,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              isDark: isDark,
              onTap: () {
                // Privacy policy functionality
              },
            ),
            const SizedBox(height: 32),

            // Logout button
            Container(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.goNamed('welcome');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.kAlertRed),
                  foregroundColor: AppColors.kAlertRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Log Out',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.kAlertRed,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App version
            Text(
              'Casa Wonders v1.0.0',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor(isDark),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(
              color: AppColors.borderColor(isDark),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: LucideIcons.house,
                  label: 'Home',
                  index: 0,
                  isSelected: _currentIndex == 0,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                    context.goNamed('home');
                  },
                ),
                _buildNavItem(
                  icon: LucideIcons.compass,
                  label: 'Explore',
                  index: 1,
                  isSelected: _currentIndex == 1,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                    context.goNamed('explore');
                  },
                ),
                _buildNavItem(
                  icon: LucideIcons.heart,
                  label: 'Wishlist',
                  index: 2,
                  isSelected: _currentIndex == 2,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _currentIndex = 2;
                    });
                    context.goNamed('wishlist');
                  },
                ),
                _buildNavItem(
                  icon: LucideIcons.user,
                  label: 'Profile',
                  index: 3,
                  isSelected: _currentIndex == 3,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _currentIndex = 3;
                    });
                    // Already on profile
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.kAccentMint.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.kAccentMint
                    : AppColors.textSecondaryColor(isDark),
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.kAccentMint
                      : AppColors.textSecondaryColor(isDark),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthState authState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor(isDark),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.mintGradient,
            ),
            child: const Icon(
              LucideIcons.user,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.userName ?? 'Guest User',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  authState.userEmail ?? 'guest@casawonders.com',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryColor(isDark),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.kAccentMint.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Verified',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.kAccentMint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Edit profile functionality
            },
            icon: const Icon(
              LucideIcons.pencil,
              color: AppColors.kAccentMint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderColor(isDark),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kAccentMint.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.kAccentMint,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondaryColor(isDark),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor(isDark),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.kAccentMint.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.kAccentMint,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.kAccentMint,
          ),
        ],
      ),
    );
  }

  void _showBookingsHistory(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Booking History',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderColor(isDark),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    color: AppColors.kAccentMint,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Luxury Riad in Medina',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Dec 15-18, 2023 • \$360 total',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.kAccentMint.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Completed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.kAccentMint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(bool isDark) {
    final languages = ['English', 'French', 'Arabic', 'Spanish'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 24),
            ...languages.map((language) => ListTile(
                  title: Text(
                    language,
                    style: AppTextStyles.bodyMedium,
                  ),
                  trailing: _selectedLanguage == language
                      ? const Icon(LucideIcons.check,
                          color: AppColors.kAccentMint)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
