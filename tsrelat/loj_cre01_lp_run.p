def input param pidrelat as int64.

if pidrelat = ?
then do:
    message "Erro parametros idRelat" .
    return.
end.

{tsrelat.i}
{admcab-batch.i new}

def temp-table ttparametros serialize-name "parametros"
    field modalidade       as char
    field posicao       as int
    field codigoFilial  as int
    field dataInicial   as date
    field dataFinal     as date
    field consideralp     as log
    field considerafeirao     as log
    field ordem     as int.
    
hEntrada = temp-table ttparametros:HANDLE.
hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").


find first ttparametros no-error.
disp ttparametros.

/* inicio normal progress. */


def temp-table ttmodal no-undo
    field modcod like modal.modcod.
if modalidade = "CREDIARIO"
then do:
    create ttmodal. ttmodal.modcod = "CRE".
end.
if modalidade = "EMPRESTIMOS"
then do:
    create ttmodal. ttmodal.modcod = "CP0".
    create ttmodal. ttmodal.modcod = "CP1".
    create ttmodal. ttmodal.modcod = "CPN".
end.

def var vtpcontrato as char format "x(1)" label "T". /*#1 */

def var vpdf as char no-undo.

def new shared temp-table tt-extrato
        field rec as recid
        field ord as int
            index ind-1 ord.
def var ii as int.

def var vqtdcli as integer.
def temp-table ttcli
    field clicod like clien.clicod.

def buffer btitulo for titulo.
def stream stela.
def var vdata like plani.pladat.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var vcont-cli  as char format "x(15)" extent 3
      initial ["  Alfabetica  ","  Vencimento  ", "  Novacao "].
def var valfa  as int.

def temp-table tt-depen        
field accod as int        
field etbcod like estab.etbcod        
field fone   as char        
field dtnasc like plani.pladat        
field nome   as char format "x(20)".        
def var vfil17 as char extent 2 format "x(15)"        
init["Nova","Antiga"].        
def var vindex as int.

def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

setbcod = ttparametros.codigofilial.



if ttparametros.posicao = 0
then do:

    for each tt-depen:
        delete tt-depen.
    end.
    for each tt-extrato.
        delete tt-extrato.
    end.
    for each ttcli.
        delete ttcli.
    end.

    ii = 0. vqtdcli = 0.
    vetbcod = setbcod.
    
    find estab where estab.etbcod = vetbcod no-lock no-error.

    vdtvenini   = ttparametros.dataInicial.
    vdtvenfim   = ttparametros.dataFinal.
    v-feirao-nome-limpo  = ttparametros.considerafeirao.



    valfa =  ttparametros.ordem.

    varquivo = "loj_cred01_lp_" + string(pidrelat).
    vsaida   = vdir + varquivo + ".txt".

    {mdadmcab.i
    &Saida     = value(vsaida)
    &Page-Size = "0"
    &Cond-Var  = "121"
    &Page-Line = "66"
    &Nom-Rel   = """cre01_lp"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """POSICAO FINANCEIRA GERAL P/FILIAL - CLIENTE - PERIODO DE ""
                + string(vdtvenini) + "" A "" + string(vdtvenfim) "
    &Width     = "121"
    &Form      = "frame f-cab"}


    VSUBTOT = 0.
    if valfa = 0
    then do:
    do vdata = vdtvenini to vdtvenfim:
        for each ttmodal,
        each titulo use-index titdtven where
                    titulo.empcod = wempre.empcod and
                    titulo.titnat = no            and
                    titulo.modcod = ttmodal.modcod        and
                    titulo.titdtven = vdata       and
                    titulo.etbcod = ESTAB.etbcod and
                    titulo.titsit = "LIB"        no-lock:
            if titulo.clifor = 1
            then next.

            if v-feirao-nome-limpo
            then do:
                if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                then.
                else next.
            end.

            if estab.etbcod = 17 and
            vindex = 2 and
            titulo.titdtemi >= 10/20/2010
            then next.
            else if estab.etbcod = 17 and
                vindex = 1 and
                titulo.titdtemi < 10/20/2010
            then next.
            if setbcod = 23 and
            estab.etbcod = 10 and
            titulo.titdtemi > 04/30/2011
            then next.

/********
Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
pertence a filial 23 .
*************/
            if estab.etbcod = 10 and
            titulo.titdtemi < 01/01/2014
            then next.



                    find clien where clien.clicod = titulo.clifor
                                no-lock no-error.
                    if not avail clien
                    then next.

                    vsubtot = vsubtot + titulo.titvlcob.
                    find first tt-depen where tt-depen.etbcod = estab.etbcod and
                                    tt-depen.accod  = int(recid(titulo)) and
                                    tt-depen.nome   = clien.clinom no-error.
                    if not avail tt-depen
                    then do transaction:
                        create tt-depen.
                        assign tt-depen.etbcod = titulo.etbcod
                            tt-depen.accod  = int(recid(titulo))
                            tt-depen.nome   = clien.clinom
                            tt-depen.dtnas  = titulo.titdtven.
                    end.
                    output stream stela to terminal.
                        display stream stela
                                titulo.clifor
                                titulo.titnum
                                titulo.titpar
                                titulo.titdtven
                                    with frame f-tela centered
                                        1 down side-label. pause 0.

                    output stream stela close.
                end.
            end.
            for each tt-depen where tt-depen.etbcod = estab.etbcod
                                                no-lock break by tt-depen.nome
                                                            by tt-depen.dtnas:
                find titulo where recid(titulo) = tt-depen.accod
                            no-lock no-error.
                if not avail titulo
                then next.

                find clien where clien.clicod = titulo.clifor
                                        no-lock no-error.
                if avail clien
                then do:

                    find first tt-extrato where tt-extrato.rec = recid(clien)
                                                no-error.
                    if not avail tt-extrato
                    then do:
                        ii = ii + 1.
                        create tt-extrato.
                        assign tt-extrato.rec = recid(clien)
                            tt-extrato.ord = ii.
                    end.
                end.

                find ttcli where ttcli.clicod = clien.clicod no-error.

                if not avail ttcli
                then do:
                    create ttcli.
                    assign ttcli.clicod = clien.clicod.
                end.

                vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                            then "F"
                            else titulo.tpcontrato.

                display titulo.etbcod   column-label "Fil."
                        tt-depen.nome     column-label "Cliente"
                        format "x(20)"
                        clien.fone when   avail clien column-label "Fone"
                        clien.fax  when   avail clien column-label "Celular"
                        titulo.clifor   column-label "Cod."
                        titulo.modcod
                        vtpcontrato column-label "T"
                        titulo.titnum   column-label "Contrato"       
                        titulo.titpar   column-label "Par"
                        titulo.titdtemi column-label "Dt.Venda"
                        format "99/99/99"
                        titulo.titdtven column-label "Vencim."
                        format "99/99/99"
                        titulo.titvlcob column-label "Valor da!Prestacao"
                        format ">>>,>>9.99"
                        titulo.titdtven - TODAY    column-label "Dias"
                        format "->>>>9"
                            with width 180.
            end.
        end.
        if valfa = 2
        then do:
            for each ttmodal,
            each titulo use-index titdtven where
                            titulo.empcod = wempre.empcod and
                            titulo.titnat = no and
                            titulo.modcod = ttmodal.modcod and
                            titulo.titdtven >= vdtvenini and
                            titulo.titdtven <= vdtvenfim and
                            titulo.etbcod = ESTAB.etbcod and
                            titulo.titsit = "LIB"        and
                            can-find(clien where clien.clicod = titulo.clifor)
                            no-lock,
                            clien where clien.clicod = titulo.clifor no-lock
                                                        break by titulo.titdtven.
                if titulo.clifor = 1
                then next.

                if v-feirao-nome-limpo
                then do:
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                    acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                    then.
                    else next.
                end.

            if estab.etbcod = 17 and
            vindex = 2 and
            titulo.titdtemi >= 10/20/2010
            then next.
            else if estab.etbcod = 17 and
            vindex = 1 and
            titulo.titdtemi < 10/20/2010
            then next.

            if setbcod = 23 and
            estab.etbcod = 10 and
            titulo.titdtemi > 04/30/2011
            then next.

            /********
            Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
            pertence a filial 23 .
            *************/
            if estab.etbcod = 10 and
            titulo.titdtemi < 01/01/2014
            then next.

            find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
            if not avail tt-extrato
            then do:
            ii = ii + 1.
            create tt-extrato.
            assign tt-extrato.rec = recid(clien)
                tt-extrato.ord = ii.
            end.

            find ttcli where ttcli.clicod = clien.clicod no-error.
            if not avail ttcli
            then do:
            create ttcli.
            assign ttcli.clicod = clien.clicod.
            end.


            vsubtot = vsubtot + titulo.titvlcob.

            vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                then "F"
                else titulo.tpcontrato.

            display titulo.etbcod    column-label "Fil."
            clien.clinom       column-label "Cliente"
            format "x(20)"
            clien.clicod       column-label "Cod."
            clien.fone         column-label "Fone"
            clien.fax          column-label "Celular"
            titulo.modcod
            vtpcontrato column-label "T"
            titulo.titnum    column-label "Contrato" 
            titulo.titpar    column-label "Par"
            titulo.titdtemi  column-label "Dt.Venda"
            format "99/99/99"
            titulo.titdtven  column-label "Vencim."
            format "99/99/99"
            titulo.titvlcob  column-label "Valor da!Prestacao"
            format ">>>,>>9.99"
            titulo.titdtven - TODAY    column-label "Dias"
            format "->>>>9"
                with width 180.
            end.
            end.

            if valfa = 3
            then do:
            for each ttmodal,
            each titulo use-index titdtven where
                titulo.empcod = wempre.empcod and
                titulo.titnat = no and
                titulo.modcod = ttmodal.modcod and
                titulo.titdtven >= vdtvenini and
                titulo.titdtven <= vdtvenfim and
                titulo.etbcod = ESTAB.etbcod and
                titulo.titsit = "LIB"        and
                titulo.tpcontrato = "N" and
                can-find(clien where clien.clicod = titulo.clifor)
                no-lock,
                clien where clien.clicod = titulo.clifor no-lock
                                            break by titulo.titdtven.
            if titulo.clifor = 1
            then next.

            if v-feirao-nome-limpo
            then do:
            if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
            acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
            then.
            else next.
            end.

            if estab.etbcod = 17 and
            vindex = 2 and
            titulo.titdtemi >= 10/20/2010
            then next.
            else if estab.etbcod = 17 and
            vindex = 1 and
            titulo.titdtemi < 10/20/2010
            then next.

            if setbcod = 23 and
            estab.etbcod = 10 and
            titulo.titdtemi > 04/30/2011
            then next.

            /********
            Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
            pertence a filial 23 .
            *************/
            if estab.etbcod = 10 and
            titulo.titdtemi < 01/01/2014
            then next.

            find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
            if not avail tt-extrato
            then do:
                ii = ii + 1.
                create tt-extrato.
                assign tt-extrato.rec = recid(clien)
                    tt-extrato.ord = ii.
            end.

            find ttcli where ttcli.clicod = clien.clicod no-error.
            if not avail ttcli
            then do:
                create ttcli.
                assign ttcli.clicod = clien.clicod.
            end.


            vsubtot = vsubtot + titulo.titvlcob.

            vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                        then "F"
                        else titulo.tpcontrato.

            display titulo.etbcod    column-label "Fil."
                    clien.clinom       column-label "Cliente"
                    format "x(20)"
                    clien.clicod       column-label "Cod."
                    clien.fone         column-label "Fone"
                    clien.fax          column-label "Celular"
                    titulo.modcod
                    vtpcontrato column-label "T"
                    titulo.titnum    column-label "Contrato" 
                    titulo.titpar    column-label "Par"
                    titulo.titdtemi  column-label "Dt.Venda"
                    format "99/99/99"
                    titulo.titdtven  column-label "Vencim."
                    format "99/99/99"
                    titulo.titvlcob  column-label "Valor da!Prestacao"
                    format ">>>,>>9.99"
                    titulo.titdtven - TODAY    column-label "Dias"
                    format "->>>>9"
                        with width 180.
            end.
        end.


    vqtdcli = 0.
    for each ttcli.
    vqtdcli = vqtdcli + 1.
    end.

display skip(2)
"TOTAL CLIENTES:" vqtdcli skip
"TOTAL GERAL   :" vsubtot with frame ff no-labels no-box.
output close.

run pdfout.p (input vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                  input "Landscape", /* Landscape/Portrait */
                  input 7,
                  input 1,
                  output vpdf).
 
    run marcatsrelat (vdirweb + varquivo + ".pdf").
    os-command silent value("rm -f " + vdir + varquivo + ".txt").    

end.


/******

/**************** POSIÇÃO 2 ****************/
if ttparametros.posicao = 2
then do: 

ii = 0.
for each tt-extrato.
    delete tt-extrato.
end.
for each ttcli.
    delete ttcli.
end.


if setbcod = 999
then update vetbcod                          colon 25 with title modalidade + " - Posicao II ".
else do:
    vetbcod = setbcod.
    disp vetbcod.
end.
find estab where estab.etbcod = vetbcod no-error.
if not avail estab
then do:
    message "Estabelecimento Invalido" .
    undo.
end.
display estab.etbnom no-label.
pause 0.


    vdtvenini   = ttparametros.dataInicial.
    vdtvenfim   = ttparametros.dataFinal.
    v-feirao-nome-limpo  = ttparametros.considerafeirao.

    valfa =  ttparametros.ordem.

    varquivo = "cre03_lp" + string(setbcod) + "_" + string(today,"99999999") + "_" + replace(string(time,"HH:MM:SS"),":","").
    hide message no-pause.
    message "gerando relatorio" varquivo.


output to value("/admcom/relat/" + varquivo + ".txt") page-size 62.
PUT UNFORMATTED CHR(15)  .

    message "cre03_lp" modalidade " - Posicao II - Ordem" vcont-cli[valfa].

vqtdcli = 0. VSUBTOT = 0.
PAGE.
if valfa = 1
then
    for each ttmodal,
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = ttmodal.modcod and
        titulo.titsit = "LIB" and
        titulo.etbcod = ESTAB.etbcod and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim no-lock,
    first clien where clien.clicod = titulo.clifor no-lock
                            break by clien.clinom
                                  by titulo.titdtven.

    if v-feirao-nome-limpo
                then do:
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                    then.
                    else next.
                end.

    if estab.etbcod = 17 and
              vindex = 2 and
                   titulo.titdtemi >= 10/20/2010
                then next.
                else if estab.etbcod = 17 and
                    vindex = 1 and
                    titulo.titdtemi < 10/20/2010
                then next.

    if setbcod = 23 and
                   estab.etbcod = 10 and
                   titulo.titdtemi > 04/30/2011
                then next.

/********
  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
  pertence a filial 23 .
   *************/
                if estab.etbcod = 10 and
                   titulo.titdtemi < 01/01/2014
                then next.


    find first btitulo use-index iclicod
            where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = titulo.modcod         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = titulo.clifor  and
                             btitulo.titdtven < vdtvenini no-lock no-error.
    if avail btitulo
    then next.

        form header
            wempre.emprazsoc
                    space(6) "cre03_lp"   at 98
                    "Pag.: " at 110 page-number format ">>9" skip
                    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 98
                    string(time,"hh:mm:ss") at 112
                    skip fill("-",122) format "x(122)" skip
                    with frame fcab no-label page-top no-box width 130.
        view frame fcab.
    vsubtot = vsubtot + titulo.titvlcob.

    find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
    if not avail tt-extrato
    then do:
        ii = ii + 1.
        create tt-extrato.
        assign tt-extrato.rec = recid(clien)
               tt-extrato.ord = ii.
    end.

    find ttcli where ttcli.clicod = clien.clicod no-error.
    if not avail ttcli
    then do:
        create ttcli.
        assign ttcli.clicod = clien.clicod.
    end.

    /* #1 */
    vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                          then "F"
                          else titulo.tpcontrato.

    display
        titulo.etbcod    column-label "Fil."
        clien.clinom when avail clien   column-label "Cliente"
        format "x(20)"
        clien.fone column-label "Fone"
        clien.fax  column-label "Celular"
        titulo.clifor     column-label "Cod."
        vtpcontrato
        titulo.titnum      column-label "Contrato"       
        titulo.titpar      column-label "Par"
        titulo.titdtemi    column-label "Dt.Venda"
        format "99/99/99"
        titulo.titdtven    column-label "Vencim."
        format "99/99/99"
        titulo.titvlcob    column-label "Valor da!Prestacao"
        format ">>>,>>9.99"
        titulo.titdtven - TODAY    column-label "Dias"
        format "->>>>9"
        with width 180.
end.
if valfa = 2
then
    for each ttmodal,
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = ttmodal.modcod and
        titulo.titsit = "LIB" and
        titulo.etbcod = ESTAB.etbcod and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim
                    no-lock break by titulo.titdtven:

    if v-feirao-nome-limpo
                then do:
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                    then.
                    else next.
                end.

    if estab.etbcod = 17 and
                   vindex = 2 and
                   titulo.titdtemi >= 10/20/2010
                then next.
                else if estab.etbcod = 17 and
                    vindex = 1 and
                    titulo.titdtemi < 10/20/2010
                then next.
    if setbcod = 23 and
                   estab.etbcod = 10 and
                   titulo.titdtemi > 04/30/2011
                then next.
/********
  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
  pertence a filial 23 .
   *************/
                if estab.etbcod = 10 and
                   titulo.titdtemi < 01/01/2014
                then next.

    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if not avail clien
    then next.
    find first btitulo use-index iclicod
            where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = titulo.modcod         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = titulo.clifor  and
                             btitulo.titdtven < vdtvenini no-lock no-error.
    if avail btitulo
    then next.

        form header
            wempre.emprazsoc
                    space(6) "cre03_lp"   at 98
                    "Pag.: " at 110 page-number format ">>9" skip
                    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 98
                    string(time,"hh:mm:ss") at 112
                    skip fill("-",122) format "x(122)" skip
                    with frame fcabb no-label page-top no-box width 130.
        view frame fcabb.
    vsubtot = vsubtot + titulo.titvlcob.

    find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
    if not avail tt-extrato
    then do:
        ii = ii + 1.
        create tt-extrato.
        assign tt-extrato.rec = recid(clien)
        tt-extrato.ord = ii.
    end.

    find ttcli where ttcli.clicod = clien.clicod no-error.
    if not avail ttcli
    then do:
        create ttcli.
        assign ttcli.clicod = clien.clicod.
    end.

    /* #1 */
    vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                          then "F"
                          else titulo.tpcontrato.

    display
        titulo.etbcod      column-label "Fil."
        clien.clinom when avail clien column-label "Cliente"
        format "x(20)"
        clien.fone when avail clien column-label "Fone"
        clien.fax  when avail clien column-label "Celular"
        titulo.clifor      column-label "Cod."
        vtpcontrato
        titulo.titnum      column-label "Contrato"        
        titulo.titpar      column-label "Par"
        titulo.titdtemi    column-label "Dt.Venda"
        format "99/99/99"
        titulo.titdtven    column-label "Vencim."
        format "99/99/99"
        titulo.titvlcob    column-label "Valor da!Prestacao"
        format ">>>,>>9.99"
        titulo.titdtven - TODAY    column-label "Dias"
        format "->>>>9"
        with width 180.
end.

if valfa = 3
then
    for each ttmodal,
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = ttmodal.modcod and
        titulo.titsit = "LIB" and
        titulo.etbcod = ESTAB.etbcod and
        titulo.tpcontrato = "N" and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim
                    no-lock break by titulo.titdtven:

    if v-feirao-nome-limpo
                then do:
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                    then.
                    else next.
                end.

if estab.etbcod = 17 and
                   vindex = 2 and
                   titulo.titdtemi >= 10/20/2010
                then next.
                else if estab.etbcod = 17 and
                    vindex = 1 and
                    titulo.titdtemi < 10/20/2010
                then next.

if setbcod = 23 and
                   estab.etbcod = 10 and
                   titulo.titdtemi > 04/30/2011
                then next.
/********
  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
  pertence a filial 23 .
   *************/
                if estab.etbcod = 10 and
                   titulo.titdtemi < 01/01/2014
                then next.

    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if not avail clien
    then next.
    find first btitulo use-index iclicod
            where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = titulo.modcod         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = titulo.clifor  and
                             btitulo.titdtven < vdtvenini no-lock no-error.
    if avail btitulo
    then next.

        form header
            wempre.emprazsoc
                    space(6) "cre03_lp"   at 98
                    "Pag.: " at 110 page-number format ">>9" skip
                    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 98
                    string(time,"hh:mm:ss") at 112
                    skip fill("-",122) format "x(122)" skip
                    with frame fcabc no-label page-top no-box width 130.
        view frame fcabc.
    vsubtot = vsubtot + titulo.titvlcob.

    find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
    if not avail tt-extrato
    then do:
        ii = ii + 1.
        create tt-extrato.
        assign tt-extrato.rec = recid(clien)
        tt-extrato.ord = ii.
    end.

    find ttcli where ttcli.clicod = clien.clicod no-error.
    if not avail ttcli
    then do:
        create ttcli.
        assign ttcli.clicod = clien.clicod.
    end.

    /* #1 */
    vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                          then "F"

else titulo.tpcontrato.

    display
        titulo.etbcod      column-label "Fil."
        clien.clinom when avail clien column-label "Cliente"
        format "x(20)"
        clien.fone when avail clien column-label "Fone"
        clien.fax  when avail clien column-label "Celular"
        titulo.clifor      column-label "Cod."
        titulo.modcod
        vtpcontrato
        titulo.titnum      column-label "Contrato"        
        titulo.titpar      column-label "Par"
        titulo.titdtemi    column-label "Dt.Venda"
        format "99/99/99"
        titulo.titdtven    column-label "Vencim."
        format "99/99/99"
        titulo.titvlcob    column-label "Valor da!Prestacao"
        format ">>>,>>9.99"
        titulo.titdtven - TODAY    column-label "Dias"
        format "->>>>9"
        with width 180.
end.


vqtdcli = 0.
for each ttcli.
    vqtdcli = vqtdcli + 1.
end.

display skip(2)
        "TOTAL CLIENTES:" vqtdcli skip
        "TOTAL GERAL   :" vsubtot with frame ff no-labels no-box.
output close.

run pdfout.p (input vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                  input "Landscape", /* Landscape/Portrait */
                  input 7,
                  input 1,
                  output vpdf).
 
    run marcatsrelat (vdirweb + varquivo + ".pdf").
    os-command silent value("rm -f " + vdir + varquivo + ".txt").    

end.

****/
