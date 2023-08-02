def input param pidrelat as int64.

if pidrelat = ?
then do:
    message "Erro parametros idRelat" .
    return.
end.

{tsrelat.i}
{admcab-batch.i new}

def temp-table ttparametros serialize-name "parametros"
    field posicao       as int
    field codigoFilial  as int
    field dataInicial   as date
    field dataFinal     as date
    field ordem         as int.
    
hEntrada = temp-table ttparametros:HANDLE.
hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").


find first ttparametros no-error.
disp ttparametros.

/* inicio normal progress. */
def var vdtvenini   as date.
def var vdtvenfim   as date.
def var valfa       as log.
 
def var vpdf as char no-undo.

def var ii as int.
def stream stela.
def var vdata like plani.pladat.
def var vqtdcli as integer.
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.

def temp-table ttcli
    field clicod like clien.clicod.

def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Alfabetica  ","  Vencimento  "].
def temp-table tt-depen
    field accod as int
    field etbcod like estab.etbcod
    field fone   as char
    field dtnasc like plani.pladat  
    field nome   as char format "x(20)".
    

def new shared temp-table tt-extrato 
        field rec as recid
        field ord as int
            index ind-1 ord.

if ttparametros.ordem = 1
then valfa = yes.
else valfa = no.
if ttparametros.posicao = 1
then do:
    vdtvenini   = dataInicial.
    vdtvenfim   = dataFinal.
    find estab where estab.etbcod = ttparametros.codigoFilial no-lock.
    
    varquivo = "loj_cred01_" + string(pidrelat).
    vsaida   = vdir + varquivo + ".txt".
    {mdadmcab.i
        &Saida     = value(vsaida)
        &Page-Size = "0"
        &Cond-Var  = "0"
        &Page-Line = "0"
        &Nom-Rel   = """loj_cre01"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
     &Tit-Rel   = """POSICAO FINANCEIRA GERAL P/FILIAL - CLIENTE - PERIODO DE ""
                       + string(vdtvenini) + "" A "" + string(vdtvenfim) "
        &Width     = "145"
        &Form      = "frame f-cab"}
    
    assign vqtdcli = 0 VSUBTOT = 0.

    if valfa
    then do:
        do vdata = vdtvenini to vdtvenfim:
            FOR each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no            and
                        titulo.modcod = "CRE"         and
                        titulo.titdtven = vdata       and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"        no-lock:
                if titulo.clifor = 1
                then next.
                find clien where clien.clicod = titulo.clifor 
                            no-lock no-error.
                if not avail clien
                then next.
                vsubtot = vsubtot + titulo.titvlcob.
                find first tt-depen where 
                              tt-depen.etbcod = estab.etbcod and
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
                                            
            find ttcli where ttcli.clicod = titulo.clifor no-error.
            if not avail ttcli
            then do:
                create ttcli.
                assign ttcli.clicod = titulo.clifor.
            end.
            
            display titulo.etbcod column-label "Fil." 
                    tt-depen.nome column-label "Nome do Cliente"
                                  format "x(30)"
                    clien.fone column-label "fone" when avail clien
                    clien.fax  column-label "Celular" when avail clien
                    titulo.clifor column-label "Cod."     
                    titulo.titnum column-label "Contr."   
                    titulo.titpar column-label "Pr."      
                    titulo.titdtemi column-label "Dt.Venda" 
                    titulo.titdtven column-label "Vencim."  
                    titulo.titvlcob column-label "Valor Prestacao" 
                    titulo.titdtven - TODAY    column-label "Dias"
                        with width 180.
        end.
        
    end.
    else do:
        FOR each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no and
                        titulo.modcod = "CRE" and
                        titulo.titdtven >= vdtvenini and
                        titulo.titdtven <= vdtvenfim and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"        and
                        can-find(clien where 
                        clien.clicod = titulo.clifor) no-lock,
                     clien where clien.clicod = titulo.clifor no-lock
                                           break by titulo.titdtven.
            if titulo.clifor = 1
            then next.

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
             
            display titulo.etbcod column-label "Fil."  
                    clien.clinom  column-label "Nome do Cliente" 
                    clien.clicod  column-label "Cod."            
                    clien.fone    column-label "Fone"
                    clien.fax     column-label "Celular"
                    titulo.titnum   column-label "Contr."  
                    titulo.titpar   column-label "Pr."        
                    titulo.titdtemi column-label "Dt.Venda" 
                    titulo.titdtven column-label "Vencim."  
                    titulo.titvlcob column-label "Valor Prestacao"  
                    titulo.titdtven - TODAY    column-label "Dias"
                        with width 180.
        end.
    end.

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

end.


if ttparametros.posicao = 2
then do:
    vdtvenini   = dataInicial.
    vdtvenfim   = dataFinal.
    find estab where estab.etbcod = ttparametros.codigoFilial no-lock.
    
    varquivo = "loj_cred01_" + string(pidrelat).
    vsaida   = vdir + varquivo + ".txt".
    {mdadmcab.i
        &Saida     = value(vsaida)
        &Page-Size = "0"
        &Cond-Var  = "0"
        &Page-Line = "0"
        &Nom-Rel   = """loj_cre01"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
     &Tit-Rel   = """POSICAO FINANCEIRA GERAL P/FILIAL - CLIENTE - PERIODO DE ""
                       + string(vdtvenini) + "" A "" + string(vdtvenfim) "
        &Width     = "145"
        &Form      = "frame f-cab"}
    
    assign vqtdcli = 0 VSUBTOT = 0.

    if valfa
    then do:
        do vdata = vdtvenini to vdtvenfim:
            FOR each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no            and
                        titulo.modcod = "CRE"         and
                        titulo.titdtven = vdata       and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"        no-lock:
                if titulo.clifor = 1
                then next.
                find clien where clien.clicod = titulo.clifor 
                            no-lock no-error.
                if not avail clien
                then next.
                vsubtot = vsubtot + titulo.titvlcob.
                find first tt-depen where 
                              tt-depen.etbcod = estab.etbcod and
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
                                            
            find ttcli where ttcli.clicod = titulo.clifor no-error.
            if not avail ttcli
            then do:
                create ttcli.
                assign ttcli.clicod = titulo.clifor.
            end.
            
            display titulo.etbcod column-label "Fil." 
                    tt-depen.nome column-label "Nome do Cliente"
                                  format "x(30)"
                    clien.fone column-label "fone" when avail clien
                    clien.fax  column-label "Celular" when avail clien
                    titulo.clifor column-label "Cod."     
                    titulo.titnum column-label "Contr."   
                    titulo.titpar column-label "Pr."      
                    titulo.titdtemi column-label "Dt.Venda" 
                    titulo.titdtven column-label "Vencim."  
                    titulo.titvlcob column-label "Valor Prestacao" 
                    titulo.titdtven - TODAY    column-label "Dias"
                        with width 180.
        end.
        
    end.
    else do:
        FOR each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no and
                        titulo.modcod = "CRE" and
                        titulo.titdtven >= vdtvenini and
                        titulo.titdtven <= vdtvenfim and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"        and
                        can-find(clien where 
                        clien.clicod = titulo.clifor) no-lock,
                     clien where clien.clicod = titulo.clifor no-lock
                                           break by titulo.titdtven.
            if titulo.clifor = 1
            then next.

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
             
            display titulo.etbcod column-label "Fil."  
                    clien.clinom  column-label "Nome do Cliente" 
                    clien.clicod  column-label "Cod."            
                    clien.fone    column-label "Fone"
                    clien.fax     column-label "Celular"
                    titulo.titnum   column-label "Contr."  
                    titulo.titpar   column-label "Pr."        
                    titulo.titdtemi column-label "Dt.Venda" 
                    titulo.titdtven column-label "Vencim."  
                    titulo.titvlcob column-label "Valor Prestacao"  
                    titulo.titdtven - TODAY    column-label "Dias"
                        with width 180.
        end.
    end.

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

end.