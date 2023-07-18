<?php
// Inicio
$log_datahora_ini = date("dmYHis");
$acao="inserir"; 
$arqlog = defineCaminhoLog()."apilebes_relatorios_".date("dmY").".log";
$arquivo = fopen($arqlog,"a");
$identificacao = $log_datahora_ini.$acao;
fwrite($arquivo,$identificacao."-ENTRADA->".json_encode($jsonEntrada)."\n");   


    $conteudoEntrada=json_encode($jsonEntrada);
/*    
    {
        "usercod": "HELIO",
        "progcod": "rel1.p",
        "relatnom": "xpto2"
    }
*/
if (!isset($dadosEntrada["tsrelat"])) {
    $parametrosJSON = /*array('parametros' 
            => array(*/ $jsonEntrada["parametros"] /*))*/;

    $conteudoEntrada = json_encode(
        array(
            'tsrelat' => 
            array(
                  array('usercod' =>  $jsonEntrada["usercod"], 
                        'progcod' =>  $jsonEntrada["progcod"],             
                        'relatnom' =>  $jsonEntrada["relatnom"],                                     
                        'REMOTE_ADDR' =>   $jsonEntrada["REMOTE_ADDR"],
                        'parametrosJSON' =>  json_encode($parametrosJSON)                           
                  )
            )
        )
    );
}

    //echo $conteudoEntrada;
    fwrite($arquivo,$identificacao."-FORMATADO->".$conteudoEntrada."\n");   

    $progr = new chamaprogress();

    $retorno = $progr->executarprogress("relatorios/1/tsrelat_inserir",$conteudoEntrada);

    fwrite($arquivo,$identificacao."-PROGRESS->".json_encode($retorno)."\n");

    $jsonSaida = json_decode($retorno,true);
    $parametros = json_decode($jsonSaida["relatorios"][0]["parametros"],true);
    $jsonSaida["relatorios"][0]["parametros"] = $parametros["parametros"][0];
    $jsonSaida = $jsonSaida["relatorios"][0];

    fwrite($arquivo,$identificacao."-SAIDA->".json_encode($jsonSaida)."\n");

fclose($arquivo);
    
?>
