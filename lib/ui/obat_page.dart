import 'package:flutter/material.dart';
import '../model/obat.dart';
import '../service/obat_service.dart';
import 'obat_form_page.dart';
import 'obat_form_update_page.dart';

class ObatPage extends StatefulWidget {
  const ObatPage({Key? key}) : super(key: key);

  @override
  State<ObatPage> createState() => _ObatPageState();
}

class _ObatPageState extends State<ObatPage> {
  final ObatService _obatService = ObatService();
  List<Obat> _obatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _obatService.retrieveObat();
      setState(() {
        _obatList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Obat'),
        content: Text('Yakin ingin menghapus obat ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text('Hapus')),
        ],
      )
    );

    if (confirm == true) {
      await _obatService.deleteObat(id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Obat (Farmasi)'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _obatList.length,
            itemBuilder: (context, index) {
              final o = _obatList[index];
              return Card(
                child: ListTile(
                  title: Text(o.namaObat),
                  subtitle: Text('Stok: ${o.stok} | Rp ${o.harga.toStringAsFixed(0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ObatFormUpdatePage(obat: o)));
                          _loadData();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(o.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => ObatFormPage()));
          _loadData();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
