import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
//page
import 'package:aplikasi_edesa/home/home_view.dart';
import 'package:aplikasi_edesa/home/permohonan_view.dart';

import 'package:aplikasi_edesa/home/profile_view.dart';
import 'package:aplikasi_edesa/login_page.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_ibu.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_keluarga.dart';

class dataKeluarga extends StatefulWidget {
  int index;
  final token;
  final nik;
  final kodeDesa;
  final kodeKecamatan;
  final kodeDusun;
  dataKeluarga(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDusun,
      required this.kodeDesa,
      required this.kodeKecamatan})
      : super(key: key);
  @override
  _dataKeluargaState createState() => _dataKeluargaState(
      index: index,
      nik: nik,
      token: token,
      kodeDesa: kodeDesa,
      kodeDusun: kodeDusun,
      kodeKecamatan: kodeKecamatan);
}

class _dataKeluargaState extends State<dataKeluarga> {
  _dataKeluargaState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDesa,
      required this.kodeKecamatan,
      required this.kodeDusun});
  final String nik;
  final String token;
  final String kodeDesa;
  final String kodeKecamatan;
  final String kodeDusun;
  bool loading = false;
  int index;
  List? data;
  String? jabatan;
  var namaDesa;

  void initState() {
    super.initState();
    this.dataCatatanKeluarga();
    this.getFromSharedPreferences();
  }

  //API
  Future<String> dataCatatanKeluarga() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/DataStatusKeluarga'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'nik': nik, 'token': token}),
    );
    if (response.statusCode == 200) {
      setState(() {
        var resBody = json.decode(response.body);
        data = resBody;
        loading = true;
      });
    } else if (response.statusCode == 201) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        loading = true;
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        borderSide: const BorderSide(
          color: Colors.green,
          width: 2,
        ),
        width: 280,
        buttonsBorderRadius: const BorderRadius.all(
          Radius.circular(2),
        ),
        headerAnimationLoop: false,
        animType: AnimType.bottomSlide,
        title: 'Proses Berhasil',
        desc: 'Mohon maaf data saat ini kosong',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        loading = true;
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        borderSide: const BorderSide(
          color: Colors.green,
          width: 2,
        ),
        width: 280,
        buttonsBorderRadius: const BorderRadius.all(
          Radius.circular(2),
        ),
        headerAnimationLoop: false,
        animType: AnimType.bottomSlide,
        title: 'Proses Gagal',
        desc: 'Mohon maaf data tidak bisa di proses, silahkan coba lagi',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => catatanKeluarga(
                        index: index,
                        nik: nik,
                        token: token,
                        kodeDesa: kodeDesa,
                        kodeDusun: kodeDusun,
                        kodeKecamatan: kodeKecamatan,
                      )));
        },
      ).show();
    }

    return "Succses !";
  }

  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jabatan = prefs.getString("jabatan");
      namaDesa = prefs.getString("namaDesa");
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      index: index,
                      nik: nik,
                      kodeDesa: kodeDesa,
                      kodeDusun: kodeDusun,
                      kodeKecamatan: kodeKecamatan,
                    )));
      } else if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Permohonan(
                      index: index,
                      nik: nik,
                      token: token,
                      kodeDesa: kodeDesa,
                      kodeDusun: kodeDusun,
                      kodeKecamatan: kodeKecamatan,
                    )));
      } else if (index == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profile(
                      index: index,
                      nik: nik,
                      token: token,
                      kodeDesa: kodeDesa,
                      kodeDusun: kodeDusun,
                      kodeKecamatan: kodeKecamatan,
                    )));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //bottom Navigasi
    final _bottomNavbarItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Beranda',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.safety_divider_outlined),
        label: 'Pelayanan',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    final _bottomNavBar = BottomNavigationBar(
      items: _bottomNavbarItems,
      currentIndex: index,
      selectedItemColor: Colors.green[600],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: _onNavBarTapped,
    );

    final header = Container(
        padding: EdgeInsets.only(bottom: 5),
        child: Column(
          children: <Widget>[
            Text(
              'Data Catatan Keluarga ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              namaDesa,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ));

    final gambar = Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "assets/images/logoEdesa.png",
          width: 150,
          height: 150,
        ),
      ],
    ));

    //pemanggilan material
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green[600],
          leading: IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if (loading == false)
                  Container(
                    child: Container(
                        child: LinearProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    )),
                  ),
                Text(
                  'DATA STATUS KELUARGA',
                ),
              ],
            ),
          )),
      body: ListView.builder(
        itemCount: data == null ? 0 : data?.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.all(10),
            alignment: Alignment.centerRight,
            child: Column(
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.account_tree,
                      size: 50,
                      color: Colors.green,
                    ),
                    contentPadding: EdgeInsets.all(15),
                    title: Text(
                      data?[index]['namaWarga'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Container(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Keadaan : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(data?[index]['berkebutuhan_khusus']),
                                  ]),
                            ),
                            SizedBox(height: 5),
                            Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Kriteria Rumah : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(data?[index]['jenis_kriteria_rumah']),
                                  ]),
                            ),
                            SizedBox(height: 5),
                            Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Sumber Air : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(data?[index]['jenis_sumber_air']),
                                  ]),
                            ),
                            SizedBox(height: 5),
                            Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Tempat Sampah : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(data?[index]['jenis_tempat_sampah']),
                                  ]),
                            ),
                            SizedBox(height: 5),
                            Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Nama Kegiatan : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(data?[index]['nama_kegiatan']),
                                  ]),
                            ),
                            SizedBox(height: 5),
                            Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Jenis Kegiatan : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(data?[index]['jenis_kegiatan']),
                                  ]),
                            ),
                            SizedBox(height: 5),
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
