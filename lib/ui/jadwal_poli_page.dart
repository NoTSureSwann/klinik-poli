import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../model/jadwal_poli.dart';
import '../model/pegawai.dart';
import '../service/jadwal_poli_service.dart';
import '../service/poli_service.dart';
import '../service/pegawai_service.dart';
import 'jadwal_poli_item_page.dart';
import 'jadwal_poli_form_page.dart';

class JadwalPoliPage extends StatefulWidget {
  final Poli? poliFilter;
  const JadwalPoliPage({super.key, this.poliFilter});

  @override
  State<JadwalPoliPage> createState() => _JadwalPoliPageState();
}

class _JadwalPoliPageState extends State<JadwalPoliPage> {
  final _jadwalService = JadwalPoliService();
  final _poliService = PoliService();
  final _pegawaiService = PegawaiService();

  Map<String, String> _poliMap = {};
  Map<String, String> _pegawaiMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poliFilter != null ? "Jadwal Poli ${widget.poliFilter!.nm_poli ?? ''}" : "Jadwal Poli"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JadwalPoliFormPage(poliFilter: widget.poliFilter))
              );
            },
          )
        ],
      ),
      body: StreamBuilder<List<Poli>>(
        stream: _poliService.streamPoli(),
        builder: (context, poliSnap) {
          if (poliSnap.hasData) {
            _poliMap = {for (var p in poliSnap.data!) p.id!: p.nm_poli ?? ''};
          }

          return StreamBuilder<List<Pegawai>>(
            stream: _pegawaiService.streamPegawai(),
            builder: (context, pegawaiSnap) {
              if (pegawaiSnap.hasData) {
                _pegawaiMap = {for (var p in pegawaiSnap.data!) p.id!: p.namaPegawai ?? ''};
              }

              return StreamBuilder<List<JadwalPoli>>(
                stream: _jadwalService.streamJadwal(),
                builder: (context, jadwalSnap) {
                  if (jadwalSnap.hasError) {
                    return Center(child: Text("Terjadi kesalahan: ${jadwalSnap.error}"));
                  }
                  if (!jadwalSnap.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var jadwalList = jadwalSnap.data!;
                  if (widget.poliFilter != null) {
                    jadwalList = jadwalList.where((j) => j.poliId == widget.poliFilter!.id).toList();
                  }

                  if (jadwalList.isEmpty) {
                    return Center(child: Text("Belum ada jadwal poli."));
                  }

                  return ListView.builder(
                    itemCount: jadwalList.length,
                    itemBuilder: (context, index) {
                      final jadwal = jadwalList[index];
                      final nmPoli = _poliMap[jadwal.poliId] ?? '-';
                      final nmDokter = _pegawaiMap[jadwal.pegawaiId] ?? '-';

                      return Dismissible(
                        key: Key(jadwal.id!),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Konfirmasi Hapus"),
                                content: const Text("Yakin ingin menghapus jadwal ini?"),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Batal"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Hapus"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          _jadwalService.deleteJadwal(jadwal.id!);
                        },
                        child: JadwalPoliItemPage(jadwal: jadwal, namaPoli: nmPoli, namaDokter: nmDokter),
                      );
                    },
                  );
                }
              );
            }
          );
        }
      ),
    );
  }
}
