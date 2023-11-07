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

class ibuHamil extends StatefulWidget {
  int index;
  final token;
  final nik;
  final kodeDusun;
  final kodeKecamatan;
  final kodeDesa;
  ibuHamil(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDesa,
      required this.kodeKecamatan,
      required this.kodeDusun})
      : super(key: key);
  @override
  _ibuHamilState createState() => _ibuHamilState(
      index: index,
      nik: nik,
      token: token,
      kodeDesa: kodeDesa,
      kodeDusun: kodeDusun,
      kodeKecamatan: kodeKecamatan);
}

class _ibuHamilState extends State<ibuHamil> {
  _ibuHamilState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDesa,
      required this.kodeDusun,
      required this.kodeKecamatan});
  TextEditingController noAkte = new TextEditingController();
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
    this.dataIbuHamil();
    this.getFromSharedPreferences();
  }

  //API
  Future<String> dataIbuHamil() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/DataStatusIbu'),
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
                  builder: (context) => ibuHamil(
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

  Future<String> perubahanAkteKelahiran(String id) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/CatatanStatusIbuEditAkte'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'id': id,
        'noAkte': noAkte.text
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
        desc: 'Akte kelahiran berhasil di perbarui',
        showCloseIcon: true,
        btnCancelOnPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ibuHamil(
                        index: index,
                        nik: nik,
                        token: token,
                        kodeDesa: kodeDesa,
                        kodeDusun: kodeDusun,
                        kodeKecamatan: kodeKecamatan,
                      )));
        },
        btnOkOnPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ibuHamil(
                        index: index,
                        nik: nik,
                        token: token,
                        kodeDesa: kodeDesa,
                        kodeDusun: kodeDusun,
                        kodeKecamatan: kodeKecamatan,
                      )));
        },
      ).show();
      return "Success!";
    } else {
      // notifikasiGagal(context);
      return "Gagal";
    }
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
              'Data Ibu Hamil ',
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
                  'CATATAN IBU DENGAN BAYI LAHIR',
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
                Container(
                  child: Column(
                    children: <Widget>[
                      if (data?[index]['akte'] == "0")
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 20,
                              child: FittedBox(child: Icon(Icons.person)),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              color: Theme.of(context).errorColor,
                              onPressed: () {
                                formUpdateAkte(data?[index]['id']);
                              },
                            ),
                            contentPadding: EdgeInsets.all(15),
                            title: Text(
                              data?[index]['nama_ibu'],
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
                                        Text('Nama Suami : '),
                                        Text(data?[index]['nama_suami']),
                                      ]),
                                    ),
                                    Container(
                                      child: Row(children: <Widget>[
                                        Text('Status Bayi : '),
                                        Text(
                                            data?[index]['catatan_status_ibu']),
                                      ]),
                                    ),
                                    Container(
                                      child: Row(children: <Widget>[
                                        Text('Akte Kelahiran : '),
                                        Text(data?[index]['akte']),
                                      ]),
                                    ),
                                    SizedBox(height: 10),
                                  ]),
                            ),
                          ),
                        ),
                      if (data?[index]['akte'] != "0")
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 20,
                              child: FittedBox(child: Icon(Icons.person)),
                            ),
                            contentPadding: EdgeInsets.all(15),
                            title: Text(
                              data?[index]['nama_ibu'],
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
                                        Text('Nama Suami : '),
                                        Text(data?[index]['nama_suami']),
                                      ]),
                                    ),
                                    Container(
                                      child: Row(children: <Widget>[
                                        Text('Status Bayi : '),
                                        Text(
                                            data?[index]['catatan_status_ibu']),
                                      ]),
                                    ),
                                    Container(
                                      child: Row(children: <Widget>[
                                        Text('Akte Kelahiran : '),
                                        Text(data?[index]['akte']),
                                      ]),
                                    ),
                                    SizedBox(height: 10),
                                  ]),
                            ),
                          ),
                        ),
                    ],
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

  void formUpdateAkte(id) {
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
                      "Silahkan Masukkan Akte Kelahiran",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              child: TextFormField(
                controller: noAkte,
                keyboardType: TextInputType.visiblePassword,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Masukkan AKte Kelahiran',
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
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  perubahanAkteKelahiran(id);
                },
              ),
            )
          ],
        );
      },
    );
  }
}
