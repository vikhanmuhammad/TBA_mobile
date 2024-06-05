<?php
    $db = mysqli_connect('localhost', 'root', '','dbtba');
    if (!$db){
        echo "Database connection faild";
    }
?>