class EmployeeProfile {
  final int id;
  final String name;
  final String username;
  final String number;
  final String email;
  final String role; // 'Admin' or 'Employee'

  const EmployeeProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.number,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      number: json['number'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'Employee',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'number': number,
      'email': email,
      'role': role,
    };
  }
}
