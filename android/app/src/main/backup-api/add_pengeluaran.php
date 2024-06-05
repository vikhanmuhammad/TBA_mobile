<?php
    include "koneksi.php"; // Sertakan file koneksi database

    // Fungsi untuk membersihkan data input
    function sanitize_input($data) {
        return htmlspecialchars(stripslashes(trim($data)));
    }

    // Periksa apakah permintaan adalah POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Ambil data formulir
        $jenis = sanitize_input($_POST['jenis']);
        $jumlah = sanitize_input($_POST['jumlah']);
        $tanggal = sanitize_input($_POST['tanggal']);
        $id_armada = sanitize_input($_POST['id_armada']);
        $jam = sanitize_input($_POST['jam']);
        
        // Unggahan file
        if (isset($_FILES['foto_bukti']) && $_FILES['foto_bukti']['error'] == 0) {
            $target_dir = "uploads/"; // Direktori tempat Anda ingin menyimpan file yang diunggah
            $target_file = $target_dir . basename($_FILES["foto_bukti"]["name"]);
            $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
            
            // Periksa apakah file gambar benar-benar gambar atau bukan
            $check = getimagesize($_FILES["foto_bukti"]["tmp_name"]);
            if($check !== false) {
                if (move_uploaded_file($_FILES["foto_bukti"]["tmp_name"], $target_file)) {
                    // File berhasil diunggah
                } else {
                    echo "Maaf, terjadi kesalahan saat mengunggah file Anda.";
                    exit;
                }
            } else {
                echo "File bukan gambar.";
                exit;
            }
        } else {
            echo "Tidak ada file yang diunggah atau terjadi kesalahan saat mengunggah file.";
            exit;
        }

        // Query SQL untuk memasukkan data
        $sql = "INSERT INTO tbkeuangan (jenis, jumlah, foto_bukti, jam, tanggal, id_armada) VALUES (?, ?, ?, ?, ?, ?)";
        $stmt = $db->prepare($sql);
        if ($stmt === false) {
            echo "Kesalahan saat menyiapkan statement: " . $db->error;
            exit;
        }

        // Bind parameter
        $stmt->bind_param("ssssss", $jenis, $jumlah, $target_file, $jam, $tanggal, $id_armada);

        if ($stmt->execute()) {
            echo "Catatan baru berhasil dibuat";
        } else {
            echo "Kesalahan: " . $stmt->error;
        }

        $stmt->close();
    } else {
        echo "Metode permintaan tidak valid";
    }

    $db->close();
?>