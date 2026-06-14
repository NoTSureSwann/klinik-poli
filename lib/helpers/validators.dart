String? requiredValidator(String? value, {String label = 'Field ini'}) {
  if (value == null || value.trim().isEmpty) {
    return '$label tidak boleh kosong';
  }
  return null;
}

String? kodePoliValidator(String? value) {
  final wajib = requiredValidator(value, label: 'Kode Poli');
  if (wajib != null) return wajib;
  final regex = RegExp(r'^[A-Z0-9]{2,5}$');
  if (!regex.hasMatch(value!.trim())) {
    return 'Kode Poli harus 2-5 karakter huruf kapital/angka (contoh: ANA, GIG)';
  }
  return null;
}

String? positiveIntValidator(String? value, {String label = 'Nilai'}) {
  final wajib = requiredValidator(value, label: label);
  if (wajib != null) return wajib;
  final n = int.tryParse(value!.trim());
  if (n == null || n <= 0) {
    return '$label harus berupa angka lebih dari 0';
  }
  return null;
}

String? timeFormatValidator(String? value, {String label = 'Jam'}) {
  final wajib = requiredValidator(value, label: label);
  if (wajib != null) return wajib;
  final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
  if (!regex.hasMatch(value!.trim())) {
    return '$label harus format HH:mm (contoh: 08:00)';
  }
  return null;
}
