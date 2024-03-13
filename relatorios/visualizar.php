<?php
// lucas 120320204 id884 bootstrap local - alterado head
// helio 03022023 - ajustes iniciais

include_once "../head.php";

$nomeArquivo = $_GET['nomeArquivo'];

?>

<!doctype html>
<html lang="pt-BR">
<head>

    <?php include_once ROOT . "/vendor/head_css.php"; ?>

</head>

<body class="bg-transparent">
	<div class="container-fluid">
		<div class="card shadow">
			<div class="card-header border-1">
				<div class="row">
					<div class="col-sm">
						<h3 class="col">PDF Relatório</h3>
					</div>
					<div class="col-sm" style="text-align:right">
						<a href="#" onclick="history.back()" role="button" class="btn btn-primary btn-sm">Voltar</a>
					</div>
				</div>
			</div>

			<div class="ExternalFiles full-width">
				<iframe class="container-fluid full-width" id="myIframe" src="<?php echo $nomeArquivo ?>" frameborder="0" scrolling="yes" height="550"></iframe>
			</div>

<!-- LOCAL PARA COLOCAR OS JS -->

<?php include_once ROOT . "/vendor/footer_js.php"; ?>

<!-- LOCAL PARA COLOCAR OS JS -FIM -->

</body>

</html>