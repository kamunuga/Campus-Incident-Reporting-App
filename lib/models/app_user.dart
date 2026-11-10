import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student('Student'),
  staff('Campus Staff');

  const UserRole(this.label);
  final String label;

  static UserRole fromValue(String? value) =>
      value == UserRole.staff.name ? UserRole.staff : UserRole.student;
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final DateTime? createdAt;

  bool get isStaff => role == UserRole.staff;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'there' : parts.first;
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    if (parts.isEmpty) return '?';
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRole.fromValue(map['role'] as String?),
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
