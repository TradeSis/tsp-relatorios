def input param pidrelat as int64.

if pidrelat = ?
then do:
    message "Erro parametros idRelat" .
    return.
end.
message "loj_cre01_ma_run.p".
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
if ttparametros.modalidade = "CREDIARIO"
then do:
    create ttmodal. ttmodal.modcod = "CRE".
end.
if ttparametros.modalidade = "EMPRESTIMOS"
then do:
    create ttmodal. ttmodal.modcod = "CP0".
    create ttmodal. ttmodal.modcod = "CP1".
    create ttmodal. ttmodal.modcod = "CPN".
end.


def var vpdf as char no-undo.
def var vtpcontrato as char format "x(1)" label "T". /*#1 */

def var ii as int.
def var vdata like plani.pladat.
def var vqtdcli as integer.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.

def temp-table ttcli no-undo
field clicod like clien.clicod
index i-cod clicod.

def temp-table ttvven no-undo
field clicod   like clien.clicod
field clinom   like clien.clinom
field etbcod   like titulo.etbcod
field titnum   like titulo.titnum
field vrecid   as recid
field titpar   like titulo.titpar
field tpcontrato    like titulo.tpcontrato
field titdtemi like titulo.titdtemi
field titdtven like titulo.titdtven
field titvlcob like titulo.titvlcob
field valmont  like titulo.titvlcob
index key      clicod
index key2     valmont.

def temp-table tt-titulo no-undo        
field etbcod like titulo.etbcod        
field clifor like titulo.clifor        
field clinom like clien.clinom        
field fone like clien.fone        
field fax  like clien.fax        
field titnum like titulo.titnum        
field titpar like titulo.titpar        
field modcod like titulo.modcod        
field tpcontrato like titulo.tpcontrato        
field titdtemi like titulo.titdtemi        
field titdtven like titulo.titdtven        
field titvlcob like titulo.titvlcob        
field dias     as int        
field imp as log        
index i1 clinom        
.        

def var vqtite as int.

def var vcont-cli  as char format "x(14)" extent 5
initial [" Alfabetica   ",
" Vencimento   ",
" Bairro       ",
" Valor Vencido",
" Novacao      "].

def var valfa as int.

def new shared temp-table tt-extrato
field rec      as recid
field ord      as int
field cidade as char
field bairro   like clien.bairro[1]
field clinom   like clien.clinom
field titnum   like titulo.titnum
field titdtven like titulo.titdtven
field etbcod   like estab.etbcod
index ind-1 ord
index i-bairro  bairro
index i1        bairro cidade clinom titdtven
index i-rec     rec.

def new shared temp-table tt-bairro
field cidade as char
field bairro as char
field marca as char
field qtdcli as int
index i1 bairro
index i-cidbai  cidade bairro.

def buffer btitulo for titulo.
def buffer bttvven for ttvven.


def var vfil17 as char extent 2 format "x(15)"
init["Nova","Antiga"].

def var vindex as int.

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
    
    repeat with 1 down:
        for each tt-extrato:
            delete tt-extrato.
        end.
        
        for each tt-bairro. delete tt-bairro. end.
        
        for each ttcli:
            delete ttcli.
        end.

if ttparametros.posicao = 1
then do:        
    if setbcod = 999
    then do:
        update vetbcod colon 25 with title ttparametros.modalidade + " - Posicao I ".
    end.
    else do:
        vetbcod = ttparametros.codigoFilial.
    end.
    
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido" .
        undo.
    end.
    display estab.etbnom no-label.
    
    pause 0.
    vindex = 0.
    if estab.etbcod = 17
    then do:
        disp vfil17 no-label with frame f-17 1 down row 10 centered
        side-label overlay.
        pause 0.
        choose field vfil17  with frame f-17.
        vindex = ttparametros.ordem.
    end.
    
    vdtvenini   = ttparametros.dataInicial.
    vdtvenfim   = ttparametros.dataFinal.
    v-consulta-parcelas-LP  = ttparametros.consideralp.
    v-feirao-nome-limpo  = ttparametros.considerafeirao.
    
    disp vcont-cli no-label with frame f1 width 80 row 10
    overlay.
    choose field vcont-cli with frame f1.
    valfa = ttparametros.ordem.
    for each tt-titulo.
    delete tt-titulo.
    end.
    run p-gera.
    
    valfa = ttparametros.ordem  .
    
    
    varquivo = "loj_cre01_ma" + string(pidrelat).
    vsaida   = vdir + varquivo + ".txt".
    
    
    {mdadmcab.i
    &Saida     = "value(vsaida)"
    &Page-Size = "0"
    &Cond-Var  = "120"
    &Page-Line = "66"
    &Nom-Rel   = """cre02_a"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """POSICAO FINANCEIRA GERAL P/FILIAL - CLIENTE - PERIODO DE ""
    + string(vdtvenini) + "" A "" + string(vdtvenfim) "
    &Width     = "120"
    &Form      = "frame f-cab"}
    
    
    assign vqtdcli = 0 VSUBTOT = 0.
    
    run p-imprime.
    
    vqtdcli = 0.
    for each ttcli:
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

    return.
end.

end.

/* = = = = = = = = = = = = = = = = = = = = = */

procedure p-gera:
    
    disp "Aguarde.....!!" skip
    "Gerando Relatorio..."  with frame f-tela.
    FOR EACH TTMODAL,
    each titulo use-index titdtven where
    titulo.empcod = wempre.empcod and
    titulo.titnat = no            and
    titulo.modcod = ttmodal.modcod and
    titulo.titdtven >= vdtvenini and
    titulo.titdtven <= vdtvenfim and
    titulo.etbcod = ESTAB.etbcod and
    titulo.titsit = "LIB"
    no-lock:
        
        if v-feirao-nome-limpo
        then do:
            if acha("FEIRAO-NOME-LIMPO",
            titulo.titobs[1]) <> ? and
            acha("FEIRAO-NOME-LIMPO",
            titulo.titobs[1]) = "SIM"
            then.
            else next.
        end.
        else do:
            /* #1 */
            if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
            then next.
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
        
        if titulo.clifor = 1 then next.
        
        find clien where clien.clicod = titulo.clifor
        no-lock no-error.
        if not avail clien then next.
        
        if /* #1 (titulo.titpar = 0
        or titulo.titpar >= 51)
        and acha("RENOVACAO",titulo.titobs[1]) = "SIM"
        */
        titulo.tpcontrato = "L" /* #1 */
        then assign v-parcela-lp = yes.
        else assign v-parcela-lp = no.
        
        if v-consulta-parcelas-LP = no
        and v-parcela-lp = yes
        then next.
        
        if v-consulta-parcelas-LP = yes
        and v-parcela-lp = no
        then next.
        
        vsubtot = vsubtot + titulo.titvlcob.
        
        
        find first tt-bairro where
        tt-bairro.cidade = clien.cidade[1] and
        tt-bairro.bairro = clien.bairro[1]
        no-error.
        if not avail tt-bairro
        then do:
            create tt-bairro.
            tt-bairro.cidade = clien.cidade[1].
            tt-bairro.bairro = clien.bairro[1].
        end.
        
        find first tt-extrato
        where tt-extrato.rec = recid(clien) no-error.
        if not avail tt-extrato then do:
            ii = ii + 1.
            create tt-extrato.
            assign
            tt-extrato.rec    = recid(clien)
            tt-extrato.ord    = ii
            tt-extrato.cidade = clien.cidade[1]
            tt-extrato.bairro = clien.bairro[1]
            tt-extrato.clinom = clien.clinom
            tt-extrato.titnum = titulo.titnum
            tt-extrato.titdtven = titulo.titdtven
            tt-extrato.etbcod   = titulo.etbcod
            tt-bairro.qtdcli = tt-bairro.qtdcli + 1.
        end.
        find first ttcli where
        ttcli.clicod = titulo.clifor no-error.
        if not avail ttcli then do:
            create ttcli.
            assign ttcli.clicod = titulo.clifor.
        end.
        
        create tt-titulo.
        assign
        tt-titulo.etbcod = titulo.etbcod
        tt-titulo.clinom = clien.clinom
        tt-titulo.fone   = clien.fone
        tt-titulo.fax    = clien.fax
        tt-titulo.clifor = titulo.clifor
        tt-titulo.titnum = titulo.titnum
        tt-titulo.titpar = titulo.titpar
        tt-titulo.modcod = titulo.modcod
        tt-titulo.tpcontrato = titulo.tpcontrato
        tt-titulo.titdtemi =  titulo.titdtemi
        tt-titulo.titdtven =  titulo.titdtven
        tt-titulo.titvlcob =  titulo.titvlcob
        tt-titulo.dias =  titulo.titdtven - TODAY.
    end.
    
end procedure.

procedure p-imprime:
    def var vqtd as int init 0.
    if valfa = 1
    then do:
        for each tt-titulo where tt-titulo.imp = no
        break by  tt-titulo.clinom :
            find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
            display tt-titulo.etbcod column-label "Fil."
            tt-titulo.clinom column-label "Nome do Cliente" format "x(20)"
            tt-titulo.fone column-label "fone" when avail clien
            tt-titulo.fax  column-label "Celular" when avail clien
            tt-titulo.clifor column-label "Cod."        format ">>>>>>>>>9"
            tt-titulo.modcod
            tt-titulo.titnum column-label "Contrato"      format "x(10)"                          
            
            tt-titulo.titpar column-label "Par"
            tt-titulo.titdtemi column-label "Dt.Venda"  format "99/99/99"
            tt-titulo.titdtven column-label "Vencim."   format "99/99/99"
            tt-titulo.titvlcob  column-label "Valor da!Prestacao"
            format ">>>,>>9.99"
            tt-titulo.titdtven - TODAY column-label "Dias" format "->>>>9"
            with frame ff1 width 130 down.
            
            tt-titulo.imp = yes.
            vqtd = vqtd + 1.
        end.
    end.
    else if valfa = 2
    then do:
        for each tt-titulo where tt-titulo.imp = no
        break by  tt-titulo.titdtven :
            find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
            display tt-titulo.etbcod column-label "Fil."
            tt-titulo.clinom column-label "Nome do Cliente"
            format "x(20)"
            tt-titulo.fone column-label "fone" when avail clien
            tt-titulo.fax  column-label "Celular" when avail clien
            tt-titulo.clifor column-label "Cod."      format ">>>>>>>>>9"
            tt-titulo.modcod
            tt-titulo.titnum column-label "Contrato"    format "x(10)"                          
            
            tt-titulo.titpar column-label "Par"
            tt-titulo.titdtemi column-label "Dt.Venda" format "99/99/99"
            tt-titulo.titdtven column-label "Vencim."  format "99/99/99"
            tt-titulo.titvlcob  column-label "Valor da!Prestacao"
            format ">>>,>>9.99"
            tt-titulo.titdtven - TODAY column-label "Dias" format "->>>>9"
            with frame ff2 width 130 down.
            
            tt-titulo.imp = yes.
            vqtd = vqtd + 1.
        end.
    end.
    else if valfa = 3
    then do:
        for each tt-titulo where tt-titulo.imp = no no-lock,
        first clien where clien.clicod = tt-titulo.clifor no-lock
        break by clien.bairro[1]
        by clien.clinom
        by tt-titulo.titdtven.
        
        display tt-titulo.etbcod column-label "Fil."
        tt-titulo.clinom column-label "Nome do Cliente"
        format "x(20)"
        clien.bairro[1] format "x(15)" column-label "Bairro"
        tt-titulo.fone column-label "fone" when avail clien
        tt-titulo.fax  column-label "Celular" when avail clien
        tt-titulo.clifor column-label "Cod."
        format ">>>>>>>>>9"
        tt-titulo.modcod
        tt-titulo.titnum column-label "Contrato"    format "x(10)"                          
        
        tt-titulo.titpar column-label "Par"
        tt-titulo.titdtemi column-label "Dt.Venda" format "99/99/99"
        tt-titulo.titdtven column-label "Vencim."  format "99/99/99"
        tt-titulo.titvlcob  column-label "Valor da!Prestacao"
        format ">>>,>>9.99"
        tt-titulo.titdtven - TODAY column-label "Dias" format "->>>>9"
        with frame ff3 width 160 down.
        
        tt-titulo.imp = yes.
        vqtd = vqtd + 1.
    end.
end.
else if valfa = 4
then do:
    for each tt-titulo where tt-titulo.imp = no :
        find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
        display tt-titulo.etbcod column-label "Fil."
        tt-titulo.clinom column-label "Nome do Cliente"
        format "x(20)"
        tt-titulo.fone column-label "fone" when avail clien
        tt-titulo.fax  column-label "Celular" when avail clien
        tt-titulo.clifor column-label "Cod."      format ">>>>>>>>>9"
        tt-titulo.modcod
        tt-titulo.titnum column-label "Contrato"    format "x(10)"                          
        
        tt-titulo.titpar column-label "Par"
        tt-titulo.titdtemi column-label "Dt.Venda"  format "99/99/99"
        tt-titulo.titdtven column-label "Vencim."   format "99/99/99"
        tt-titulo.titvlcob  column-label "Valor da!Prestacao"
        format ">>>,>>9.99"
        tt-titulo.titdtven - TODAY column-label "Dias" format "->>>>9"
        with frame ff4 width 130 down.
        
        tt-titulo.imp = yes.
        vqtd = vqtd + 1.
    end.
end.
else if valfa = 5
then do:
    for each tt-titulo where tt-titulo.imp = no
    and tt-titulo.tpcontrato = "N"
    break by  tt-titulo.clinom :
        find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
        display tt-titulo.etbcod column-label "Fil."
        tt-titulo.clinom column-label "Nome do Cliente" format "x(20)"
        tt-titulo.fone column-label "fone" when avail clien
        tt-titulo.fax  column-label "Celular" when avail clien
        tt-titulo.clifor column-label "Cod."      format ">>>>>>>>>9"
        tt-titulo.modcod
        tt-titulo.titnum column-label "Contrato"    format "x(10)"                          
        
        tt-titulo.titpar column-label "Par"
        tt-titulo.titdtemi column-label "Dt.Venda"  format "99/99/99"
        tt-titulo.titdtven column-label "Vencim."   format "99/99/99"
        tt-titulo.titvlcob  column-label "Valor da!Prestacao"
        format ">>>,>>9.99"
        tt-titulo.titdtven - TODAY    column-label "Dias"
        format "->>>>9"
        with frame ff5 width 130 down.
        
        tt-titulo.imp = yes.
        vqtd = vqtd + 1.
    end.
end.
end procedure.

/*****
/**************** POSIÇÃO 2 ****************/
if ttparametros.posicao = 2
then do:
    if setbcod = 999
    then update vetbcod colon 25 with title pmodalidade + " - Posicao II ".
    else do:
        vetbcod = ttparametros.codigoFilial.
    end.
    
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab then do:
        message "Estabelecimento Invalido" .
        undo.
    end.
    
    for each tt-extrato.
    delete tt-extrato.
end.

for each ttcli.
delete ttcli.
end.

for each ttvven.
delete ttvven.
end.
ii = 0.

display estab.etbnom no-label.

vindex = 0.
if estab.etbcod = 17
then do:
    disp vfil17 no-label with frame f-17 1 down row 10 centered
    side-label.
    choose field vfil17  with frame f-17.
    vindex = ttparametros.ordem.
end.

vdtvenini   = ttparametros.dataInicial.
vdtvenfim   = ttparametros.dataFinal.
v-consulta-parcelas-LP  = ttparametros.consideralp.
v-feirao-nome-limpo  = ttparametros.considerafeirao.

disp vcont-cli no-label with frame f1 width 80.
choose field vcont-cli with frame f1.

valfa = ttparametros.ordem.

varquivo = "cre03_a" + string(setbcod) + "_" + string(today,"99999999") + "_" + replace(string(time,"HH:MM:SS"),":","").
hide message no-pause.
message "gerando relatorio" varquivo.

output to value("/admcom/relat/" + varquivo + ".txt") page-size 62.

PUT UNFORMATTED CHR(15)  .

message "cre03_a" pmodalidade " - Posicao II - Ordem" vcont-cli[valfa].

VSUBTOT = 0.
PAGE.

case valfa:
    when 1 then run p-alfabetica.
    when 2 then run p-vencimento.
    when 3 then run p-bairro.
    when 4 then run p-valven.
    when 5 then run p-novacao.
end case.

vqtdcli = 0.
for each ttcli.
vqtdcli = vqtdcli + 1.
end.
display
skip(2)
"TOTAL CLIENTES:" vqtdcli skip
"TOTAL GERAL   :" vsubtot
with frame ff no-labels no-box.

output close.
hide message no-pause.
run visurel.p ("/admcom/relat/" + varquivo + ".txt","").
sresp = no.
message "Deseja gerar um PDF do relatorio?" update sresp.
if sresp
then do:
    
    run pdfout.p (input "/admcom/relat/" + varquivo + ".txt",
    input "/admcom/kbase/pdfout/",
    input varquivo + ".pdf",
    input "Portrait",
    input 8.2,
    input 1,
    output vpdf).
    
    message ("Arquivo " + vpdf + " gerado com sucesso!").
    
    /* substituido pela geracao de PDF
    os-command silent /fiscal/lp value(varquivo). */
end.
sresp = no.
message "Deseja gerar extratos? " update sresp.
if sresp
then do:
    run loj/extrato2.p (input valfa).
end.


/* = = = = = = = = = = = = = = = = = = = = = */

procedure p-alfabetica:
    
    for each tt-bairro.
    delete tt-bairro.
end.
for  each ttmodal no-lock,
each titulo use-index titdtven where
titulo.empcod = wempre.empcod and
titulo.titnat = no and
titulo.modcod = ttmodal.modcod   and
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
else do:
    /* #1 */
    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
    then next.
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

if titulo.tpcontrato = "L" /* #1 */
then assign v-parcela-lp = yes.
else assign v-parcela-lp = no.

if v-consulta-parcelas-LP = no
and v-parcela-lp = yes
then next.

if v-consulta-parcelas-LP = yes
and v-parcela-lp = no
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
space(6) "cre03_a"   at 98
"Pag.: " at 110 page-number format ">>9" skip
"POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
" Periodo" vdtvenini " A " vdtvenfim
today format "99/99/9999" at 98
string(time,"hh:mm:ss") at 112
skip fill("-",122) format "x(122)" skip
with frame fcab no-label page-top no-box width 130.
view frame fcab.
vsubtot = vsubtot + titulo.titvlcob.

find first tt-bairro use-index i-cidbai where
tt-bairro.cidade = clien.cidade[1] and
tt-bairro.bairro = clien.bairro[1] no-error.
if not avail tt-bairro
then do:
    create tt-bairro.
    tt-bairro.cidade = clien.cidade[1].
    tt-bairro.bairro = clien.bairro[1].
end.
find first tt-extrato use-index i-rec
where tt-extrato.rec = recid(clien) no-error.
if not avail tt-extrato
then do:
    ii = ii + 1.
    create tt-extrato.
    assign tt-extrato.rec = recid(clien)
    tt-extrato.cidade = clien.cidade[1]
    tt-extrato.bairro = clien.bairro[1]
    tt-extrato.ord = ii
    tt-bairro.qtdcli = tt-bairro.qtdcli + 1.
end.

find ttcli use-index i-cod
where ttcli.clicod = titulo.clifor no-error.
if not avail ttcli
then do:
    create ttcli.
    assign ttcli.clicod = titulo.clifor.
end.

vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
then "F"
else titulo.tpcontrato.

display
titulo.etbcod    column-label "Fil."
clien.clinom when avail clien    column-label "Nome do Cliente"
format "x(20)"
clien.fone column-label "Fone"
clien.fax column-label "Celular"
titulo.clifor     column-label "Cod."
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
with width 130 .

end.

end procedure.
/* = = = = = = = = = = = = = = = = = = = = = */

procedure p-vencimento:
    
    for each tt-bairro:
        delete tt-bairro.
    end.
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
        
        find clien where clien.clicod = titulo.clifor no-lock no-error.
        if not avail clien
        then next.
        
        if v-feirao-nome-limpo
        then do:
            if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
            acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
            then.
            else next.
        end.
        else do:
            /* #1 */
            if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
            then next.
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
        
        if titulo.tpcontrato = "L"  /* #1 */
        then assign v-parcela-lp = yes.
        else assign v-parcela-lp = no.
        
        if v-consulta-parcelas-LP = no
        and v-parcela-lp = yes
        then next.
        
        if v-consulta-parcelas-LP = yes
        and v-parcela-lp = no
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
        space(6) "POCLI"   at 98
        "Pag.: " at 110 page-number format ">>9" skip
        "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
        " Periodo" vdtvenini " A " vdtvenfim
        today format "99/99/9999" at 98
        string(time,"hh:mm:ss") at 112
        skip fill("-",122) format "x(122)" skip
        with frame fcabb no-label page-top no-box width 130.
        view frame fcabb.
        vsubtot = vsubtot + titulo.titvlcob.
        find first tt-bairro use-index i-cidbai where
        tt-bairro.cidade = clien.cidade[1] and
        tt-bairro.bairro = clien.bairro[1] no-error.
        if not avail tt-bairro
        then do:
            create tt-bairro.
            tt-bairro.cidade = clien.cidade[1].
            tt-bairro.bairro = clien.bairro[1].
        end.
        find first tt-extrato use-index i-rec
        where tt-extrato.rec = recid(clien) no-error.
        if not avail tt-extrato
        then do:
            ii = ii + 1.
            create tt-extrato.
            assign tt-extrato.rec = recid(clien)
            tt-extrato.cidade = clien.cidade[1]
            tt-extrato.bairro = clien.bairro[1]
            tt-extrato.ord = ii
            tt-bairro.qtdcli = tt-bairro.qtdcli + 1.
        end.
        
        
        find ttcli use-index i-cod
        where ttcli.clicod = titulo.clifor no-error.
        if not avail ttcli
        then do:
            create ttcli.
            assign ttcli.clicod = titulo.clifor.
        end.
        
        
        
        vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
        then "F"
        else titulo.tpcontrato.
        
        display
        titulo.etbcod    column-label "Fil."
        clien.clinom when avail clien    column-label "Nome do Cliente"
        format "x(20)"
        clien.fone column-label "Fone"
        clien.fax column-label "Celular"
        titulo.clifor     column-label "Cod."
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
        with width 130 .
        
    end.
end procedure.
/* = = = = = = = = = = = = = = = = = = = = = */

/* * * Identica ah opcao "alfabetica" mudando apenas o break by * * */
procedure p-bairro:
    for each tt-bairro.
    delete tt-bairro.
end.
for  each ttmodal,
each titulo use-index titdtven where
titulo.empcod = wempre.empcod and
titulo.titnat = no and
titulo.modcod = ttmodal.modcod and
titulo.titsit = "LIB" and
titulo.etbcod = ESTAB.etbcod and
titulo.titdtven >= vdtvenini and
titulo.titdtven <= vdtvenfim no-lock,
first clien where clien.clicod = titulo.clifor no-lock
break by clien.bairro[1]
by clien.clinom
by titulo.titdtven.

if v-feirao-nome-limpo
then do:
    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
    acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
    then.
    else next.
end.
else do:
    /* #1 */
    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
    then next.
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


if titulo.tpcontrato = "L" /* #1 */
then assign v-parcela-lp = yes.
else assign v-parcela-lp = no.

if v-consulta-parcelas-LP = no
and v-parcela-lp = yes
then next.

if v-consulta-parcelas-LP = yes
and v-parcela-lp = no
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
space(6) "cre03_a"   at 98
"Pag.: " at 110 page-number format ">>9" skip
"POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
" Periodo" vdtvenini " A " vdtvenfim
today format "99/99/9999" at 98
string(time,"hh:mm:ss") at 112
skip fill("-",122) format "x(122)" skip
with frame fcab no-label page-top no-box width 130.
view frame fcab.
vsubtot = vsubtot + titulo.titvlcob.
find first tt-bairro use-index i-cidbai where
tt-bairro.cidade = clien.cidade[1] and
tt-bairro.bairro = clien.bairro[1] no-error.
if not avail tt-bairro
then do:
    create tt-bairro.
    tt-bairro.cidade = clien.cidade[1].
    tt-bairro.bairro = clien.bairro[1].
end.
find first tt-extrato use-index i-rec
where tt-extrato.rec = recid(clien) no-error.
if not avail tt-extrato
then do:
    ii = ii + 1.
    create tt-extrato.
    assign tt-extrato.rec = recid(clien)
    tt-extrato.cidade = clien.cidade[1]
    tt-extrato.bairro = clien.bairro[1]
    tt-extrato.ord = ii
    tt-bairro.qtdcli = tt-bairro.qtdcli + 1.
end.

find ttcli use-index i-cod
where ttcli.clicod = titulo.clifor no-error.
if not avail ttcli
then do:
    create ttcli.
    assign ttcli.clicod = titulo.clifor.
end.

vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
then "F"
else titulo.tpcontrato.

display
titulo.etbcod    column-label "Fil."
clien.clinom when avail clien    column-label "Nome do Cliente"
format "x(20)"
clien.fone column-label "Fone"
clien.fax column-label "Celular"
titulo.clifor     column-label "Cod."
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
with width 130 .

end.


end procedure.

/********************************************************/

Procedure p-valven.

for each ttmodal,
each titulo use-index titdtven where
titulo.empcod = wempre.empcod and
titulo.titnat = no and
titulo.modcod = ttmodal.modcod and
titulo.titsit = "LIB" and
titulo.etbcod = ESTAB.etbcod and
titulo.titdtven >= vdtvenini and
titulo.titdtven <= vdtvenfim no-lock,
first clien where clien.clicod = titulo.clifor no-lock :
    
    if v-feirao-nome-limpo
    then do:
        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
        acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
        then.
        else next.
    end.
    else do:
        /* #1 */
        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
        then next.
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
    
    if /* #1 (titulo.titpar = 0
    or titulo.titpar >= 51)
    and acha("RENOVACAO",titulo.titobs[1]) = "SIM"
    */
    titulo.tpcontrato = "L" /* #1 */
    then assign v-parcela-lp = yes.
    else assign v-parcela-lp = no.
    
    if v-consulta-parcelas-LP = no
    and v-parcela-lp = yes
    then next.
    
    if v-consulta-parcelas-LP = yes
    and v-parcela-lp = no
    then next.
    
    
    /* Registros Acumulados */
    find first ttvven where
    ttvven.clicod   = clien.clicod and
    ttvven.vrecid   = ? no-error.
    if not avail ttvven
    then do:
        create ttvven.
        assign ttvven.clicod = clien.clicod
        ttvven.clinom = clien.clinom
        ttvven.vrecid = ?.
    end.
    assign ttvven.valmont  = ttvven.valmont + titulo.titvlcob
    ttvven.titvlcob = 0.
    
    /* Registros de titulos */
    find first ttvven where
    ttvven.clicod   = clien.clicod and
    ttvven.vrecid   = recid(titulo) no-error.
    if not avail ttvven
    then do:
        create ttvven.
        assign  ttvven.clicod = clien.clicod
        ttvven.clinom = clien.clinom
        ttvven.vrecid = recid(titulo).
    end.
    assign ttvven.valmont  = 0
    ttvven.etbcod   = titulo.etbcod
    ttvven.titnum   = titulo.titnum
    ttvven.titpar   = titulo.titpar
    ttvven.titdtemi = titulo.titdtemi
    ttvven.titdtven = titulo.titdtven
    ttvven.titvlcob = titulo.titvlcob
    ttvven.titdtven = titulo.titdtven .
    
    vsubtot = vsubtot + titulo.titvlcob.
    
    
    
    find first tt-extrato use-index i-rec
    where tt-extrato.rec = recid(clien) no-error.
    if not avail tt-extrato
    then do:
        ii = ii + 1.
        create tt-extrato.
        assign tt-extrato.rec = recid(clien)
        tt-extrato.cidade = clien.cidade[1]
        tt-extrato.bairro = clien.bairro[1]
        tt-extrato.ord = ii
        /*tt-bairro.qtdcli = tt-bairro.qtdcli + 1*/.
    end.
    
    
    find ttcli use-index i-cod
    where ttcli.clicod = titulo.clifor no-error.
    if not avail ttcli
    then do:
        create ttcli.
        assign ttcli.clicod = titulo.clifor.
    end.
end.

/* Imprime */
for each bttvven where bttvven.vrecid = ?,
first clien where clien.clicod = bttvven.clicod no-lock,
each ttvven where ttvven.clicod = bttvven.clicod and
ttvven.vrecid <> ?
break by bttvven.valmont desc
by ttvven.titvlcob desc:
    
    display
    ttvven.etbcod column-label "Fil." /* when first-of(bttvven.valmont)*/                ttvven.clinom /*
    when first-of(bttvven.valmont)
    */
    column-label "Nome do Cliente"
    format "x(20)"
    clien.fone column-label "Fone"
    clien.fax column-label "Celular"
    ttvven.clicod      column-label "Cod."
    ttvven.titnum      column-label "Contrato"                                
    
    ttvven.titpar      column-label "Par"
    ttvven.titdtemi    column-label "Dt.Venda"
    format "99/99/99"
    ttvven.titdtven    column-label "Vencim."
    format "99/99/99"
    ttvven.titvlcob    column-label "Valor da!Prestacao"
    format ">>>,>>9.99"
    ttvven.titdtven - TODAY    column-label "Dias"
    format "->>>>9"
    with width 130 .
    
end.

end procedure.
Procedure p-novacao.

for each ttmodal,
each titulo use-index titdtven where
titulo.empcod = wempre.empcod and
titulo.titnat = no and
titulo.modcod = ttmodal.modcod and
titulo.titsit = "LIB" and
titulo.etbcod = ESTAB.etbcod and
titulo.titdtven >= vdtvenini and
titulo.titdtven <= vdtvenfim and /* #1
titulo.titpar >= 30 */
titulo.tpcontrato = "N" /* #1 */
no-lock,
first clien where clien.clicod = titulo.clifor no-lock :
    
    if v-feirao-nome-limpo
    then do:
        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
        acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
        then.
        else next.
    end.
    else do:
        /* #1 */
        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
        then next.
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
    
    if /* #1 (titulo.titpar = 0
    or titulo.titpar >= 51)
    and acha("RENOVACAO",titulo.titobs[1]) = "SIM"
    */
    titulo.tpcontrato = "L" /* #1 */
    then assign v-parcela-lp = yes.
    else assign v-parcela-lp = no.
    
    if v-consulta-parcelas-LP = no
    and v-parcela-lp = yes
    then next.
    
    if v-consulta-parcelas-LP = yes
    and v-parcela-lp = no
    then next.
    
    
    /* Registros Acumulados */
    find first ttvven where
    ttvven.clicod   = clien.clicod and
    ttvven.vrecid   = ? no-error.
    if not avail ttvven
    then do:
        create ttvven.
        assign ttvven.clicod = clien.clicod
        ttvven.clinom = clien.clinom
        ttvven.vrecid = ?.
    end.
    assign ttvven.valmont  = ttvven.valmont + titulo.titvlcob
    ttvven.titvlcob = 0.
    
    /* Registros de titulos */
    find first ttvven where
    ttvven.clicod   = clien.clicod and
    ttvven.vrecid   = recid(titulo) no-error.
    if not avail ttvven
    then do:
        create ttvven.
        assign  ttvven.clicod = clien.clicod
        ttvven.clinom = clien.clinom
        ttvven.vrecid = recid(titulo).
    end.
    assign ttvven.valmont  = 0
    ttvven.etbcod   = titulo.etbcod
    ttvven.titnum = titulo.titnum
    ttvven.titpar   = titulo.titpar
    ttvven.titdtemi = titulo.titdtemi
    ttvven.titdtven = titulo.titdtven
    ttvven.titvlcob = titulo.titvlcob
    ttvven.titdtven = titulo.titdtven .
    
    vsubtot = vsubtot + titulo.titvlcob.
    
    find first tt-extrato use-index i-rec
    where tt-extrato.rec = recid(clien) no-error.
    if not avail tt-extrato
    then do:
        ii = ii + 1.
        create tt-extrato.
        assign tt-extrato.rec = recid(clien)
        tt-extrato.cidade = clien.cidade[1]
        tt-extrato.bairro = clien.bairro[1]
        tt-extrato.ord = ii.
    end.
    
    
    find ttcli use-index i-cod
    where ttcli.clicod = titulo.clifor no-error.
    if not avail ttcli
    then do:
        create ttcli.
        assign ttcli.clicod = titulo.clifor.
    end.
end.

/* Imprime */
for each bttvven where bttvven.vrecid = ?,
first clien where clien.clicod = bttvven.clicod no-lock,
each ttvven where ttvven.clicod = bttvven.clicod and
ttvven.vrecid <> ?
break by bttvven.valmont desc
by ttvven.titvlcob desc:
    
    display
    ttvven.etbcod column-label "Fil."
    ttvven.clinom column-label "Nome do Cliente"
    format "x(20)"
    clien.fone column-label "Fone"
    clien.fax column-label "Celular"
    ttvven.clicod      column-label "Cod."
    ttvven.titnum      column-label "Contrato"                                
    
    ttvven.titpar      column-label "Par"
    ttvven.titdtemi    column-label "Dt.Venda"
    format "99/99/99"
    ttvven.titdtven    column-label "Vencim."
    format "99/99/99"
    ttvven.titvlcob    column-label "Valor da!Prestacao"
    format ">>>,>>9.99"
    ttvven.titdtven - TODAY    column-label "Dias"
    format "->>>>9"
    with width 130 .
    
    
end.

end procedure.


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


***/