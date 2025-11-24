class MahasiswaModel {
  final String id;
  final String nama;
  final String nrp;
  final String prodi;
  final String angkatan;
  final String emailRecovery;
  final String phone;

  MahasiswaModel({
    required this.id,
    required this.nama,
    required this.nrp,
    required this.prodi,
    required this.angkatan,
    required this.emailRecovery,
    required this.phone,
  });

  factory MahasiswaModel.fromMap(Map<String, dynamic> map) {
    return MahasiswaModel(
      id: map["id"],
      nama: map["nama"],
      nrp: map["nrp"],
      prodi: map["prodi"],
      angkatan: map["angkatan"],
      emailRecovery: map["email_recovery"],
      phone: map["phone"],
    );
  }
}
