<?php
    include "koneksi.php";

    // Terima email dari POST request
    $email = $_POST['email'];

    // Query untuk mencari data driver berdasarkan email
    $sql = "SELECT tbdriver.nama_driver, tbdriver.tgl_lahir, tbdriver.nik, tbdriver.nomor_sim, tbdriver.foto_profile, tbarmada.julukan, tbarmada.nomor_body, tbarmada.plat_depan, tbarmada.nomor_plat, tbarmada.plat_belakang, tbarmada.tempat_awal, tbarmada.tempat_akhir, tbarmada.jam_keberangkatan, tbarmada.tanggal_keberangkatan, tbarmada.status
    FROM tbdriver 
    INNER JOIN tbarmada ON tbdriver.id_driver = tbarmada.id_driver 
    WHERE tbdriver.email = '".$email."'";

    // Lakukan query ke database
    $result = mysqli_query($db, $sql);

    // Cek apakah ada hasil dari query
    if (mysqli_num_rows($result) > 0) {
        // Ambil baris pertama dari hasil query
        $row = mysqli_fetch_assoc($result);

        // Simpan data dalam sebuah array
        $dataDriver = array(
            'nama_driver' => $row['nama_driver'],
            'tgl_lahir' => $row['tgl_lahir'],
            'nik' => $row['nik'],
            'nomor_sim' => $row['nomor_sim'],
            //'foto_profile' => $row['foto_profile'],
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
        );

        // Kembalikan data dalam format JSON
        echo json_encode($dataDriver);
    } else {
        // Jika tidak ditemukan data driver untuk email yang diberikan, kembalikan pesan error
        echo json_encode("Error: Data driver tidak ditemukan");
    }
?>
