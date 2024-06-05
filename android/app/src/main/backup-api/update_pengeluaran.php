<?php
    include "koneksi.php";

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $id = $_POST['id_keuangan'];
        $jenis = $_POST['jenis'];
        $jumlah = $_POST['jumlah'];
        $tanggal = $_POST['tanggal'];
        $id_armada = $_POST['id_armada'];

        // Handle file upload
        $target_dir = "uploads/";
        $target_file = $target_dir . basename($_FILES["foto_bukti"]["name"]);
        $uploadOk = 1;
        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

        // Check if image file is a actual image or fake image
        $check = getimagesize($_FILES["foto_bukti"]["tmp_name"]);
        if($check !== false) {
            $uploadOk = 1;
        } else {
            echo "File is not an image.";
            $uploadOk = 0;
        }

        // Check file size
        if ($_FILES["foto_bukti"]["size"] > 5000000) { // 5MB max file size
            echo "Sorry, your file is too large.";
            $uploadOk = 0;
        }

        // Allow certain file formats
        if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
        && $imageFileType != "gif" ) {
            echo "Sorry, only JPG, JPEG, PNG & GIF files are allowed.";
            $uploadOk = 0;
        }

        // Check if $uploadOk is set to 0 by an error
        if ($uploadOk == 0) {
            echo "Sorry, your file was not uploaded.";
        // if everything is ok, try to upload file
        } else {
            if (move_uploaded_file($_FILES["foto_bukti"]["tmp_name"], $target_file)) {
                echo "The file ". htmlspecialchars( basename( $_FILES["foto_bukti"]["name"])). " has been uploaded.";

                // Proceed with updating the database
                $sql = "UPDATE tbkeuangan SET jenis=?, jumlah=?, foto_bukti=?, tanggal=?, id_armada=? WHERE id_keuangan=?";
                $stmt = $db->prepare($sql);
                $stmt->bind_param("sssssi", $jenis, $jumlah, $target_file, $tanggal, $id_armada,  $id);

                if ($stmt->execute()) {
                    echo "Record updated successfully";
                } else {
                    echo "Error: " . $stmt->error;
                }

                $stmt->close();
            } else {
                echo "Sorry, there was an error uploading your file.";
            }
        }

        $db->close();
    }
?>