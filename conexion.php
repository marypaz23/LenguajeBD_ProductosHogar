<?php
$usuario = "Emily";  
$password = "e123"; 
$host = "localhost/orcl";

$conn = oci_connect($usuario, $password, $host);

if (!$conn) {
    $error = oci_error();
    die("Error de conexión: " . $error['message']);
}else {
    echo "La conexion OKAY";
}
?>
