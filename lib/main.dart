import 'package:flutter/material.dart';
import 'package:klinik_app/ui/beranda.dart';
import 'package:klinik_app/ui/dokter_dashboard.dart';
import 'package:klinik_app/ui/pasien_dashboard.dart';
import 'package:klinik_app/ui/login.dart';
import '/helpers/user_info.dart';
import '/helpers/theme_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await ThemeHelper.loadTheme();

  var token = await UserInfo().getToken();
  var role = await UserInfo().getRole();
  
  Widget initialScreen = Login();
  if (token != null) {
    if (role == "Admin") {
      initialScreen = Beranda();
    } else if (role == "Dokter" || role == "Perawat") {
      initialScreen = DokterDashboard();
    } else if (role == "Pasien") {
      initialScreen = PasienDashboard();
    } else {
      initialScreen = Beranda(); // Fallback
    }
  }

  runApp(ValueListenableBuilder<ThemeMode>(
    valueListenable: themeNotifier,
    builder: (context, currentMode, _) {
      return MaterialApp(
        title: "Klinik App",
        debugShowCheckedModeBanner: false,
        theme: ThemeHelper.lightTheme,
        darkTheme: ThemeHelper.darkTheme,
        themeMode: currentMode,
        home: initialScreen,
      );
    },
  ));
}
