<?php 
    include 'koneksi.php'; 
    $response = []; 
    // Cek koneksi database 
    if(!$db){ 
        die("Koneksi database gagal: " . mysqli_connect_error()); 
    } if(isset($_GET['id_keuangan'])) { 
        $id = $_GET['id_keuangan']; 
        try { // Buat query 
            $sql = "SELECT * FROM tbkeuangan WHERE id_keuangan=$id"; 
            // Eksekusi query 
            $result = $db->query($sql); 
            // Handle error query 
            if(!$result){ 
                die("Query gagal: " . $db->error); 
            } // Ambil data 
            if($result->num_rows > 0) { 
                $row = $result->fetch_assoc(); 
                $response = $row; 
            } else { 
                $response['error'] = "Data tidak ditemukan"; 
            } 
        } catch (Exception $e) { 
            // Handle exception 
            $response['error'] = $e->getMessage(); 
        } finally { 
            // Jangan tutup result 
            // $result->close(); 
        } 
    } // Tutup koneksi setelah selesai proses 
    $db->close(); 
    echo json_encode($response); 
?>