/*
Projeto: Auditoria fiscal
Objetivo: consultar documentos fiscais por período.
Exemplo demonstrativo para portfólio.
*/

SELECT
    D1_FILIAL,
    D1_DOC,
    D1_SERIE,
    D1_FORNECE,
    D1_LOJA,
    D1_TOTAL
FROM SD1010
WHERE D_E_L_E_T_ = ''
  AND D1_DTDIGIT BETWEEN '20260101' AND '20260131'
ORDER BY
    D1_FILIAL,
    D1_DTDIGIT;
