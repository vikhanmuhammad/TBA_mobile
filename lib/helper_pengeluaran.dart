import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PengeluaranHelper extends StatefulWidget {
  final String kotaAsal;
  final String kotaTujuan;
  final String penumpang;
  final String ipAddress;

  const PengeluaranHelper(
      {Key? key,
      required this.kotaAsal,
      required this.kotaTujuan,
      required this.penumpang,
      required this.ipAddress})
      : super(key: key);

  @override
  State<PengeluaranHelper> createState() => _PengeluaranHelperState();
}

class _PengeluaranHelperState extends State<PengeluaranHelper> {
  List<dynamic> _items = [];
  TextEditingController _dateController = TextEditingController();
  TextEditingController _jenisController = TextEditingController();
  TextEditingController _hargaController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _jenisController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2/mobpro/get_pengeluaran.php'));
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      try {
        setState(() {
          _items = jsonDecode(response.body);
        });
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  late File _image;
  final picker = ImagePicker();
  String? imageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('Tidak ada gambar yang dipilih');
      }
    });
  }

  Future<void> createPengeluaran(
      String jenis, String jumlah, String tanggal, File image) async {
    final jam = DateTime.now().toString().split(' ')[1];
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://10.0.2.2/mobpro/add_pengeluaran.php'));

    request.fields['jenis'] = jenis;
    request.fields['jumlah'] = jumlah;
    request.fields['jam'] = jam;
    request.fields['tanggal'] = tanggal;
    request.fields['id_armada'] = '3';
    request.files
        .add(await http.MultipartFile.fromPath('foto_bukti', image.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      _jenisController.clear();
      _hargaController.clear();
      _dateController.clear();
      fetchData(); // Memperbarui data setelah menambahkan pengeluaran baru
      print('Pengeluaran berhasil ditambahkan');
    } else {
      print('Gagal menambahkan pengeluaran');
    }
  }

  Future<Map> fetchDataById(int id_keuangan) async {
    final response = await http.get(Uri.parse(
        'http://10.0.2.2/mobpro/get_pengeluaranbyid.php?id_keuangan=$id_keuangan'));
    print('Response body: ${response.body}');

    var map = jsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return map;
      } catch (e) {
        print(e);
        print(response.body);
        return map;
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> updatePengeluaran(int id, String jenis, String jumlah,
      String tanggal, File? fotoBukti) async {
    var uri = Uri.parse('http://10.0.2.2/mobpro/update_pengeluaran.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields['id_keuangan'] = id.toString();
    request.fields['jenis'] = jenis;
    request.fields['jumlah'] = jumlah;
    request.fields['tanggal'] = tanggal;
    request.fields['id_armada'] = '3';

    if (fotoBukti != null) {
      var stream = http.ByteStream(fotoBukti.openRead());
      var length = await fotoBukti.length();
      var multipartFile = http.MultipartFile('foto_bukti', stream, length,
          filename: fotoBukti.path.split('/').last);
      request.files.add(multipartFile);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Data pengeluaran berhasil diupdate');
      await fetchData();
    } else {
      print('Gagal mengupdate data pengeluaran');
    }
  }

  Future<void> deletePengeluaran(int id) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/mobpro/delete_pengeluaran.php'),
      body: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      // Data berhasil dihapus
      print('Data pengeluaran berhasil dihapus');
      fetchData(); // Refresh data setelah menghapus pengeluaran
    } else {
      // Gagal menghapus data
      print('Gagal menghapus data pengeluaran');
    }
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
          title: Text(
            "Pengeluaran",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
            },
          ),
        ),
        body: buildPageView(
            context, widget.kotaAsal, widget.kotaTujuan, widget.penumpang),
        floatingActionButton: buildFloatingActionButton(context),
      ),
    );
  }

  Widget buildPageView(BuildContext context, String kotaAsal, String kotaTujuan,
      String penumpang) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            children: [
              buildExpenseContainer(context, kotaAsal, kotaTujuan, penumpang),
            ],
          ),
        ),
      ],
    );
  }

  // info penumpang
  Widget buildExpenseContainer(BuildContext context, String kotaAsal,
      String kotaTujuan, String penumpang) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 125,
                      child: Text(
                        'Kota Awal',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '${kotaAsal}',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black),
                    ),
                  ],
                )),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 125,
                      child: Text(
                        'Kota Tujuan',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '${kotaTujuan}',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black),
                    ),
                  ],
                )),
            SizedBox(
              height: 10,
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jumlah Penumpang',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '30',
                    style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            buildExpenseInfo(context),
            // buildExpenseList(context),
          ],
        ),
      ),
    );
  }

  Widget buildExpenseRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // info pengeluaran
  Widget buildExpenseInfo(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: 320,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Tanggal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Jenis',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Rp. ${item['jumlah']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 71, 169, 146),
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          item['tanggal'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 71, 169, 146),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item['jenis'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 71, 169, 146),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Row(
                                      children: [
                                        Text(
                                          'Bukti Pengeluaran',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Spacer(),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (item['foto_bukti'] != null)
                                            Image.network(
                                              "http://10.0.2.2/mobpro/${item['foto_bukti']}",
                                              height: 300,
                                              width: 300,
                                            )
                                          else
                                            Text(
                                                'Tidak ada bukti yang diunggah'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 71, 169, 146),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              showUpdateModal(
                                context,
                                int.parse(item['id_keuangan']),
                              );
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 71, 169, 146),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              deletePengeluaran(
                                int.parse(item['id_keuangan']),
                              );
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // modal untuk mengubah pengeluaran
  void showUpdateModal(BuildContext context, int id) async {
    Map item = await fetchDataById(id);

    _jenisController.text = item['jenis'];
    _hargaController.text = item['jumlah'].toString();
    _dateController.text = item['tanggal'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Text(
                'Ubah Pengeluaran',
                style: TextStyle(color: Colors.black),
              ),
              Spacer(),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Tanggal',
                      labelStyle: TextStyle(color: Colors.black)),
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(color: Colors.black),
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                  controller: _dateController,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Jenis Pengeluaran',
                      labelStyle: TextStyle(color: Colors.black)),
                  keyboardType: TextInputType.text,
                  style: TextStyle(color: Colors.black),
                  controller: _jenisController,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Harga',
                      labelStyle: TextStyle(color: Colors.black)),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.black),
                  controller: _hargaController,
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Color.fromARGB(255, 71, 169, 146),
                    ),
                    child: Text(
                      'Upload Bukti',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        updatePengeluaran(
                          int.parse(item['id_keuangan']),
                          _jenisController.text,
                          _hargaController.text,
                          _dateController.text,
                          _image,
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: Color.fromARGB(255, 71, 169, 146),
                      ),
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // tombol tambah bukti
  Widget buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Text(
                    'Tambah Pengeluaran',
                    style: TextStyle(color: Colors.black),
                  ),
                  Spacer(),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Tanggal',
                          labelStyle: TextStyle(color: Colors.black)),
                      keyboardType: TextInputType.datetime,
                      style: TextStyle(color: Colors.black),
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                      controller: _dateController,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Jenis Pengeluaran',
                          labelStyle: TextStyle(color: Colors.black)),
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.black),
                      controller: _jenisController,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Harga',
                          labelStyle: TextStyle(color: Colors.black)),
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.black),
                      controller: _hargaController,
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: Color.fromARGB(255, 71, 169, 146),
                        ),
                        child: Text(
                          'Upload Bukti',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            createPengeluaran(
                              _jenisController.text,
                              _hargaController.text,
                              _dateController.text,
                              _image,
                            );
                            Navigator.pop(context); // Tutup modal
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            backgroundColor: Color.fromARGB(255, 71, 169, 146),
                          ),
                          child: Text(
                            'Kirim',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Icon(Icons.add, color: Colors.white),
      backgroundColor: Color.fromARGB(255, 71, 169, 146),
    );
  }
}
