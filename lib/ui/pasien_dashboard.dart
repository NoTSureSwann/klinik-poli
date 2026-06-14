import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import 'login.dart';

class PasienDashboard extends StatelessWidget {
  const PasienDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Pasien"),
        backgroundColor: Color(0xFF2A2D3E),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await UserInfo().logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
            },
          )
        ],
      ),
      backgroundColor: Color(0xFF1E1E2C),
      body: Center(
        child: Text(
          "Selamat Datang di Dashboard Pasien",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
