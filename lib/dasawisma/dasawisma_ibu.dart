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

class catatanIbu extends StatefulWidget {
  int index;
  var token;
  final nik;
  final kodeDesa;
  final kodeKecamatan;
  final kodeDusun;
  catatanIbu(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDesa,
      required this.kodeDusun,
      required this.kodeKecamatan})
      : super(key: key);
  @override
  _catatanIbuState createState() => _catatanIbuState(
      index: index,
      nik: nik,
      token: token,
      kodeDesa: kodeDesa,
      kodeKecamatan: kodeKecamatan,
      kodeDusun: kodeDusun);
}

class _catatanIbuState extends State<catatanIbu> {
  _catatanIbuState(
      {Key? key,
      required this.index,
      required this.nik,
      required this.token,
      required this.kodeDesa,
      required this.kodeKecamatan,
      required this.kodeDusun});
  TextEditingController tanggal = new TextEditingController();
  TextEditingController namaSuami = new TextEditingController();
  TextEditingController status = new TextEditingController();
  TextEditingController akteKelahiran = new TextEditingController();
  TextEditingController sebabMeninggal = new TextEditingController();
  TextEditingController keterangan = new TextEditingController();
  TextEditingController keteranganLahir = new TextEditingController();
  TextEditingController namaBayi = new TextEditingController();
  TextEditingController search = TextEditingController();
  bool loading = false;
  DateTime _tanggalPembuatan = DateTime.now();
  DateTime _tanggalLahir = DateTime.now();
  DateTime _tanggalMeninggal = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final String nik;
  final String token;
  final String kodeDesa;
  final String kodeKecamatan;
  final String kodeDusun;
  String? jabatan;
  int index;
  List? dataIbu;
  List<String> listKota = [
    "-",
    "lahir",
    "mati",
  ];
  List<String> listStatusMelahirkan = ["-", "HAMIL", "MELAHIRKAN", "NIFAS"];
  List<String> listJenisKelamin = [
    "-",
    "Laki - Laki",
    "Perempuan",
  ];
  // variable untuk dropdown

  String nKota = "-";
  int? nilaiKota;
  int? nilaiStatusMelahirkan;
  String nJenisKelamin = "-";
  String nStatusMelahirkan = "-";
  int? nilaiJenisKelamin;
  var wargaValue;
  List wargaList = [];

  void initState() {
    super.initState();
    this.getFromSharedPreferences();
    this.listWarga();
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

  void pilihKota(String value) {
    //menampilkan kota yang dipilih
    setState(() {
      nKota = value;
    });
  }

  void pilihJenisKelamin(String value) {
    //menampilkan kota yang dipilih
    setState(() {
      nJenisKelamin = value;
    });
  }

  void pilihStatusMelahirkan(String value) {
    //menampilkan kota yang dipilih
    setState(() {
      nStatusMelahirkan = value;
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

  void tanggalLahir() {
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
        _tanggalLahir = value;
      });
    });
  }

  void tanggalMeninggal() {
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
        _tanggalMeninggal = value;
      });
    });
  }

  //API
  Future<String> catatanIbu() async {
    final response = await http.post(
      Uri.parse(
          'https://desajatirejo.deliserdangkab.go.id/API/CatatanStatusIbu'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nik,
        'token': token,
        'tgl': "${_tanggalPembuatan.toLocal()}",
        'nikIbu': wargaValue,
        'namaSuami': namaSuami.text,
        'status': nKota,
        'statusMelahirkan': nStatusMelahirkan,
        'namaBayi': namaBayi.text,
        'jenisKelamin': nJenisKelamin,
        'tglLahir': "${_tanggalLahir.toLocal()}",
        'akte': akteKelahiran.text,
        'tglMeninggal': "${_tanggalMeninggal.toLocal()}",
        'sebabMeninggal': sebabMeninggal.text,
        'keterangan': keterangan.text,
        'keteranganLahir': keteranganLahir.text
      }),
    );

    if (response.statusCode == 200) {
      notifikasiBerhasil(context);
      return "Success!";
    } else {
      setState(() {
        var resBody = json.decode(response.body);
        dataIbu = resBody;
      });
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
                  "Penambahan Catatan Ibu",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          )),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          //agar semua widget diposisi kiri
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loading == true)
              Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                  TextFormField(
                    controller: namaSuami,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        labelText: 'Nama Suami',
                        hintText: 'Masukkan Nama Suami'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Nama Suami Tidak Boleh Kosong';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: namaBayi,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        labelText: 'Nama bayi', hintText: 'Masukkan Nama Bayi'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Nama Bayi Tidak Boleh Kosong';
                      }
                      return null;
                    },
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(height: 15),
                              Text("jenis Kelamin"),
                              SizedBox(width: 8),
                              DropdownButton(
                                value: nJenisKelamin,
                                onChanged: (String? value) {
                                  pilihJenisKelamin(value ??
                                      ""); //perubahaan saat kota di pilih
                                  nilaiJenisKelamin = listJenisKelamin.indexOf(
                                      value ??
                                          ""); //mengambil nilai index berdasarkan urutan list
                                },
                                items: listJenisKelamin.map((String value) {
                                  return DropdownMenuItem(
                                    //tampilan isi data dropdown
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(height: 15),
                              Text("Status"),
                              SizedBox(width: 8),
                              DropdownButton(
                                value: nKota,
                                onChanged: (String? value) {
                                  pilihKota(value ??
                                      ""); //perubahaan saat kota di pilih
                                  nilaiKota = listKota.indexOf(value ??
                                      ""); //mengambil nilai index berdasarkan urutan list
                                },
                                items: listKota.map((String value) {
                                  return DropdownMenuItem(
                                    //tampilan isi data dropdown
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  if (nKota == "lahir")
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.green),
                                  child: Text(
                                    "Silahkan Pilih Tanggal Lahir",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    tanggalLahir();
                                  },
                                ),
                                Text(
                                    "${_tanggalLahir.toLocal()}".split(' ')[0]),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(height: 15),
                                Text("Status Melahirkan"),
                                SizedBox(width: 8),
                                DropdownButton(
                                  value: nStatusMelahirkan,
                                  onChanged: (String? value) {
                                    pilihStatusMelahirkan(value ??
                                        ""); //perubahaan saat kota di pilih
                                    nilaiStatusMelahirkan =
                                        listStatusMelahirkan.indexOf(value ??
                                            ""); //mengambil nilai index berdasarkan urutan list
                                  },
                                  items:
                                      listStatusMelahirkan.map((String value) {
                                    return DropdownMenuItem(
                                      //tampilan isi data dropdown
                                      child: Text(value),
                                      value: value,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: akteKelahiran,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                                labelText: 'Akte Kelahiran',
                                hintText: 'Masukkan Akte Kelahiran'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Nama Suami Tidak Boleh Kosong';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Silahkan isi keterangan jika tidak memiliki akte kelahiran',
                            style: TextStyle(color: Colors.red),
                          ),
                          TextFormField(
                            controller: keteranganLahir,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                                labelText: 'keterangan',
                                hintText: 'Masukkan keterangan'),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  if (nKota == "mati")
                    Container(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 15),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.green),
                                  child: Text(
                                    "Silahkan Pilih Tanggal Meninggal",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    tanggalMeninggal();
                                  },
                                ),
                                Text("${_tanggalMeninggal.toLocal()}"
                                    .split(' ')[0]),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: sebabMeninggal,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                                labelText: 'Sebab Meninggal',
                                hintText: 'Masukkan Sebab Meninggal'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Sebab Meninggal Tidak Boleh Kosong';
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
                                labelText: 'Keterangan',
                                hintText: 'Masukkan Keterangan'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Sebab Meninggal Tidak Boleh Kosong';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                    child: Text(
                      "Tambah",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      catatanIbu();
                    },
                  ),
                ],
              ))
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
                      dataIbu![0]['messages'],
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
