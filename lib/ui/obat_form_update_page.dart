import 'package:flutter/material.dart';
import '../model/obat.dart';
import '../service/obat_service.dart';

class ObatFormUpdatePage extends StatefulWidget {
  final Obat obat;
  const ObatFormUpdatePage({Key? key, required this.obat}) : super(key: key);

  @override
  State<ObatFormUpdatePage> createState() => _ObatFormUpdatePageState();
}

class _ObatFormUpdatePageState extends State<ObatFormUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _kategoriCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _stokCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.obat.namaObat);
    _kategoriCtrl = TextEditingController(text: widget.obat.kategori);
    _hargaCtrl = TextEditingController(text: widget.obat.harga.toStringAsFixed(0));
    _stokCtrl = TextEditingController(text: widget.obat.stok.toString());
  }

  void _simpan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final o = Obat(
          id: widget.obat.id,
          namaObat: _namaCtrl.text,
          kategori: _kategoriCtrl.text,
          harga: double.parse(_hargaCtrl.text),
          stok: int.parse(_stokCtrl.text),
        );
        await ObatService().updateObat(o);
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
      appBar: AppBar(title: Text('Edit Obat')),
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
                child: _isLoading ? CircularProgressIndicator() : Text('Simpan Perubahan')
              )
            ],
          ),
        ),
      ),
    );
  }
}
