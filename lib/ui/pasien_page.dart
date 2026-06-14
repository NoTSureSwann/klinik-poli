import 'package:flutter/material.dart';
import 'package:klinik_app/ui/pasien_form_page.dart';
import 'package:klinik_app/ui/pasien_item_page.dart';
import 'package:klinik_app/widget/sidebar.dart';

import '../model/pasien.dart';
import '../service/pasien_service.dart';

class PasienPage extends StatefulWidget {
  PasienPage({super.key});

  @override
  State<PasienPage> createState() => _PasienPageState();
}

class _PasienPageState extends State<PasienPage> {
  PasienService _pasienService = PasienService();
  Future<List<Pasien>>? _pasienList;
  List<Pasien>? _retrievedPasienList;

  Future<void> _initRetrieval() async {
    _pasienList = _pasienService.retrievePasien();
    _retrievedPasienList = await _pasienService.retrievePasien();
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
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;


    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(
        title: Text("Data Pasien", style: TextStyle(color: Colors.white),),
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
              padding: EdgeInsets.all(8*fem),
              child: Icon(Icons.add, color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => 	PasienForm()));
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: FutureBuilder(
            future: _pasienList,
            builder: (BuildContext context, AsyncSnapshot<List<Pasien>> snapshot) {
              if(!snapshot.hasData){
                return Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                  itemCount: _retrievedPasienList!.length,
                  itemBuilder: (context, index){
                    var pasien = _retrievedPasienList![index];
                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.delete, color: Colors.white,),
                      ),
                      onDismissed: (direction){
                        _pasienService.deletePasien(pasien.id!);
                      },
                      direction: DismissDirection.endToStart,
                      child: PasienItemPage(pasien: pasien),
                    );
                  }
              );
            }
        ),
      ),
    );
  }
}
