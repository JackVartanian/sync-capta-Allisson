IF OBJECT_ID ('tempdb.dbo.#TMPUM','U') is not null 
DROP TABLE #TMPUM;
    SELECT
        CASE
    WHEN b.encoms = 1 THEN 'Sim'
    ELSE 'Nao'
    END AS "Encomendavel",
        CONVERT(DATE, a.datas, 103) AS "Data",
        RTRIM( a.ggrus ) AS "Grande Grupo",
        RTRIM( a.cpros ) AS "Cod. Prod.",
        a.qtds AS "Qtd",
        a.totas AS "Total Liq."
    INTO #TMPUM
    FROM sljgdmi AS a with (nolock)
        LEFT OUTER JOIN sljpro AS b with (nolock) ON a.cpros = b.cpros
    WHERE a.codbarras <> 0
        AND a.emps <> 'NY'
        AND a.vvistas <> 0
        AND a.tipoops NOT IN (91, 92)
        AND A.DOPES <> 'ADTO ENCOMENDA '
        AND (a.dopes <> 'VENDA PERMUTA'
        AND a.dopes <> 'VENDA FUNCIONARIO'
        AND a.dopes <> 'VENDA ENCOMENDA'
        AND a.dopes <> 'VENDA ENC E-COMM' )

UNION ALL
    SELECT
        CASE
    WHEN b.encoms = 1 THEN 'Sim'
    ELSE 'Nao'
    END AS "Encomendavel",
        CONVERT(DATE, a.datas, 103) AS "Data",
        RTRIM(a.ggrus) AS "Grande Grupo",
        RTRIM(a.cpros) AS "Cod. Prod.",
        a.qtds AS "Qtd",
        a.totas AS "Total Liq."
    FROM sljgdmi AS a with(nolock)
        LEFT OUTER JOIN sljpro AS b with(nolock) ON a.cpros = b.cpros
    WHERE a.codbarras = 0
        AND a.emps <> 'NY'
        AND a.vvistas <> 0
        AND a.tipoops NOT IN (91, 92)
        AND a.dopes <> 'ADTO ENCOMENDA '
        AND
        (a.dopes <> 'VENDA PERMUTA'
        AND a.dopes <> 'VENDA FUNCIONARIO'
        AND a.dopes <> 'VENDA ENCOMENDA'
        AND a.dopes <> 'VENDA ENC E-COMM')
UNION ALL
    SELECT
        CASE
    WHEN b.encoms = 1 THEN 'Sim'
    ELSE 'Nao'
    END AS "Encomendavel",
        CONVERT(DATE, EEST.datas, 103) AS "Data",
        RTRIM(B.MERCS) AS "Grande Grupo",
        RTRIM(EESTI.cpros) AS "Cod. Prod.",
        EESTI.qtds AS "Qtd",
        EESTI.totas + eesti.valrats AS "Total Liq."
    FROM SLJEEST AS EEST with(nolock)
        LEFT OUTER JOIN SLJEESTI AS EESTI with(nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
        LEFT OUTER JOIN sljpro AS b with(nolock) ON EESTI.cpros = b.cpros
    WHERE EEST.DOPES IN ('ADTO ENCOMENDA ', 'ENCOMENDA E-COMM')
        AND EEST.emps <> 'NY'
        AND EESTI.unitorigs <> 0
        AND ( EEST.dopes <> 'VENDA PERMUTA'
        AND EEST.dopes <> 'VENDA FUNCIONARIO'
        AND EEST.dopes <> 'VENDA ENCOMENDA'
        AND EEST.dopes <> 'VENDA ENC E-COMM')
ORDER BY "Data" DESC

IF OBJECT_ID ('tempdb.dbo.#TMPDOIS','U') is not null 
DROP TABLE #TMPDOIS;

SELECT DISTINCT [Cod. Prod.], MAX(Data) AS 'DATA', DATEDIFF(DAY,MAX(Data),GETDATE()) AS 'DIAS DA ULTIMA SAIDA', [Encomendavel]
INTO #TMPDOIS
FROM #TMPUM
WHERE [Grande Grupo] = 'PA'
GROUP BY [Cod. Prod.],Encomendavel

IF OBJECT_ID ('tempdb.dbo.#TMPTRES','U') is not null 
DROP TABLE #TMPTRES;

SELECT DISTINCT
    RTRIM( t.cpros ) AS "Cod. Prod",
    SUM(t.sqtds) AS "Qtd"
INTO #TMPTRES
FROM sljest t with(nolock)
    LEFT JOIN sljpro r with(nolock) ON t.cpros = r.cpros
WHERE t.sqtds <> 0
    AND r.mercs = 'PA'
    AND t.emps NOT IN ('NY')
GROUP BY t.cpros

IF OBJECT_ID ('tempdb.dbo.#TMPQUATRO','U') is not null 
DROP TABLE #TMPQUATRO;

SELECT [Cod. Prod.], [DATA] AS 'Data inclusao/venda', [DIAS DA ULTIMA SAIDA]  AS 'Dias da ultima venda', Qtd AS 'Qtd em estoque', [Encomendavel]
INTO #TMPQUATRO
FROM (SELECT *,
        IIF(Encomendavel = 'Nao' and Qtd is null ,'retirar', 'não retirar') AS 'FILTRO'
    FROM #TMPDOIS
        LEFT JOIN #TMPTRES AS A with(nolock) ON A.[Cod. Prod] = #TMPDOIS.[Cod. Prod.]) AS TAB
WHERE FILTRO = 'não retirar'

IF OBJECT_ID ('tempdb.dbo.#TMPCINCO','U') is not null 
DROP TABLE #TMPCINCO;

SELECT [Cod. Prod] AS 'Cod. Prod.', MAX(Inclusao) AS 'Data inclusao/venda', 
AVG([DIAS SEM SAIDA])  AS 'Dias da ultima venda', SUM(Qtde) AS 'Qtd em estoque', [Encomendavel]
INTO #TMPCINCO
FROM
    (SELECT
        DATEDIFF(DAY,a.dtincs,GETDATE()) AS 'DIAS SEM SAIDA',
        FORMAT ( a.dtincs, 'yyyy-MM-dd') AS 'Inclusao',
        RTRIM ( a.cpros ) as 'Cod. Prod',
        a.qtds as Qtde,
        RTRIM ( a.cbars ) AS 'Cod. Barra',
        RTRIM ( #TMPQUATRO.[Cod. Prod.] ) AS 'PRODUTO',
        CASE
WHEN b.encoms = 1 THEN 'Sim'
ELSE 'Nao'
END AS "Encomendavel"
    FROM sljeti a WITH(NOLOCK)
        LEFT JOIN sljcli c with(nolock) ON a.contas = c.iclis
        LEFT JOIN sljpro b WITH(NOLOCK) ON a.cpros = b.cpros
        LEFT JOIN #TMPQUATRO WITH(NOLOCK) ON a.cpros = #TMPQUATRO.[Cod. Prod.]
    WHERE a.contas <> '' AND b.mercs = 'PA'
        AND empos NOT IN ('NY')) AS TABB
WHERE PRODUTO IS NULL
GROUP BY [Cod. Prod],[Encomendavel]

IF OBJECT_ID ('tempdb.dbo.#TMPQUATRO','U') is not null 
DROP TABLE #TMPUM;
IF OBJECT_ID ('tempdb.dbo.#TMPQUATRO','U') is not null 
DROP TABLE #TMPDOIS;
IF OBJECT_ID ('tempdb.dbo.#TMPQUATRO','U') is not null 
DROP TABLE #TMPTRES;

SELECT * ,
    CASE
WHEN [Dias da ultima venda] < 365 THEN '01. Menor 365'
WHEN [Dias da ultima venda] BETWEEN 365 AND 720 THEN '02. Entre 365 e 720'
WHEN [Dias da ultima venda] > 720 THEN '03. Acima 720'
ELSE 'Null'
END AS 'CLUSTER DIAS SEM VENDAS',
    CASE
WHEN [Dias da ultima venda] < 90 THEN '01. Menor 90'
WHEN [Dias da ultima venda] BETWEEN 90  AND 180 THEN '02. Entre 90 e 180'
WHEN [Dias da ultima venda] BETWEEN 180 AND 270 THEN '03. Entre 180 e 270'
WHEN [Dias da ultima venda] BETWEEN 270 AND 360 THEN '04. Entre 270 e 360'
WHEN [Dias da ultima venda] BETWEEN 360 AND 450 THEN '05. Entre 360 e 450'
WHEN [Dias da ultima venda] BETWEEN 450 AND 540 THEN '06. Entre 450 e 540'
WHEN [Dias da ultima venda] BETWEEN 540 AND 630 THEN '07. Entre 540 e 630'
WHEN [Dias da ultima venda] BETWEEN 630 AND 720 THEN '08. Entre 630 e 720'
WHEN [Dias da ultima venda] > 720 THEN '09. Acima 720'
ELSE 'Null'
END AS '2 CLUSTER DIAS SEM VENDAS',
    CASE
WHEN [Dias da ultima venda] < 180 THEN '01. Menor 180'
WHEN [Dias da ultima venda] BETWEEN 180 AND 360 THEN '02. Entre 180 e 360'
WHEN [Dias da ultima venda] BETWEEN 360 AND 540 THEN '03. Entre 360 e 540'
WHEN [Dias da ultima venda] BETWEEN 540 AND 720 THEN '04. Entre 540 e 720'
WHEN [Dias da ultima venda] > 720 THEN '05. Acima 720'
ELSE 'Null'
END AS '3 CLUSTER DIAS SEM VENDAS'
FROM
    (
        SELECT *, 'VENDIDOS' AS tipo_base
        FROM #TMPQUATRO
    UNION ALL
        SELECT *, 'NÃO VENDIDOS' AS tipo_base
        FROM #TMPCINCO
) TABC
ORDER BY [Cod. Prod.]
