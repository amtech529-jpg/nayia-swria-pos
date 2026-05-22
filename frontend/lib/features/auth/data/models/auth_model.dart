class AuthUser {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String token;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json, String token) =>
      AuthUser(
        id: json['id'] ?? 0,
        fullName: json['full_name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'STAFF',
        token: token,
      );

  factory AuthUser.fromMap(Map<String, dynamic> map) => AuthUser(
        id: map['id'] ?? 0,
        fullName: map['fullName'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? 'STAFF',
        token: map['token'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'role': role,
        'token': token,
      };
}
