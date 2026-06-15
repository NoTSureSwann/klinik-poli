<?php
$host = '127.0.0.1';
$db = 'klinik_db';
$user = 'root';
$pass = ''; // Default laragon

try {
    $pdo = new PDO("mysql:host=$host;charset=utf8", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $sql = file_get_contents('klinik_db.sql');
    $pdo->exec($sql);
    
    echo "Migration successful!";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
