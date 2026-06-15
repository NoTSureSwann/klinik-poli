import 'package:flutter/material.dart';
import '../service/login_service.dart';
import '../helpers/user_info.dart';
import '../helpers/animated_alert.dart';
import '../widget/glassmorphism.dart';
import 'beranda.dart';
import 'dokter_dashboard.dart';
import 'pasien_dashboard.dart';
import 'register_pasien_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String username = _usernameCtrl.text.trim();
      String password = _passwordCtrl.text.trim();

      bool success = await LoginService().login(username, password);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        String role = await UserInfo().getRole();
        if (!mounted) return;
        
        AnimatedAlert.success(context, "Login berhasil sebagai $role", onConfirm: () {
          if (!mounted) return;
          Widget nextScreen = Beranda();
          if (role == "Dokter" || role == "Perawat") nextScreen = DokterDashboard();
          if (role == "Pasien") nextScreen = PasienDashboard();
          
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
        });
      } else {
        AnimatedAlert.error(context, "Username atau Password salah!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Glassmorphism(
              blur: 15,
              opacity: 0.1,
              padding: EdgeInsets.all(30),
              child: Form(autovalidateMode: AutovalidateMode.onUserInteraction, 
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_hospital, size: 80, color: Theme.of(context).colorScheme.secondary),
                    SizedBox(height: 20),
                    Text(
                      "Klinik App",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.displayLarge?.color,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Silakan login untuk melanjutkan", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    SizedBox(height: 30),
                    _buildTextField(_usernameCtrl, "Username / Email", Icons.person),
                    SizedBox(height: 20),
                    _buildTextField(_passwordCtrl, "Password", Icons.lock, obscureText: true),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPasienPage()));
                      },
                      child: Text("Belum punya akun? Daftar sebagai Pasien",
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                    )
                  ],
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: theme.colorScheme.secondary),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "$label tidak boleh kosong";
          return null;
        },
      );
    });
  }
}
