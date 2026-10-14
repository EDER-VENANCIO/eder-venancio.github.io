#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
    Projeto: Exportação de dados DEF para CSV
    Plataforma: TOTVS Protheus
    Desenvolvedor: Eder Venancio
    Data original: 14/02/2025

    Objetivo:
    Consultar dados de valores DEF por período e código,
    formatar os registros e exportá-los para arquivo CSV.
*/

User Function XGERARDFA()

    Local cMesAno := ""
    Local cPath   := ""
    Local aPergs  := {}
    Local nHandle := 0
    Local cMes    := Space(2)
    Local cAno    := Space(4)
    Local cCodDef := Space(6)

    // Parâmetros de execução
    AAdd(aPergs, {1, "Mês",        cMes,    "", ".T.", "", ".T.", 120, .T.})
    AAdd(aPergs, {1, "Ano",        cAno,    "", ".T.", "", ".T.", 120, .T.})
    AAdd(aPergs, {1, "Código DEF", cCodDef, "", ".T.", "", ".T.",  80, .T.})

    If ParamBox(aPergs, "Informe os parâmetros")

        cMesAno := MV_PAR02 + MV_PAR01
        cCodDef := AllTrim(MV_PAR03)

        // Validação do período informado
        If Empty(cMesAno) .Or. Len(cMesAno) != 6
            MsgAlert("Período inválido. Informe mês e ano.", "Atenção")
            Return
        EndIf

        If Val(MV_PAR01) < 1 .Or. Val(MV_PAR01) > 12
            MsgAlert("Mês inválido. Informe um valor entre 01 e 12.", "Atenção")
            Return
        EndIf

        If Empty(cCodDef)
            MsgAlert("Informe o Código DEF.", "Atenção")
            Return
        EndIf

        // Seleção do arquivo de saída
        cPath := tFileDialog( ;
            "Arquivos CSV (*.csv)|*.csv", ;
            "Salvar arquivo", ;
            , ;
            "DFA_" + cMesAno + ".csv", ;
            .T., ;
            NIL ;
        )

        If Empty(cPath)
            Return
        EndIf

        // Garante a extensão CSV
        If Lower(SubStr(cPath, -4)) != ".csv"
            cPath += ".csv"
        EndIf

        // Criação do arquivo de saída
        nHandle := FCreate(cPath)

        If nHandle < 0
            MsgAlert("Erro ao criar o arquivo de saída.", "Erro")
            Return
        EndIf

        Processa( ;
            {|| PorcReport(nHandle, cMesAno, cCodDef)}, ;
            "Gerando relatório DEF" ;
        )

        FClose(nHandle)

        MsgInfo("Arquivo gerado: " + cPath, "Sucesso")

    EndIf

Return


Static Function PorcReport(nHandle, cMesAno, cCodDef)

    Local cLinha  := ""
    Local cAlias  := GetNextAlias()
    Local nAtual  := 0
    Local nTotal  := 0

    // Consulta dos dados DEF
    BeginSql Alias cAlias

        SELECT
            SUBSTRING(VD9_CPODEF, 1, 3)
            + '00'
            + SUBSTRING(VD9_CPODEF, 4, 2)
            + SUBSTRING(VDC_FILIAL, 5, 2)
            + ';'
            + CASE
                WHEN VDC_VALOR = 0 THEN '0'
                ELSE TRIM(STR(VDC_VALOR, 20, 2))
              END AS RESULTADO

        FROM VDC010

        INNER JOIN VD9010
            ON VD9_CODCON = VDC_CODCON
            AND VD9010.D_E_L_E_T_ = ''

        WHERE VDC010.D_E_L_E_T_ = ''
            AND SUBSTRING(VDC_DATA, 1, 6) = %Exp:cMesAno%
            AND VDC_VALOR <> 0
            AND VDC_CODDEF = %Exp:cCodDef%
            AND VD9_CODDEF = %Exp:cCodDef%

        ORDER BY
            VD9_CPODEF,
            VDC_FILIAL

    EndSql

    // Conta os registros retornados
    (cAlias)->(DbGoTop())
    Count To nTotal
    ProcRegua(nTotal)
    (cAlias)->(DbGoTop())

    // Exporta os registros
    While (cAlias)->(!Eof())

        nAtual++

        IncProc( ;
            "Exportando registro " + ;
            cValToChar(nAtual) + ;
            " de " + ;
            cValToChar(nTotal) ;
        )

        cLinha += (cAlias)->RESULTADO + CRLF

        (cAlias)->(DbSkip())

    EndDo

    If !Empty(cLinha)
        FWrite(nHandle, cLinha)
    EndIf

    // Libera a área de consulta
    (cAlias)->(DbCloseArea())

Return
