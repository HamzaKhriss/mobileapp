import 'dart:io';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: LoginRequest(
        email: email,
        password: password,
      ).toJson(),
    );

    final loginResponse = LoginResponse.fromJson(response.data);

    // Store the auth token
    await _apiClient.setAuthToken(loginResponse.accessToken);

    return loginResponse;
  }

  Future<RegisterResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      ).toJson(),
    );

    final registerResponse = RegisterResponse.fromJson(response.data);

    // Registration doesn't return a token - user needs to login separately
    // This matches the web frontend behavior

    return registerResponse;
  }

  Future<void> logout() async {
    try {
      // Try to logout from server
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Even if server logout fails, clear local token
      print('Server logout failed: $e');
    } finally {
      // Always clear local token
      await _apiClient.clearAuthToken();
    }
  }

  Future<User> getProfile() async {
    final response = await _apiClient.get('/user/profile');
    return User.fromJson(response.data);
  }

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (email != null) data['email'] = email;

    final response = await _apiClient.put('/user/profile', data: data);
    return User.fromJson(response.data);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _apiClient.put('/user/change-password', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<User> uploadAvatar(File imageFile) async {
    try {
      final response = await _apiClient.uploadFile(
        '/user/profile/avatar',
        file: imageFile,
        field: 'file',
      );

      // The backend returns just the updated profile_picture_url, not full user
      // So we need to get the full updated profile after upload
      if (response.statusCode == 200) {
        // Refresh the profile to get the updated avatar URL
        return await getProfile();
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
      // If upload response parsing fails, still try to get updated profile
      // The upload might have succeeded but response parsing failed
      try {
        return await getProfile();
      } catch (e2) {
        throw Exception('Avatar upload failed: $e');
      }
    }
  }

  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  Future<User?> getCurrentUser() async {
    try {
      if (await isAuthenticated()) {
        return await getProfile();
      }
      return null;
    } catch (e) {
      // If getting profile fails, user is not authenticated
      await _apiClient.clearAuthToken();
      return null;
    }
  }
}
