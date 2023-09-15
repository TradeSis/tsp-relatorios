<?php

if (session_status() === PHP_SESSION_NONE) {
	session_start();
}
include_once __DIR__."/../config.php";

include_once(ROOT.'/sistema/database/mysql.php');
include_once(ROOT.'/sistema/database/api.php');

include_once(ROOT.'/sistema/database/functions.php');
include_once(ROOT.'/sistema/database/email.php');
include_once(ROOT.'/sistema/database/progress.php');

?>
