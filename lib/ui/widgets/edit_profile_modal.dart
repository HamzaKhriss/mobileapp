import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../data/models/user.dart';
import '../../data/services/auth_service.dart';
import '../../state/auth_provider.dart';

class EditProfileModal extends ConsumerStatefulWidget {
  final User user;
  final VoidCallback onProfileUpdated;

  const EditProfileModal({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  ConsumerState<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends ConsumerState<EditProfileModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _authService = AuthService();
  final _imagePicker = ImagePicker();

  // Basic profile form
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  // Password change form
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State management
  bool _isUpdatingProfile = false;
  bool _isChangingPassword = false;
  bool _isUploadingAvatar = false;
  String? _profileError;
  String? _passwordError;
  String? _successMessage;
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize form controllers with current user data
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingAvatar = true;
      _profileError = null;
    });

    try {
      final updatedUser = await _authService.uploadAvatar(_selectedImage!);

      // Update auth provider with new user data
      ref.read(authProvider.notifier).updateUser(updatedUser);

      widget.onProfileUpdated();
      _showSuccess('Profile picture updated successfully!');

      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      _showError('Failed to upload avatar: $e');
    } finally {
      setState(() {
        _isUploadingAvatar = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isUpdatingProfile = true;
      _profileError = null;
    });

    try {
      final updatedUser = await _authService.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      // Update auth provider with new user data
      ref.read(authProvider.notifier).updateUser(updatedUser);

      widget.onProfileUpdated();
      _showSuccess('Profile updated successfully!');
    } catch (e) {
      _showError('Failed to update profile: $e');
    } finally {
      setState(() {
        _isUpdatingProfile = false;
      });
    }
  }

  Future<void> _changePassword() async {
    // Validate passwords
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('New passwords do not match');
      return;
    }

    if (_newPasswordController.text.length < 8) {
      _showError('Password must be at least 8 characters long');
      return;
    }

    setState(() {
      _isChangingPassword = true;
      _passwordError = null;
    });

    try {
      await _authService.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      _showSuccess('Password changed successfully!');

      // Clear password fields
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      _showError('Failed to change password: $e');
    } finally {
      setState(() {
        _isChangingPassword = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _profileError = message;
      _passwordError = message;
      _successMessage = null;
    });
  }

  void _showSuccess(String message) {
    setState(() {
      _successMessage = message;
      _profileError = null;
      _passwordError = null;
    });

    // Clear success message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _successMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor(isDark),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.kAccentMint,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Edit Profile',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Success/Error Messages
            if (_successMessage != null || _profileError != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _successMessage != null
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _successMessage != null
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _successMessage != null
                          ? Icons.check_circle
                          : Icons.error,
                      color:
                          _successMessage != null ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage ?? _profileError ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _successMessage != null
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.kAccentMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textColor(isDark),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Security'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileTab(isDark),
                  _buildSecurityTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar Section
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.kAccentMint,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.user.profilePictureUrl ??
                                '/placeholder-avatar.jpg',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.borderColor(isDark),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.borderColor(isDark),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.kAccentMint,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundColor(isDark),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Upload button for selected image
          if (_selectedImage != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => setState(() => _selectedImage = null),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isUploadingAvatar ? null : _uploadAvatar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kAccentMint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploadingAvatar
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Upload',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),

          const SizedBox(height: 32),

          // Form Fields
          _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            icon: Icons.person_outline,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Icons.person_outline,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUpdatingProfile ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kAccentMint,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUpdatingProfile
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Password',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textColor(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildPasswordField(
            controller: _oldPasswordController,
            label: 'Current Password',
            isVisible: _showOldPassword,
            onToggleVisibility: () =>
                setState(() => _showOldPassword = !_showOldPassword),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'New Password',
            isVisible: _showNewPassword,
            onToggleVisibility: () =>
                setState(() => _showNewPassword = !_showNewPassword),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            isVisible: _showConfirmPassword,
            onToggleVisibility: () =>
                setState(() => _showConfirmPassword = !_showConfirmPassword),
            isDark: isDark,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isChangingPassword ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kAccentMint,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isChangingPassword
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Change Password',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textColor(isDark),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.textSecondaryColor(isDark),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.kAccentMint, width: 2),
        ),
        filled: true,
        fillColor: AppColors.cardColor(isDark),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryColor(isDark),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textColor(isDark),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: AppColors.textSecondaryColor(isDark),
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondaryColor(isDark),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.kAccentMint, width: 2),
        ),
        filled: true,
        fillColor: AppColors.cardColor(isDark),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryColor(isDark),
        ),
      ),
    );
  }
}
