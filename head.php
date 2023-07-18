<?php
// Lucas 19042023 -  adicionado link para bootstrap.css e padraoCss.css
// Lucas 29032023 - modificado tempo da seção
// Lucas 09032023 -  linha 5, foi adicionado parametro de tempo 
// helio 26012023 16:16
session_start();
include_once __DIR__ . "/../config.php";

if (!isset($_SESSION['LAST_ACTIVITY']) || !isset($_SESSION['usuario'])) {
        echo "<script>top.window.location = '" . URLROOT . "/painel/login.php'</script>";
}

if (isset($_SESSION['LAST_ACTIVITY']) && (time() - $_SESSION['LAST_ACTIVITY'] > (2 * 60 * 60))) { // 60segundos * MINUTOS * HORAS
        session_unset();
        session_destroy();
        echo "<script>top.window.location = '" . URLROOT . "/painel/login.php'</script>";
}

$_SESSION['LAST_ACTIVITY'] = time(); // update last activity time stamp
$logado = $_SESSION['usuario'];



?>


<!DOCTYPE html>
<html>

<?php
        include_once ROOT. "/vendor/vendor.php";
?>