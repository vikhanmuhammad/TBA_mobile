import 'package:flutter/material.dart';
import 'driver_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AktivitasDriver extends StatefulWidget {
  final String email;
  final String ipAddress;
  const AktivitasDriver({Key? key, required this.email, required this.ipAddress}) : super(key: key);

  @override
  State<AktivitasDriver> createState() => _AktivitasDriverState();
}

class _AktivitasDriverState extends State<AktivitasDriver> {
  String tempatAwal = '';
  String tempatAkhir = '';
  String jamBerangkat = '';
  String tanggalBerangkat = '';

  @override
  void initState() {
    super.initState();
    fetchData(); // Panggil fungsi fetchData saat widget pertama kali dibuat
  }

  Future<void> fetchData() async {
    try {
      final response = await http.post(
        // Uri.parse('https://api.tba.transportberkaharmada.my.id/get_data_driver.php'),
        Uri.parse('http://10.0.2.2/mobpro/get_data_driver.php'),
        body: {'email': widget.email},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        setState(() {
          tempatAwal = jsonData['tempat_awal'] ?? '';
          tempatAkhir = jsonData['tempat_akhir'] ?? '';
          jamBerangkat = jsonData['jam_keberangkatan'] ?? '';
          tanggalBerangkat = jsonData['tanggal_keberangkatan'] ?? '';
          // Set the second activity item data
          data[1] = [
            AktivitasItem(
              kotaAsal: tempatAwal,
              kotaTujuan: tempatAkhir,
              jamAsal: jamBerangkat,
              jamTujuan: '', // You might want to adjust this based on your data structure
              tanggal: tanggalBerangkat,
            ),
          ];
        });
        print(tempatAwal);
        print(tempatAkhir);
        print(jamBerangkat);
        print(tanggalBerangkat);
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // List untuk setiap kategori
  final List<List<AktivitasItem>> data = [
    [], // Initialize an empty list for the first activity item
    [], // Initialize an empty list for the second activity item
    [], // Initialize an empty list for the third activity item
  ];

  int currentListIndex = 0;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<AktivitasItem> currentData = data[currentListIndex];

    final List<List<AktivitasItem>> pages = [];
    for (int i = 0; i < currentData.length; i += 4) {
      pages.add(currentData.sublist(
          i, i + 4 > currentData.length ? currentData.length : i + 4));
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF47A992),
          title: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Aktivitas",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 55,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10, left: 15, top: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentListIndex = index;
                          currentPage = 0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                        minimumSize: Size(100, 20),
                        backgroundColor: Color.fromARGB(255, 235, 235, 235),
                      ),
                      child: Text(
                        index == 0
                            ? 'Selanjutnya'
                            : (index == 1 ? 'Proses' : 'Selesai'),
                        style: TextStyle(
                            color: index == currentListIndex
                                ? Color.fromARGB(255, 66, 66, 66)
                                : Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: currentData.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data ditemukan',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: pages[currentPage].length +
                            (pages.length > 1 ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == pages[currentPage].length &&
                              pages.length > 1) {
                            // Tampilkan pagination
                            return Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  pages.length,
                                  (pageIndex) => Padding(
                                    padding: const EdgeInsets.only(
                                        top: 25.0, left: 3.0, right: 3.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          currentPage = pageIndex;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        padding: EdgeInsets.all(5.0),
                                        backgroundColor: currentPage ==
                                                pageIndex
                                            ? Color.fromARGB(255, 71, 169, 146)
                                            : Colors.white,
                                        minimumSize: Size(35, 50),
                                      ),
                                      child: Text(
                                        (pageIndex + 1).toString(),
                                        style: TextStyle(
                                          color: currentPage == pageIndex
                                              ? Colors.white
                                              : Color.fromARGB(
                                                  255, 71, 169, 146),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final item = pages[currentPage][index];
                            return GestureDetector(
                              onTap: () {
                                if (currentListIndex == 1) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapViewDriver(
                                        email: widget.email,
                                        ipAddress: widget.ipAddress,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 12.0),
                                width: 340,
                                height: 105,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '${item.jamAsal}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '${item.jamTujuan}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '${item.kotaAsal}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 71, 169, 146),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '>>',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 71, 169, 146),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '${item.kotaTujuan}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 71, 169, 146),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 22.0, bottom: 6.0),
                                        child: Text(
                                          '${item.tanggal}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 128, 128, 128),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AktivitasItem {
  final String kotaAsal;
  final String kotaTujuan;
  final String jamAsal;
  final String jamTujuan;
  final String tanggal;

  AktivitasItem({
    required this.kotaAsal,
    required this.kotaTujuan,
    required this.jamAsal,
    required this.jamTujuan,
    required this.tanggal,
  });
}
