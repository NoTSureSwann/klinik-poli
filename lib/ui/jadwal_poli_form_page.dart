import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../model/pegawai.dart';
import '../model/jadwal_poli.dart';
import '../service/poli_service.dart';
import '../service/pegawai_service.dart';
import '../service/jadwal_poli_service.dart';
import '../helpers/date_helper.dart';
import '../helpers/validators.dart';
import '../helpers/queue_algorithm.dart';

class JadwalPoliFormPage extends StatefulWidget {
  final Poli? poliFilter;
  const JadwalPoliFormPage({super.key, this.poliFilter});

  @override
  State<JadwalPoliFormPage> createState() => _JadwalPoliFormPageState();
}

class _JadwalPoliFormPageState extends State<JadwalPoliFormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPoliId;
  String? _selectedDokterId;
  String? _selectedHari;

  final _jamMulaiCtrl = TextEditingController();
  final _jamSelesaiCtrl = TextEditingController();
  final _kuotaCtrl = TextEditingController(text: '10');
  bool _statusAktif = true;

  @override
  void initState() {
    super.initState();
    if (widget.poliFilter != null) {
      _selectedPoliId = widget.poliFilter!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Jadwal Poli")),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Form(autovalidateMode: AutovalidateMode.onUserInteraction, 
              key: _formKey,
              child: Column(
                children: [
                  _buildPoliDropdown(),
                  SizedBox(height: 10),
                  _buildDokterDropdown(),
                  SizedBox(height: 10),
                  _buildHariDropdown(),
                  SizedBox(height: 10),
                  _wTextField(
                      namaField: "Jam Mulai (HH:mm)",
                      namaController: _jamMulaiCtrl,
                      namaIcon: Icons.access_time,
                      validator: timeFormatValidator),
                  SizedBox(height: 10),
                  _wTextField(
                      namaField: "Jam Selesai (HH:mm)",
                      namaController: _jamSelesaiCtrl,
                      namaIcon: Icons.access_time_filled,
                      validator: timeFormatValidator),
                  SizedBox(height: 10),
                  _wTextField(
                      namaField: "Kuota",
                      namaController: _kuotaCtrl,
                      namaIcon: Icons.people,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          positiveIntValidator(v, label: 'Kuota')),
                  SizedBox(height: 10),
                  SwitchListTile(
                    title: Text("Status Aktif"),
                    value: _statusAktif,
                    onChanged: (val) {
                      setState(() {
                        _statusAktif = val;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  _wTombolSimpan()
                ],
              )),
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
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Pilih Poli",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            initialValue: _selectedPoliId,
            items: list
                .map((e) =>
                    DropdownMenuItem(value: e.id, child: Text(e.nm_poli ?? '')))
                .toList(),
            onChanged: widget.poliFilter != null
                ? null
                : (val) {
                    setState(() {
                      _selectedPoliId = val;
                    });
                  },
            validator: (v) => v == null ? 'Poli wajib dipilih' : null,
          );
        });
  }

  Widget _buildDokterDropdown() {
    return FutureBuilder<List<Pegawai>>(
        future: PegawaiService().retrieveDokter(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Pilih Dokter",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            initialValue: _selectedDokterId,
            items: snapshot.data!
                .map((e) => DropdownMenuItem(
                    value: e.id, child: Text(e.namaPegawai ?? '')))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedDokterId = val;
              });
            },
            validator: (v) => v == null ? 'Dokter wajib dipilih' : null,
          );
        });
  }

  Widget _buildHariDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Pilih Hari",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      initialValue: _selectedHari,
      items: daftarHari
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedHari = val;
        });
      },
      validator: (v) => v == null ? 'Hari wajib dipilih' : null,
    );
  }

  Widget _wTextField({
    required String namaField,
    required TextEditingController namaController,
    required IconData namaIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: namaField,
        prefixIcon: Icon(namaIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      controller: namaController,
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _wTombolSimpan() {
    return ElevatedButton(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;
          if (timeToMinutes(_jamSelesaiCtrl.text.trim()) <=
              timeToMinutes(_jamMulaiCtrl.text.trim())) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Jam selesai harus setelah jam mulai")));
            return;
          }

          JadwalPoli jadwalBaru = JadwalPoli(
            poliId: _selectedPoliId!,
            pegawaiId: _selectedDokterId!,
            hari: _selectedHari!,
            jamMulai: _jamMulaiCtrl.text.trim(),
            jamSelesai: _jamSelesaiCtrl.text.trim(),
            kuota: int.parse(_kuotaCtrl.text.trim()),
            statusAktif: _statusAktif,
          );

          final service = JadwalPoliService();
          final hasConflict = await service.hasConflict(jadwalBaru);
          if (hasConflict) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      content: Text(
                          "Jadwal bertabrakan dengan jadwal dokter ini di hari & jam yang sama (cek poli/jadwal lain milik dokter tersebut)."),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK"))
                      ],
                    ));
            return;
          }

          await service.addJadwal(jadwalBaru);
          Navigator.pop(context);
        },
        child: Text("Simpan"));
  }
}
