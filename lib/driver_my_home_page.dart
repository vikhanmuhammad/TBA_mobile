import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'driver_map.dart';

class MyHomePageDriver extends StatefulWidget {
  final String email;
  final String ipAddress;
  const MyHomePageDriver({Key? key, required this.title, required this.email, required this.ipAddress}) : super(key: key);

  final String title;

  @override
  State<MyHomePageDriver> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePageDriver> {
  late DateTime currentTime = DateTime.now();
  String namaDriver = '';
  String julukan = '';
  String noBody = '';
  String platDepan = '';
  String noPlat = '';
  String platBelakang = '';
  String tempatAwal = '';
  String tempatAkhir = '';
  String jamBerangkat = '';
  String tanggalBerangkat = '';

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now();
    fetchData(); // Panggil fungsi fetchData saat widget pertama kali dibuat
  }

  Future<void> fetchData() async { // Langkah 2: Buat fungsi async untuk mengambil data dari server
    try {
      final response = await http.post(
        Uri.parse('https://api.tba.transportberkaharmada.my.id/get_data_driver.php'), // Ganti dengan URL server Anda
        body: {'email': widget.email}, // Kirim email ke server
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          namaDriver = data['nama_driver'] ?? '';
          julukan = data['julukan'] ?? '';
          noBody = data['nomor_body'] ?? '';
          platDepan = data['plat_depan'] ?? '';
          noPlat = data['nomor_plat'] ?? '';
          platBelakang = data['plat_belakang'] ?? '';
          tempatAwal = data['tempat_awal'] ?? '';
          tempatAkhir = data['tempat_akhir'] ?? '';
          jamBerangkat = data['jam_keberangkatan'] ?? '';
          tanggalBerangkat = data['tanggal_keberangkatan'] ?? '';
        });
        print(julukan);
        print(noBody);
        print(platDepan);
        print(noPlat);
        print(platBelakang);
        print(tempatAwal);
        print(tempatAkhir);
        print(jamBerangkat);
        print(tanggalBerangkat);
      } else {
        throw Exception('Gagal mengambil data'); // Tangani kesalahan jika permintaan gagal
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 71, 169, 146),
      body: Center(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 55),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${_getHari(currentTime.weekday)}, ${currentTime.day} ${_getBulan(currentTime.month)} ${currentTime.year}\n',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Selamat Pagi, \n',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            TextSpan(
                              text: '$namaDriver!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 150),
                    Expanded(
                      child: Container(
                        width: screenWidth,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 243, 243, 243),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        height: 350,
                        width: screenWidth - 50,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0, top: 30.0),
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Perjalanan\n',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Kota Awal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$tempatAwal\n',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Kota Tujuan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$tempatAkhir\n',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Jam',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '$jamBerangkat WIB',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tanggal',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '$tanggalBerangkat',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25), // Jarak antara jam/tanggal dan tombol
                            Center( // Tempatkan tombol di tengah
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapViewDriver(email: widget.email, ipAddress: widget.ipAddress,),
                                    ),
                                  );
                                },
                                // Warna teks tombol saat di atas latar belakang
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 71, 169, 146),
                                  minimumSize: Size((screenWidth - 125), 50), // Ukuran minimum tombol (panjang, lebar)
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Border radius tombol
                                  ),
                                ),
                                child: const Text(
                                  'Selengkapnya',
                                  style: TextStyle(
                                    fontSize: 18, // Ukuran teks tombol
                                    color: Colors.white, // Warna teks tombol
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Align(
                        alignment: Alignment.centerLeft, // Geser teks ke kiri
                        child: Padding(
                          padding: EdgeInsets.only(left: 40.0), // Padding kiri 30.0
                          child: Text(
                            'Armada',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        height: 100,
                        width: screenWidth - 75, // Atur lebar container tambahan
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // Warna shadow
                              spreadRadius: 4, // Jarak penyebaran shadow
                              blurRadius: 5, // Tingkat blur shadow
                              offset: const Offset(0, 0), // Posisi shadow
                            ),
                          ],
                        ), 
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 15.0), // Padding kiri 20
                                child: CircleAvatar(
                                  radius: 35, // Ukuran radius lingkaran
                                  backgroundColor: Colors.grey, // Warna latar belakang lingkaran
                                  // Isi lingkaran di sini (misalnya, gambar)
                                ),
                              ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15.0, top: 15.0), // Padding kiri 20
                                      child: Text(
                                              'Julukan',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15.0), // Padding kiri 20
                                      child: Text(
                                              '$julukan',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 71, 169, 146),
                                              ),
                                            ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                child: Text(
                                                  'No Body',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: 15.0),
                                                  child: Text(
                                                  '$noBody',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(left: 15.0, top: 5.0),
                                                child: Text(
                                                  'Plat No',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: 15.0),
                                                  child: Text(
                                                  '$platDepan $noPlat $platBelakang',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ), 
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              // Anda dapat menambahkan konten lain di sini
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  String _getHari(int day) {
    switch (day) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  String _getBulan(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }
}
