<?php
// lucas 120320204 id884 bootstrap local - alterado head
include_once '../head.php';
?>

<!doctype html>
<html lang="pt-BR">
<head>

    <?php include_once ROOT . "/vendor/head_css.php"; ?>

</head>

<div class="container-fluid">
  <div class="row mt-3" ><!-- style="border: 1px solid #DFDFDF;" -->
    <div class="col-md-2 ">
      <ul class="nav nav-pills flex-column" id="myTab" role="tablist">
        <?php
        $stab = 'relqtdNovo';
        if (isset($_GET['stab'])) {
          $stab = $_GET['stab'];
        }
        //echo "<HR>stab=" . $stab;
        ?>
        <li class="nav-item ">
          <a class="nav-link ts-tabConfig <?php if ($stab == "relqtdNovo") {
            echo " active ";
          } ?>"
            href="?tab=relatorios&stab=relqtdNovo" role="tab" style="font-size:12px" >Liquidações diarias p/ periodo</a>
        </li>
        <li class="nav-item ">
          <a class="nav-link ts-tabConfig <?php if ($stab == "loj_cred01") {
            echo " active ";
          } ?>"
            href="?tab=relatorios&stab=loj_cred01" role="tab" style="font-size:12px" >Extrato de cobrança simples</a>
        </li>
        <li class="nav-item ">
          <a class="nav-link ts-tabConfig <?php if ($stab == "loj_cre01_ma") {
            echo " active ";
          } ?>"
            href="?tab=relatorios&stab=loj_cre01_ma" role="tab" style="font-size:12px" >Posição de cliente por periodo - A</a>
        </li>
        <li class="nav-item ">
          <a class="nav-link ts-tabConfig <?php if ($stab == "loj_cre01_lp") {
            echo " active ";
          } ?>"
            href="?tab=relatorios&stab=loj_cre01_lp" role="tab" style="font-size:12px" >Posição de cliente por periodo - B</a>
        </li>
        <li class="nav-item ">
          <a class="nav-link ts-tabConfig <?php if ($stab == "anavenlj") {
            echo " active ";
          } ?>"
            href="?tab=relatorios&stab=anavenlj" role="tab" style="font-size:12px" >Conferência notas de transfêrencia</a>
        </li>
        <li class="nav-item ">
          <a class="nav-link ts-tabConfig <?php if ($stab == "vendas_nfce") {
            echo " active ";
          } ?>"
            href="?tab=relatorios&stab=vendas_nfce" role="tab" style="font-size:12px" >Vendas NFCE</a>
        </li>
        <li class="nav-item ">
          <a class="nav-link ts-tabConfig <?php if ($stab == "resliqnov") {
            echo " active ";
          } ?>"
            href="?tab=relatorios&stab=resliqnov" role="tab" style="font-size:12px" >Resumo liquidações p/periodo Novação</a>
        </li>
        <li class="nav-item ">
          <a class="nav-link ts-tabConfig <?php if ($stab == "pogersin11") {
            echo " active ";
          } ?>"
            href="?tab=relatorios&stab=pogersin11" role="tab" style="font-size:12px" >Posição financeira vencidos/a vencer</a>
        </li>

      </ul>
    </div>
    <div class="col-md-10">
      <?php
          $ssrc = "";

          if ($stab == "loj_cred01") {
            $ssrc = "loj_cred01.php";
          }
          if ($stab == "loj_cre01_ma") {
            $ssrc = "loj_cre01_ma.php";
          }
          if ($stab == "loj_cre01_lp") {
            $ssrc = "loj_cre01_lp.php";
          }
          if ($stab == "anavenlj") {
            $ssrc = "anavenlj.php";
          }
          if ($stab == "vendas_nfce") {
            $ssrc = "vendas_nfce.php";
          }
          if ($stab == "resliqnov") {
            $ssrc = "resliqnov.php";
          }
          if ($stab == "pogersin11") {
            $ssrc = "pogersin11.php";
          }
          if ($stab == "relqtdNovo") {
            $ssrc = "relqtdNovo.php";
          }

          if ($ssrc !== "") {
            //echo $ssrc;
            include($ssrc);
          }

      ?>

    </div>
  </div>



</div>
<!-- /.container -->

<!-- LOCAL PARA COLOCAR OS JS -->

<?php include_once ROOT . "/vendor/footer_js.php"; ?>

<!-- LOCAL PARA COLOCAR OS JS -FIM -->