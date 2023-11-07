import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

//page
import 'package:aplikasi_edesa/home/home_view.dart';
import 'package:aplikasi_edesa/home/profile_view.dart';
import 'package:aplikasi_edesa/umkm/umkmList_view.dart';
import 'package:aplikasi_edesa/umkm/umkm_detail.dart';

import '../home/permohonan_view.dart';

class UMKMKatalog extends StatefulWidget {
  int index;
  var token;
  final nik;
  final idUMKM;
  final kodeDesa;
  final kodeDusun;
  final kodeKecamatan;
  UMKMKatalog(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.idUMKM,
      required this.kodeDusun,
      required this.kodeKecamatan,
      required this.kodeDesa})
      : super(key: key);
  @override
  _UMKMKatalogState createState() => _UMKMKatalogState(
      index: index,
      nik: nik,
      token: token,
      idUMKM: idUMKM,
      kodeDusun: kodeDusun,
      kodeDesa: kodeDesa,
      kodeKecamatan: kodeKecamatan);
}

class _UMKMKatalogState extends State<UMKMKatalog> {
  _UMKMKatalogState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.idUMKM,
      required this.kodeDesa,
      required this.kodeDusun,
      required this.kodeKecamatan});
  TextEditingController passphrase = new TextEditingController();
  final String nik;
  final String idUMKM;
  final String token;
  final String kodeDesa;
  final String kodeDusun;
  final String kodeKecamatan;
  String? jabatan;
  String? hakAkses;
  String? namaDesa;
  String? UMKM;
  int index;
  List? data;
  bool loading = false;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // function
  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jabatan = prefs.getString("jabatan");
      hakAkses = prefs.getString("hakAkses");
      namaDesa = prefs.getString("namaDesa");
      UMKM = prefs.getString("UMKM");
    });
  }

  //API
  Future<String> daftarKatalog() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/DataUMKMKatalog'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'nik': nik, 'token': token, 'idUMKM': idUMKM}),
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
                  builder: (context) => UMKMList(
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

  Future<String> hapusUMKM(idKatalog) async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/HapusKatalog'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'nik': nik, 'token': token, 'idKatalog': idKatalog}),
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
        desc: 'Data UMKM Berhasil di Hapus',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
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
      ).show();
      return "Succses !";
    } else {
      return "Succses !";
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
                  "Katalog UMKM",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.left,
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
                      Icons.shopping_bag,
                      size: 50,
                      color: Colors.green,
                    ),
                    trailing: Container(
                      child: Column(children: <Widget>[
                        if (UMKM == "ada")
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Theme.of(context).errorColor,
                            onPressed: () {
                              hapusUMKM(data?[index]['idKatalog']);
                            },
                          ),
                      ]),
                    ),
                    contentPadding: EdgeInsets.all(15),
                    title: Text(
                      data?[index]['namaKatalog'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Harga : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(data?[index]['harga']),
                                  ]),
                            ),
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

  @override
  void initState() {
    super.initState();
    this.getFromSharedPreferences();
    this.daftarKatalog();
  }
}
