import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MapViewDriver extends StatefulWidget {
  final String email;
  final String ipAddress;
  MapViewDriver({Key? key, required this.email, required this.ipAddress})
      : super(key: key);

  @override
  State<MapViewDriver> createState() => _MapViewDriverState();
}

class _MapViewDriverState extends State<MapViewDriver> {
  List<LatLng> routepoints = [];
  MapController mapController = MapController();

  String julukan = '';
  String noBody = '';
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
    // Langkah 2: Buat fungsi async untuk mengambil data dari server
    try {
      final response = await http.post(
        Uri.parse(
            // 'https://api.tba.transportberkaharmada.my.id/get_data_driver.php'), // Ganti dengan URL server Anda
            'http://10.0.2.2/mobpro/get_data_driver.php'), // Ganti dengan URL server Anda
        body: {'email': widget.email}, // Kirim email ke server
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          julukan = data['julukan'] ?? '';
          noBody = data['nomor_body'] ?? '';
          tempatAwal = data['tempat_awal'] ?? '';
          tempatAkhir = data['tempat_akhir'] ?? '';
          jamBerangkat = data['jam_keberangkatan'] ?? '';
          tanggalBerangkat = data['tanggal_keberangkatan'] ?? '';
        });

        // Ambil koordinat dari alamat tempat awal dan akhir
        List<Location> startLoc = await locationFromAddress(tempatAwal);
        List<Location> endLoc = await locationFromAddress(tempatAkhir);

        var startLat = startLoc[0].latitude;
        var startLng = startLoc[0].longitude;
        var endLat = endLoc[0].latitude;
        var endLng = endLoc[0].longitude;

        var url = Uri.parse(
            'http://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$endLng,$endLat?steps=true&annotations=true&geometries=geojson&overview=full');
        var resp = await http.get(url);

        setState(() {
          routepoints = [];
          var routes =
              jsonDecode(resp.body)['routes'][0]['geometry']['coordinates'];
          for (var route in routes) {
            routepoints.add(LatLng(route[1], route[0]));
          }

          // Set posisi peta agar berpusat pada rute
          if (routepoints.isNotEmpty) {
            mapController.move(
                routepoints[0], 10); // Ganti zoom level sesuai kebutuhan
          }
        });
      } else {
        throw Exception(
            'Gagal mengambil data'); // Tangani kesalahan jika permintaan gagal
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF47A992),
          title: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Peta",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: ListView(
          children: [
            Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Stack(
                    children: [
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SingleChildScrollView(
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 500,
                                  width: 400,
                                  child: FlutterMap(
                                    mapController: mapController,
                                    options: MapOptions(
                                      center: routepoints.isNotEmpty
                                          ? routepoints[0]
                                          : LatLng(0, 0),
                                      zoom: 10,
                                    ),
                                    nonRotatedChildren: [
                                      AttributionWidget.defaultWidget(
                                        source: 'OpenStreetMap contributors',
                                        onSourceTapped: null,
                                      ),
                                    ],
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'com.example.app',
                                      ),
                                      if (routepoints.isNotEmpty)
                                        PolylineLayer(
                                          polylines: [
                                            Polyline(
                                              points: routepoints,
                                              color: Colors.blue,
                                              strokeWidth: 4,
                                            ),
                                          ],
                                        ),
                                      if(routepoints.isNotEmpty)
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              width: 80.0,
                                              height: 80.0,
                                              point: routepoints.isNotEmpty
                                                  ? routepoints.last
                                                  : LatLng(0, 0),
                                              builder: (ctx) => Container(
                                                child: Icon(
                                                  Icons.location_on,
                                                  color: Colors.red,
                                                  size: 50.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top:15.0, right: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            mapController.move(
                                                mapController.center,
                                                mapController.zoom + 0.5);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets
                                                .zero, // Set padding menjadi 0
                                            shape:
                                                CircleBorder(), // Bentuk tombol menjadi lingkaran
                                            backgroundColor: Colors.white// Warna teks
                                          ),
                                          child: Icon(Icons.add, color: Colors.black,)),
                                      ElevatedButton(
                                          onPressed: () {
                                            mapController.move(
                                                mapController.center,
                                                mapController.zoom - 0.5);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets
                                                .zero, // Set padding menjadi 0
                                            shape:
                                                CircleBorder(), // Bentuk tombol menjadi lingkaran
                                            backgroundColor: Colors.white// Warna teks
                                          ),
                                          child: Icon(Icons.remove, color: Colors.black,)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildDetailContainer(context),
                      _buildText('$noBody', screenWidth - 300, 375, 16,
                          FontWeight.w600, Color(0xFF5B5B5B)),
                      _buildText('$julukan', screenWidth - 300, 400, 12,
                          FontWeight.w600, Color(0xFF5B5B5B)),
                      _buildText('$tanggalBerangkat', screenWidth - 115, 380,
                          12, FontWeight.w600, Color(0xFF737373)),
                      _buildText('$jamBerangkat WIB', screenWidth - 125, 400,
                          12, FontWeight.w600, Color(0xFF737373)),
                      _buildText('Detail Perjalanan', 25, 470, 14,
                          FontWeight.w600, Colors.black.withOpacity(0.5)),
                      _buildDivider(450, context),
                      _buildRotatedContainer(35, 532, 55, 1, 1),
                      _buildDotWithIcon(
                          25, 505, Icons.location_on, Color(0xFF47A992)),
                      _buildVerticalLine(35, 525, 650),
                      _buildDotWithIcon(
                          25, 570, Icons.location_on, Color(0xFF47A992)),
                      //_buildImage("assets/img/pandawa.jpg", 10, 410, 55, 43),
                      _buildText('Lokasi Keberangkatan', 55, 500, 12,
                          FontWeight.w600, Colors.black.withOpacity(0.5)),
                      _buildText('$tempatAwal', 55, 520, 12, FontWeight.w500,
                          Colors.black),
                      // _buildText('Lokasi Tujuan - 152 km', 55, 565, 12,
                      //     FontWeight.w600, Colors.black.withOpacity(0.5)),
                      _buildText('$tempatAkhir', 55, 585, 12, FontWeight.w500,
                          Colors.black),
                      Container(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(
    String text,
    double left,
    double top,
    double fontSize,
    FontWeight fontWeight,
    Color color, // Mengganti tipe data menjadi Color
  ) {
    return Positioned(
      left: left,
      top: top,
      child: Text(
        text,
        style: TextStyle(
          color: color, // Menggunakan warna yang diberikan
          fontSize: fontSize,
          fontFamily: 'Poppins',
          fontWeight: fontWeight,
          height: 0,
        ),
      ),
    );
  }

  Widget _buildDivider(double top, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      left: 0,
      top: top,
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1,
              color: Colors.black.withOpacity(0.25),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRotatedContainer(
    double left,
    double top,
    double width,
    double height,
    double angle,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotWithIcon(
      double left, double top, IconData iconData, Color dotColor) {
    return Positioned(
      left: left,
      top: top,
      child: Stack(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: ShapeDecoration(
              color: dotColor,
              shape: CircleBorder(),
            ),
          ),
          Center(
            child: Icon(
              iconData,
              color: Colors.white,
              size: 20, // Sesuaikan dengan ukuran yang diinginkan
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(
    String
        imagePath, // Menggunakan string untuk mewakili path relatif dari gambar
    double left,
    double top,
    double width,
    double height,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        // child: Image.asset(
        //   "assets/img/pandawa.jpg", // Menggunakan Image.asset dengan path relatif dari gambar
        //   fit: BoxFit.fill,
        // ),
      ),
    );
  }

  Widget _buildHeaderContainer(
      double left, double top, double width, double height, Color color) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: color),
      ),
    );
  }

  Widget _buildInputContainer(double left, double top, double width,
      double height, double borderRadius, Color color) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContainer(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      left: 0,
      top: 340,
      child: Container(
        width: screenWidth,
        height: screenHeight - 50,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 10,
              offset: Offset(0, 2),
              spreadRadius: 9,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    double left,
    double top,
    double width,
    double height,
    String text,
    double textLeft,
    double textTop,
    double fontSize,
    FontWeight fontWeight,
    Color textColor, // Menambahkan parameter untuk warna teks
    int color, // Mengganti tipe data menjadi int
  ) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Color(color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          shadows: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 1),
              spreadRadius: 0,
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor, // Menggunakan warna teks yang ditentukan
              fontSize: fontSize,
              fontFamily: 'Poppins',
              fontWeight: fontWeight,
              height: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalLine(double startX, double startY, double endY) {
    return Positioned(
      left: startX,
      top: startY,
      child: CustomPaint(
        size: Size(1, endY - startY), // Lebar garis adalah 1 pixel
        painter: VerticalLinePainter(),
      ),
    );
  }
}

class VerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black // Warna garis
      ..strokeWidth = 1; // Lebar garis

    // Gambar garis vertikal
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

