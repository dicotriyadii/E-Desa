import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

//page
import 'package:aplikasi_edesa/home/home_view.dart';
import 'package:aplikasi_edesa/umkm/umkmList_view.dart';
import 'package:aplikasi_edesa/home/profile_view.dart';
import 'package:aplikasi_edesa/home/permohonan_view.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma.dart';

class HomePage extends StatefulWidget {
  int index;
  var token;
  var kodeDesa;
  var kodeKecamatan;
  var kodeDusun;
  var jabatan;
  final String nik;
  HomePage({
    Key? key,
    required this.index,
    required this.nik,
    required this.kodeKecamatan,
    required this.kodeDesa,
    required this.kodeDusun,
  }) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState(
      index: index,
      nik: nik,
      kodeKecamatan: kodeKecamatan,
      kodeDesa: kodeDesa,
      kodeDusun: kodeDusun);
}

class _HomePageState extends State<HomePage> {
  _HomePageState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.kodeKecamatan,
      required this.kodeDesa,
      required this.kodeDusun});
  // inisialisasi variable
  final String nik;
  final String kodeDesa;
  final String kodeKecamatan;
  final String kodeDusun;
  var token;
  var namaDesa;
  var hakAkses;
  var namaWarga;
  var jabatan;
  var UMKM;
  int index;
  List? dataPermohonan;

  // function dan API
  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token");
      hakAkses = prefs.getString("hakAkses");
      namaDesa = prefs.getString("namaDesa");
      namaWarga = prefs.getString("namaWarga");
      jabatan = prefs.getString("jabatan");
      UMKM = prefs.getString("UMKM");
    });
  }

  // API Untuk Permohonan Surat
  Future<String> permohonanBelumMenikah(
      String nikController, String token) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PermohonanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'idJenisSurat': "2",
        'token': token,
        'kodeDesa': kodeDesa,
        'kodeKecamatan': kodeKecamatan
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      notifikasiGagal(context);
      return "Gagal";
    }
  }

  Future<String> permohonanBerkelakuanBaik(
      String nikController, String token) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PermohonanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'idJenisSurat': "5",
        'token': token,
        'kodeDesa': kodeDesa,
        'kodeKecamatan': kodeKecamatan
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      notifikasiGagal(context);
      return "Gagal";
    }
  }

  Future<String> permohonanDomisili(String nikController, String token) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PermohonanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'idJenisSurat': "1",
        'token': token,
        'kodeDesa': kodeDesa,
        'kodeKecamatan': kodeKecamatan
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      notifikasiGagal(context);
      return "Gagal";
    }
  }

  Future<String> permohonanBedaNamaKK(
      String nikController, String token) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PermohonanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'idJenisSurat': "7",
        'token': token,
        'kodeDesa': kodeDesa,
        'kodeKecamatan': kodeKecamatan
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      notifikasiGagal(context);
      return "Gagal";
    }
  }

  Future<String> permohonanNikah(String nikController, String token) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PermohonanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'idJenisSurat': "4",
        'token': token,
        'kodeDesa': kodeDesa,
        'kodeKecamatan': kodeKecamatan
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      notifikasiGagal(context);
      return "Gagal";
    }
  }

  Future<String> permohonanTanah(String nikController, String token) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PermohonanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'idJenisSurat': "8",
        'token': token,
        'kodeDesa': kodeDesa,
        'kodeKecamatan': kodeKecamatan
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      notifikasiGagal(context);
      return "Gagal";
    }
  }

  Future<String> permohonanTidakMampu(
      String nikController, String token) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PermohonanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'idJenisSurat': "6",
        'token': token,
        'kodeDesa': kodeDesa,
        'kodeKecamatan': kodeKecamatan
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      notifikasiGagal(context);
      return "Gagal";
    }
  }

  Future<String> permohonanUsaha(String nikController, String token) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PermohonanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'idJenisSurat': "3",
        'token': token,
        'kodeDesa': kodeDesa,
        'kodeKecamatan': kodeKecamatan
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      notifikasiGagal(context);
      return "Gagal";
    }
  }

  // Kegunaan untuk button
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  void _onNavBarTapped(int index) {
    setState(() {
      if (index == 1) {
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

    //menginisialisasi material
    final _bottomNavBar = BottomNavigationBar(
      items: _bottomNavbarItems,
      currentIndex: index,
      selectedItemColor: Colors.green[600],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: _onNavBarTapped,
    );

    final header = Container(
        height: 70,
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(50))),
        child: Center(
            child: Row(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 10, left: 10),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/logoKabupaten.png",
                      width: 50,
                      height: 50,
                    ),
                  ],
                )),
            Container(
              margin: EdgeInsets.only(top: 15),
              padding: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Selamat datang di Aplikasi E Desa',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'powered by : superApps',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        )));

    final judul = Container(
        padding: EdgeInsets.only(bottom: 20, top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Layanan Permohonan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            Text(
              'Desa ' + namaDesa,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ],
        ));

    //pemanggilan material
    return Scaffold(
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            header,
            Card(
              margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
              child: ListTile(
                leading: Icon(
                  Icons.account_box_rounded,
                  size: 50,
                  color: Colors.green,
                ),
                title: Text(nik + " | " + namaWarga),
                subtitle: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (hakAkses == "warga" && UMKM == "tidak ada")
                        Text("Status : " + hakAkses),
                      if (hakAkses == "warga" && UMKM == "ada")
                        Text("Status : " + hakAkses + " | UMKM"),
                      if (hakAkses != "warga")
                        Text("Status : " + hakAkses + " | " + jabatan)
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: <Widget>[
                  //Column menu
                  judul,
                  // menu baris pertama
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  permohonanBelumMenikah(nik, token);
                                },
                                child: Icon(
                                  Icons.file_copy,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Belum Menikah'),
                            ],
                          ),
                        ),
                        Container(
                          width: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  permohonanBerkelakuanBaik(nik, token);
                                },
                                child: Icon(
                                  Icons.file_copy,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Berkelakuan Baik'),
                            ],
                          ),
                        ),
                        Container(
                          width: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  permohonanTidakMampu(nik, token);
                                },
                                child: Icon(
                                  Icons.file_copy,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Tidak Mampu'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  permohonanUsaha(nik, token);
                                },
                                child: Icon(
                                  Icons.file_copy,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Usaha'),
                            ],
                          ),
                        ),
                        Container(
                          width: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  permohonanBedaNamaKK(nik, token);
                                },
                                child: Icon(
                                  Icons.file_copy,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Beda Nama'),
                            ],
                          ),
                        ),
                        Container(
                          width: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  permohonanDomisili(nik, token);
                                },
                                child: Icon(
                                  Icons.file_copy,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Domisili'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  permohonanNikah(nik, token);
                                },
                                child: Icon(
                                  Icons.file_copy,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Nikah'),
                            ],
                          ),
                        ),
                        Container(
                          width: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  permohonanTanah(nik, token);
                                },
                                child: Icon(
                                  Icons.file_copy,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Tanah'),
                            ],
                          ),
                        ),
                        Container(
                          width: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
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
                                child: Icon(
                                  Icons.shopping_bag_sharp,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('UMKM'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (hakAkses == "dasawisma")
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => dasawisma(
                                                  index: index,
                                                  nik: nik,
                                                  token: token,
                                                  kodeDesa: kodeDesa,
                                                  kodeDusun: kodeDusun,
                                                  kodeKecamatan: kodeKecamatan,
                                                )));
                                  },
                                  child: Icon(
                                    Icons.group,
                                    size: 30,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text('Dasawisma'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavBar,
    );
  }

  // Fungsi Notifikasi
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
                      "Permohonan Surat Anda Sudah Masuk Ke Dalam Sistem Desa",
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
                      "Anda Sedang dalam permohonan surat, silahkan hubungi admin desa",
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
      },
    );
  }

  void initState() {
    super.initState();
    this.getFromSharedPreferences();
  }
}
