class DosenModel {
  final String id;
  final String nama;
  final String nip;
  final String prodiAjar;
  final String emailRecovery;
  final String phone;

  DosenModel({
    required this.id,
    required this.nama,
    required this.nip,
    required this.prodiAjar,
    required this.emailRecovery,
    required this.phone,
  });

  factory DosenModel.fromMap(Map<String, dynamic> map) {
    return DosenModel(
      id: map["id"],
      nama: map["nama"],
      nip: map["nip"],
      prodiAjar: map["prodi_ajar"],
      emailRecovery: map["email_recovery"],
      phone: map["phone"],
    );
  }
}
