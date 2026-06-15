import 'package:flutter/material.dart';
import '../model/antrian.dart';
import '../model/obat.dart';
import '../model/rekam_medis.dart';
import '../service/obat_service.dart';
import '../service/rekam_medis_service.dart';
import '../service/antrian_service.dart';
import 'struk_pembayaran_page.dart';

class PemeriksaanFormPage extends StatefulWidget {
  final Antrian antrian;
  const PemeriksaanFormPage({Key? key, required this.antrian}) : super(key: key);

  @override
  State<PemeriksaanFormPage> createState() => _PemeriksaanFormPageState();
}

class _PemeriksaanFormPageState extends State<PemeriksaanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosaCtrl = TextEditingController();
  final _biayaJasaCtrl = TextEditingController(text: "50000"); // default fee

  List<Obat> _masterObat = [];
  List<ResepObat> _resepList = [];
  Obat? _selectedObat;
  final _jumlahObatCtrl = TextEditingController(text: "1");

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadObat();
  }

  Future<void> _loadObat() async {
    try {
      final list = await ObatService().retrieveObat();
      setState(() {
        _masterObat = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat daftar obat')));
    }
  }

  void _tambahObatKeResep() {
    if (_selectedObat == null) return;
    int qty = int.tryParse(_jumlahObatCtrl.text) ?? 1;
    if (qty <= 0) qty = 1;
    if (qty > _selectedObat!.stok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stok tidak mencukupi!')));
      return;
    }

    setState(() {
      _resepList.add(ResepObat(
        obatId: _selectedObat!.id!,
        jumlah: qty,
        hargaSatuan: _selectedObat!.harga,
        subtotal: qty * _selectedObat!.harga,
        obat: _selectedObat,
      ));
      _selectedObat = null;
      _jumlahObatCtrl.text = "1";
    });
  }

  void _hapusResep(int index) {
    setState(() {
      _resepList.removeAt(index);
    });
  }

  double _hitungTotalObat() {
    double total = 0;
    for (var r in _resepList) {
      total += r.subtotal;
    }
    return total;
  }

  Future<void> _simpanPemeriksaan() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      double jasa = double.parse(_biayaJasaCtrl.text);
      double totalObat = _hitungTotalObat();

      final rm = RekamMedis(
        antrianId: widget.antrian.id!,
        pasienId: widget.antrian.pasienId,
        pegawaiId: "admin_id", // For simple implementation, assuming current user is doctor (using admin_id)
        diagnosa: _diagnosaCtrl.text,
        biayaJasa: jasa,
        totalBiayaObat: totalObat,
        resep: _resepList,
      );

      final rmId = await RekamMedisService().simpanRekamMedis(rm);
      rm.id = rmId; // assign generated ID back

      // Update antrian status to selesai
      await AntrianService().updateStatus(widget.antrian.id!, AntrianStatus.selesai);

      if (mounted) {
        Navigator.pop(context); // close pemeriksaan
        Navigator.push(context, MaterialPageRoute(builder: (context) => StrukPembayaranPage(rekamMedis: rm, antrian: widget.antrian)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pemeriksaan - ${widget.antrian.nomorAntrian}')),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(autovalidateMode: AutovalidateMode.onUserInteraction, 
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Keluhan Pasien:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.antrian.keluhan ?? '-'),
              SizedBox(height: 20),
              TextFormField(
                controller: _diagnosaCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Diagnosa', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _biayaJasaCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Biaya Jasa Dokter (Rp)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 30),
              Text('Resep Obat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<Obat>(
                      decoration: InputDecoration(labelText: 'Pilih Obat', border: OutlineInputBorder()),
                      value: _selectedObat,
                      items: _masterObat.map((o) => DropdownMenuItem(value: o, child: Text('${o.namaObat} (Stok: ${o.stok})'))).toList(),
                      onChanged: (val) => setState(() => _selectedObat = val),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _jumlahObatCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: _tambahObatKeResep, child: Icon(Icons.add))
                ],
              ),
              SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _resepList.length,
                itemBuilder: (context, index) {
                  final r = _resepList[index];
                  return Card(
                    child: ListTile(
                      title: Text(r.obat?.namaObat ?? 'Obat ID: ${r.obatId}'),
                      subtitle: Text('${r.jumlah} x Rp ${r.hargaSatuan.toStringAsFixed(0)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Rp ${r.subtotal.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _hapusResep(index))
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Total Biaya Obat: Rp ${_hitungTotalObat().toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: _isSaving ? null : _simpanPemeriksaan,
                  child: _isSaving ? CircularProgressIndicator(color: Colors.white) : Text('SIMPAN PEMERIKSAAN & CETAK STRUK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
