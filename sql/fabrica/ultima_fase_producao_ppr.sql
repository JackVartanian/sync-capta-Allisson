
SELECT
    RTRIM(o.dopps) as 'OperacaoProd',
    RTRIM(o.dopes) as 'Desc_Operacao',
    RTRIM(t.dopps) as 'Fase',
    CAST(t.nops AS INT) AS 'OP',
    CAST(o.numes AS INT) as 'Num_Pedido',
    CAST(t.numps AS INT) AS 'num OP',
    MAX(CAST(o.dataps AS DATE)) as 'Abertura_Pedido',
    MAX(CAST(o.dataes AS DATE)) as 'Processamento_op',
    DATEDIFF(DAY, CAST(o.dataes AS DATE), CAST(GETDATE() AS DATE)) AS 'Dias em aberto',
    MAX(CAST(t.datars AS DATE)) AS 'Data',
    MIN(CASE 
    WHEN CAST(t.qtds AS INT) > CAST(tm.MinQtde AS INT) 
        THEN CAST(tm.MinQtde AS INT)
    ELSE CAST(t.qtds AS INT)
    END) AS 'Qtd',
    RTRIM(t.grupods) as 'Grupo Destino',
    RTRIM(t.contads) as 'Conta Destino',
    RTRIM(t.codpds) as 'Cod_Prod',
    RTRIM( b.cftios ) AS "Tab. Pr.",
    RTRIM( b.nivelqs ) AS 'Metal',
    RTRIM( b.mercs ) AS "Gde. Gr.",
    MIN(CAST(b.pesoms AS DECIMAL(10,2))) AS "Peso",
    MAX(CAST(tm.Maior_Peso_Fase AS INT)) AS Peso_Fase
FROM SLJMFAS t with(nolock)
    LEFT JOIN sljpro AS b with (nolock) ON b.cpros = t.codpds
    LEFT JOIN sljopi AS o with(nolock) ON o.nops = t.nops
    INNER JOIN (
    SELECT
        CAST(t.nops AS INT) AS 'OP',
        MAX(t.datas) as MaxDate,
        MIN(CAST(t.qtds AS INT)) as MinQtde,
        MAX(
    CASE 
        WHEN RTRIM(t.dopps) LIKE 'MOVIMENTACAO ESTOQUE' THEN 1
        WHEN RTRIM(t.dopps) LIKE 'MUDANCA DE FASE' THEN 2
        WHEN RTRIM(t.dopps) LIKE 'ORDEM DE PRODUÇÃO' THEN 0
        WHEN RTRIM(t.dopps) LIKE 'DIVISAO DE OP' THEN 1
        WHEN RTRIM(t.dopps) LIKE 'ENCERRAMENTO DE OP' THEN 10
        WHEN RTRIM(t.dopps) LIKE 'ENCERRA OP SEM COMP' THEN 10
        WHEN RTRIM(t.dopps) LIKE 'AGREGAR MATERIAL' THEN 2
        WHEN RTRIM(t.dopps) LIKE 'ENCERRAMENTO N.PRODZ' THEN 10
        WHEN RTRIM(t.dopps) LIKE 'ENCERRA ESTOQUE FAB' THEN 10
        ELSE '' 
    END ) AS 'Maior_Peso_Fase'
    FROM SLJMFAS t with(nolock)
        LEFT JOIN sljopi AS o with(nolock) ON o.nops = t.nops
    WHERE o.dopps NOT LIKE 'ORDEM DE SERVIÇO'
    GROUP BY t.nops
) tm on t.nops = tm.OP and t.datas = tm.MaxDate and t.qtds = tm.MinQtde
WHERE o.dataps >= '2023-01-01'
    AND RTRIM(t.contads) = 'PRÉ-PRODUÇ'
    AND o.dopps NOT LIKE 'ORDEM DE SERVIÇO'
-- AND tm.Maior_Peso_Fase <> 10
GROUP BY t.nops, t.numps, o.dopps, o.dopes, t.dopps, o.numes, o.dataps, o.dataes, t.datars, t.grupods, t.contads, t.codpds, b.cftios, b.nivelqs, b.mercs, b.pesoms
ORDER BY OP DESC