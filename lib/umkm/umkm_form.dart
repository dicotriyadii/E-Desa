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
import 'package:aplikasi_edesa/umkm/umkmList_view.dart';

class umkmForm extends StatefulWidget {
  int index;
  var token;
  final nik;
  final kodeKecamatan;
  final kodeDesa;
  final kodeDusun;
  umkmForm(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeKecamatan,
      required this.kodeDesa,
      required this.kodeDusun})
      : super(key: key);
  @override
  _umkmFormState createState() => _umkmFormState(
      index: index,
      nik: nik,
      token: token,
      kodeKecamatan: kodeKecamatan,
      kodeDesa: kodeDesa,
      kodeDusun: kodeDusun);
}

class _umkmFormState extends State<umkmForm> {
  _umkmFormState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
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
  final String kodeKecamatan;
  final String kodeDesa;
  final String kodeDusun;
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
    this.listWarga();
    this.listKategoriUMKM();
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
  Future<String> tambahUMKM() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/TambahUMKM'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'kodeKecamatan': kodeKecamatan,
        'kodeDesa': kodeDesa,
        'nikUMKM': wargaValue,
        'namaUMKM': namaUMKM.text,
        'kategori': kategoriValue,
        'alamat': alamatUMKM.text
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
        desc: 'Data terbaru UMKM berhasil di tambah',
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
        desc: 'Data UMKM sudah terdaftar, silahkan coba kembali',
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
      return "Gagal";
    }
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
        btnOkOnPress: () {},
      ).show();
    }
    return "Succses !";
  }

  Future<String> listKategoriUMKM() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/DataKategoriUMKM'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'nik': nik, 'token': token}),
    );
    setState(() {
      var resBody = json.decode(response.body);
      kategoriList = resBody;
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
        btnCancelOnPress: () {},
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
        title: Text(
          "Penambahan Data UMKM",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.left,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: [
            if (loading == false)
              Container(
                child: Container(
                    child: LinearProgressIndicator(
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )),
              ),
            if (loading == true)
              Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: namaUMKM,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        labelText: 'Nama UMKM', hintText: 'Masukkan Nama UMKM'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Nama UMKM Tidak Boleh Kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: alamatUMKM,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        labelText: 'Alamat UMKM',
                        hintText: 'Masukkan Alamat UMKM'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Alamat UMKM Tidak Boleh Kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  Container(
                    child: DropdownButton2(
                      isExpanded: true,
                      hint: Text(
                        '- Silahkan Pilih Kategori Usaha -',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items: kategoriList
                          .map((item) => DropdownMenuItem(
                              value: item['idKategori'].toString(),
                              child: Text(item['kategori'].toString())))
                          .toList(),
                      value: kategoriValue,
                      onChanged: (value) {
                        setState(() {
                          kategoriValue = value as String;
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
                              hintText: 'Silahkan Masukkan Kategori',
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
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          search.clear();
                        }
                      },
                    ),
                  ),
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
                        "Tambah",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        tambahUMKM();
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: 500,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Text(
                        "Daftar UMKM",
                        style: TextStyle(color: Colors.white),
                      ),
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
