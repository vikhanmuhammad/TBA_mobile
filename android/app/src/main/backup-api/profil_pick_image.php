<?php

// Set header untuk mengizinkan akses dari semua domain (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// File koneksi.php
require_once('koneksi.php');

// Memeriksa apakah metode yang digunakan adalah POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Memeriksa apakah ada file yang dikirim, email, dan table yang dikirim
    if (isset($_FILES['image']['name']) && isset($_POST['email']) && isset($_POST['table'])) {
        // Mendapatkan informasi file yang dikirim
        $file_name = $_FILES['image']['name'];
        $file_tmp = $_FILES['image']['tmp_name'];
        $file_size = $_FILES['image']['size'];
        $file_error = $_FILES['image']['error'];

        // Mendapatkan email dan table dari POST
        $email = $_POST['email'];
        $table = $_POST['table'];

        // Menentukan lokasi penyimpanan gambar (dalam kasus ini, uploads/ di direktori proyek)
        $upload_dir = 'uploads/';
        $file_destination = $upload_dir . $file_name;

        // Memindahkan file ke direktori yang ditentukan
        if (move_uploaded_file($file_tmp, $file_destination)) {
            // Menentukan query berdasarkan tabel yang dipilih
            if ($table === 'tbhelper' || $table === 'tbdriver') {
                $query = "UPDATE $table SET foto_profile = '$file_destination' WHERE email = '$email'";
                if (mysqli_query($db, $query)) {
                    echo json_encode(array('status' => 'success', 'message' => 'Gambar berhasil diunggah.', 'file_path' => $file_destination));
                } else {
                    echo json_encode(array('status' => 'error', 'message' => 'Gagal menyimpan path file ke database.'));
                }
            } else {
                echo json_encode(array('status' => 'error', 'message' => 'Tabel tidak valid.'));
            }
        } else {
            echo json_encode(array('status' => 'error', 'message' => 'Gagal menyimpan file ke server.'));
        }
    } else {
        echo json_encode(array('status' => 'error', 'message' => 'Tidak ada file, email, atau tabel yang dikirim.'));
    }
} else {
    echo json_encode(array('status' => 'error', 'message' => 'Metode yang digunakan tidak diizinkan.'));
}

?>
