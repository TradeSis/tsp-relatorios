<?php

include_once('../head.php');

$filial = explode(".", $_SERVER['REMOTE_ADDR']);
$filial = $filial[2];
?>

<body class="bg-transparent">

    <div class="container" style="width:700px">
        <div class="card shadow">
            <div class="card-header border-1">
                <div class="row">
                    <div class="col-10">
                        <h4 class="col">Conferência das notas de transfêrencia</h4>
                    </div>
                    <div class="col-sm" style="text-align:right">
                        <a href="#" onclick="history.back()" role="button" class="btn btn-primary btn-sm">Voltar</a>
                    </div>
                </div>
            </div>
            <div class="container" style="margin-top: 10px">

                <form action="../database/relatorios.php?operacao=anavenlj" method="post">
                    <div class="row">
                        <div class="col">
                            <label>Usuário</label>
                            <div class="form-group">
                                <input type="text" name="usercod" class="form-control" value="Lebes" autocomplete="off" readonly>
                            </div>
                        </div>
                        <div class="col">
                            <label>Programa</label>
                            <div class="form-group">
                                <input type="text" name="progcod" class="form-control" value="anavenlj" autocomplete="off" readonly>
                            </div>
                        </div>
                    </div>
                    <label>Nome do relatório</label>
                    <div class="form-group">
                        <input type="text" name="relatnom" class="form-control" value="Conferencia das notas de transferencia" autocomplete="off" readonly>
                    </div>
                    <div class="row">
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
                            <label>Data</label>
                            <input type="date" class="form-control" name="data">
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col">
                            <label>Cod. Movimentação</label>
                            <input type="number" class="form-control" name="codMov">
                        </div>
                        <div class="form-group col">
                            <label>Departamento</label>
                            <input type="number" class="form-control" name="departamento">
                        </div>
                        <div class="form-group col">
                            <label>Ordenação</label>
                            <select class="form-control" name="ordem">
                                <option value="1">Numerico</option>
                                <option value="2">Alfabetica</option>
                                <option value="3">Nota Fiscal</option>
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


</body>

</html>