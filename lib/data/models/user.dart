import 'mahasiswa.dart';
import 'dosen.dart';

class UserModel {
  final String id;
  final String email;
  final String role; // "mahasiswa" atau "dosen"

  final MahasiswaModel? mahasiswa;
  final DosenModel? dosen;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.mahasiswa,
    this.dosen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      email: map["email"],
      role: map["role"],
      mahasiswa: null,
      dosen: null,
    );
  }
}
