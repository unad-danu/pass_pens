import '../../core/roles.dart';

class UserModel {
  final String id;
  final String email;
  final UserRole role;
  final Map<String, dynamic>? profile;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.profile,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      role: map['role'] == "mahasiswa" ? UserRole.mahasiswa : UserRole.dosen,
      profile: map['profile'],
    );
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "email": email, "role": role.name, "profile": profile};
  }
}
