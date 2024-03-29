<?php
// lucas 120320204 id884 bootstrap local - alterado head

include_once('../head.php');
$filial = explode(".", $_SERVER['REMOTE_ADDR']);
$filial = $filial[2];
?>

<!doctype html>
<html lang="pt-BR">
<head>

    <?php include_once ROOT . "/vendor/head_css.php"; ?>

</head>

<body class="bg-transparent">

    <div class="container" style="width:700px">
        <div class="card shadow">
            <div class="card-header border-1">
                <div class="row">
                    <div class="col-10">
                        <h4 class="col">Extrato de cobrança simples</h4>
                    </div>
                    <div class="col-sm" style="text-align:right">
                        <a href="#" onclick="history.back()" role="button" class="btn btn-primary btn-sm">Voltar</a>
                    </div>
                </div>
            </div>
            <div class="container" style="margin-top: 10px">

                <form action="../database/relatorios.php?operacao=loj_cred01" method="post">
                    <div class="row">
                        <div class="col">
                            <label>Usuário</label>
                            <div class="form-group">
                                <input type="text" name="usercod" class="form-control" value="Lebes" autocomplete="off"
                                    readonly>
                            </div>
                        </div>
                        <div class="col">
                            <label>Programa</label>
                            <div class="form-group">
                                <input type="text" name="progcod" class="form-control" value="loj_cred01"
                                    autocomplete="off" readonly>
                            </div>
                        </div>

                    </div>
                    <label>Nome do relatório</label>
                    <div class="form-group">
                        <input type="text" name="relatnom" class="form-control" value="Extrato de cobranca simples"
                            autocomplete="off" readonly>
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
                    <div class="row">
                        <div class="form-group col">
                            <label>Posição</label>
                            <select class="form-control" name="posicao">
                                <option value="1">Posição 1</option>
                                <option value="2">Posição 2</option>
                            </select>
                        </div>
                        <div class="form-group col">
                            <label>Filial</label>
                            <?php if ($filial <= 0){ ?>
                            <input type="number" class="form-control" name="codigoFilial">
                            <?php } else { ?>
                            <input type="number" class="form-control" value="<?php echo $filial ?>" name="codigoFilial" readonly>
                            <?php } ?>
                            <input type="text" class="form-control" value="<?php echo $_SERVER['REMOTE_ADDR']?>" name="REMOTE_ADDR" hidden>
                        </div>
                        <div class="form-group col">
                            <label>Ordenação</label>
                            <select class="form-control" name="ordem">
                                <option value="1">Alfabetica</option>
                                <option value="0">Vencimento</option>
                            </select>
                        </div>
                    </div>

                    <div class="card-footer bg-transparent" style="text-align:right">
                        <button type="submit" class="btn btn-sm btn-success">Gerar Relatório</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

<!-- LOCAL PARA COLOCAR OS JS -->

<?php include_once ROOT . "/vendor/footer_js.php"; ?>

<!-- LOCAL PARA COLOCAR OS JS -FIM -->

</body>

</html>