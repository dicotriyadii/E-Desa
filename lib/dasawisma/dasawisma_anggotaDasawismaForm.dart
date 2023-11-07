import 'dart:io';
import 'package:aplikasi_edesa/home/permohonan_view.dart';
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
import 'package:aplikasi_edesa/dasawisma/dasawisma_ibu.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_keluarga.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma.dart';
import 'package:aplikasi_edesa/dasawisma/dasawisma_anggotaDasawisma.dart';

class anggotaDasawismaForm extends StatefulWidget {
  int index;
  var token;
  final nik;
  final kodeDesa;
  final kodeDusun;
  final kodeKecamatan;
  anggotaDasawismaForm(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDesa,
      required this.kodeKecamatan,
      required this.kodeDusun})
      : super(key: key);
  @override
  _anggotaDasawismaFormState createState() => _anggotaDasawismaFormState(
      index: index,
      nik: nik,
      token: token,
      kodeDusun: kodeDusun,
      kodeDesa: kodeDesa,
      kodeKecamatan: kodeKecamatan);
}

class _anggotaDasawismaFormState extends State<anggotaDasawismaForm> {
  _anggotaDasawismaFormState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeKecamatan,
      required this.kodeDusun,
      required this.kodeDesa});
  TextEditingController search = TextEditingController();

  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final String nik;
  final String token;
  final String kodeDesa;
  final String kodeKecamatan;
  final String kodeDusun;
  String? jabatan;
  int index;
  List? data;
  // variable untuk dropdown

  var wargaValue;
  var dasawismaValue;
  List wargaList = [];
  List dasawismaList = [];

  void initState() {
    super.initState();
    this.getFromSharedPreferences();
    listWarga();
    listDasaWisma();
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
  Future<String> tambahAnggotaDasawisma() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/TambahAnggotaDasawisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'kodeDesaDasawisma': kodeDesa,
        'kodeKecamatanDasawisma': kodeKecamatan,
        'kodeDusunDasawisma': kodeDusun,
        'nikAnggota': wargaValue,
        'idDasawisma': dasawismaValue,
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
        desc: 'Anggota dasawisma berhasil ditambah',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
      return "Success!";
    } else if (response.statusCode == 400) {
      setState(() {
        var resBody = json.decode(response.body);
        data = resBody;
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
        desc: data?[0]['messages'],
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {},
      ).show();
      return "Gagal";
    }
    return "Gagal";
  }

  Future<String> listDasaWisma() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/DataDasaWisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'kode_kecamatan': kodeKecamatan,
        'kode_desa': kodeDesa
      }),
    );
    setState(() {
      var resBody = json.decode(response.body);
      dasawismaList = resBody;
    });
    return "Succses !";
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
      await Future.delayed(const Duration(seconds: 10));
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
                  "Tambah Anggota Dasawisma",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          )),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: [
            if (loading == true)
              Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //penggunaan dropdown button
                  Container(
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
                              value: item['nomorIndukKependudukan'].toString(),
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
                          return (item.value.toString().contains(searchValue));
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
                  SizedBox(height: 15),
                  Container(
                    child: DropdownButton2(
                      isExpanded: true,
                      hint: Text(
                        '- Silahkan Pilih Dasawisma -',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items: dasawismaList
                          .map((item) => DropdownMenuItem(
                              value: item['id'].toString(),
                              child: Text(item['nama_dasa_wisma'].toString())))
                          .toList(),
                      value: dasawismaValue,
                      onChanged: (value) {
                        setState(() {
                          dasawismaValue = value as String;
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
                              hintText: 'Silahkan Masukkan Dasawisma',
                              hintStyle: const TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return (item.value.toString().contains(searchValue));
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
                  SizedBox(height: 15),

                  Container(
                    width: 500,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Text(
                        "Tambah Anggota",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        tambahAnggotaDasawisma();
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: 500,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Text(
                        "Daftar Anggota Dasawisma",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => anggotaDasawisma(
                                    index: 0,
                                    nik: nik,
                                    token: token,
                                    kodeDesa: kodeDesa,
                                    kodeDusun: kodeDusun,
                                    kodeKecamatan: kodeKecamatan,
                                  )),
                        );
                      },
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
