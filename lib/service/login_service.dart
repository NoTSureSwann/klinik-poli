import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/user_info.dart';

class LoginService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> login(String username, String password) async {
    // 1. Cek Admin (Hardcoded)
    if (username == 'admin' && password == 'admin') {
      await UserInfo().setToken("admin");
      await UserInfo().setUserID("admin_id");
      await UserInfo().setUsername("Administrator");
      await UserInfo().setRole("Admin");
      return true;
    }

    // 2. Cek Pegawai (Dokter/Perawat) -> Asumsi menggunakan emailPegawai
    final pegawaiSnap = await _db.collection('pegawai')
        .where('emailPegawai', isEqualTo: username)
        .where('passwordPegawai', isEqualTo: password)
        .get();
        
    if (pegawaiSnap.docs.isNotEmpty) {
      final doc = pegawaiSnap.docs.first;
      final data = doc.data();
      final role = data['jabatanPegawai'] ?? 'Pegawai';
      
      await UserInfo().setToken("token_${doc.id}");
      await UserInfo().setUserID(doc.id);
      await UserInfo().setUsername(data['namaPegawai'] ?? username);
      await UserInfo().setRole(role); // 'Dokter', 'Perawat', dll
      return true;
    }

    // 3. Cek Pasien
    final pasienSnap = await _db.collection('pasien')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();
        
    if (pasienSnap.docs.isNotEmpty) {
      final doc = pasienSnap.docs.first;
      final data = doc.data();
      
      await UserInfo().setToken("token_${doc.id}");
      await UserInfo().setUserID(doc.id);
      await UserInfo().setUsername(data['namaPasien'] ?? username);
      await UserInfo().setRole("Pasien");
      return true;
    }

    return false;
  }
}
