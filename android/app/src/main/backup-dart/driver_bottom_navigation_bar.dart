import 'driver_aktivitas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'driver_my_home_page.dart';
import 'driver_map.dart';
import 'driver_profil.dart';

class BottomNavigationBarWidgetDriver extends StatefulWidget {
  final String ipAddress;
  final String email;
  const BottomNavigationBarWidgetDriver({Key? key, required this.email, required this.ipAddress}) : super(key: key);

  @override
  _BottomNavigationBarWidgetState createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidgetDriver> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions(String email, String ipAddress) => <Widget>[
    MyHomePageDriver(title: 'Flutter Demo Application', email: email, ipAddress: ipAddress,),
    MapViewDriver(email: email, ipAddress: ipAddress,),
    AktivitasDriver(email: email, ipAddress: ipAddress,),
    ProfilDriver(email: email, ipAddress: ipAddress,)
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
            icon: Icon(Icons.location_on),
            label: 'Peta',
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
