IF OBJECT_ID ('tempdb.dbo.#TMPUM', 'U') IS NOT NULL
DROP TABLE #TMPUM;
IF OBJECT_ID ('tempdb.dbo.#TMPDOIS', 'U') IS NOT NULL
DROP TABLE #TMPDOIS;
IF OBJECT_ID ('tempdb.dbo.#TMPTRES', 'U') IS NOT NULL
DROP TABLE #TMPTRES;
IF OBJECT_ID ('tempdb.dbo.#TMPQUATRO', 'U') IS NOT NULL
DROP TABLE #TMPQUATRO;
IF OBJECT_ID ('tempdb.dbo.#TMPCINCO', 'U') IS NOT NULL
DROP TABLE #TMPCINCO;

SELECT
    CASE
            WHEN RTRIM( a.emps ) LIKE 'IGL' THEN 'IGU'
            WHEN RTRIM( a.emps ) LIKE 'FSM' THEN 'DES'
            WHEN RTRIM( a.emps ) LIKE 'BAL' THEN 'BAT'
            WHEN RTRIM( a.emps ) LIKE 'CUR' THEN 'BAT'
            WHEN RTRIM( a.emps ) LIKE 'FTH' THEN 'WEB'
            WHEN RTRIM( a.emps ) LIKE 'FFL' THEN 'BEL'
            WHEN RTRIM( a.emps ) LIKE 'LMA' THEN 'MAT'
            WHEN RTRIM( a.emps ) LIKE 'MPV' THEN 'MP2'
            ELSE RTRIM( a.emps )
                END AS "Empresa",
    RTRIM( a.dopes ) AS "Operacao",
    RTRIM( F.OPERS ) AS "Tipo movimentacao",
    CAST (a.numes AS INTEGER ) AS "No.Oper",
    CAST( a.datas AS DATE ) AS "Data",
    CASE
            WHEN A.ICLIS LIKE '110401%' THEN (
                CASE
                WHEN F.OPERS = 'S' THEN RTRIM( G.CONTADS )
            ELSE RTRIM( G.CONTAOS )
            END)
            ELSE RTRIM( a.iclis )
            END AS "Cod. Cliente",
    CASE
                WHEN A.ICLIS = '' THEN ''
                ELSE (CASE
                WHEN A.ICLIS LIKE '110401%' THEN (CASE
                WHEN F.OPERS = 'S' THEN RTRIM( I.RCLIS )
                ELSE RTRIM( J.RCLIS )
                END)
                ELSE RTRIM( a.rclis )
                END)
                END AS "Nome Cliente",
    CASE 
                        WHEN RTRIM( a.vends ) IS NULL THEN 'WEB'
                        WHEN RTRIM( a.vends ) LIKE '0399/6' THEN 'WEB'
                        WHEN RTRIM( a.vends ) LIKE '0531/5' THEN 'WEB'
                        WHEN RTRIM( a.vends ) LIKE '0720/2' THEN 'WEB'
                        ELSE RTRIM( a.vends )
                    END AS "Cod. Vend.",
    CASE
                        WHEN RTRIM( K.RCLIS ) IS NULL THEN 'WEB'
                        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'ZAGO' + '%' THEN 'WEB'
                        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'PERSIO' + '%' THEN 'WEB'
                        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'MENINO' + '%' THEN 'WEB'
                        ELSE RTRIM( K.RCLIS )
                    END AS "Consultora",
    RTRIM( a.resps ) AS "Cod. Acomp.",
    RTRIM( e.rclis ) AS "Acompanhante",
    RTRIM( a.ggrus ) AS "Grande Grupo",
    RTRIM( a.cpros ) AS "Cod. Prod.",
    RTRIM( a.codbarras ) AS "Cod. Barras",
    RTRIM( a.codtams ) AS "Tamanho",
    CAST( a.qtds AS INTEGER ) AS "Qtd",
    CAST( a.totas AS DECIMAL(10) ) AS "Total Liq.",
    CAST( a.valrats AS DECIMAL(10) ) AS "Desconto",
    CAST( a.custos AS DECIMAL(10) ) AS "Custo",
    CASE
        WHEN f.opers = 'S' THEN CAST(  f.totas AS DECIMAL(10) )
        ELSE CAST( -1 * F.TOTAS AS DECIMAL(10) )
        END AS "Total Brt",
    RTRIM( g.notas ) AS "NF",
    CONCAT( RTRIM( a.iclis ),'-', CAST( a.datas AS DATE )) AS ID_Venda,
    RTRIM( G.CODEVENTS ) AS "Evento" INTO #TMPUM
FROM sljgdmi AS a with (nolock)
    LEFT JOIN sljcli AS e with (nolock) ON a.resps = e.iclis
    LEFT JOIN sljeesti AS f with (nolock) ON a.empdopnums + CONVERT (CHAR (8), a.codbarras) = f.empdopnums + CONVERT (CHAR (8), f.codbarras)
    LEFT JOIN sljeest AS g with (nolock) ON a.empdopnums = g.empdopnums
    LEFT JOIN SLJCLI AS J with (nolock) ON G.CONTAOS = J.ICLIS
    LEFT JOIN SLJCLI AS I with (nolock) ON G.CONTADS = I.ICLIS
    LEFT JOIN SLJCLI AS K with (nolock) ON K.ICLIS = A.VENDS
WHERE RTRIM( a.emps ) <> 'NY'
    AND a.vvistas <> 0
    AND a.tipoops NOT IN (91, 92)
    AND RTRIM( a.dopes ) NOT IN ('ADTO ENCOMENDA', 'VENDA PERMUTA', 'VENDA FUNCIONARIO', 'VENDA ENCOMENDA', 'VENDA ENC E-COMM')
    AND a.datas < '2024-01-01 00:00:00'
UNION ALL
SELECT
    CASE 
                WHEN RTRIM( EEST.emps ) LIKE 'IGL' THEN 'IGU'
                WHEN RTRIM( EEST.emps ) LIKE 'BAL' THEN 'BAT'
                WHEN RTRIM( EEST.emps ) LIKE 'CUR' THEN 'BAT'
                WHEN RTRIM( EEST.emps ) LIKE 'FSM' THEN 'DES'
                WHEN RTRIM( EEST.emps ) LIKE 'FTH' THEN 'WEB'
                WHEN RTRIM( EEST.emps ) LIKE 'FFL' THEN 'BEL'
                WHEN RTRIM( EEST.emps ) LIKE 'LMA' THEN 'MAT'
                WHEN RTRIM( EEST.emps ) LIKE 'MPV' THEN 'MP2'
                ELSE RTRIM( EEST.emps )
            END AS "Empresa",
    RTRIM(EEST.dopes) AS "Operacao",
    RTRIM( EESTI.OPERS ) AS "Tipo movimentacao",
    CAST (EEST.numes AS INTEGER ) AS "No.Oper",
    CAST( EEST.datas AS DATE ) AS "Data",
    CASE
        WHEN EEST.Contads LIKE '110401%' THEN (
            CASE
                WHEN EESTI.OPERS = 'S' THEN RTRIM( EEST.CONTADS )
                ELSE RTRIM( EEST.CONTAOS )
                END)
                ELSE RTRIM( EEST.Contads )
        END AS "Cod. Cliente",
    CASE
                WHEN I.RCLIS = '' THEN ''
                ELSE (CASE
                WHEN EEST.Contads LIKE '110401%' THEN (CASE
                WHEN EESTI.OPERS = 'S' THEN RTRIM( I.RCLIS )
                ELSE RTRIM( J.RCLIS )
                END)
                ELSE RTRIM( I.RCLIS )
                END)
                END AS "Nome Cliente",
    CASE 
        WHEN RTRIM( EEST.vends ) IS NULL THEN 'WEB'
        WHEN RTRIM( EEST.vends ) LIKE '0399/6' THEN 'WEB'
        WHEN RTRIM( EEST.vends ) LIKE '0531/5' THEN 'WEB'
        WHEN RTRIM( EEST.vends ) LIKE '0720/2' THEN 'WEB'
        ELSE RTRIM( EEST.vends )
    END AS "Cod. Vend.",
    CASE
        WHEN RTRIM( K.RCLIS ) IS NULL THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'ZAGO' + '%' THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'PERSIO' + '%' THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'MENINO' + '%' THEN 'WEB'
        ELSE RTRIM( K.RCLIS )
    END AS "Consultora",
    RTRIM(EEST.resps) AS "Cod. Acomp.",
    RTRIM(e.rclis) AS "Acompanhante",
    RTRIM(B.MERCS) AS "Grande Grupo",
    RTRIM(EESTI.cpros) AS "Cod. Prod.",
    RTRIM(EESTI.codbarras) AS "Cod. Barras",
    RTRIM(M.codtams) AS "Tamanho",
    CASE 
        WHEN RTRIM( EESTI.OPERS ) = 'S' THEN CAST( EESTI.qtds AS INTEGER )
        ELSE CAST( EESTI.qtds AS INTEGER ) * -1 
    END AS "Qtd",
    CASE
        WHEN RTRIM( EESTI.OPERS ) = 'S' THEN CAST( EESTI.totas + eesti.valrats AS DECIMAL(10))
        ELSE CAST( EESTI.totas + eesti.valrats AS DECIMAL(10)) * -1
    END AS "Total Liq.",
    CAST( EESTI.valrats AS DECIMAL(10) ) AS "Desconto",
    CAST( B.PCUSS AS DECIMAL(10) ) AS "Custo",
    CASE
        WHEN RTRIM( EESTI.OPERS ) = 'S' THEN CAST( EESTI.unitorigs AS DECIMAL(10) )
        ELSE CAST( EESTI.unitorigs AS DECIMAL(10) ) * -1
    END AS "Total Brt",
    RTRIM( EEST.notas ) AS "NF",
    CONCAT( EEST.Contads,'-', CAST( EEST.datas AS DATE )) AS ID_Venda,
    RTRIM( EEST.codevents ) AS "Evento"
FROM SLJEEST AS EEST with(nolock)
    LEFT JOIN SLJEESTI AS EESTI with(nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
    LEFT JOIN sljpro AS b with(nolock) ON EESTI.cpros = b.cpros
    LEFT JOIN sljcli AS e with(nolock) ON EEST.resps = e.iclis
    LEFT JOIN SLJCLI AS J with (nolock) ON EEST.CONTAOS = J.ICLIS
    LEFT JOIN SLJCLI AS I with (nolock) ON EEST.CONTADS = I.ICLIS
    LEFT JOIN SLJCLI AS K with(nolock) ON K.ICLIS = EEST.VENDS
    LEFT JOIN sljeti AS M with(nolock) ON EESTI.codbarras = M.cbars
WHERE RTRIM( EEST.emps ) <> 'NY'
    AND EESTI.unitorigs <> 0
    AND RTRIM( EEST.DOPES) NOT IN ('VENDA PERMUTA', 'VENDA FUNCIONARIO', 'VENDA ENCOMENDA', 'VENDA ENC E-COMM')
    AND RTRIM( EEST.DOPES) IN ('ADTO ENCOMENDA', 'ENCOMENDA E-COMM', 'VENDA E-COMMERCE', 'VENDA', 'VENDA FR', 'VENDA CONSIGNACAO', 'TROCA', 'TROCA COM CREDITO', 'DEVOLUÇÃO DE VENDA', 'VENDA ENCOM SINAL', 'TROCA SEM BARRA', 'VENDA E-COMMERCE LJ', 'DEVOLUCAO DE VENDA', 'VENDA SF', 'DEV VENDA SF')
    AND EEST.datas >= '2024-01-01 00:00:00'
ORDER BY "Data" DESC, "Cod. Cliente" DESC
------------------------------------------------------------------------------------------------------------------------------------------
-- INICIO MODELAGEM - TMP2
------------------------------------------------------------------------------------------------------------------------------------------

SELECT *,
    DATEDIFF(DAY, [Data], Prxdata) AS 'DIAS',
    IIF (Empresa = 'WEB', 'Online', IIF (Empresa <> 'WEB', 'Fisica', 'null')) AS 'Tipo Compra'
INTO #TMPDOIS
FROM
    (SELECT *,
        lag ([Data]) OVER (PARTITION BY [Cod. Cliente]
                             ORDER BY [Data] DESC) AS 'Prxdata'
    FROM #TMPUM) A
------------------------------------------------------------------------------------------------------------------------------------------
-- MODELAGEM - TMP3
------------------------------------------------------------------------------------------------------------------------------------------

SELECT [Cod. Cliente],
    MIN([Data]) AS 'Primeira compra',
    MAX([Data]) AS 'Ultima compra',
    SUM([Total Liq.]) AS 'Total liq.',
    COUNT(DISTINCT ID_Venda) AS 'Qtd tickets',
    COUNT(DISTINCT [Tipo Compra]) AS 'Tipo compra n',
    MAX([Tipo Compra]) AS 'Resultado da compra',
    AVG(DIAS) AS 'Media entre compras'
INTO #TMPTRES
FROM #TMPDOIS
WHERE 1=1
    AND [Cod. Cliente] <> ''
    AND [Grande Grupo] LIKE '%PA%'
GROUP BY [Cod. Cliente]
------------------------------------------------------------------------------------------------------------------------------------------
-- MODELAGEM - TMP4 - CRIANDO TIPO DE CLIENTE
------------------------------------------------------------------------------------------------------------------------------------------

SELECT *,
    SUM([Total Liq.]/[Qtd tickets]) AS 'Ticket medio',
    DATEDIFF([DAY], [Ultima compra], GETDATE()) AS 'Dias ultima compra',
    IIF ([Tipo compra n] = 2, 'Ambos', IIF([Tipo compra n] = 1, [Resultado da compra], 'null')) AS 'Tipo cliente'
INTO #TMPQUATRO
FROM #TMPTRES
GROUP BY [Cod. Cliente],
         [Primeira compra],
         [Ultima compra],
         [Total liq.],
         [Qtd tickets],
         [Tipo compra n],
         [Resultado da compra],
         [Media entre compras]
------------------------------------------------------------------------------------------------------------------------------------------
-- MODELAGEM - TMP5 - RFV UTILIZADO
------------------------------------------------------------------------------------------------------------------------------------------

SELECT *,
    CASE
           WHEN ([Tipo cliente] = 'Online') THEN CASE
                                                     WHEN [Dias ultima compra] BETWEEN 0 AND 365 THEN 5
                                                     WHEN [Dias ultima compra] BETWEEN 366 AND 545 THEN 4
                                                     WHEN [Dias ultima compra] BETWEEN 546 AND 725 THEN 3
                                                     WHEN [Dias ultima compra] BETWEEN 726 AND 1095 THEN 2
                                                     WHEN [Dias ultima compra] > 1095 THEN 1
                                                 END
           ELSE CASE
                    WHEN [Dias ultima compra] BETWEEN 0 AND 180 THEN 5
                    WHEN [Dias ultima compra] BETWEEN 181 AND 365 THEN 4
                    WHEN [Dias ultima compra] BETWEEN 366 AND 730 THEN 3
                    WHEN [Dias ultima compra] BETWEEN 731 AND 1095 THEN 2
                    WHEN [Dias ultima compra] > 1095 THEN 1
                END
       END AS 'Recencia',
    CASE
           WHEN ([Tipo cliente] = 'Online') THEN CASE
                                                     WHEN [Qtd tickets] = 1 THEN 1
                                                     WHEN [Qtd tickets] BETWEEN 2 AND 3 THEN 2
                                                     WHEN [Qtd tickets] = 4 THEN 3
                                                     WHEN [Qtd tickets] = 5 THEN 4
                                                     WHEN [Qtd tickets] > 5 THEN 5
                                                 END
           ELSE CASE
                    WHEN [Qtd tickets] = 1 THEN 1
                    WHEN [Qtd tickets] BETWEEN 2 AND 4 THEN 2
                    WHEN [Qtd tickets] BETWEEN 5 AND 7 THEN 3
                    WHEN [Qtd tickets] BETWEEN 8 AND 10 THEN 4
                    WHEN [Qtd tickets] >= 11 THEN 5
                END
       END AS 'Frequencia',
    CASE
           WHEN ([Tipo cliente] = 'Online') THEN CASE
                                                     WHEN [Total liq.] BETWEEN 0 AND 4999 THEN 1
                                                     WHEN [Total liq.] BETWEEN 5000 AND 7999 THEN 2
                                                     WHEN [Total liq.] BETWEEN 8000 AND 11999 THEN 3
                                                     WHEN [Total liq.] BETWEEN 12000 AND 17999 THEN 4
                                                     WHEN [Total liq.] >= 18000 THEN 5
                                                 END
           ELSE CASE
                    WHEN [Total liq.] BETWEEN 0 AND 14999 THEN 1
                    WHEN [Total liq.] BETWEEN 15000 AND 34999 THEN 2
                    WHEN [Total liq.] BETWEEN 35000 AND 69999 THEN 3
                    WHEN [Total liq.] BETWEEN 70000 AND 99999 THEN 4
                    WHEN [Total liq.] >= 100000 THEN 5
                END
       END AS 'Valor',
    CASE
           WHEN [Qtd tickets] = 1 THEN '01-Esporadico'
           WHEN [Qtd tickets] BETWEEN 2 AND 3 THEN '02-Ocasional'
           WHEN [Qtd tickets] BETWEEN 4 AND 5 THEN '03-Recorrente'
           WHEN [Qtd tickets] BETWEEN 6 AND 8 THEN '04-Frequente'
           WHEN [Qtd tickets] >= 9 THEN '05-Consistente'
           ELSE NULL
       END AS 'Cluster frequencia'
INTO #TMPCINCO
FROM #TMPQUATRO
SELECT [Cod. Cliente],
    [Primeira compra],
    [Ultima compra],
    [Total liq.],
    [Qtd tickets],
    [Ticket medio],
    [Dias ultima compra],
    [Tipo cliente],
    Recencia,
    Frequencia,
    Valor,
    [Cluster frequencia],
    IIF ([Media entre compras] = NULL, ' ', [Media entre compras]) AS 'Media entre compras',
    IIF(DATEADD(DAY, [Media entre compras], [Ultima compra]) <= GETDATE(), NULL, DATEADD(DAY, [Media entre compras], [Ultima compra])) AS 'Proxima Compra',
    CASE
           WHEN [Recencia] >= 5
        AND [Frequencia] >=3
        AND [Valor] >= 4 THEN '01.Especial'
           WHEN [Recencia] >= 4
        AND [Recencia] <= 5
        AND [Frequencia] >= 2
        AND [Frequencia] <= 5
        AND [Valor] >= 4
        AND [Valor] <= 5 THEN '02.Muito potencial'
           WHEN [Recencia] >= 4
        AND [Recencia] <= 5
        AND [Frequencia] >= 2
        AND [Frequencia] <= 5
        AND [Valor] >= 2
        AND [Valor] <= 5 THEN '03.Potencial'
           WHEN [Recencia] >= 2
        AND [Recencia] <= 3
        AND [Frequencia] >= 2
        AND [Frequencia] <= 5
        AND [Valor] >= 4
        AND [Valor] <= 5 THEN '06.Nao podemos perde-los'
           WHEN [Recencia] >= 3
        AND [Recencia] <= 4
        AND [Frequencia] >= 2
        AND [Frequencia] <= 5
        AND [Valor] >= 2
        AND [Valor] <= 5 THEN '07.Precisam de atencao'
           WHEN [Recencia] = 5
        AND [Frequencia] = 1
        AND [Valor] <= 3 THEN '04.Novo'
           WHEN [Recencia] >= 4
        AND [Recencia] <= 5
        AND [Frequencia] >= 1
        AND [Frequencia] <= 4
        AND [Valor] >= 1
        AND [Valor] <= 5 THEN '05.Promissor'
           WHEN [Recencia] >= 2
        AND [Recencia] <= 3
        AND [Frequencia] >= 1
        AND [Frequencia] <= 5
        AND [Valor] >= 1
        AND [Valor] <= 5 THEN '08.Prestes a perde-lo'
           WHEN [Recencia] = 1
        AND [Frequencia] <= 5
        AND [Valor] <= 5 THEN '09.Perdido'
           ELSE 'Nao segmentado'
       END AS CLUSTER
FROM #TMPCINCO
IF OBJECT_ID ('tempdb.dbo.#TMPUM', 'U') IS NOT NULL
DROP TABLE #TMPUM;

IF OBJECT_ID ('tempdb.dbo.#TMPDOIS', 'U') IS NOT NULL
DROP TABLE #TMPDOIS;

IF OBJECT_ID ('tempdb.dbo.#TMPTRES', 'U') IS NOT NULL
DROP TABLE #TMPTRES;

IF OBJECT_ID ('tempdb.dbo.#TMPQUATRO', 'U') IS NOT NULL
DROP TABLE #TMPQUATRO;

IF OBJECT_ID ('tempdb.dbo.#TMPCINCO', 'U') IS NOT NULL
DROP TABLE #TMPCINCO;