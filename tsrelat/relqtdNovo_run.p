def input param pidrelat as int64.

if pidrelat = ?
then do:
    message "Erro parametros idRelat" .
    return.
end.

{tsrelat.i}
{admcab-batch.i new}

def temp-table ttparametros serialize-name "parametros"
    field codigoFilial  as int
    field dataInicial   as date
    field dataFinal     as date.
    
hEntrada = temp-table ttparametros:HANDLE.
hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").


find first ttparametros no-error.
disp ttparametros.

/* inicio normal progress. */
def var vdtvenini   as date.
def var vdtvenfim   as date.


def var i       as   int.
def var varq    as   char.
def var vdata   like plani.pladat.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vtotal  like titulo.titvlcob column-label "Total".

def temp-table wftotal
    field etbcod    like estab.etbcod       column-label "Estab"
    field data      like titulo.titdtpag    column-label "Data"
    field atras     like titulo.titvlcob    column-label "Atrasados"
    field pont1     like titulo.titvlcob    column-label "Pontual 1"
    field pont2     like titulo.titvlcob    column-label "Pontual 2"
    field antec     like titulo.titvlcob    column-label "Antecipado"
    field pagfil    like titulo.titvlcob    column-label "P.P!Filial".

def var vfil17 as char extent 2 format "x(15)"
    init["Nova","Antiga"].

def var vindex as int.

do:
    vdtini   = dataInicial.
    vdtfin   = dataFinal.
    find estab where estab.etbcod = ttparametros.codigoFilial no-lock.
    

def var v-feirao-nome-limpo as log init no.

    i = 0.
   
    do vdata = vdtini to vdtfin:
        if estab.etbcod = 17 and
            vindex = 2 and
            vdata >= 10/20/2010
        then next.


        for each titulo use-index titdtpag where
                              titulo.empcod = wempre.empcod and
                              titulo.titnat = no            and
                              titulo.modcod = "CRE"         and
                              titulo.titdtpag = vdata       and
                              titulo.etbcod = estab.etbcod no-lock.
            
            if ttparametros.codigoFilial = 23 and
               estab.etbcod = 10 and
               titulo.titdtemi > 04/30/2011
            then next.

            if titulo.titpar = 0
            then next.
            if titulo.modcod = "VVI"
            then next.
            if titulo.clifor <= 1
            then next.

             

            {filtro-feiraonl.i}

            find first wftotal where wftotal.etbcod = estab.etbcod and
                                     wftotal.data   = titulo.titdtpag
                                     no-error.
            if not avail wftotal
            then do:

                create wftotal.
                assign wftotal.etbcod = estab.etbcod
                       wftotal.data   = titulo.titdtpag.
            end.

            

            if titulo.titdtven < vdtini
            then wftotal.atras = wftotal.atras + titulo.titvlcob.

            if month(titulo.titdtven) = month(vdtfin) and
               year(titulo.titdtven) = year(vdtfin) and
               titulo.titdtemi < vdtini
            then wftotal.pont1 = wftotal.pont1 + titulo.titvlcob.

            if month(titulo.titdtemi) = month(vdtfin) and
               year(titulo.titdtemi) = year(vdtfin) and
               month(titulo.titdtven) = month(vdtfin) and
               year(titulo.titdtven) = year(vdtfin)
            then wftotal.pont2 = wftotal.pont2 + titulo.titvlcob.

            if titulo.titdtven >  vdtfin
            then wftotal.antec = wftotal.antec + titulo.titvlcob.



            if titulo.moecod = "nov" or
               titulo.clifor = 1 or
               titulo.titpar = 0 /* #1 or
               titulo.titpar >= 50 */
               or
               titulo.tpcontrato = "L"
            then next.

            wftotal.pagfil = wftotal.pagfil + titulo.titvlcob.


        end.

    end.
end.

varquivo = "relqtdNovo_" + string(pidrelat).
vsaida   = vdir + varquivo + ".txt".

output to value(vsaida).

    form header wempre.emprazsoc
             space(6) "RELQDTNOVO_040418" at 112
             "Pag.: " at 123 page-number format ">>9" skip
             "RESUMO DAS LIQUIDACOES DIARIO FL" ttparametros.codigoFilial
             "PERIODO DE " string(vdtini) " A " string(vdtfin)
             today format "99/99/9999" at 112
             string(time,"hh:mm:ss") at 125
             skip fill("-",132) format "x(132)" skip
             with frame fcab no-label page-top no-box width 132.

        view frame fcab.

    for each wftotal break by wftotal.etbcod
                     by wftotal.data  with width 132.

        if first-of(wftotal.etbcod) and
           first-of(wftotal.data)
        then vtotal = 0.
        vtotal = wftotal.atras + wftotal.pont1 + wftotal.pont2
                    + wftotal.antec.
        if vtotal > 0
        then do:
            disp wftotal.etbcod
                    wftotal.data
                    wftotal.atras (TOTAL)
                    wftotal.pont1 (TOTAL)
                    wftotal.pont2 (TOTAL)
                    .
                        pause 0.

        end.
    end.

output close.
def var vpdf as char.
    run pdfout.p (input vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                  input "Landscape", /* Landscape/Portrait */
                  input 7,
                  input 1,
                  output vpdf).
 
    run marcatsrelat (vdirweb + varquivo + ".pdf").
    os-command silent value("rm -f " + vdir + varquivo + ".txt").    


