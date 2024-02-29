<!DOCTYPE html>
<head>
        <title>Relatórios</title>
</head>
<html>

<?php
include_once __DIR__ . "/../config.php";
include_once ROOT . "/sistema/painel.php";
include_once ROOT . "/sistema/database/loginAplicativo.php";

$nivelMenuLogin = buscaLoginAplicativo($_SESSION['idLogin'], 'Relatorios');

$nivelMenu = $nivelMenuLogin['nivelMenu'];



?>


<div class="container-fluid mt-1">
    <div class="row">
        <div class="col-md-12 d-flex justify-content-center">
            <ul class="nav a" id="myTabs">


                <?php
                $tab = '';

                if (isset($_GET['tab'])) {
                    $tab = $_GET['tab'];
                }

                ?>


                <?php if ($nivelMenu >= 1) {
                    if ($tab == '') {
                        $tab = 'relatorios';
                    } ?>
                    <li class="nav-item mr-1">
                        <a class="nav-link1 nav-link <?php if ($tab == "relatorios") {
                            echo " active ";
                        } ?>"
                            href="?tab=relatorios" role="tab" data-toggle="tooltip" data-placement="top"
                            title="Relatórios">Relatórios</a>
                    </li>
                <?php } ?>
            </ul>

        </div>

    </div>

</div>

<?php
$src = "";

if ($tab == "relatorios") {
    $src = "relatorios/";
    if (isset($_GET['stab'])) {
        $src = $src . "?stab=" . $_GET['stab'];
    }
}

if ($src !== "") {
    //echo URLROOT ."/relatorios/". $src;
    ?>
    <div class="diviFrame">
        <iframe class="iFrame container-fluid " id="iFrameTab"
            src="<?php echo URLROOT ?>/relatorios/<?php echo $src ?>"></iframe>
    </div>
    <?php
}
?>

</body>

</html>