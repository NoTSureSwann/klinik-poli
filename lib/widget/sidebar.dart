import 'package:flutter/material.dart';
import '../ui/pegawai_page.dart';
import '../ui/pasien_page.dart';
import '../ui/poli_page.dart';
import '../ui/beranda.dart';
import '../ui/login.dart';
import '../helpers/theme_helper.dart';
import '../ui/jadwal_poli_page.dart';
import '../ui/antrian_menu_page.dart';
import '../ui/chatbot_page.dart';
import '../ui/obat_page.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: Image.asset("assets/img/logo_ubsi.png"),
            accountName: Text("Admin"),
            accountEmail: Text("admin@admin.com"),
            decoration: BoxDecoration(
              color: Colors.blue
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Beranda"),
            onTap: (){
              Navigator.push(
              context, MaterialPageRoute(builder: (context) => Beranda()));
            },
          ),

          ListTile(
            leading: Icon(Icons.accessible),
            title: Text("Poli"),
            onTap: (){
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => PoliPage()));
            },
          ),

          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text("Jadwal Poli"),
            onTap: (){
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => JadwalPoliPage()));
            },
          ),

          ListTile(
            leading: Icon(Icons.people_alt),
            title: Text("Antrian"),
            onTap: (){
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AntrianMenuPage()));
            },
          ),

          ListTile(
            leading: Icon(Icons.people),
            title: Text("Pegawai"),
            onTap: (){
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => PegawaiPage()));
            },
          ),

          ListTile(
            leading: Icon(Icons.account_box_sharp),
            title: Text("Pasien"),
            onTap: (){
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => PasienPage()));
            },
          ),

          ListTile(
            leading: Icon(Icons.medication),
            title: Text("Farmasi (Obat)"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ObatPage()));
            },
          ),

          ListTile(
            leading: Icon(Icons.medical_information),
            title: Text("Rekam Medis"),
            onTap: (){
              // Navigator.push(context, MaterialPageRoute(builder: (context) => RekamMedisPage()));
            },
          ),

          ListTile(
            leading: Icon(Icons.smart_toy_rounded, color: Color(0xFF6C63FF)),
            title: Text("AI Assistant", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Chat dengan AI Klinik", style: TextStyle(fontSize: 11)),
            tileColor: Color(0xFF6C63FF).withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: (){
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ChatbotPage()));
            },
          ),

          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text("Keluar"),
            onTap: (){
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (Route<dynamic> route) => false);
            },
          ),

          Divider(),
          
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              final isDark = currentMode == ThemeMode.dark;
              return SwitchListTile(
                title: Text(isDark ? "Dark Mode" : "Light Mode", style: TextStyle(fontWeight: FontWeight.bold)),
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? Color(0xFF6C63FF) : Color(0xFF5A52E0)),
                value: isDark,
                onChanged: (value) {
                  ThemeHelper.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
