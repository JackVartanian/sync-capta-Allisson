SELECT
    CASE
    WHEN RTRIM( emps ) LIKE 'IGL' THEN 'IGU'
    WHEN RTRIM( emps ) LIKE 'FTH' THEN 'WEB'
    WHEN RTRIM( emps ) LIKE 'FFL' THEN 'BEL'
    WHEN RTRIM( emps ) LIKE 'LMA' THEN 'MAT'
    WHEN RTRIM( emps ) LIKE 'MPV' THEN 'MP2'
    ELSE RTRIM( emps )
END AS "Empresa",
    datas AS 'Data',
    RTRIM( dopes ) AS 'Operacao',
    RTRIM( numes ) AS 'Numero OP',
    RTRIM( contas ) AS 'Cod. Vend',
    CASE
    WHEN RTRIM( dopes ) LIKE 'TROCA COM CREDITO' THEN -bases
    WHEN RTRIM( dopes ) LIKE 'DEVOLUÇÃO DE VENDA' THEN -bases
    ELSE bases
END AS 'Valor Base',
    percs AS 'Percentual',
    CASE
    WHEN RTRIM( dopes ) LIKE 'TROCA COM CREDITO' THEN -comissaos
    WHEN RTRIM( dopes ) LIKE 'DEVOLUÇÃO DE VENDA' THEN -comissaos
    ELSE comissaos
END AS 'Comissao'
FROM SLJCOMIS  with(nolock)
WHERE grupos = '21022' AND datas >= '2017/01/01 00:00:00'
ORDER BY datas DESC