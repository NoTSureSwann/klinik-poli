class Obat {
  String? id;
  String namaObat;
  String kategori;
  double harga;
  int stok;

  Obat({
    this.id,
    required this.namaObat,
    required this.kategori,
    required this.harga,
    required this.stok,
  });

  factory Obat.fromJson(Map<String, dynamic> json) {
    return Obat(
      id: json['id'],
      namaObat: json['nama_obat'],
      kategori: json['kategori'],
      harga: double.parse(json['harga'].toString()),
      stok: int.parse(json['stok'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_obat': namaObat,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
    };
  }
}
