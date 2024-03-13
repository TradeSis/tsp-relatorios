<?php
// lucas 120320204 id884 bootstrap local - alterado head
// gabriel 09022023 15:35

include_once '../head.php';
include_once '../database/relatorios.php';

$progcod="loj_cre01_ma";
$relatorios = buscaRelatorios($progcod);
?>

<!doctype html>
<html lang="pt-BR">
<head>

    <?php include_once ROOT . "/vendor/head_css.php"; ?>

</head>

<body class="bg-transparent">

    <div class="container-fluid mt-3">
        <div class="card">
            <div class="card-header">
                <div class="row">
                    <div class="col-10">
                        <h3 class="col">Posição cliente por periodo - A</h3>
                    </div>
                    <div class="col-1" style="text-align:right">
                        <a href="#" role="button" class="btn btn-info btn-sm" style="margin-left:-20px" onClick="window.location.reload()">
                            Atualizar
                        </a>
                    </div>
                    <div class="col-1" style="text-align:right">
                        <a href="loj_cre01_ma_inserir.php" role="button" class="btn btn-success btn-sm">Novo</a>
                    </div>
                </div>
            </div>
        </div>
        <div class="table table-responsive">
            <table class="table table-sm table-hover table-bordered">
                <thead class="thead-light">
                    <tr>
                        <th class="text-center">ID</th>
                        <th class="text-center">Usuário</th>
                        <th class="text-center">Data</th>
                        <th class="text-center">Hora</th>
                        <th class="text-center">Nome do relatório</th>
                        <th class="text-center">Nome do arquivo</th>
                        <th class="text-center">REMOTE_ADDR</th>
                        <th class="text-center">Parâmetros</th>
                        <th class="text-center">PDF</th>
                    </tr>
                </thead>
                <?php
                if (!empty($relatorios)) {
                foreach ($relatorios as $relatorio) {
                ?>
                    <tr>
                        <td class="text-center"><?php echo $relatorio['IDRelat'] ?></td>
                        <td class="text-center"><?php echo $relatorio['usercod'] ?></td>
                        <td class="text-center"><?php echo date('d/m/Y', strtotime($relatorio['dtinclu'])) ?></td>
                        <td class="text-center"><?php echo $relatorio['hrinclu'] ?></td>
                        <td class="text-center"><?php echo $relatorio['progcod'] ?></td>
                        <td class="text-center"><?php echo $relatorio['nomeArquivo'] ?></td>
                        <td class="text-center"><?php echo $relatorio['REMOTE_ADDR'] ?></td>
                        <td class="text-center">
                            <a class="btn btn-sm" href="#" data-toggle="modal" data-target="#parametros-modal-<?php echo $relatorio['IDRelat'] ?>">Parâmetros</a>
                        </td>
                        <td class="text-center">
                            <a class="btn btn-sm" href="visualizar.php?nomeArquivo=<?php echo $relatorio['nomeArquivo'] ?>">Visualizar</a>
                        </td>
                    </tr>
                    <div class="modal fade" id="parametros-modal-<?php echo $relatorio['IDRelat'] ?>" tabindex="-1" role="dialog" aria-labelledby="ModalLabel" aria-hidden="true">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="ModalLabel">Parâmetros do Relatorio</h5>
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                                <div class="modal-body">
                                    <div class="col">
                                        <label>Modalidade</label>
                                        <input type="text" class="form-control" value="<?php echo $relatorio['parametros']['modalidade'] ?>" readonly>
                                        <label>Filial</label>
                                        <input type="text" class="form-control" value="<?php echo $relatorio['parametros']['codigoFilial'] ?>" readonly>
                                        <label>Data Inicial</label>
                                        <input type="text" class="form-control" value="<?php echo date('d/m/Y', strtotime($relatorio['parametros']['dataInicial'])) ?>" readonly>
                                        <label>Data Final</label>
                                        <input type="text" class="form-control" value="<?php echo date('d/m/Y', strtotime($relatorio['parametros']['dataFinal'])) ?>" readonly>
                                        <label>Considera LP</label>
                                        <input type="text" class="form-control" value="<?php echo $relatorio['parametros']['consideralp'] ?>" readonly>
                                        <label>Considera Feirão</label>
                                        <input type="text" class="form-control" value="<?php echo $relatorio['parametros']['considerafeirao'] ?>" readonly>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <?php }} ?>
                </table>
            </div>
        </div>
        
<!-- LOCAL PARA COLOCAR OS JS -->

<?php include_once ROOT . "/vendor/footer_js.php"; ?>

<!-- LOCAL PARA COLOCAR OS JS -FIM -->

</body>

</html>