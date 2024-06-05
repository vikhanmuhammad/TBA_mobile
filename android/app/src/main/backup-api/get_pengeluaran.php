<?php
    include "koneksi.php";
    
    $sql = "SELECT * FROM tbkeuangan";
    $result = $db->query($sql);
    
    $data = array();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    
    echo json_encode($data);
    
    $db->close();
?>
