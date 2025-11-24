enum UserRole { mahasiswa, dosen }

extension UserRoleFromEmail on String {
  UserRole? get detectUserRole {
    final email = toLowerCase();

    // Mapping prodi ke domain
    const Map<String, String> prodiToDomain = {
      "D3 Teknik Informatika": "it",
      "D4 Teknik Informatika": "it",
      "D4 Teknik Komputer": "ce",
      "D4 Sains Data Terapan": "ds",
      "D4 Teknologi Rekayasa Multimedia": "met",
      "D4 Teknologi Rekayasa Internet": "iet",
      "D3 Multimedia Broadcasting": "mmb",
      "D4 Teknologi Game": "gt",
      "D3 Teknik Elektronika Industri": "iee",
      "D4 Teknik Elektronika Industri": "iee",
      "D3 Teknik Elektronika": "ee",
      "D4 Teknik Elektronika": "ee",
      "D4 Teknik Mekatronika": "me",
      "D4 Sistem Pembangkit Energi": "pg",
      "D3 Teknik Telekomunikasi": "te",
      "D4 Teknik Telekomunikasi": "te",
    };

    // Generate domain mahasiswa berdasarkan mapping
    final List<String> prodiPrefixes = prodiToDomain.values
        .map((code) => "@$code.student.pens.ac.id")
        .toList();

    // CEK MAHASISWA
    for (final prefix in prodiPrefixes) {
      if (email.endsWith(prefix)) {
        return UserRole.mahasiswa;
      }
    }

    // CEK DOSEN
    if (email.endsWith("@lecturer.pens.ac.id")) {
      return UserRole.dosen;
    }

    return null;
  }
}
