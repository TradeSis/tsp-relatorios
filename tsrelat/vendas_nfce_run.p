def input param pidrelat as int64.

if pidrelat = ?
then do:
    message "Erro parametros idRelat" .
    return.
end.

{tsrelat.i}
{admcab-batch.i new}

def temp-table ttparametros serialize-name "parametros"
    field FilialInicial  as int
    field FilialFinal   as int
    field dataInicial   as date
    field dataFinal     as date.
    
hEntrada = temp-table ttparametros:HANDLE.
hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").


find first ttparametros no-error.
disp ttparametros.

/* inicio normal progress. */

def var filialini as int init 1.
def var filialfim as int init 134.
def var dataini as date init today.
def var datafim as date init today.

def var inut as int.
def var semchave as int.

/* Atualiza variaveis */
filialini = ttparametros.FilialInicial.
filialfim = ttparametros.FilialFinal.
dataini   = ttparametros.dataInicial.
datafim   = ttparametros.dataFinal.

/* Inicia o gerenciador de Impressao*/

varquivo = "vendas_nfce_" + string(pidrelat).
vsaida   = vdir + varquivo + ".txt".

 {mdad.i
  &Saida     = "value(vsaida)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""vendas_nfce""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """VENDAS NFCE"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

for each plani where pladat >= dataini and
                     pladat <= datafim and
                     etbcod >= filialini and
                     etbcod <= filialfim and
                                         etbcod <> 140 and /* PDV fiscal */
                                                (length(serie) = 2 or /* Descata recargas */
                                                 serie = "3") and /* NFC-e ADMCOM */
                                         movtdc = 5 /* venda */
                                         no-lock by etbcod.

        /* Atualizado para ler NFC-e P2K Serie > 29 */
        if integer(serie) > 29 or integer(serie) = 3 then do:
            if plani.movtdc = 76 then inut = inut + 1.
            if (plani.ufdes = "" or plani.ufdes = "C" or plani.ufdes = "S") then semchave = semchave + 1.

            find estab where estab.etbcod = plani.emite no-lock.
            if not avail estab then next.

            find tipmov where tipmov.movtdc = plani.movtdc no-lock.

            disp plani.emite(count) estab.munic estab.etbcgc plani.desti format ">>>>>>>>>>9" plani.cxacod plani.numero plani.serie plani.pladat plani.platot(total) plani.movtdc format ">>9" tipmov.movtnom plani.ufdes label "Chave" format "x(44)" with width 400.
    end.

end.

message "Notas inutilizadas: "inut.
message "Notas sem chave: "semchave.

output close.

def var vpdf as char.
    run pdfout.p (input vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                  input "Landscape", /* Landscape/Portrait */
                  input 6,
                  input 1,
                  output vpdf).
 
    run marcatsrelat (vdirweb + varquivo + ".pdf").
    os-command silent value("rm -f " + vdir + varquivo + ".txt").   
