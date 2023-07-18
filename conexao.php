<?php
// Helio 26042023 - conexao agora pega dados do ../config.php, e vai para versao
// helio 01022023 criado funcao defineConexao API e MySQl com aprametros locais
// helio 01022023 altereado para include_once
// helio 31012023 - include database/api
// helio 26012023 16:16

include_once __DIR__."/../config.php";

function defineConexaoApi () {
  return API_IP;
} 

function defineConexaoMysql () {

    return        array(   "host" => MYSQL_HOST, 
                           "base" => MYSQL_BASE,
                        "usuario" => MYSQL_USUARIO, 
                        "senhadb" => MYSQL_SENHADB
                            );

}

function defineEmail () {

  return        array(  "Host"      => EMAIL_HOST, 
                        "Port"      => EMAIL_PORT, 
                        "Username"  => EMAIL_USERNAME,
                        "Password"  => EMAIL_PASSWORD,
                        "from"      => EMAIL_FROM,
                        "fromNome"  => EMAIL_FROMNOME
                          );

}

function defineSenderWhatsapp () {

  return        array(  'api_key' => WHATS_APIKEY, 
                        'sender' => WHATS_SENDER
                          );

}

include_once(ROOT.'/painel/database/mysql.php');
include_once(ROOT.'/painel/database/api.php');
// helio 26042023
include_once(ROOT.'/painel/database/functions.php');
include_once(ROOT.'/painel/database/email.php');

?>
