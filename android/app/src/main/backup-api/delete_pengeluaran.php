<?php
include "koneksi.php";

$id = $_POST['id'];

$sql = "DELETE FROM tbkeuangan WHERE id_keuangan=?";
$stmt = $db->prepare($sql);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo "Record deleted successfully";
} else {
    echo "Error: " . $stmt->error;
}

$stmt->close();
$db->close();
?>
