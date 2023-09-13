def var vdir as char.
def var vdirweb as char.
def var varquivo as char.
def var vsaida   as char.

def var lcjsonentrada as longchar.
def var hentrada as handle.
def var lokJSON as log.
def var vpropath as char.

find tsrelat where tsrelat.idrelat = pidrelat no-lock no-error.
if not avail tsrelat
then do:
    message "TS/Relat " pidrelat "Nao Encontrado".
    return.
end.    

run marcatsrelat ("INICIO").

vdir    = "/var/www/html/prophp/tslebes/relat/".
vdirweb = "/tslebes/relat/".

copy-lob FROM parametrosJSON to lcjsonentrada CONVERT TARGET CODEPAGE 'UTF-8'.

input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.
propath = vpropath + ",/var/www/html/prophp/tslebes/tsrelat/".

procedure marcatsrelat.
    def input param varquivo    as char.
    message "marcando" varquivo.
    find current tsrelat exclusive.
    if varquivo = "INICIO"
    then do:
        tsrelat.dtproc = today.
        tsrelat.hrinic = time.
        tsrelat.nomeArquivo = "PROCESSANDO...".
    end.    
    else do:
        tsrelat.nomeArquivo = varquivo.
        tsrelat.hrproc      = time.
    end.        
end procedure.

