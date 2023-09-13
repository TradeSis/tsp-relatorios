
def input  parameter vlcentrada as longchar.
def input param vtmp       as char.

def var vlcsaida   as longchar.
def var vsaida as char.

def var lokjson as log.
def var hentrada as handle.
def var hsaida   as handle.
def temp-table ttentrada no-undo serialize-name "entrada"
    field progcod   as char
    field usercod   as char.

def temp-table tttsrelat  no-undo serialize-name "relatorios"
    field IDRelat   as int64
    field usercod   as char    
    field dtinclu   as date format "99/99/9999"
    field hrinclu   as char
    field progcod   as char
    field relatnom  as char
    field nomeArquivo  as char
    field REMOTE_ADDR as char
    field parametrosJSON as char serialize-name "parametros".

    
 
hEntrada = temp-table ttentrada:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").
find first ttentrada.

def var lcjsonentrada as longchar.
for each tsrelat where tsrelat.progcod = ttentrada.progcod and 
                       tsrelat.dtinclu >= today - 2 
                       no-lock.
    if ttentrada.usercod <> ?
    then if ttentrada.usercod <> tsrelat.usercod
         then next.
         
    create tttsrelat.
    tttsrelat.idRelat  = tsrelat.idRelat. 
    tttsrelat.progcod  = tsrelat.progcod.
    tttsrelat.usercod  = tsrelat.usercod.
    tttsrelat.relatnom = tsrelat.relatnom.
    tttsrelat.dtinclu  = tsrelat.dtinclu.
    tttsrelat.hrinclu  = string(tsrelat.hrinclu,"HH:MM:SS").
    tttsrelat.REMOTE_ADDR = tsrelat.REMOTE_ADDR.
    tttsrelat.nomeArquivo = tsrelat.nomeArquivo.
    copy-lob FROM tsrelat.parametrosJSON to lcjsonentrada.
    tttsrelat.parametrosJSON = lcjsonentrada.

    

end.

hsaida  = temp-table tttsrelat:handle.

lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).

put unformatted string(vlcSaida).
