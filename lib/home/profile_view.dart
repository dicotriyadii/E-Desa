import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
//page
import 'package:aplikasi_edesa/home/home_view.dart';
import 'package:aplikasi_edesa/home/permohonan_view.dart';
import 'package:aplikasi_edesa/umkm/umkm_form.dart';
import 'package:aplikasi_edesa/umkm/umkm_formKatalog.dart';
import 'package:aplikasi_edesa/login_page.dart';

class Profile extends StatefulWidget {
  int index;
  final token;
  final nik;
  final kodeKecamatan;
  final kodeDusun;
  final kodeDesa;
  Profile(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeKecamatan,
      required this.kodeDesa,
      required this.kodeDusun})
      : super(key: key);
  @override
  _ProfileState createState() => _ProfileState(
      index: index,
      nik: nik,
      token: token,
      kodeKecamatan: kodeKecamatan,
      kodeDesa: kodeDesa,
      kodeDusun: kodeDusun);
}

class _ProfileState extends State<Profile> {
  _ProfileState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeKecamatan,
      required this.kodeDesa,
      required this.kodeDusun});
  final String nik;
  TextEditingController pass = new TextEditingController();
  int index;
  List? data;
  final String token;
  final String kodeDusun;
  final String kodeDesa;
  final String kodeKecamatan;
  String? jabatan;
  String? hakAkses;
  String? namaWarga;
  String? UMKM;
  String? idUMKM;

  void initState() {
    // this.getUser();
    super.initState();
    this.getFromSharedPreferences();
  }

  Future<String> gantiPassword() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/GantiPassword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'nik': nik, 'token': token, 'pass': pass.text}),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      notifikasiGagal(context);
      return "Gagal";
    }
  }

  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hakAkses = prefs.getString("hakAkses");
      namaWarga = prefs.getString("namaWarga");
      UMKM = prefs.getString("UMKM");
      idUMKM = prefs.getString("idUMKM");
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

    final gambar = Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "assets/images/logoEdesa.png",
          width: 200,
          height: 200,
        ),
      ],
    ));

    final profileWarga = Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 20),
        if (hakAkses == 'pemerintahDesa')
          Container(
            width: 790,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffF18265),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => umkmForm(
                              index: index,
                              nik: nik,
                              token: token,
                              kodeDesa: kodeDesa,
                              kodeDusun: kodeDusun,
                              kodeKecamatan: kodeKecamatan,
                            )));
              },
              child: Text(
                'UMKM',
                style: TextStyle(
                  color: Color(0xffffffff),
                ),
              ),
            ),
          ),
        SizedBox(height: 20),
        if (UMKM == "ada")
          Container(
            width: 790,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffF18265),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => umkmFormKatalog(
                              index: index,
                              nik: nik,
                              token: token,
                              idUMKM: idUMKM,
                              kodeDesa: kodeDesa,
                              kodeDusun: kodeDusun,
                              kodeKecamatan: kodeKecamatan,
                            )));
              },
              child: Text(
                'Tambah Katalog UMKM',
                style: TextStyle(
                  color: Color(0xffffffff),
                ),
              ),
            ),
          ),
        SizedBox(height: 20),
        Container(
          width: 790,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffF18265),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
            onPressed: () {
              formGantiPassword(context);
            },
            child: Text(
              'Ganti Password',
              style: TextStyle(
                color: Color(0xffffffff),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: 790,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffF18265),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Keluar',
              style: TextStyle(
                color: Color(0xffffffff),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
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
        title: Text(
          'Kembali',
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
          children: <Widget>[gambar, profileWarga],
        ),
      ),
      bottomNavigationBar: _bottomNavBar,
    );
  }

  void formGantiPassword(context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Silahkan Masukkan Password Baru",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              child: TextFormField(
                controller: pass,
                decoration: InputDecoration(
                  hintText: 'Masukkan Password',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              child: ElevatedButton(
                child: Text(
                  "Ganti Password",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  gantiPassword();
                },
              ),
            )
          ],
        );
      },
    );
  }

  void notifikasiBerhasil(context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Password berhasil dirubah",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              child: ElevatedButton(
                child: Text(
                  "Tutup Notifikasi",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              index: 0,
                              nik: nik,
                              kodeDesa: kodeDesa,
                              kodeDusun: kodeDusun,
                              kodeKecamatan: kodeKecamatan,
                            )),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  void notifikasiGagal(context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "password gagal di ganti",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                child: ElevatedButton(
                  child: Text(
                    "Tutup Notifikasi",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          );
        });
  }
}
