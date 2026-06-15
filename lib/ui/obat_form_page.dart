import 'package:flutter/material.dart';
import '../model/obat.dart';
import '../service/obat_service.dart';

class ObatFormPage extends StatefulWidget {
  const ObatFormPage({Key? key}) : super(key: key);

  @override
  State<ObatFormPage> createState() => _ObatFormPageState();
}

class _ObatFormPageState extends State<ObatFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _kategoriCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _stokCtrl = TextEditingController();
  bool _isLoading = false;

  void _simpan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final o = Obat(
          namaObat: _namaCtrl.text,
          kategori: _kategoriCtrl.text,
          harga: double.parse(_hargaCtrl.text),
          stok: int.parse(_stokCtrl.text),
        );
        await ObatService().addObat(o);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Obat')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(autovalidateMode: AutovalidateMode.onUserInteraction, 
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _namaCtrl, decoration: InputDecoration(labelText: 'Nama Obat'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _kategoriCtrl, decoration: InputDecoration(labelText: 'Kategori')),
              TextFormField(controller: _hargaCtrl, decoration: InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _stokCtrl, decoration: InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _simpan,
                child: _isLoading ? CircularProgressIndicator() : Text('Simpan')
              )
            ],
          ),
        ),
      ),
    );
  }
}
