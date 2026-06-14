import 'package:flutter/material.dart';
import 'package:klinik_app/ui/pegawai_item_page.dart';
import 'package:klinik_app/ui/pegawai_form_page.dart';
import 'package:klinik_app/widget/sidebar.dart';

import '../model/pegawai.dart';
import '../service/pegawai_service.dart';

class PegawaiPage extends StatefulWidget {
  PegawaiPage({super.key});

  @override
  State<PegawaiPage> createState() => _PegawaiPageState();
}

class _PegawaiPageState extends State<PegawaiPage> {
  PegawaiService _pegawaiService = PegawaiService();
  Future<List<Pegawai>>? _pegawaiList;
  List<Pegawai>? _retrievedPegawaiList;

  Future<void> _initRetrieval() async {
    _pegawaiList = _pegawaiService.retrievePegawai();
    _retrievedPegawaiList = await _pegawaiService.retrievePegawai();
  }

  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  Future refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _initRetrieval();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(
        title: Text("Data Pegawai", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        leading: Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }
        ),
        actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.add, color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => 	PegawaiForm()));
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: FutureBuilder(
            future: _pegawaiList,
            builder: (BuildContext context, AsyncSnapshot<List<Pegawai>> snapshot) {
              if(!snapshot.hasData){
                return Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                  itemCount: _retrievedPegawaiList!.length,
                  itemBuilder: (context, index){
                    var pegawai = _retrievedPegawaiList![index];
                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.delete, color: Colors.white,),
                      ),
                      onDismissed: (direction){
                        _pegawaiService.deletePegawai(pegawai.id!);
                      },
                      direction: DismissDirection.endToStart,
                      child: PegawaiItemPage(pegawai: pegawai),
                    );
                  }
              );
            }
        ),
      ),
    );
  }
}
