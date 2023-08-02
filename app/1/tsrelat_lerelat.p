def var pidrelat as int64.
pidrelat = 1.

def var lcjsonentrada as longchar.
def var hentrada as handle.
def var lokJSON as log.

find tsrelat where tsrelat.idrelat = pidrelat no-lock.

/*    
 {"parametros":
    [{"codigoCliente":"",
      "codigoFilial":"",
      "modalidade":"",
      "dataInicial":"",
      "dataFinal":"2023-03-28",
      "numeroCertificado":""}
     ] 
 } 
*/

copy-lob FROM parametrosJSON to lcjsonentrada CONVERT TARGET CODEPAGE 'UTF-8'.
    
def temp-table ttparametros serialize-name "parametros"
    field codigoCliente as int
    field codigoFilial  as int
    field modalidade    as char
    field dataInicial   as date
    field dataFinal     as date
    field numeroCertificado as char.
    
hEntrada = temp-table ttparametros:HANDLE.
lokJSON = hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
find first ttparametros no-error.

disp ttparametros.


                    
