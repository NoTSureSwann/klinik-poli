import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import '../helpers/animated_alert.dart';
import '../widget/glassmorphism.dart';
import 'login.dart';

class RegisterPasienPage extends StatefulWidget {
  const RegisterPasienPage({super.key});

  @override
  State<RegisterPasienPage> createState() => _RegisterPasienPageState();
}

class _RegisterPasienPageState extends State<RegisterPasienPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomorRMCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _tglLahirCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Pasien newPasien = Pasien(
        nomorRMPasien: _nomorRMCtrl.text,
        namaPasien: _namaCtrl.text,
        tgllhrPasien: _tglLahirCtrl.text,
        telpPasien: _telpCtrl.text,
        alamatPasien: _alamatCtrl.text,
        username: _usernameCtrl.text,
        password: _passwordCtrl.text,
      );

      try {
        await PasienService().addPasien(newPasien);
        if (!mounted) return;
        setState(() => _isLoading = false);
        AnimatedAlert.success(context, "Registrasi berhasil! Silakan login.", onConfirm: () {
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        AnimatedAlert.error(context, "Terjadi kesalahan: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.3)
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Glassmorphism(
                blur: 15,
                opacity: 0.1,
                padding: EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              "Registrasi Pasien",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.displayLarge?.color),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 48),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildTextField(_nomorRMCtrl, "Nomor RM", Icons.pin),
                      SizedBox(height: 15),
                      _buildTextField(_namaCtrl, "Nama Lengkap", Icons.person),
                      SizedBox(height: 15),
                      _buildTextField(_tglLahirCtrl, "Tanggal Lahir (YYYY-MM-DD)", Icons.calendar_today),
                      SizedBox(height: 15),
                      _buildTextField(_telpCtrl, "No. Telepon", Icons.phone),
                      SizedBox(height: 15),
                      _buildTextField(_alamatCtrl, "Alamat", Icons.home),
                      SizedBox(height: 15),
                      Divider(color: Theme.of(context).dividerColor, thickness: 1),
                      SizedBox(height: 15),
                      _buildTextField(_usernameCtrl, "Username", Icons.account_circle),
                      SizedBox(height: 15),
                      _buildTextField(_passwordCtrl, "Password", Icons.lock, obscureText: true),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onSecondary)
                              : Text("DAFTAR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
          prefixIcon: Icon(icon, color: theme.iconTheme.color?.withValues(alpha: 0.7)),
          filled: true,
          fillColor: theme.brightness == Brightness.dark 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.black.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: theme.colorScheme.secondary)),
        ),
        validator: (value) => (value == null || value.isEmpty) ? "Wajib diisi" : null,
      );
    });
  }
}
