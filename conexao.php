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
function defineCaminhoLog() {
  $pasta = '/ws/tslog/';
  return $pasta;
} 
function defineConexaoProgress()
{
  $progresscfg = "progress.cfg";
  $progresscfg="progress.cfg";
  $dlc                = "/usr/dlc";
  $tmp            = "/u/bsweb/works/";
  $pf                = "/admcom/bases/wsp2k.pf";
  $propath        = "/u/bsweb/progr/tslebes/api/app/,/admcom/progr/,";
  $proginicial = "/u/bsweb/progr/tslebes/api/app/database/progress.p";

  return        array(   "progresscfg" => $progresscfg, 
                         "dlc" => $dlc,
                         "pf" => $pf, 
                         "tmp" => $tmp,
                         "propath" => $propath,
                         "proginicial" => $proginicial
                          );
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

include_once(ROOT.'/sistema/database/mysql.php');
include_once(ROOT.'/sistema/database/api.php');
// helio 26042023
include_once(ROOT.'/sistema/database/functions.php');
include_once(ROOT.'/sistema/database/email.php');

?>
