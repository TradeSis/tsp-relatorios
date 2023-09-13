<?php

include_once('../head.php');
?>

<body class="bg-transparent">

    <div class="container" style="width:700px">
        <div class="card shadow">
            <div class="card-header border-1">
                <div class="row">
                    <div class="col-sm">
                        <h3 class="col">Inserir Relatório</h3>
                    </div>
                    <div class="col-sm" style="text-align:right">
                        <a href="relatorios.php" role="button" class="btn btn-primary btn-sm">Voltar</a>
                    </div>
                </div>
            </div>
            <div class="container" style="margin-top: 10px">

                <form action="../database/relatorios.php?operacao=relat" method="post">
                    <div class="row">
                        <div class="col">
                            <label>Usuário</label>
                            <div class="form-group">
                                <input type="text" name="usercod" class="form-control" placeholder="Digite o nome do Usuário" autocomplete="off">
                            </div>
                        </div>
                        <div class="col">
                            <label>Programa</label>
                            <div class="form-group">
                                <input type="text" name="progcod" class="form-control" placeholder="rel" autocomplete="off">
                            </div>
                        </div>
                    </div>
                    <label>Nome do relatório</label>
                    <div class="form-group">
                        <input type="text" name="relatnom" class="form-control" placeholder="Digite o nome do Relatório" autocomplete="off">
                    </div>
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
                        <button type="submit" class="btn btn-sm btn-success">Cadastrar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>


</body>

</html>