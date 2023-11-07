import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
//page
import 'package:aplikasi_edesa/dasawisma/dasawisma_anggotaDasawisma.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_dataKeluarga.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_ibuHamil.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_ibuHamilMeninggal.dart';
import 'package:aplikasi_edesa/home/home_view.dart';
import 'package:aplikasi_edesa/home/permohonan_view.dart';
import 'package:aplikasi_edesa/home/profile_view.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_ibu.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_keluarga.dart';

class dasawisma extends StatefulWidget {
  int index;
  final token;
  final nik;
  final kodeDesa;
  final kodeKecamatan;
  final kodeDusun;
  dasawisma(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDusun,
      required this.kodeKecamatan,
      required this.kodeDesa})
      : super(key: key);
  @override
  _dasawismaState createState() => _dasawismaState(
      index: index,
      nik: nik,
      token: token,
      kodeDesa: kodeDesa,
      kodeDusun: kodeDusun,
      kodeKecamatan: kodeKecamatan);
}

class _dasawismaState extends State<dasawisma> {
  _dasawismaState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDusun,
      required this.kodeDesa,
      required this.kodeKecamatan});
  final String nik;
  final String token;
  final String kodeDusun;
  final String kodeDesa;
  final String kodeKecamatan;
  TextEditingController search = TextEditingController();
  bool loading = false;
  int index;
  List? data;

  String? jabatan;
  String? hakAkses;
  var namaDasaWisma;
  var namaDesa;
  DateTime _tanggalAwal = DateTime.now();
  DateTime _tanggalAkhir = DateTime.now();
  List wargaList = [];
  var wargaValue;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void tanggalAwal() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now())
        .then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _tanggalAwal = value;
      });
    });
  }

  void tanggalAkhir() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now())
        .then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _tanggalAkhir = value;
      });
    });
  }

  void initState() {
    this.listWarga();
    this.getFromSharedPreferences();
  }

  Future<String> listWarga() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/APIWarga'),
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
    setState(() {
      var resBody = json.decode(response.body);
      wargaList = resBody;
    });
    if (response.statusCode == 200) {
      setState(() {
        loading = true;
      });
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
        title: 'Proses Gagal',
        desc: 'Mohon maaf data tidak bisa di proses, silahkan coba lagi',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
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
      ).show();
    }
    return "Succses !";
  }

  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jabatan = prefs.getString("jabatan");
      namaDesa = prefs.getString("namaDesa");
      namaDasaWisma = prefs.getString("namaDasaWisma");
      hakAkses = prefs.getString("hakAkses");
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

    final judul = Container(
        padding: EdgeInsets.only(bottom: 20, top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Dasawisma',
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
      appBar: AppBar(
          backgroundColor: Colors.green[600],
          leading: IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
                icon: new Icon(Icons.switch_account_rounded),
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
                              kodeKecamatan: kodeKecamatan)));
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
                  'DASAWISMA',
                ),
              ],
            ),
          )),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            if (loading == true)
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  children: <Widget>[
                    judul,
                    //Column menu
                    if (hakAkses == "dasawisma")
                      Card(
                        margin:
                            EdgeInsets.only(right: 20, left: 20, bottom: 10),
                        child: ListTile(
                          leading: Icon(
                            Icons.pregnant_woman,
                            size: 30,
                            color: Colors.green,
                          ),
                          title: Text('Catatan Status Ibu'),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => catatanIbu(
                                          index: index,
                                          nik: nik,
                                          token: token,
                                          kodeDesa: kodeDesa,
                                          kodeDusun: kodeDusun,
                                          kodeKecamatan: kodeKecamatan,
                                        )));
                          },
                        ),
                      ),
                    if (hakAkses == "dasawisma")
                      Card(
                        margin:
                            EdgeInsets.only(right: 20, left: 20, bottom: 10),
                        child: ListTile(
                          leading: Icon(
                            Icons.family_restroom,
                            size: 30,
                            color: Colors.green,
                          ),
                          title: Text('Catatan Status Keluarga'),
                          onTap: () {
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
                        ),
                      ),
                    Card(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          Icons.notes_outlined,
                          size: 30,
                          color: Colors.green,
                        ),
                        title: Text('Daftar Catatan Status Ibu Bayi Lahir'),
                        onTap: () {
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
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          Icons.notes_outlined,
                          size: 30,
                          color: Colors.green,
                        ),
                        title: Text('Daftar Catatan Status Ibu Bayi Meninggal'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ibuHamilMeninggal(
                                        index: index,
                                        nik: nik,
                                        token: token,
                                        kodeDesa: kodeDesa,
                                        kodeDusun: kodeDusun,
                                        kodeKecamatan: kodeKecamatan,
                                      )));
                        },
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          Icons.notes_outlined,
                          size: 30,
                          color: Colors.green,
                        ),
                        title: Text('Daftar Catatan Status Keluarga'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => dataKeluarga(
                                        index: index,
                                        nik: nik,
                                        token: token,
                                        kodeDesa: kodeDesa,
                                        kodeDusun: kodeDusun,
                                        kodeKecamatan: kodeKecamatan,
                                      )));
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: DropdownButton2(
                        isExpanded: true,
                        hint: Text(
                          '- Silahkan Pilih Warga Negara -',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items: wargaList
                            .map((item) => DropdownMenuItem(
                                value:
                                    item['nomorIndukKependudukan'].toString(),
                                child: Text(
                                    item['nomorIndukKependudukan'].toString() +
                                        ' | ' +
                                        item['namaWarga'].toString())))
                            .toList(),
                        value: wargaValue,
                        onChanged: (value) {
                          setState(() {
                            wargaValue = value as String;
                          });
                        },
                        dropdownSearchData: DropdownSearchData(
                          searchController: search,
                          searchInnerWidgetHeight: 50,
                          searchInnerWidget: Container(
                            height: 70,
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              expands: true,
                              maxLines: null,
                              controller: search,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                hintText:
                                    'Silahkan Masukkan Nomor Induk Kependudukan',
                                hintStyle: const TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          searchMatchFn: (item, searchValue) {
                            return (item.value
                                .toString()
                                .contains(searchValue));
                          },
                        ),
                        //This to clear the search value when you close the menu
                        onMenuStateChange: (isOpen) {
                          if (!isOpen) {
                            search.clear();
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            width: 230,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              child: Text(
                                "Tanggal Awal Rekapitulasi",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                tanggalAwal();
                              },
                            ),
                          ),
                          Text("${_tanggalAwal.toLocal()}".split(' ')[0]),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            width: 230,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              child: Text(
                                "Tanggal Akhir Rekapitulasi",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                tanggalAkhir();
                              },
                            ),
                          ),
                          Text("${_tanggalAkhir.toLocal()}".split(' ')[0]),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          Icons.list_alt,
                          size: 30,
                          color: Colors.green,
                        ),
                        title:
                            Text('Rekapitulasi Catatan Keluarga per keluarga'),
                        onTap: () {
                          _launchURL(
                              'https://desajatirejo.deliserdangkab.go.id/laporan/catatan_keluarga?nama_kepala_keluarga=' +
                                  wargaValue +
                                  '&tgl_mulai_catatan_keluarga=' +
                                  _tanggalAwal.toString() +
                                  '&tgl_akhir_catatan_keluarga=' +
                                  _tanggalAkhir.toString());
                        },
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          Icons.list_alt,
                          size: 30,
                          color: Colors.green,
                        ),
                        title: Text(
                            'Rekapitulasi Catatan Keluarga per dasa wisma'),
                        onTap: () {
                          _launchURL(
                              'https://desajatirejo.deliserdangkab.go.id/laporan/catatan_keluarga_kelompok_dasa_wisma?tgl_mulai_catatan_data_kelompok_dasa_wisma=' +
                                  _tanggalAwal.toString() +
                                  '&tgl_akhir_catatan_data_kelompok_dasa_wisma=' +
                                  _tanggalAkhir.toString());
                        },
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          Icons.list_alt,
                          size: 30,
                          color: Colors.green,
                        ),
                        title:
                            Text('Rekapitulasi Data Catatan Keluarga per Desa'),
                        onTap: () {
                          _launchURL(
                              'https://desajatirejo.deliserdangkab.go.id/laporan/catatan_keluarga_tp_pkk_desa?tgl_mulai_catatan_data_tp_pkk_desa=' +
                                  _tanggalAwal.toString() +
                                  '&tgl_akhir_catatan_data_tp_pkk_desa=' +
                                  _tanggalAkhir.toString());
                        },
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          Icons.list_alt,
                          size: 30,
                          color: Colors.green,
                        ),
                        title: Text(
                            'Rekapitulasi Data Catatan Status Ibu Per Dasawisma'),
                        onTap: () {
                          _launchURL(
                              'https://desajatirejo.deliserdangkab.go.id/laporan/catatan_status_ibu_kelompok_dasa_wisma?tgl_mulai_catatan_status_ibu_kelompok_dasa_wisma=' +
                                  _tanggalAwal.toString() +
                                  '&tgl_akhir_catatan_status_ibu_kelompok_dasa_wisma=' +
                                  _tanggalAkhir.toString());
                        },
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          Icons.list_alt,
                          size: 30,
                          color: Colors.green,
                        ),
                        title: Text(
                            'Rekapitulasi Data Catatan Status Ibu Per Dusun'),
                        onTap: () {
                          _launchURL(
                              'https://desajatirejo.deliserdangkab.go.id/laporan/catatan_status_ibu_tingkat_dusun?tgl_mulai_catatan_status_ibu_tingkat_dusun=' +
                                  _tanggalAwal.toString() +
                                  '&tgl_akhir_catatan_status_ibu_tingkat_dusun=' +
                                  _tanggalAkhir.toString());
                        },
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          Icons.list_alt,
                          size: 30,
                          color: Colors.green,
                        ),
                        title: Text(
                            'Rekapitulasi Data Catatan Status Ibu Per Desa'),
                        onTap: () {
                          _launchURL(
                              'https://desajatirejo.deliserdangkab.go.id/laporan/catatan_status_ibu_tingkat_desa?tgl_mulai_catatan_status_ibu_tingkat_desa=' +
                                  _tanggalAwal.toString() +
                                  '&tgl_akhir_catatan_status_ibu_tingkat_desa=' +
                                  _tanggalAkhir.toString());
                        },
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
}
