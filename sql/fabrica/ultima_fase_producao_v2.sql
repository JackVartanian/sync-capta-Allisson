-- Query to track order status and production phases with optimized joins and filtering
SELECT
    RTRIM(e.emps) AS "Loja",
    RTRIM(e.dopes) AS 'Desc_Operacao',
    RTRIM(t.dopps) AS 'Fase',
    RTRIM(t.grupods) as 'Grupo_Destino',
    RTRIM(t.contads) as 'Conta_Destino',
    RTRIM(q.rclis) AS 'Nome_Destino',
    CAST(e.numes AS INT) AS 'Num_Pedido',
    CAST(e.datas AS DATE) AS 'Abertura_Encomenda',
    CAST(o.dataes AS DATE) AS 'Abertura_Pedido',
    DATEDIFF(DAY, CAST(o.dataes AS DATE), GETDATE()) AS 'Dias_em_aberto',
    CAST(e.prazoents AS DATE) AS 'Prev_Entrega',
    RTRIM(e.vends) AS 'Cod.Consultora',
    RTRIM(K.RCLIS) AS 'Consultora',
    RTRIM(e.contaos) AS 'Conta_Cliente',
    RTRIM(d.rclis) AS 'Cliente',
    RTRIM(d.cpfs) AS 'CPF',
    RTRIM(o.cpros) AS 'Cod_Prod',
    CASE 
        WHEN t.nops IS NOT NULL AND RTRIM(t.dopps) = 'ENCERRAMENTO DE OP' THEN 'Baixado'
        ELSE 'Aberto'
    END as 'Status'
FROM sljeest e with(nolock)
LEFT JOIN sljcli d with(nolock) ON e.contaos = d.iclis
LEFT JOIN SLJCLI K with(nolock) ON e.vends = K.ICLIS
LEFT JOIN sljopi o with(nolock) ON e.emps = o.empds
    AND e.numes = o.numes 
    -- AND e.datas >= o.dataes
LEFT JOIN (
    SELECT 
        m.nops,
        m.dopps,
        m.datas,
        m.contads,
        m.grupods
    FROM SLJMFAS m with(nolock)
    INNER JOIN (
        SELECT nops, MAX(datas) as last_date
        FROM SLJMFAS with(nolock)
        WHERE datas >= '2024-01-01'
        GROUP BY nops
    ) latest ON m.nops = latest.nops AND m.datas = latest.last_date
) t ON o.nops = t.nops
LEFT JOIN sljcli q with(nolock) ON t.contads = q.iclis
WHERE RTRIM(e.dopes) LIKE '%ADTO%'
    AND e.datas >= '2024-01-01'
ORDER BY CAST(e.datas AS DATE) DESC
OPTION (RECOMPILE);