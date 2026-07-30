-- select top 10 * from SLJEEST as t
-- where RTRIM( t.DOPES) IN ('ADTO ENCOMENDA ', 'ENCOMENDA E-COMM')
-- -- AND t.datas >= '2025-01-01'
-- AND t.numes = '9248'
-- -- AND numes = '9264'

-- select top 10 * from sljopi as t
-- -- where t.numes = '4537'
-- where t.dataes >= '2025-01-01'
-- AND RTRIM( t.DOPES) IN ('ADTO ENCOMENDA ', 'ENCOMENDA E-COMM')


-- select top 100 * from SLJMFAS as t
-- where t.datas >= '2025-01-01'
-- and RTRIM(t.dopps) LIKE 'ENCERRAMENTO DE OP'
-- -- AND RTRIM( t.DOPES) IN ('ADTO ENCOMENDA ', 'ENCOMENDA E-COMM')
-- AND t.numps = '4537'

-- SELECT DISTINCT
--     RTRIM(dopes) as 'Desc_Operacao'
-- FROM sljeest with(nolock)
-- WHERE RTRIM(dopes) LIKE '%ENCOMENDA%'
-- ORDER BY RTRIM(dopes)


-- Query to track order status and details
SELECT
    RTRIM(e.emps) AS "Loja",
    RTRIM(e.dopes) AS 'Desc_Operacao',
    CAST(e.numes AS INT) AS 'Num_Pedido',
    CAST(e.datas AS DATE) AS 'Abertura_Encomenda',
    CAST(o.dataes AS DATE) AS 'Abertura_Pedido',
    DATEDIFF(DAY, CAST(o.dataes AS DATE), GETDATE()) AS 'Dias_em_aberto',
    CAST(e.prazoents AS DATE) AS 'Prev_Entrega',
    RTRIM(e.vends) AS 'Cod_Consultora',
    RTRIM(cons.rclis) AS 'Consultora',
    RTRIM(e.contaos) AS 'Conta_Cliente',
    RTRIM(cli.rclis) AS 'Cliente',
    RTRIM(cli.cpfs) AS 'CPF',
    RTRIM(o.cpros) AS 'Cod_Prod',
    CASE 
        WHEN t.nops IS NOT NULL THEN 'Baixado'
        ELSE 'Aberto'
    END AS 'Status'
FROM sljeest e WITH(NOLOCK)
    LEFT JOIN sljcli cli WITH(NOLOCK) ON e.contaos = cli.iclis
    LEFT JOIN sljcli cons WITH(NOLOCK) ON e.vends = cons.iclis
    LEFT JOIN sljopi o WITH(NOLOCK) ON e.emps = o.empds 
        AND e.numes = o.numes
    LEFT JOIN SLJMFAS t WITH(NOLOCK) ON o.nops = t.nops
        AND t.datas >= '2024-01-01'
        AND RTRIM(t.dopps) = 'ENCERRAMENTO DE OP'
WHERE RTRIM(e.dopes) LIKE '%ADTO%'
    AND e.datas >= '2024-01-01'
ORDER BY e.datas DESC