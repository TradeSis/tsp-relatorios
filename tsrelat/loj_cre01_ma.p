def var pidrelat as int64.

pidrelat = int(SESSION:PARAMETER) no-error.

if pidrelat = ?
then do:
    message "Erro parametros Sesssion".
    return.
end.

{/var/www/html/prophp/tslebes/tsrelat/tsrelat.i}
 
message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/" + tsrelat.progcod + "_run.p".

run value("/var/www/html/prophp/tslebes/tsrelat/" + tsrelat.progcod + "_run.p") (input pidrelat).

message today string(time,"HH:MM:SS") "encerrado " pidrelat "tsrelat/" + tsrelat.progcod + "_run.p".


