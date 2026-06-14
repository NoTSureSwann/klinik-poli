import 'package:flutter/material.dart';
import '../widget/sidebar.dart';
import 'antrian_form_page.dart';
import 'layar_antrian_page.dart';
import 'antrian_riwayat_page.dart';

class AntrianMenuPage extends StatelessWidget {
  const AntrianMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu Antrian")),
      drawer: Sidebar(),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.person_add, size: 40, color: Colors.blue),
              title: Text("Daftar Antrian Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text("Pendaftaran pasien ke poli"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AntrianFormPage()));
              },
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.tv, size: 40, color: Colors.green),
              title: Text("Layar Antrian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text("Layar real-time pemanggilan antrian"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LayarAntrianPage()));
              },
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.history, size: 40, color: Colors.orange),
              title: Text("Riwayat Antrian Hari Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text("Daftar seluruh antrian dan ubah status manual"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AntrianRiwayatPage()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
