import 'dart:io';
import 'package:aplikasi_edesa/home/permohonan_view.dart';
import 'package:aplikasi_edesa/umkm/umkmKatalog_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

//page
import 'package:aplikasi_edesa/home/home_view.dart';
import 'package:aplikasi_edesa/home/profile_view.dart';
import 'package:aplikasi_edesa/umkm/umkmList_view.dart';

class umkmFormKatalog extends StatefulWidget {
  int index;
  var token;
  final nik;
  final idUMKM;
  final kodeKecamatan;
  final kodeDusun;
  final kodeDesa;
  umkmFormKatalog(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.idUMKM,
      required this.kodeDesa,
      required this.kodeDusun,
      required this.kodeKecamatan})
      : super(key: key);
  @override
  _umkmFormKatalogState createState() => _umkmFormKatalogState(
      index: index,
      nik: nik,
      token: token,
      idUMKM: idUMKM,
      kodeDesa: kodeDesa,
      kodeDusun: kodeDusun,
      kodeKecamatan: kodeKecamatan);
}

class _umkmFormKatalogState extends State<umkmFormKatalog> {
  _umkmFormKatalogState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.idUMKM,
      required this.kodeDesa,
      required this.kodeDusun,
      required this.kodeKecamatan});

  TextEditingController namaKatalog = new TextEditingController();
  TextEditingController harga = new TextEditingController();

  TextEditingController search = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final String nik;
  final String idUMKM;
  final String token;
  final String kodeDesa;
  final String kodeDusun;
  final String kodeKecamatan;

  String? jabatan;
  int index;
  List? dataUMKM;

  // variable untuk dropdown
  var wargaValue;
  var kategoriValue;
  List wargaList = [];
  List kategoriList = [];

  void initState() {
    super.initState();
    this.getFromSharedPreferences();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  // function
  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jabatan = prefs.getString("jabatan");
    });
  }

  //API
  Future<String> tambahUMKMKatalog() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/TambahUMKMKatalog'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'idUMKM': idUMKM,
        'namaKatalog': namaKatalog.text,
        'harga': harga.text,
      }),
    );

    if (response.statusCode == 200) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
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
        desc: 'Data terbaru Katalog berhasil di tambah',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
      return "Success!";
    } else {
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
        title: 'Proses gagal',
        desc: 'Data Katalog sudah terdaftar, silahkan coba kembali',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
      return "Gagal";
    }
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
        title: Text(
          "Penambahan Katalog UMKM",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.left,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: namaKatalog,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: 'Nama Katalog',
                      hintText: 'Masukkan Nama Katalog'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Nama Katalog Tidak Boleh Kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: harga,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: 'Harga Katalog',
                      hintText: 'Masukkan Harga Katalog'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Harga Katalog Tidak Boleh Kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                Container(
                  width: 500,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    child: Text(
                      "Tambah",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      tambahUMKMKatalog();
                    },
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  width: 500,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    child: Text(
                      "Daftar Katalog",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UMKMKatalog(
                                    index: index,
                                    nik: nik,
                                    token: token,
                                    idUMKM: idUMKM,
                                    kodeDesa: kodeDesa,
                                    kodeDusun: kodeDusun,
                                    kodeKecamatan: kodeKecamatan,
                                  )));
                    },
                  ),
                )
              ],
            ))
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
