import 'helper_aktivitas.dart';
import 'package:flutter/material.dart';
import 'helper_my_home_page.dart';
import 'helper_profil.dart';

class BottomNavigationBarWidgetHelper extends StatefulWidget {
  final String email;
  final String ipAddress;
  const BottomNavigationBarWidgetHelper({Key? key, required this.email, required this.ipAddress}) : super(key: key);

  @override
  _BottomNavigationBarWidgetHelperState createState() => _BottomNavigationBarWidgetHelperState();
}

class _BottomNavigationBarWidgetHelperState extends State<BottomNavigationBarWidgetHelper> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions(String email, String ipAddress) => <Widget>[
    MyHomePageHelper(title: 'Flutter Demo Application', email: email, ipAddress: ipAddress,),
    AktivitasHelper(email: email, ipAddress: ipAddress,),
    ProfilHelper(email: email, ipAddress: ipAddress,),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        child: _widgetOptions(widget.email, widget.ipAddress).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 71, 169, 146),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}

