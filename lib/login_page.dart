import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aplikasi_edesa/home/home_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //inisialisasi variable
  String namaWarga = "";
  String token = "";
  String kodeKecamatan = "";
  String kodeDesa = "";
  String kodeDusun = "";
  String namaDesa = "";
  String hakAkses = "";
  String jabatan = "";
  String namaDasawisma = "";
  String idUMKM = "";
  String nik = "";
  String UMKM = "";
  String password = "";
  List? dataNik;
  bool? statusLogin = false;
  TextEditingController nikController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool passwordVisible = false;
  //function
  // Lihat Password
  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  //Login Warga
  Future<String> LoginWarga(
      String nikController, String passwordController) async {
    final response = await http.post(
      // Uri.parse('http://localhost/kantor/ManagementDesa/API/LoginWarga'),
      Uri.parse('https://desajatirejo.deliserdangkab.go.id/API/LoginWarga'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nik': nikController,
        'password': passwordController,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        var resBody = json.decode(response.body);
        dataNik = resBody;
      });
      setIntoSharedPreferences();
      hakAkses = dataNik?[0]['hakAkses'];
      if (hakAkses == "pkk" || hakAkses == "pemerintahDesa")
        jabatan = dataNik?[0]['data'][0]['jabatan'];
      if (hakAkses == "dasawisma") jabatan = dataNik?[0]['data'][0]['jabatan'];
      token = dataNik?[0]['data'][0]['token'];
      kodeKecamatan = dataNik?[0]['data'][0]['kodeKecamatan'];
      kodeDusun = dataNik?[0]['data'][0]['kodeDusun'];
      kodeDesa = dataNik?[0]['data'][0]['kodeDesa'];
      namaDesa = dataNik?[0]['data'][0]['namaDesa'];
      namaWarga = dataNik?[0]['data'][0]['namaWarga'];
      UMKM = dataNik?[0]['UMKM'];
      if (UMKM == "ada") idUMKM = dataNik?[0]['idUMKM'];
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
        title: 'Login Berhasil',
        desc: 'Selamat datang di aplikasi E Desa Kabupaten Deli Serdang',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      index: 0,
                      nik: nikController,
                      kodeDesa: kodeDesa,
                      kodeDusun: kodeDusun,
                      kodeKecamatan: kodeKecamatan,
                    )),
          );
        },
      ).show();
      return "Success!";
    } else {
      setState(() {
        var resBody = json.decode(response.body);
        dataNik = resBody;
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
        title: 'Gagal',
        desc: dataNik?[0]['messages'],
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          LoginPage();
        },
      ).show();
      return "Gagal";
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: Center(
        child: Image.asset(
          'assets/images/logoEdesa.png',
          width: 400,
          height: 300,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            TextFormField(
              controller: nikController,
              keyboardType: TextInputType.text,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Masukkan Nomor Induk Kependudukan',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0)),
              ),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              obscureText: !passwordVisible,
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              autofocus: false,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  splashRadius: 1,
                  icon: Icon(passwordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: togglePassword,
                ),
                hintText: 'Masukkan Password',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                borderRadius: BorderRadius.circular(30.0),
                shadowColor: Colors.green,
                elevation: 5.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  onPressed: () {
                    LoginWarga(nikController.text, passwordController.text);
                  },
                  child: Text('Masuk', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("nik", nikController.text);
    await prefs.setString("token", token);
    await prefs.setString("hakAkses", hakAkses);
    await prefs.setString("namaDesa", namaDesa);
    await prefs.setString("kodeDesa", kodeDesa);
    await prefs.setString("kodeKecamatan", kodeKecamatan);
    await prefs.setString("namaWarga", namaWarga);
    await prefs.setString("UMKM", UMKM);
    if (UMKM == 'ada') await prefs.setString("idUMKM", idUMKM);
    if (hakAkses == "pkk" || hakAkses == "pemerintahDesa")
      await prefs.setString("jabatan", jabatan);
    if (hakAkses == "dasawisma") await prefs.setString("jabatan", jabatan);
    if (hakAkses == "dasawisma")
      await prefs.setString("namaDasaWisma", namaDasawisma);
    if (hakAkses == "warga") await prefs.setString("jabatan", "warga");
  }
}
