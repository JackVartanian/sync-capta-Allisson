SELECT DISTINCT
    RTRIM(o.dopps) as 'OperacaoProd',
    RTRIM(o.dopes) as 'Desc_Operacao',
    RTRIM(t.dopps) as 'Fase',
    RTRIM(fa.Fase) as 'Ultima_Fase',
    CAST(t.nops AS INT) AS 'OP',
    CAST(o.numes AS INT) as 'Num_Pedido',
    -- CAST(t.numps AS INT) AS 'num OP',
    CAST(o.dataps AS DATE) as 'Abertura_Pedido',
    CAST(o.dataes AS DATE) as 'Processamento_op',
    DATEDIFF(DAY, CAST(o.dataes AS DATE), CAST(GETDATE() AS DATE)) AS 'Dias em aberto',
    MAX(CAST(t.datas AS DATE)) AS 'Data',
    CAST(do.[Data] AS DATE) AS 'Data Conclusao Funcionario',
    CASE 
    WHEN MIN(CAST(t.qtds AS INT)) > MIN(CAST(tm.MinQtde AS INT)) 
        THEN MIN(CAST(tm.MinQtde AS INT))
    ELSE MIN(CAST(t.qtds AS INT))
    END AS 'Qtd',
    RTRIM(t.grupoos) as 'Grupo Origem',
    RTRIM(t.contaos) as 'Conta Origem',
    CASE
   WHEN fo.Nome IS NULL THEN RTRIM(t.contaos)
   ELSE fo.Nome
   END AS 'Nome Origem',
    RTRIM(t.grupods) as 'Grupo Destino',
    RTRIM(t.contads) as 'Conta Destino',
    CASE
   WHEN fd.Nome IS NULL THEN RTRIM(t.contads)
   ELSE fd.Nome
   END AS 'Nome Destino',
    RTRIM(t.codpds) as 'Cod_Prod',
    RTRIM( b.nivelqs ) AS 'Metal',
    RTRIM( b.mercs ) AS "Gde. Gr.",
    RTRIM( b.cftios ) AS "Tab. Pr.",
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
FROM SLJMFAS t WITH(NOLOCK)
    LEFT JOIN sljpro b with (nolock) ON t.codpds = b.cpros
    LEFT JOIN sljopi o with(nolock) ON o.nops = t.nops
    -- LEFT JOIN NOME FUNCIONARIO DESTINO
    LEFT JOIN(
      SELECT
        RTRIM( a.iclis ) AS Cod_Vend,
        RTRIM( a.rclis ) AS Nome
    FROM sljcli a WITH(NOLOCK)
    WHERE grupos = 'FUNCIONARI' OR
        grupos = 'FUNCIONAR' OR
        grupos = 'FORNECEDOR'
   ) fd ON t.contads = fd.Cod_Vend
    -- LEFT JOIN NOME FUNCIONARIO ORIGEM
    LEFT JOIN(
      SELECT
        RTRIM( a.iclis ) AS Cod_Vend,
        RTRIM( a.rclis ) AS Nome
    FROM sljcli a WITH(NOLOCK)
    WHERE grupos = 'FUNCIONARI' OR
        grupos = 'FUNCIONAR' OR
        grupos = 'FORNECEDOR'
   ) fo ON t.contaos = fo.Cod_Vend
    -- LEFT JOIN ULTIMA FASE DA PRODUCAO
    LEFT JOIN (
    SELECT
        RTRIM(t.dopps) as 'Fase',
        CAST(t.nops AS INT) AS 'OP',
        CAST(o.numes AS INT) as 'Num_Pedido'
    FROM SLJMFAS t with(nolock)
        LEFT JOIN sljopi o with(nolock) ON o.nops = t.nops
        INNER JOIN (
    SELECT
            b.dataes as dataes,
            CAST(b.nops AS INT) as nops,
            CAST(b.numes AS INT) as numes,
            sum(b.qtds) as qtds
        FROM sljopi b with (nolock)
        GROUP by b.dataes, b.nops, b.numes
) ts on t.nops = ts.nops
        INNER JOIN (
    select nops, max(datas) as MaxDate, min(qtds) as MinQtde
        from SLJMFAS with(nolock)
        WHERE datas >= '2023/01/01 00:00:00'
        group by nops
) tm on t.nops = tm.nops and t.datas = tm.MaxDate and t.qtds = tm.MinQtde
   ) fa on t.nops = fa.OP
    -- LEFT JOIN MENOR QUANTIDADE
    LEFT JOIN (
    select nops,
        max(datas) as MaxDate,
        min(qtds) as MinQtde
    from SLJMFAS with(nolock)
    WHERE datas >= '2023/01/01 00:00:00'
    group by nops
) tm on t.nops = tm.nops
    -- LEFT JOIN ULTIMA DATA
    LEFT JOIN (
    SELECT DISTINCT
        CONCAT(CAST(t.nops AS INT), RTRIM(t.grupoos), RTRIM(t.contaos)) AS 'ID',
        MAX (CAST(t.datas AS DATE)) AS 'Data'
    FROM SLJMFAS t WITH(NOLOCK)
    WHERE t.datas >= '2023/01/01 00:00:00'
    GROUP BY CAST(t.nops AS INT), RTRIM(t.grupoos), RTRIM(t.contaos)

) do ON do.ID = CONCAT(CAST(t.nops AS INT), RTRIM(t.grupods), RTRIM(t.contads))

WHERE t.datas >= '2023/01/01 00:00:00' 
-- AND t.nops = '514210002' and t.contads = 'PMAT003055'
GROUP BY
RTRIM(o.dopps),
RTRIM(o.dopes),
RTRIM(t.dopps),
RTRIM(fa.Fase),
CAST(t.nops AS INT),
CAST(o.numes AS INT),
CAST(o.dataps AS DATE),
CAST(o.dataes AS DATE),
CAST(do.[Data] AS DATE),
RTRIM(t.grupoos),
RTRIM(t.contaos),
fo.Nome,
RTRIM(t.grupods),
RTRIM(t.contads),
fd.Nome,
RTRIM(t.codpds),
RTRIM(b.nivelqs),
RTRIM(b.mercs),
RTRIM(b.cftios),
CAST(b.pesoms AS DECIMAL(10,2))