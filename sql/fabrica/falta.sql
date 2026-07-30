SELECT
    RTRIM(o.dopps) as 'OperacaoProd',
    RTRIM(o.dopes) as 'Desc_Operacao',
    RTRIM(t.dopps) as 'Fase',
    CAST(t.nops AS INT) AS 'OP',
    CAST(o.numes AS INT) as 'Num_Pedido',
    CAST(t.numps AS INT) AS 'num OP',
    CAST(o.dataps AS DATE) as 'Abertura_Pedido',
    CAST(o.dataes AS DATE) as 'Processamento_op',
    DATEDIFF(DAY, CAST(o.dataes AS DATE), CAST(GETDATE() AS DATE)) AS 'Dias em aberto',
    CAST(t.datars AS DATE) AS 'Data',
    CAST(t.qtds AS INT) AS 'Qtd',
    RTRIM(t.grupods) as 'Grupo Destino',
    RTRIM(t.contads) as 'Conta Destino',
    RTRIM(t.codpds) as 'Cod_Prod',
    RTRIM( b.nivelqs ) AS 'Metal',
    RTRIM( b.mercs ) AS "Gde. Gr.",
    CAST(b.pesoms AS DECIMAL(10,2))AS "Peso",
    CASE WHEN RTRIM(t.dopps) LIKE 'ENCERRAMENTO DE OP' THEN '10'
     WHEN RTRIM(t.dopps) LIKE 'MOVIMENTACAO ESTOQUE' THEN '1'
     WHEN RTRIM(t.dopps) LIKE 'MUDANCA DE FASE' THEN '2'
     WHEN RTRIM(t.dopps) LIKE 'ORDEM DE PRODUÇÃO' THEN '0'
     WHEN RTRIM(t.dopps) LIKE 'DIVISAO DE OP' THEN '1'
     WHEN RTRIM(t.dopps) LIKE 'ENCERRA OP SEM COMP' THEN '10'
     WHEN RTRIM(t.dopps) LIKE 'AGREGAR MATERIAL' THEN '2'
     WHEN RTRIM(t.dopps) LIKE 'ENCERRAMENTO N.PRODZ' THEN '10'
     WHEN RTRIM(t.dopps) LIKE 'ENCERRA ESTOQUE FAB' THEN '10'
ELSE '' 
END AS 'Peso_Fase'
from SLJMFAS t with(nolock)
    INNER JOIN sljpro AS b with (nolock) ON t.codpds = b.cpros
    INNER JOIN sljopi o with(nolock) ON o.nops = t.nops
WHERE t.contads LIKE '%FALTA%'
