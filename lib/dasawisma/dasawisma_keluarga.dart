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

class catatanKeluarga extends StatefulWidget {
  int index;
  var token;
  final nik;
  final kodeDesa;
  final kodeDusun;
  final kodeKecamatan;
  catatanKeluarga(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDesa,
      required this.kodeDusun,
      required this.kodeKecamatan})
      : super(key: key);
  @override
  _catatanKeluargaState createState() => _catatanKeluargaState(
      index: index,
      nik: nik,
      token: token,
      kodeKecamatan: kodeKecamatan,
      kodeDesa: kodeDesa,
      kodeDusun: kodeDusun);
}

class _catatanKeluargaState extends State<catatanKeluarga> {
  _catatanKeluargaState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDusun,
      required this.kodeDesa,
      required this.kodeKecamatan});
  TextEditingController namaKegiatan = new TextEditingController();
  TextEditingController akteKelahiran = new TextEditingController();
  TextEditingController keterangan = new TextEditingController();
  TextEditingController jamban = new TextEditingController();
  TextEditingController search = TextEditingController();
  bool loading = false;
  DateTime _tanggalPembuatan = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final String nik;
  final String token;
  final String kodeDesa;
  final String kodeKecamatan;
  final String kodeDusun;
  String? jabatan;
  int index;
  var kriteriaRumahValue;
  var sumberAirValue;
  var tempatSampahValue;
  var jenisKegiatanValue;
  var makananPokokValue;
  var wargaValue;
  var berkebutuhanKhususValue;
  List kriteriaRumahlist = [];
  List sumberAirlist = [];
  List tempatSampahlist = [];
  List jenisKegiatanlist = [];
  List makananPokoklist = [];
  List wargaList = [];
  List<String> berkebutuhanKhusus = [
    "Sehat",
    "Disabilitas Penglihatan",
    "Disabilitas Pendengaran",
    "Disabilitas Intelektual",
    "Disabilitas Fisik",
    "Disabilitas Sosial",
    "Anak dengan gangguan pemusatan \nperhatian dan hiperaktivitas",
    "Anak dengan gangguan spektrum \nautisma",
    "Anak dengan gangguan ganda",
    "Anak dengan kapasitas menyerap \nyang lamban",
    "Anak dengan kesulitan belajar \nkhusus",
    "Anak dengan gangguan kemampuan \nkomunikasi",
    "Anak dengan potensi kecerdasan \ndan/atau bakat istimewa"
  ];

  void initState() {
    super.initState();
    this.getFromSharedPreferences();
    kriteriaRumah();
    sumberAir();
    tempatSampah();
    jenisKegiatan();
    makananPokok();
    listWarga();
  }

  // function
  void getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jabatan = prefs.getString("jabatan");
    });
  }

  void tanggalPembuatan() {
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
        _tanggalPembuatan = value;
      });
    });
  }

  //API
  Future<String> catatanKeluarga() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/CatatanKeluarga'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'nikWarga': wargaValue,
        'berkebutuhanKhusus': berkebutuhanKhususValue,
        'kriteriaRumahId': kriteriaRumahValue,
        'sumberAirId': sumberAirValue,
        'tempatSampahId': tempatSampahValue,
        'jenisKegiatanId': jenisKegiatanValue,
        'namaKegiatan': namaKegiatan.text,
        'makananPokokId': makananPokokValue,
        'keterangan': keterangan.text,
        'jml_jamban_keluarga': jamban.text,
        'tgl': "${_tanggalPembuatan.toLocal()}",
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

  Future<String> kriteriaRumah() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/KriteriaRumah'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'nik': nik, 'token': token}),
    );
    setState(() {
      var resBody = json.decode(response.body);
      kriteriaRumahlist = resBody;
    });
    return "Succses !";
  }

  Future<String> sumberAir() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/SumberAirKeluarga'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'nik': nik, 'token': token}),
    );
    setState(() {
      var resBody = json.decode(response.body);
      sumberAirlist = resBody;
    });
    return "Succses !";
  }

  Future<String> tempatSampah() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/TempatSampah'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'nik': nik, 'token': token}),
    );
    setState(() {
      var resBody = json.decode(response.body);
      tempatSampahlist = resBody;
    });
    return "Succses !";
  }

  Future<String> jenisKegiatan() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/KegiatanPKK'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'nik': nik, 'token': token}),
    );
    setState(() {
      var resBody = json.decode(response.body);
      jenisKegiatanlist = resBody;
    });
    return "Succses !";
  }

  Future<String> makananPokok() async {
    final response = await http.post(
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/MakananPokok'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'nik': nik, 'token': token}),
    );
    setState(() {
      var resBody = json.decode(response.body);
      makananPokoklist = resBody;
    });
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

    final card = Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 5),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  // title: Text('Jenis Surat'),
                  // subtitle: Text(data![0]["jenisSurat"]),
                  ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    ));

    //pemanggilan material
    var snapGenre;
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
                  "Penambahan Catatan Keluarga",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          )),
      body: Container(
        child: ListView(
          children: <Widget>[
            if (loading == true)
              Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  //agar semua widget diposisi kiri
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green),
                            child: Text(
                              "Silahkan Pilih Tanggal",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              tanggalPembuatan();
                            },
                          ),
                          Text("${_tanggalPembuatan.toLocal()}".split(' ')[0]),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
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
                    SizedBox(height: 15),
                    DropdownButton(
                      hint: Text('Jenis Berkebutuhan Khusus'),
                      items: berkebutuhanKhusus.map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          berkebutuhanKhususValue = newVal;
                        });
                      },
                      value: berkebutuhanKhususValue,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: namaKegiatan,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          labelText: 'Nama Kegiatan',
                          hintText: 'Masukkan Nama Kegiatan'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Nama Kegiatan Tidak Boleh Kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: keterangan,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          labelText: 'keterangan',
                          hintText: 'Masukkan keterangan'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Keterangan Tidak Boleh Kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: jamban,
                      keyboardType: TextInputType.number,
                      maxLines: null,
                      decoration: InputDecoration(
                          labelText: 'Jamban',
                          hintText: 'Masukkan Jumlah Jamban'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Keterangan Tidak Boleh Kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    DropdownButton(
                      hint: Text('Silahkan Pilih Kriteria Rumah'),
                      items: kriteriaRumahlist.map((item) {
                        return DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Text(item['jenis_kriteria_rumah'].toString()),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          kriteriaRumahValue = newVal;
                        });
                      },
                      value: kriteriaRumahValue,
                    ),
                    SizedBox(height: 15),
                    DropdownButton(
                      hint: Text('Silahkan Sumber Air'),
                      items: sumberAirlist.map((item) {
                        return DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Text(item['jenis_sumber_air'].toString()),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          sumberAirValue = newVal;
                        });
                      },
                      value: sumberAirValue,
                    ),
                    SizedBox(height: 15),
                    DropdownButton(
                      hint: Text('Silahkan Pilih Tempat Sampah'),
                      items: tempatSampahlist.map((item) {
                        return DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Text(item['jenis_tempat_sampah'].toString()),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          tempatSampahValue = newVal;
                        });
                      },
                      value: tempatSampahValue,
                    ),
                    SizedBox(height: 15),
                    DropdownButton(
                      hint: Text('Silahkan Pilih Jenis Kegiatan'),
                      items: jenisKegiatanlist.map((item) {
                        return DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Text(item['jenis_kegiatan'].toString()),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          jenisKegiatanValue = newVal;
                        });
                      },
                      value: jenisKegiatanValue,
                    ),
                    SizedBox(height: 15),
                    DropdownButton(
                      hint: Text('Silahkan Pilih Makanan Pokok'),
                      items: makananPokoklist.map((item) {
                        return DropdownMenuItem(
                          value: item['id'].toString(),
                          child: Text(item['makanan_pokok'].toString()),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          makananPokokValue = newVal;
                        });
                      },
                      value: makananPokokValue,
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Text(
                        "Tambah",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        catatanKeluarga();
                      },
                    ),
                  ],
                ),
              )
          ],
        ),
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
                      "Penambahan Data Berhasil",
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
                      "Gagal Penambahan Data",
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
}
