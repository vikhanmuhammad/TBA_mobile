import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'driver_bottom_navigation_bar.dart';
import 'helper_bottom_navigation_bar.dart';
import 'session_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await SessionDatabase.instance.deleteSession();
  var session = await SessionDatabase.instance.getSession();
  String? email = session['email'];
  String? ipAddress = session['ipAddress'];
  String? userType = session['userType'];

  runApp(MyApp(email: email ?? '', ipAddress: ipAddress ?? '', userType: userType ?? ''));
}

class MyApp extends StatelessWidget {
  final String email;
  final String ipAddress;
  final String userType;

  MyApp({required this.email, required this.ipAddress, required this.userType});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Berkah Armada',
      home: SplashScreen(email: email, ipAddress: ipAddress, userType: userType),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final String email;
  final String ipAddress;
  final String userType;

  SplashScreen({required this.email, required this.ipAddress, required this.userType});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String email;
  late String ipAddress;
  late String userType;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    ipAddress = widget.ipAddress;
    userType = widget.userType;

    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => email.isNotEmpty
              ? userType == 'driver'
                  ? BottomNavigationBarWidgetDriver(
                      email: email,
                      ipAddress: ipAddress,
                    )
                  : BottomNavigationBarWidgetHelper(
                      email: email,
                      ipAddress: ipAddress,
                    )
              : LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 71, 169, 146),
      body: Center(
        child: Text(
          'TBA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 48.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> login() async {
    var email = _emailController.text;
    var password = _passwordController.text;
    var ipAddress = '10.0.2.2';

    // URL pertama
    var url1 = Uri.parse('http://$ipAddress/mobpro/login.php');
    // URL kedua
    var url2 = Uri.parse('http://$ipAddress/mobpro/login_helper.php');

    // Request ke URL pertama
    var response1 =
        await http.post(url1, body: {'email': email, 'password': password});

    if (response1.statusCode == 200) {
      var jsonResponse1 = json.decode(response1.body);
      if (jsonResponse1 == "Success") {
        // Simpan session ke SQLite
        await SessionDatabase.instance.insertSession({
          'email': email,
          'ipAddress': ipAddress,
          'userType': 'driver',
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BottomNavigationBarWidgetDriver(
                    email: email,
                    ipAddress: ipAddress,
                  )),
        );
      } else {
        // Request ke URL kedua jika tidak berhasil di URL pertama
        var response2 = await http.post(url2,
            body: {'email': email, 'password': password});
        if (response2.statusCode == 200) {
          var jsonResponse2 = json.decode(response2.body);
          if (jsonResponse2 == "Success") {
            // Data ditemukan di URL kedua
            print("ini data helper");

            // Simpan session ke SQLite
            await SessionDatabase.instance.insertSession({
              'email': email,
              'ipAddress': ipAddress,
              'userType': 'helper',
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavigationBarWidgetHelper(
                      email: email, ipAddress: ipAddress)),
            );
          } else {
            // Data tidak ditemukan di kedua URL
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Login Gagal'),
                content: Text('Email atau password salah.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content:
                  Text('Terjadi kesalahan saat login. Silakan coba lagi.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Terjadi kesalahan saat login. Silakan coba lagi.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transport Berkah Armada',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 71, 169, 146),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Masuk Ke Akun',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              key: Key('emailField'),
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hoverColor: Color.fromARGB(255, 71, 169, 146),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              key: Key('passwordField'),
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                hoverColor: Color.fromARGB(255, 71, 169, 146),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              key: Key('loginButton'),
              onPressed: login,
              child: Text('Masuk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 71, 169, 146),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}