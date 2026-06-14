String formatTanggal(DateTime date) {
  String dua(int n) => n.toString().padLeft(2, '0');
  return "${date.year}-${dua(date.month)}-${dua(date.day)}";
}

const List<String> namaHari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu'
];

String hariIni(DateTime date) => namaHari[date.weekday - 1];

const List<String> daftarHari = namaHari;
