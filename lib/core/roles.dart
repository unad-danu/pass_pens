enum UserRole { mahasiswa, dosen }

extension UserRoleExt on UserRole {
  String get name {
    switch (this) {
      case UserRole.mahasiswa:
        return "mahasiswa";
      case UserRole.dosen:
        return "dosen";
    }
  }
}
