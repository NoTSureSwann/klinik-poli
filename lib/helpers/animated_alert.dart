import 'package:flutter/material.dart';
import '../widget/glassmorphism.dart';

class AnimatedAlert {
  static void show(BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    VoidCallback? onConfirm,
    String confirmText = "OK",
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Glassmorphism(
                blur: 15,
                opacity: 0.15,
                color: Colors.white,
                padding: EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 50, color: color),
                    ),
                    SizedBox(height: 20),
                    Text(
                      title,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      message,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (onConfirm != null) onConfirm();
                        },
                        child: Text(confirmText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void success(BuildContext context, String message, {VoidCallback? onConfirm}) {
    show(context, title: "Berhasil", message: message, icon: Icons.check_circle, color: Colors.greenAccent, onConfirm: onConfirm);
  }

  static void error(BuildContext context, String message, {VoidCallback? onConfirm}) {
    show(context, title: "Gagal", message: message, icon: Icons.error, color: Colors.redAccent, onConfirm: onConfirm);
  }
}
