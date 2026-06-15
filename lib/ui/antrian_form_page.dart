import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../model/jadwal_poli.dart';
import '../model/pasien.dart';
import '../service/poli_service.dart';
import '../service/jadwal_poli_service.dart';
import '../service/pasien_service.dart';
import '../service/antrian_service.dart';
import '../helpers/date_helper.dart';

import 'layar_antrian_page.dart';

class AntrianFormPage extends StatefulWidget {
  const AntrianFormPage({super.key});

  @override
  State<AntrianFormPage> createState() => _AntrianFormPageState();
}

class _AntrianFormPageState extends State<AntrianFormPage> {
  Poli? _selectedPoli;
  JadwalPoli? _selectedJadwal;
  Pasien? _selectedPasien;
  bool _isPrioritas = false;

  final _searchCtrl = TextEditingController();
  List<Pasien> _allPasien = [];
  List<Pasien> _filteredPasien = [];
  bool _isLoadingJadwal = false;
  List<JadwalPoli> _jadwalList = [];

  @override
  void initState() {
    super.initState();
    _loadPasien();
  }

  Future<void> _loadPasien() async {
    final list = await PasienService().retrievePasien();
    setState(() {
      _allPasien = list;
    });
  }

  void _searchPasien() {
    final query = _searchCtrl.text;
    setState(() {
      _filteredPasien = _allPasien.where((p) {
        return (p.namaPasien ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (p.nomorRMPasien ?? '').toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _onPoliSelected(Poli poli) async {
    setState(() {
      _selectedPoli = poli;
      _selectedJadwal = null;
      _isLoadingJadwal = true;
    });
    final today = hariIni(DateTime.now());
    final list = await JadwalPoliService().retrieveJadwalAktif(poli.id!, today);
    setState(() {
      _jadwalList = list;
      _isLoadingJadwal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Antrian Baru")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPoliDropdown(),
              SizedBox(height: 15),
              if (_selectedPoli != null) _buildJadwalDropdown(),
              SizedBox(height: 15),
              _buildPasienSearch(),
              SizedBox(height: 15),
              SwitchListTile(
                title: Text("Pasien Prioritas (Lansia/Ibu Hamil/Disabilitas)"),
                value: _isPrioritas,
                onChanged: (val) {
                  setState(() {
                    _isPrioritas = val;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _daftarAntrian,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15)),
                child: Text("DAFTAR ANTRIAN", style: TextStyle(fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoliDropdown() {
    return StreamBuilder<List<Poli>>(
        stream: PoliService().streamPoli(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final list = snapshot.data!.where((p) => p.status_aktif).toList();
          return DropdownButtonFormField<Poli>(
            decoration: InputDecoration(
              labelText: "1. Pilih Poli",
              border: OutlineInputBorder(),
            ),
            initialValue: _selectedPoli,
            items: list
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e.nm_poli ?? '')))
                .toList(),
            onChanged: (val) {
              if (val != null) _onPoliSelected(val);
            },
          );
        });
  }

  Widget _buildJadwalDropdown() {
    if (_isLoadingJadwal) return CircularProgressIndicator();

    List<DropdownMenuItem<JadwalPoli?>> items = [
      DropdownMenuItem(
          value: null, child: Text("Walk-in / Tanpa Sesi Terjadwal"))
    ];

    for (var j in _jadwalList) {
      // In a real app we'd fetch Pegawai name, but since we can't do async inside map easily,
      // we'll just show the time. We can assume we pass Pegawai name if we mapped it, but let's keep it simple.
      items.add(DropdownMenuItem(
          value: j, child: Text("Sesi: ${j.jamMulai} - ${j.jamSelesai}")));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_jadwalList.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text("Tidak ada jadwal dokter untuk poli ini hari ini",
                style: TextStyle(color: Colors.red)),
          ),
        DropdownButtonFormField<JadwalPoli?>(
          decoration: InputDecoration(
            labelText: "2. Pilih Jadwal/Sesi",
            border: OutlineInputBorder(),
          ),
          initialValue: _selectedJadwal,
          items: items,
          onChanged: (val) {
            setState(() {
              _selectedJadwal = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPasienSearch() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text("3. Pilih Pasien",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(hintText: "Cari Nama / No RM"),
                )),
                IconButton(icon: Icon(Icons.search), onPressed: _searchPasien)
              ],
            ),
            if (_filteredPasien.isNotEmpty) ...[
              SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _filteredPasien.length,
                  itemBuilder: (context, index) {
                    final p = _filteredPasien[index];
                    return RadioListTile<Pasien>(
                      title: Text("${p.namaPasien} (${p.nomorRMPasien})"),
                      value: p,
                      groupValue: _selectedPasien,
                      onChanged: (val) {
                        setState(() {
                          _selectedPasien = val;
                        });
                      },
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _daftarAntrian() async {
    if (_selectedPoli == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Pilih poli terlebih dahulu")));
      return;
    }
    if (_selectedPasien == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pilih pasien terlebih dahulu")));
      return;
    }

    try {
      final tanggal = formatTanggal(DateTime.now());
      final nomor = await AntrianService().daftarAntrian(
        poli: _selectedPoli!,
        jadwal: _selectedJadwal,
        pasienId: _selectedPasien!.id!,
        tanggal: tanggal,
        prioritas: _isPrioritas,
      );

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title:
                    Text("Pendaftaran Berhasil", textAlign: TextAlign.center),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Nomor Antrian:"),
                    Text(nomor,
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                  ],
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context); // back to menu
                      },
                      child: Text("Tutup")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LayarAntrianPage()));
                      },
                      child: Text("Lihat Layar Antrian")),
                ],
              ));
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Gagal Mendaftar"),
                content: Text(e.toString().replaceAll("Exception: ", "")),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"))
                ],
              ));
    }
  }
}
