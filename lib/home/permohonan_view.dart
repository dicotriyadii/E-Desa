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

class Permohonan extends StatefulWidget {
  int index;
  var token;
  final nik;
  final kodeDesa;
  final kodeKecamatan;
  final kodeDusun;
  Permohonan(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDesa,
      required this.kodeKecamatan,
      required this.kodeDusun})
      : super(key: key);
  @override
  _PermohonanState createState() => _PermohonanState(
      index: index,
      nik: nik,
      token: token,
      kodeDesa: kodeDesa,
      kodeKecamatan: kodeKecamatan,
      kodeDusun: kodeDusun);
}

class _PermohonanState extends State<Permohonan> {
  _PermohonanState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeKecamatan,
      required this.kodeDesa,
      required this.kodeDusun});
  TextEditingController passphrase = new TextEditingController();
  final String nik;
  final String token;
  final String kodeKecamatan;
  final String kodeDesa;
  final String kodeDusun;
  String? jabatan;
  String? hakAkses;
  int index;
  List? data;
  List? statusTTE;
  bool passwordVisible = false;
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
    });
  }

  //API
  Future<String> daftarPermohonan() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/DaftarPermohonan'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'kodeDesa': kodeDesa,
        'kodeKecamatan': kodeKecamatan
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        var resBody = json.decode(response.body);
        data = resBody;
        if (jabatan != "kepala desa") loading = true;
      });
    } else if (response.statusCode == 201) {
      setState(() {
        if (jabatan != "kepala desa") loading = true;
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
        desc: 'Mohon maaf data saat ini kosong',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
    } else {
      await Future.delayed(const Duration(seconds: 1));
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
                  builder: (context) => Permohonan(
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
    return "Success!";
  }

  Future<String> persetujuanOperator(String idSurat) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PersetujuanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'nik': nik, 'token': token, 'idSurat': idSurat}),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      // notifikasiGagal(context);
      return "Gagal";
    }
  }

  Future<String> persetujuanKades(String idSurat) async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/PersetujuanSurat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'idSurat': idSurat,
        'passphrase': passphrase.text
      }),
    );
    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      // notifikasiGagal(context);
      return "Gagal";
    }
  }

  Future<String> cekStatusTTE() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/CekStatusTTE'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
      }),
    );
    setState(() {
      var resBody = json.decode(response.body);
      statusTTE = resBody;
    });
    if (jabatan == "kepala desa") {
      if (response.statusCode == 200) {
        if (statusTTE![0]['status'] == "ISSUE") {
          setState(() {
            loading = true;
          });
          if (data! != null)
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
              desc: 'Selamat, anda bisa melakukan tanda tangan elektronik',
              showCloseIcon: true,
              btnCancelOnPress: () {},
              btnOkOnPress: () {},
            ).show();
          return "Success!";
        } else {
          setState(() {
            var resBody = json.decode(response.body);
            statusTTE = resBody;
            loading = true;
          });
          if (data! != null)
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
              desc:
                  'Mohon maaf, untuk saat ini anda tidak bisa melakukan tanda tangan elektronik. Silahkan Hubungin Pihak Kominfo',
              showCloseIcon: true,
              btnCancelOnPress: () {},
              btnOkOnPress: () {},
            ).show();
          return "Gagal";
        }
      }
    }
    return "Gagal";
  }

  @override
  void initState() {
    super.initState();
    this.getFromSharedPreferences();
    this.daftarPermohonan();
    this.cekStatusTTE();
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
                      kodeKecamatan: kodeKecamatan,
                      kodeDusun: kodeDusun,
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
        padding: EdgeInsets.only(bottom: 20),
        child: Row(
          children: <Widget>[
            Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
              Route route = MaterialPageRoute(
                  builder: (context) => HomePage(
                        nik: nik,
                        index: 0,
                        kodeDesa: kodeDesa,
                        kodeDusun: kodeDusun,
                        kodeKecamatan: kodeKecamatan,
                      ));
              Navigator.push(context, route);
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
                  "Daftar Permohonan Surat ",
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
                      Icons.mail,
                      size: 50,
                      color: Colors.green,
                    ),
                    contentPadding: EdgeInsets.all(15),
                    title: Text(
                      data?[index]['jenisSurat'],
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
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Tanggal Permohonan : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(data?[index]['tanggalPermohonan']),
                                  ]),
                            ),
                            Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'NIK Pemohon : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(data?[index]['nikPemohon']),
                                  ]),
                            ),
                            Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Tanggal Surat : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(data?[index]['tanggalSurat']),
                                  ]),
                            ),
                            if (data?[index]['status'] == '1')
                              Container(
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.only(top: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Status : ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Selesai',
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _launchURL(
                                                  'https://desajatirejo.deliserdangkab.go.id/API/DownloadBerkas/' +
                                                      data?[index]['idSurat']);
                                            },
                                            child: new Text("Download Surat",
                                                style: new TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            if (data?[index]['operator'] == '0' &&
                                data?[index]['kades'] == '0')
                              Container(
                                child: Column(children: <Widget>[
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Status : ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                            "Menunggu Disposisi ke kepala desa",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                  if (hakAkses == "pemerintahDesa")
                                    Container(
                                      margin: EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              persetujuanOperator(
                                                  data?[index]['idSurat']);
                                            },
                                            child: new Text(
                                                "Disposisi surat ke kepala desa",
                                                style: new TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    )
                                ]),
                              ),
                            if (data?[index]['operator'] == '1' &&
                                data?[index]['kades'] == '0')
                              Container(
                                child: Column(children: <Widget>[
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Status : ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text("Menunggu Persetujuan Kepala Desa",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                  if (hakAkses == "pemerintahDesa" &&
                                      loading == true)
                                    if (statusTTE![0]['status'] == "ISSUE")
                                      Container(
                                        alignment: Alignment.centerRight,
                                        margin: EdgeInsets.only(top: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                formPassPhrases(
                                                    data?[index]['idSurat']);
                                              },
                                              child: new Text(
                                                  "Masukkan Passphrase",
                                                  style: new TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      )
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

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void formPassPhrases(idSurat) {
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
                      "Silahkan Masukkan Passphrasse ",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              child: TextFormField(
                obscureText: !passwordVisible,
                controller: passphrase,
                keyboardType: TextInputType.visiblePassword,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Masukkan Passphrasse',
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
                  "Tanda Tangan Elektronik",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  persetujuanKades(idSurat);
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
                      "Permohonan surat berhasil di setujui",
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
                  Route route = MaterialPageRoute(
                      builder: (context) => Permohonan(
                            nik: nik,
                            index: index,
                            token: token,
                            kodeDesa: kodeDesa,
                            kodeDusun: kodeDusun,
                            kodeKecamatan: kodeKecamatan,
                          ));
                  Navigator.push(context, route);
                },
              ),
            )
          ],
        );
      },
    );
  }
}
