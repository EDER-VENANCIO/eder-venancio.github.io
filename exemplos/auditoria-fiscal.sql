/*
Projeto: Análise e auditoria de ICMS-ST
Tecnologia: SQL Server / TOTVS Protheus

Objetivo:
Consultar informações fiscais de uma nota de entrada,
comparando valores registrados de ICMS-ST com valores
recalculados conforme os parâmetros do cenário analisado.

Observação:
Os percentuais utilizados são específicos deste exemplo
e devem ser validados conforme a operação fiscal aplicável.
*/

DECLARE @FILIAL  VARCHAR(10) = '123456';
DECLARE @TIPOMOV CHAR(1)     = 'E';
DECLARE @NFISCAL VARCHAR(20) = '999999999';

SELECT
    FT.FT_FILIAL AS 'FILIAL',
    FT.FT_ESTADO AS 'ORIGEM / DESTINO',
    FT.FT_CFOP AS 'CFOP',
    FT.FT_TES AS 'TES',
    FT.FT_NFISCAL AS 'NOTA',

    CASE
        WHEN FT.FT_TIPOMOV = 'E' THEN 'Entrada'
        WHEN FT.FT_TIPOMOV = 'S' THEN 'Saída'
        ELSE 'Não Definido'
    END AS 'TIPO_MOVIMENTO',

    FT.FT_EMISSAO AS 'PERIODO',
    FT.FT_CLIEFOR AS 'CLIENTE',

    CASE
        WHEN A1.A1_TIPO = 'F' THEN 'Cons.Final'
        WHEN A1.A1_TIPO = 'L' THEN 'Produtor Rural'
        WHEN A1.A1_TIPO = 'R' THEN 'Revendedor'
        WHEN A1.A1_TIPO = 'S' THEN 'Solidario'
        WHEN A1.A1_TIPO = 'X' THEN 'Exportacao'
        ELSE 'Nao Definido'
    END AS 'TIPO_CLIENTE',

    CASE
        WHEN A1.A1_CONTRIB = '1' THEN 'Sim'
        WHEN A1.A1_CONTRIB = '2' THEN 'Não'
        ELSE 'Nao Definido'
    END AS 'CONTRIBUINTE',

    FT.FT_LOJA AS 'LOJA',
    FT.FT_PRODUTO AS 'PRODUTO',
    B1.B1_POSIPI AS 'NCM',
    FT.FT_TIPO AS 'TIPO',
    FT.FT_CODISS AS 'COD_SERVICO',

    /* ICMS */
    FT.FT_CLASFIS AS 'CST_ICMS',
    FT.FT_BASEICM AS 'BC_ICMS',
    FT.FT_ALIQICM AS 'ALIQ_ICMS',
    FT.FT_VALICM AS 'VLR_ICMS',
    FT.FT_ISENICM AS 'ICMS_ISENTO',
    FT.FT_OUTRICM AS 'ICMS_OUTRAS',
    FT.FT_BASERET AS 'BC_ICMS_ST_ERRADA',

    ROUND(
        FT.FT_OUTRICM * (63.87 / 100.0) + FT.FT_OUTRICM,
        2
    ) AS 'BC_ICMS_ST_CORRETA',

    FT.FT_ICMSRET AS 'VLR_ICMS_ST_ERRADA',

    ROUND(
        (
            FT.FT_OUTRICM
            * (1 + 63.87 / 100.0)
            * (20.0 / 100.0)
        )
        - (FT.FT_TOTAL * (4.0 / 100.0)),
        2
    ) AS 'VLR_ICMS_ST_CORRETA',

    ROUND(
        (
            FT.FT_OUTRICM
            * (1 + 63.87 / 100.0)
            * (20.0 / 100.0)
        )
        - (FT.FT_TOTAL * (4.0 / 100.0))
        - FT.FT_ICMSRET,
        2
    ) AS 'VLR_DIFERENCA_ICMS_ST',

    FT.FT_CREDST AS 'CRD_ICMS_ST',
    FT.FT_MARGEM AS 'MVA_ST',
    FT.FT_DIFAL AS 'DIFAL_ICMS',
    FT.FT_ICMSCOM AS 'VLR_ICMS_COMPL',
    FT.FT_VFCPDIF AS 'VLR_FECP_UF_DEST',
    FT.FT_ICMSDIF AS 'ICMS_DIFERIDO',

    /* PIS */
    FT.FT_BASEPIS AS 'BASE_PIS',
    FT.FT_ALIQPIS AS 'ALIQ_PIS',
    FT.FT_VALPIS AS 'VLR_PIS',
    FT.FT_CSTPIS AS 'SIT_TRIB_PIS',

    /* COFINS */
    FT.FT_BASECOF AS 'BASE_COF',
    FT.FT_CSTCOF AS 'SIT_TRIB_COF',
    FT.FT_ALIQCOF AS 'ALIQ_COF',
    FT.FT_VALCOF AS 'VLR_COF',

    /* IPI */
    FT.FT_CTIPI AS 'CST_IPI',
    FT.FT_BASEIPI AS 'BASE_IPI',
    FT.FT_ALIQIPI AS 'ALIQ_IPI',
    FT.FT_VALIPI AS 'VAL_IPI',
    FT.FT_ISENIPI AS 'VAL_IPI_ISENTO',
    FT.FT_OUTRIPI AS 'VAL_IPI_OUTROS',

    /* EXCEÇÃO FISCAL */
    BZ.BZ_GRTRIB AS 'GRP_TRIB_PRODUTO',
    A1.A1_GRPTRIB AS 'GRP_TRIB_CLIENTE'

FROM SFT010 AS FT

INNER JOIN SF3010 AS F3
    ON FT.FT_NFISCAL = F3.F3_NFISCAL
    AND FT.FT_SERIE = F3.F3_SERIE
    AND FT.FT_FILIAL = F3.F3_FILIAL
    AND FT.FT_CLIEFOR = F3.F3_CLIEFOR
    AND F3.D_E_L_E_T_ = ' '

INNER JOIN SBZ010 AS BZ
    ON FT.FT_PRODUTO = BZ.BZ_COD
    AND FT.FT_FILIAL = BZ.BZ_FILIAL
    AND BZ.D_E_L_E_T_ = ' '

INNER JOIN SA1010 AS A1
    ON FT.FT_CLIEFOR = A1.A1_COD
    AND FT.FT_LOJA = A1.A1_LOJA
    AND A1.D_E_L_E_T_ = ' '

INNER JOIN SB1010 AS B1
    ON FT.FT_PRODUTO = B1.B1_COD
    AND B1.D_E_L_E_T_ = ''

WHERE
    FT.D_E_L_E_T_ = ' '
    AND FT.FT_FILIAL = @FILIAL
    AND FT.FT_TIPOMOV = @TIPOMOV
    AND FT.FT_NFISCAL = @NFISCAL

ORDER BY
    FT.R_E_C_N_O_;
