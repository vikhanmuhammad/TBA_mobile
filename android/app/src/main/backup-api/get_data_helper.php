<?php
    include "koneksi.php";

    // Terima email dari POST request
    $email = $_POST['email'];

    // Query untuk mencari data driver berdasarkan email
    $sql = "SELECT tbhelper.nama_helper, tbhelper.tgl_lahir, tbhelper.nik, tbhelper.foto_profile, tbarmada.julukan, tbarmada.nomor_body, tbarmada.plat_depan, tbarmada.nomor_plat, tbarmada.plat_belakang, tbarmada.tempat_awal, tbarmada.tempat_akhir, tbarmada.jam_keberangkatan, tbarmada.tanggal_keberangkatan, tbarmada.status, tbarmada.penumpang
    FROM tbhelper 
    INNER JOIN tbarmada ON tbhelper.id_helper = tbarmada.id_helper 
    WHERE tbhelper.email = '".$email."'";

    // Lakukan query ke database
    $result = mysqli_query($db, $sql);

    // Cek apakah ada hasil dari query
    if (mysqli_num_rows($result) > 0) {
        // Ambil baris pertama dari hasil query
        $row = mysqli_fetch_assoc($result);

        // Simpan data dalam sebuah array
        $datahelper = array(
            'nama_helper' => $row['nama_helper'],
            'tgl_lahir' => $row['tgl_lahir'],
            'nik' => $row['nik'],
            //'foto_profile' => $row['foto_profile'], // Menambahkan URL gambar
            'julukan' => $row['julukan'],
            'nomor_body' => $row['nomor_body'],
            'plat_depan' => $row['plat_depan'],
            'nomor_plat' => $row['nomor_plat'],
            'plat_belakang' => $row['plat_belakang'],
            'tempat_awal' => $row['tempat_awal'],
            'tempat_akhir' => $row['tempat_akhir'],
            'jam_keberangkatan' => $row['jam_keberangkatan'],
            'tanggal_keberangkatan' => $row['tanggal_keberangkatan'],
            'status' => $row['status'],
            'penumpang' => $row['penumpang']
        );

        // Kembalikan data dalam format JSON
        echo json_encode($datahelper);
    } else {
        // Jika tidak ditemukan data helper untuk email yang diberikan, kembalikan pesan error
        echo json_encode(array('status' => 'error', 'message' => 'Data helper tidak ditemukan.'));
    }
?>
