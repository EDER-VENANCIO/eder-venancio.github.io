#Include "protheus.ch"

/*
    Projeto: Exportacao demonstrativa
    Tecnologia: ADVPL / TOTVS Protheus
    Objetivo: demonstrar estrutura de rotina,
    validacao de parametros e gravacao de arquivo.

    Exemplo para portfolio.
*/

User Function ExportaDEF()

    Local cArquivo := "\temp\exportacao_demo.txt"
    Local cConteudo := ""
    Local nHandle := -1
    Local lSucesso := .F.

    If Empty(cArquivo)
        MsgStop("Informe o caminho do arquivo.", "Exportacao")
        Return
    EndIf

    cConteudo := "ID;DESCRICAO" + CRLF
    cConteudo += "001;REGISTRO DEMONSTRATIVO" + CRLF

    nHandle := FCreate(cArquivo)

    If nHandle < 0
        MsgStop("Nao foi possivel criar o arquivo.", "Exportacao")
        Return
    EndIf

    If FWrite(nHandle, cConteudo) == Len(cConteudo)
        lSucesso := .T.
    EndIf

    FClose(nHandle)

    If lSucesso
        MsgInfo("Arquivo gerado com sucesso.", "Exportacao")
    Else
        MsgStop("Falha ao gravar o arquivo.", "Exportacao")
    EndIf

Return
