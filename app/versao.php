<?php
// helio 27032023 aplicacao relatorios

// NOVA VERSAO 
include  __DIR__ . "/../conexao.php";
//include "app/conexao.php";

if ($versao==""){$versao="1";}

if ($metodo=="GET"||$metodo=="PUT") {

      switch ($versao) {
         case "1":
               include '1/controle.php';
               break;
         default:
          $jsonSaida = json_decode(json_encode(
             array("erro" => "400",
                 "retorno" => "Aplicacao " . $aplicacao . " Versao ".$versao." Invalida")
               ), TRUE);
            break;
          }

} else {

      $jsonSaida = json_decode(json_encode(
        array("erro" => "400",
            "retorno" => "Aplicacao " . $aplicacao . " Metodo ".$metodo." Invalido")
          ), TRUE);

    }

  
