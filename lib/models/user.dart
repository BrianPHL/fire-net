/// User model
class User {
  final String id;
  final String name;
  final String email;
  final String role; 

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isEngineer => role == 'engineer';
  bool get isUser => role == 'user';

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
