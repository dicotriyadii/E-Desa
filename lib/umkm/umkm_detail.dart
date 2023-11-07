import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

//page
import 'package:aplikasi_edesa/home/permohonan_view.dart';
import 'package:aplikasi_edesa/home/home_view.dart';
import 'package:aplikasi_edesa/home/profile_view.dart';
import 'package:aplikasi_edesa/umkm/umkmList_view.dart';
import 'package:aplikasi_edesa/umkm/umkmKatalog_view.dart';

class umkmDetail extends StatefulWidget {
  int index;
  var token;
  final nik;
  final idUMKM;
  final kodeDesa;
  final kodeDusun;
  final kodeKecamatan;
  umkmDetail(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.idUMKM,
      required this.kodeKecamatan,
      required this.kodeDesa,
      required this.kodeDusun})
      : super(key: key);
  @override
  _umkmDetailState createState() => _umkmDetailState(
      index: index,
      nik: nik,
      token: token,
      idUMKM: idUMKM,
      kodeKecamatan: kodeKecamatan,
      kodeDesa: kodeDesa,
      kodeDusun: kodeDusun);
}

class _umkmDetailState extends State<umkmDetail> {
  _umkmDetailState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.idUMKM,
      required this.kodeKecamatan,
      required this.kodeDesa,
      required this.kodeDusun});

  TextEditingController namaUMKM = new TextEditingController();
  TextEditingController alamatUMKM = new TextEditingController();
  TextEditingController search = TextEditingController();
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final String nik;
  final String token;
  final String idUMKM;
  final String kodeKecamatan;
  final String kodeDesa;
  final String kodeDusun;
  String? jabatan;
  int index;
  List? data;

  // variable untuk dropdown
  var wargaValue;
  var kategoriValue;
  List wargaList = [];
  List kategoriList = [];

  void initState() {
    super.initState();
    this.getFromSharedPreferences();
    this.detailUMKM();
  }

  final snackBar = SnackBar(
    content: Text('Yay ! Snack Bar !'),
    action: SnackBarAction(
      label: "undo",
      onPressed: () {},
    ),
  );

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

  Future<String> detailUMKM() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/DetailUMKM'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'nik': nik, 'token': token, 'idUMKM': idUMKM}),
    );
    setState(() {
      var resBody = json.decode(response.body);
      data = resBody;
    });
    if (response.statusCode == 200) {
      setState(() {
        loading = true;
      });
    } else {
      await Future.delayed(const Duration(seconds: 10));
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
        btnCancelOnPress: () {
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
        btnOkOnPress: () {},
      ).show();
    }
    return "Succses !";
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
                  "Detail UMKM",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          )),
      body: Container(
        child: ListView(
          children: [
            if (loading == true)
              Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(15),
                          title: Text(
                            data?[0]['namaUMKM'],
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Pemilik UMKM : ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(data?[0]['namaWarga']),
                                        ]),
                                  ),
                                  Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Kategori : ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(data?[0]['kategori']),
                                        ]),
                                  ),
                                  Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Alamat : ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(data?[0]['alamatUMKM']),
                                        ]),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          UMKMKatalog(
                                                            index: 0,
                                                            nik: nik,
                                                            idUMKM: idUMKM,
                                                            token: token,
                                                            kodeDesa: kodeDesa,
                                                            kodeDusun:
                                                                kodeDusun,
                                                            kodeKecamatan:
                                                                kodeKecamatan,
                                                          )),
                                                );
                                              },
                                              child: const Text('Katalog UMKM'),
                                            ),
                                          ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ],
                  ))
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
