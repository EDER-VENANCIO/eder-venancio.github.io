/*
Projeto: Análise de estoque e custo
Tecnologia: SQL Server / TOTVS Protheus
Objetivo: consolidar quantidade e valor estimado do estoque
por filial e produto.

Exemplo demonstrativo.
Validar os campos e regras de custo no ambiente de destino.
*/

SELECT
    B2_FILIAL AS FILIAL,
    B2_COD    AS PRODUTO,
    SUM(B2_QATU) AS QUANTIDADE_ESTOQUE,
    SUM(B2_QATU * B2_CM1) AS VALOR_ESTIMADO_ESTOQUE
FROM SB2010
WHERE D_E_L_E_T_ = ''
  AND B2_QATU <> 0
GROUP BY
    B2_FILIAL,
    B2_COD
ORDER BY
    B2_FILIAL,
    B2_COD;
