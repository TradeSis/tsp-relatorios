def var pidrelat as int64.

pidrelat = int(SESSION:PARAMETER) no-error.

if pidrelat = ?
then do:
    message "Erro parametros Sesssion".
    return.
end.
/* Ajustado o PROPATH */
{relatorios/tsrelat/tsrelat.i}
 
message today string(time,"HH:MM:SS") "Disparando " pidrelat "relatorios/tsrelat/" + tsrelat.progcod + "_run.p".

run value("relatorios/tsrelat/" + tsrelat.progcod + "_run.p") (input pidrelat).

message today string(time,"HH:MM:SS") "encerrado " pidrelat "relatorios/tsrelat/" + tsrelat.progcod + "_run.p".


