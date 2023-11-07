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
import 'package:aplikasi_edesa/dasawisma/dasawisma_anggotaDasawismaForm.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_keluarga.dart';

class anggotaDasawisma extends StatefulWidget {
  int index;
  final token;
  final nik;
  final kodeDesa;
  final kodeDusun;
  final kodeKecamatan;
  anggotaDasawisma(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDesa,
      required this.kodeDusun,
      required this.kodeKecamatan})
      : super(key: key);
  @override
  _anggotaDasawismaState createState() => _anggotaDasawismaState(
      index: index,
      nik: nik,
      token: token,
      kodeDesa: kodeDesa,
      kodeKecamatan: kodeKecamatan,
      kodeDusun: kodeDusun);
}

class _anggotaDasawismaState extends State<anggotaDasawisma> {
  _anggotaDasawismaState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDusun,
      required this.kodeDesa,
      required this.kodeKecamatan});
  final String nik;
  final String token;
  final String kodeDesa;
  final String kodeKecamatan;
  final String kodeDusun;
  int index;
  List? data;

  String? jabatan;
  String? hakAkses;
  var namaDesa;
  bool loading = false;

  void initState() {
    super.initState();
    this.getFromSharedPreferences();
    this.dataAnggotaDasawisma();
  }

  //API
  Future<String> dataAnggotaDasawisma() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/DataAnggotaDasawisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'kodeKecamatan': kodeKecamatan,
        'kodeDesa': kodeDesa,
        'kodeDusun': kodeDusun
      }),
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
      setState(() {
        loading = true;
      });
      await Future.delayed(const Duration(seconds: 1));
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
        desc: 'Mohon maaf, saat ini data kosong',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
    }
    return "Succses !";
  }

  Future<String> hapusAnggotaDaswisma(nikAnggota) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/HapusAnggotaDasawisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'nikAnggota': nikAnggota,
        'kodeKecamatan': kodeKecamatan,
        'kodeDesa': kodeDesa,
        'kodeDusun': kodeDusun
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Succses !";
    } else {
      return "Succses !";
    }
  }

  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jabatan = prefs.getString("jabatan");
      namaDesa = prefs.getString("namaDesa");
      hakAkses = prefs.getString("hakAkses");
      jabatan = prefs.getString("jabatan");
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
          actions: [
            if (jabatan == "Ketua")
              IconButton(
                  icon: new Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => anggotaDasawismaForm(
                                  index: index,
                                  nik: nik,
                                  token: token,
                                  kodeDesa: kodeDesa,
                                  kodeDusun: kodeDusun,
                                  kodeKecamatan: kodeKecamatan,
                                )));
                  }),
          ],
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
                  'Daftar Anggota Dasawisma',
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
                    leading: CircleAvatar(
                      radius: 20,
                      child: FittedBox(child: Icon(Icons.person)),
                    ),
                    trailing: Container(
                      child: Column(children: <Widget>[
                        if (jabatan == "Ketua")
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Theme.of(context).errorColor,
                            onPressed: () {
                              hapusAnggotaDaswisma(data?[index]['nik']);
                            },
                          ),
                      ]),
                    ),
                    contentPadding: EdgeInsets.all(15),
                    title: Text(
                      data?[index]['namaWarga'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
                              child: Row(children: <Widget>[
                                Text('Jabatan : '),
                                Text(data?[index]['jabatan']),
                              ]),
                            ),
                            Container(
                              child: Row(children: <Widget>[
                                Text('Jenis Kelamin : '),
                                Text(data?[index]['jenisKelamin']),
                              ]),
                            ),
                            Container(
                              child: Row(children: <Widget>[
                                Text('Dasawisma : '),
                                Text(data?[index]['nama_dasa_wisma']),
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
                      "Pengahusan Anggota Dasawisma berhasil",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Text(
                  "Tutup Notifikasi",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => anggotaDasawisma(
                                index: index,
                                nik: nik,
                                token: token,
                                kodeDesa: kodeDesa,
                                kodeDusun: kodeDusun,
                                kodeKecamatan: kodeKecamatan,
                              )));
                },
              ),
            )
          ],
        );
      },
    );
  }
}
