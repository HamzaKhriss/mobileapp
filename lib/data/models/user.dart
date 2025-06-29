import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  final String role;
  @JsonKey(name: 'registration_date')
  final String registrationDate;
  @JsonKey(name: 'last_login_date')
  final String? lastLoginDate;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.role,
    required this.registrationDate,
    this.lastLoginDate,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$firstName $lastName';
  String get displayName => firstName.isNotEmpty ? firstName : email;
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  final String role;
  @JsonKey(name: 'registration_date')
  final String registrationDate;
  @JsonKey(name: 'last_login_date')
  final String? lastLoginDate;
  @JsonKey(name: 'access_token')
  final String accessToken;

  LoginResponse({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.role,
    required this.registrationDate,
    this.lastLoginDate,
    required this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  // Convert to User object
  User get user => User(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        profilePictureUrl: profilePictureUrl,
        role: role,
        registrationDate: registrationDate,
        lastLoginDate: lastLoginDate,
      );
}

@JsonSerializable()
class RegisterRequest {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String password;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String role;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.role = 'user', // Default to 'user' role like web frontend
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class RegisterResponse {
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  final String role;
  @JsonKey(name: 'registration_date')
  final String registrationDate;
  @JsonKey(name: 'last_login_date')
  final String? lastLoginDate;

  RegisterResponse({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.role,
    required this.registrationDate,
    this.lastLoginDate,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);

  // Convert to User object
  User get user => User(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        profilePictureUrl: profilePictureUrl,
        role: role,
        registrationDate: registrationDate,
        lastLoginDate: lastLoginDate,
      );
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
 