<?php
// lucas 120320204 id884 bootstrap local - alterado head
// gabriel 09022023 15:35

include_once '../head.php';
include_once '../database/relatorios.php';


$relatorios = buscaRelatorios(null,null);
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
                    <div class="col-sm">
                        <h3 class="col">Relatórios (Progress)</h3>
                    </div>
                    <div class="col-sm" style="text-align:center">
                        <a class="btn btn-sm btn-warning" href="#" data-toggle="modal" data-target="#parametros">Parâmetros</a>
                    </div>
                    <div class="col-sm" style="text-align:right">
                        <a href="relatorio_inserir.php" role="button" class="btn btn-success btn-sm">Adicionar Relatório</a>
                    </div>
                </div>
            </div>
        </div>
        <div class="table table-responsive">
            <table class="table table-sm table-hover table-bordered">

                <thead class="thead-light">
                    <tr>
                        <th class="text-center">Usuário</th>
                        <th class="text-center">Data</th>
                        <th class="text-center">Hora</th>
                        <th class="text-center">Programa</th>
                        <th class="text-center">Nome do relatório</th>
                        <th class="text-center">Nome do arquivo</th>
                        <th class="text-center">REMOTE_ADDR</th>
                        <th class="text-center">PDF</th>
                    </tr>
                </thead>
                <?php
                if (!empty($relatorios)) {
                foreach ($relatorios as $relatorio) {
                ?>
                    <tr>
                        <td class="text-center"><?php echo $relatorio['usercod'] ?></td>
                        <td class="text-center"><?php echo date('d/m/Y', strtotime($relatorio['dtinclu'])) ?></td>
                        <td class="text-center"><?php echo $relatorio['hrinclu'] ?></td>
                        <td class="text-center"><?php echo $relatorio['progcod'] ?></td>
                        <td class="text-center"><?php echo $relatorio['relatnom'] ?></td>
                        <td class="text-center"><?php echo $relatorio['nomeArquivo'] ?></td>
                        <td class="text-center"><?php echo $relatorio['REMOTE_ADDR'] ?></td>
                        <td class="text-center">
                            <a class="btn btn-sm" href="visualizar.php?nomeArquivo=<?php echo $relatorio['nomeArquivo'] ?>">Visualizar</a>
                        </td>
                    </tr>
                <?php }} ?>
            </table>
        </div>
    </div>

    <div class="modal fade" id="parametros" tabindex="-1" role="dialog" aria-labelledby="ModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="ModalLabel">Parâmetros Relatórios</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="container-fluid">
                        <form action="relatorios.php?parametros" method="post">
                            <div class="form-group">
                                <label>Código Cliente</label>
                                <input type="text" class="form-control" name="codigoCliente">
                            </div>
                            <div class="row">
                                <div class="form-group col">
                                    <label>Filial</label>
                                    <input type="number" class="form-control" name="codigoFilial">
                                </div>
                                <div class="form-group col">
                                    <label>Modalidade</label>
                                    <select class="form-control" name="modalidade">
                                        <option value=""></option>
                                        <option value="CRE">CRE</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row">
                                <div class="form-group col">
                                    <label>Data Inicial</label>
                                    <input type="date" class="form-control" name="dataInicial">
                                </div>
                                <div class="form-group col">
                                    <label>Data Final</label>
                                    <input type="date" class="form-control" name="dataFinal">
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Certificado</label>
                                <input type="number" class="form-control" name="numeroCertificado">
                            </div>
                            <div class="card-footer bg-transparent" style="text-align:right">
                                <button type="submit" class="btn btn-sm btn-success">Verificar Relatorios</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

<!-- LOCAL PARA COLOCAR OS JS -->

<?php include_once ROOT . "/vendor/footer_js.php"; ?>

<!-- LOCAL PARA COLOCAR OS JS -FIM -->

</body>

</html>