<?php
// Lucas 19042023 -  adicionado link para bootstrap.css e padraoCss.css
// Lucas 29032023 - modificado tempo da seção
// Lucas 09032023 -  linha 5, foi adicionado parametro de tempo 
// helio 26012023 16:16
if (session_status() === PHP_SESSION_NONE) {
	session_start();
}
include_once __DIR__ . "/../config.php";

if (!isset($_SESSION['LAST_ACTIVITY']) || !isset($_SESSION['usuario'])) {
        echo "<script>top.window.location = '" . URLROOT . "/sistema/login.php'</script>";
}

if (isset($_SESSION['LAST_ACTIVITY']) && (time() - $_SESSION['LAST_ACTIVITY'] > ($_SESSION['timeSessao'] * 60 * 60))) { // 60segundos * MINUTOS * HORAS
        session_unset();
        session_destroy();
        echo "<script>top.window.location = '" . URLROOT . "/sistema/login.php'</script>";
}

$_SESSION['LAST_ACTIVITY'] = time(); // update last activity time stamp
$logado = $_SESSION['usuario'];
// helio 051023 - retirado toda parte HTML, HEAD, que precisa ficar em cada programa
?>
