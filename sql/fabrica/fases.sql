SELECT
   RTRIM(o.dopps) AS 'OperacaoProd',
   RTRIM(o.dopes) AS 'Desc_Operacao',
   RTRIM(t.dopps) AS 'Fase',
   RTRIM(t.nops) AS 'OP',
   CAST(o.numes AS INT) as 'Num_Pedido',
   CAST(t.numps AS INT)    AS 'num OP',
   CAST(o.dataps AS DATE) as 'Abertura_Pedido',
   CAST(o.dataes AS DATE) as 'Processamento_op',
   DATEDIFF(DAY, CAST(o.dataes AS DATE), CAST(GETDATE() AS DATE)) AS 'Dias desde abertura',
   CAST(t.datars AS DATE)   AS 'Data',
CASE 
    WHEN CAST(t.qtds AS INT) > CAST(tm.MinQtde AS INT) 
        THEN CAST(tm.MinQtde AS INT)
    ELSE CAST(t.qtds AS INT)
    END AS 'Qtd',
   
   RTRIM(t.grupods)  AS 'Grupo Destino',
   RTRIM(t.contads)  AS 'Conta Destino',
   CASE
   WHEN fo.Nome IS NULL THEN RTRIM(t.contads)
   ELSE fo.Nome
   END AS 'Nome Destino',
   RTRIM( b.cftios ) AS "Tab. Pr.",
   RTRIM( b.nivelqs ) AS 'Metal',
   RTRIM( f.dgrus ) AS "Desc. Gr.",
   RTRIM(t.codpds)   AS 'Cod_Prod',
   CAST(b.pesoms AS DECIMAL(10,2))AS "Peso",
   tp.Percentual AS 'Percentual',
   CASE WHEN RTRIM(t.dopps) LIKE 'ENCERRAMENTO DE OP' THEN '10'
     WHEN RTRIM(t.dopps) LIKE 'MOVIMENTACAO ESTOQUE' THEN '1'
     WHEN RTRIM(t.dopps) LIKE 'MUDANCA DE FASE' THEN '2'
     WHEN RTRIM(t.dopps) LIKE 'ORDEM DE PRODUÇÃO' THEN '0'
     WHEN RTRIM(t.dopps) LIKE 'DIVISAO DE OP' THEN '1'
     WHEN RTRIM(t.dopps) LIKE 'ENCERRA OP SEM COMP' THEN '10'
     WHEN RTRIM(t.dopps) LIKE 'AGREGAR MATERIAL' THEN '2'
     WHEN RTRIM(t.dopps) LIKE 'ENCERRAMENTO N.PRODZ' THEN '10'
     WHEN RTRIM(t.dopps) LIKE 'ENCERRA ESTOQUE FAB' THEN '10'
     ELSE ''  END  AS 'Peso Fase'
FROM SLJMFAS t WITH(NOLOCK)
   LEFT JOIN sljpro AS b with (nolock) ON t.codpds = b.cpros
   LEFT JOIN sljopi o with(nolock) ON o.nops = t.nops
   LEFT JOIN sljgru f WITH(NOLOCK) ON b.cgrus = f.cgrus

   LEFT JOIN(
      SELECT
      RTRIM( a.iclis ) AS Cod_Vend,
      RTRIM( a.rclis ) AS Nome
   FROM sljcli a WITH(NOLOCK)
   WHERE grupos = 'FUNCIONARI' OR
      grupos = 'FUNCIONAR' OR
      grupos = 'FORNECEDOR'
   ) fo ON t.contads = fo.Cod_Vend

   LEFT JOIN(
      SELECT
      RTRIM(NOPS) as OP,
      REPLACE(TPOPS, 'TRABALHADO ', '') as Percentual
   FROM SLJNENSI with (nolock)
   WHERE TPOPS LIKE '%TRABALHADO 3,5%%'
      OR TPOPS LIKE '%TRABALHADO 5%%'
   GROUP BY NOPS, TPOPS
   ) tp ON t.nops = tp.OP

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
    WHERE datas >= '2018/01/01 00:00:00'
    group by nops
) tm on t.nops = tm.nops and t.datas = tm.MaxDate and t.qtds = tm.MinQtde
-- WHERE o.dopps NOT LIKE '%SERVIÇO%'