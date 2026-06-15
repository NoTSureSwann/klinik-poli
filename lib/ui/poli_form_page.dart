import 'package:flutter/material.dart';
import 'package:klinik_app/ui/poli_detail_page.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import '../helpers/validators.dart';

class PoliForm extends StatefulWidget {
  const PoliForm({super.key});

  @override
  State<PoliForm> createState() => _PoliFormState();
}

class _PoliFormState extends State<PoliForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPoliCtrl = TextEditingController();
  final _kodePoliCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _kuotaCtrl = TextEditingController(text: '30');
  bool _statusAktif = true;

  @override
  void initState() {
    super.initState();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Poli")),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Form(autovalidateMode: AutovalidateMode.onUserInteraction, 
            key: _formKey,
            child: Column(
              children: [
                _wTextField(
                    namaField: "Nama Poli", 
                    namaController: _namaPoliCtrl, 
                    namaIcon: Icons.room_preferences_rounded,
                    validator: requiredValidator),
                SizedBox(height: 10),
                _wTextField(
                    namaField: "Kode Poli", 
                    namaController: _kodePoliCtrl, 
                    namaIcon: Icons.code,
                    validator: kodePoliValidator),
                SizedBox(height: 10),
                _wTextField(
                    namaField: "Deskripsi", 
                    namaController: _deskripsiCtrl, 
                    namaIcon: Icons.description,
                    maxLength: 200),
                SizedBox(height: 10),
                _wTextField(
                    namaField: "Kuota Harian", 
                    namaController: _kuotaCtrl, 
                    namaIcon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                    validator: (v) => positiveIntValidator(v, label: 'Kuota Harian')),
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
            )
          ),
        ),
      ),
    );
  }

  Widget _wTextField({
    required String namaField, 
    required TextEditingController namaController, 
    required IconData namaIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLength,
  }){
    return TextFormField(
      decoration: InputDecoration(
        labelText: namaField,
        prefixIcon: Icon(namaIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)
        ),
      ),
      controller: namaController,
      validator: validator,
      keyboardType: keyboardType,
      maxLength: maxLength,
    );
  }

  Widget _wTombolSimpan(){
    return ElevatedButton(
      onPressed: () async {
        if (!_formKey.currentState!.validate()) return;

        final kode = _kodePoliCtrl.text.trim();
        final isUnique = await PoliService().isKodePoliUnique(kode);
        if (!isUnique) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Kode Poli sudah digunakan poli lain"))
          );
          return;
        }

        Poli poli = Poli(
            nm_poli: _namaPoliCtrl.text.trim(),
            kode_poli: kode,
            deskripsi_poli: _deskripsiCtrl.text.trim(),
            kuota_harian: int.parse(_kuotaCtrl.text.trim()),
            status_aktif: _statusAktif,
        );
        await PoliService().addPoli(poli).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder:
                  (context) => PoliDetailPage(poli: poli)));
        });
      },
      child: Text("Simpan")
    );
  }
}
