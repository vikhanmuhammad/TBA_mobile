import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'session_database.dart';
import 'dart:convert';
import 'dart:io';
import 'login.dart';

class ProfilDriver extends StatefulWidget {
  final String email;
  final String ipAddress;

  const ProfilDriver({Key? key, required this.email, required this.ipAddress}) : super(key: key);

  @override
  State<ProfilDriver> createState() => _ProfilDriverState();
}

class _ProfilDriverState extends State<ProfilDriver> {
  String namaDriver = '';
  String tgl_lahir = '';
  String nik = '';
  String nomor_sim = '';
  String? fotoProfile; // Menyimpan URL gambar

  @override
  void initState() {
    super.initState();
    fetchData(); // Panggil fungsi fetchData saat widget pertama kali dibuat
  }

  Future<void> fetchData() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.tba.transportberkaharmada.my.id/get_data_driver.php'),
        body: {'email': widget.email},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          namaDriver = data['nama_driver'] ?? '';
          tgl_lahir = data['tgl_lahir'] ?? '';
          nik = data['nik'] ?? '';
          nomor_sim = data['nomor_sim'] ?? '';
          //fotoProfile = data['foto_profile']; // Menyimpan URL gambar
        });
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  File? _image;

  Future<void> _getImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);

  if (pickedFile != null) {
    _image = File(pickedFile.path);
    
    // Mengirim gambar ke API
    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://${widget.ipAddress}/mobpro/profil_pick_image.php'));
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      request.fields['email'] = widget.email; // Menambahkan email ke request body
      request.fields['table'] = 'tbdriver'; // Atau 'tbdriver' sesuai dengan kebutuhan
      var response = await request.send();
      
      if (response.statusCode == 200) {
        // Gambar berhasil diunggah ke server
        print('Gambar berhasil diunggah');
        fetchData(); // Memuat ulang data profil setelah mengunggah gambar
      } else {
        // Gagal mengunggah gambar ke server
        print('Gagal mengunggah gambar');
      }
    } catch (error) {
      // Terjadi kesalahan saat mengunggah gambar
      print('Error: $error');
    }
  } else {
    print('No image selected.');
  }

  setState(() {}); // Update UI setelah gambar dipilih
}


  Future<void> _showImageOptions(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih sumber gambar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text('Ambil dari kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Ambil dari galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              "Profil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: ProfilDetail(
            email: widget.email,
            namaDriver: namaDriver,
            tgl_lahir: tgl_lahir,
            nik: nik,
            nomor_sim: nomor_sim,
            image: _image,
            fotoProfile: fotoProfile,
            getImage: _getImage,
          ),
        ),
      ),
    );
  }
}

class ProfilDetail extends StatelessWidget {
  final String email;
  final String namaDriver;
  final String tgl_lahir;
  final String nik;
  final String nomor_sim;
  final File? image;
  final String? fotoProfile; // URL gambar
  final Function(ImageSource) getImage;

  const ProfilDetail({
    required this.email,
    required this.namaDriver,
    required this.tgl_lahir,
    required this.nik,
    required this.nomor_sim,
    required this.image,
    required this.fotoProfile,
    required this.getImage,
  });

  Future<void> _showImageOptions(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih sumber gambar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text('Ambil dari kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    getImage(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Ambil dari galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 71, 169, 146),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: GestureDetector(
                    onTap: () {
                      _showImageOptions(context);
                    },
                    child: image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.file(
                              image!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (fotoProfile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network(
                                  'http://192.168.0.111/$fotoProfile', // Ganti dengan path server yang sesuai
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.account_circle,
                                size: 60,
                                color: Colors.white,
                              )),
                  ),
                ),
                SizedBox(width: 30),
                Expanded( // Menambahkan Expanded untuk menyesuaikan dengan baik
                  child: Text(
                    '$namaDriver - Driver',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                    overflow: TextOverflow.ellipsis, // Tambahan untuk teks yang terlalu panjang
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          _buildDetailRow('Email', email),
          _buildDetailRow('Tanggal Lahir', tgl_lahir),
          _buildDetailRow('NIK', nik),
          _buildDetailRow('Nomor SIM', nomor_sim),
          //SizedBox(height: 10),
          Center(
            child: ElevatedButton(
            onPressed: () {
              _showConfirmationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              minimumSize: Size(300, 20),
              backgroundColor: Colors.red,
            ),
            child: Text(
              "Keluar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            detail,
            style: TextStyle(
              color: Color.fromARGB(255, 71, 169, 146),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Divider(),
        SizedBox(height: 20),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () async{
                Navigator.of(context).pop();
                await SessionDatabase.instance.deleteSession();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Keluar"),
            ),
          ],
        );
      },
    );
  }
}
