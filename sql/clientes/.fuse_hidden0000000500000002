    SELECT
        CASE 
        WHEN RTRIM( a.emps ) LIKE 'IGL' THEN 'IGU'
        WHEN RTRIM( a.emps ) LIKE 'FTH' THEN 'WEB'
        WHEN RTRIM( a.emps ) LIKE 'FFL' THEN 'BEL'
        WHEN RTRIM( a.emps ) LIKE 'LMA' THEN 'MAT'
        WHEN RTRIM( a.emps ) LIKE 'MPV' THEN 'MP2'
        WHEN RTRIM( a.vends ) LIKE '0385%' THEN 'BAT'
        ELSE RTRIM( a.emps )
    END AS "Empresa",
        RTRIM( a.dopes ) AS "Operacao",
        CAST (a.numes AS NUMERIC (10)) AS "No.Oper",
        CONVERT(DATE, a.datas, 103) AS "Data",
        CASE
WHEN A.ICLIS LIKE '110401%' THEN (CASE
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

        --RTRIM( a.vends ) AS "Cod. Vend.",

        CASE
        WHEN RTRIM( K.RCLIS ) IS NULL THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'ZAGO' + '%' THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'PERSIO' + '%' THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'MENINO' + '%' THEN 'WEB'
        ELSE RTRIM( K.RCLIS )
    END AS "Consultora",

        --RTRIM( K.RCLIS ) AS "Consultora",
        RTRIM( a.resps ) AS "Cod. Acomp.",
        RTRIM( e.rclis ) AS "Acompanhante",
        RTRIM( a.ggrus ) AS "Grande Grupo",
        RTRIM( a.cpros ) AS "Cod. Prod.",
        RTRIM( a.codbarras ) AS "Cod. Barras",
        RTRIM( a.codtams ) AS "Tamanho",
        a.qtds AS "Qtd",
        a.totas AS "Total Liq.",
        a.valrats AS "Desconto",
        a.custos as "Custo",
        CASE
WHEN f.opers = 'S' THEN f.totas
ELSE -1 * F.TOTAS
END AS "Total Brt",
        RTRIM( g.notas ) AS "NF",
        CONCAT( RTRIM( a.iclis ),'-',  CONVERT(DATE, a.datas, 3)) AS ID_Venda,
        CONCAT( RTRIM( a.iclis ),'-',  RTRIM( g.notas )) AS ID_Pedido,
        RTRIM( G.CODEVENTS ) AS "Evento"
    FROM sljgdmi AS a with (nolock)
        LEFT JOIN sljpro AS b with (nolock) ON a.cpros = b.cpros
        LEFT JOIN sljcli AS c with (nolock) ON a.contaests = c.iclis
        LEFT JOIN sljcli AS e with (nolock) ON a.resps = e.iclis
        LEFT JOIN sljeesti AS f with (nolock) ON a.empdopnums + CONVERT (CHAR (8), a.codbarras) = f.empdopnums + CONVERT (CHAR (8), f.codbarras)
        LEFT JOIN sljeest AS g with (nolock) ON a.empdopnums = g.empdopnums
        LEFT JOIN sljcli AS h with (nolock) ON a.iclis = h.iclis
        LEFT JOIN SLJCLI AS J with (nolock) ON G.CONTAOS = J.ICLIS
        LEFT JOIN SLJCLI AS I with (nolock) ON G.CONTADS = I.ICLIS
        LEFT JOIN SLJCLI AS K with (nolock) ON K.ICLIS = A.VENDS
        LEFT JOIN SLJPRO AS L with (nolock) ON B.CPROEQS = L.CPROS
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
        WHEN RTRIM( a.emps ) LIKE 'IGL' THEN 'IGU'
        WHEN RTRIM( a.emps ) LIKE 'FTH' THEN 'WEB'
        WHEN RTRIM( a.emps ) LIKE 'FFL' THEN 'BEL'
        WHEN RTRIM( a.emps ) LIKE 'LMA' THEN 'MAT'
        WHEN RTRIM( a.emps ) LIKE 'MPV' THEN 'MP2'
        WHEN RTRIM( a.vends ) LIKE '0385%' THEN 'BAT'
        ELSE RTRIM( a.emps )
    END AS "Empresa",
        --a.emps AS "Empresa",
        a.dopes AS "Operacao",
        CAST (a.numes AS NUMERIC (10)) AS "No.Oper",
        CONVERT(DATE, a.datas, 103) AS "Data",
        CASE
WHEN RTRIM( A.ICLIS ) LIKE '110401%' THEN RTRIM( G.CONTADS )
ELSE RTRIM( a.iclis )
END AS "Cod. Cliente",
        CASE
WHEN RTRIM( A.ICLIS ) = '' THEN ''
ELSE (CASE
WHEN RTRIM( A.ICLIS ) LIKE '110401%' THEN RTRIM( I.RCLIS )
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

        --RTRIM( a.vends ) AS "Cod. Vend.",

        CASE
        WHEN RTRIM( K.RCLIS ) IS NULL THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'ZAGO' + '%' THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'PERSIO' + '%' THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'MENINO' + '%' THEN 'WEB'
        ELSE RTRIM( K.RCLIS )
    END AS "Consultora",

        --RTRIM( K.RCLIS ) AS "Consultora",

        a.resps AS "Cod. Acomp.",
        e.rclis AS "Acompanhante",
        a.ggrus AS "Grande Grupo",
        a.cpros AS "Cod. Prod.",
        a.codbarras AS "Cod. Barras",
        a.codtams AS "Tamanho",
        a.qtds AS "Qtd",
        a.totas AS "Total Liq.",
        a.valrats AS "Desconto",
        a.custos as "Custo",
        a.vvistas AS "Total Brt",
        g.notas AS "NF",
        CONCAT( RTRIM( a.iclis ),'-',  CONVERT(DATE, a.datas, 3)) AS ID_Venda,
        CONCAT( RTRIM( a.iclis ),'-',  RTRIM( g.notas )) AS ID_Pedido,
        G.CODEVENTS AS "Evento"
    FROM sljgdmi AS a with(nolock)
        LEFT JOIN sljpro AS b with(nolock) ON a.cpros = b.cpros
        LEFT JOIN sljcli AS c with(nolock) ON a.contaests = c.iclis
        LEFT JOIN sljcli AS e with(nolock) ON a.resps = e.iclis
        LEFT JOIN sljeest AS g with(nolock) ON a.empdopnums = g.empdopnums
        LEFT JOIN sljcli AS h with(nolock) ON a.iclis = h.iclis
        LEFT JOIN SLJCLI AS J with(nolock) ON G.CONTAOS = J.ICLIS
        LEFT JOIN SLJCLI AS I with(nolock) ON G.CONTADS = I.ICLIS
        LEFT JOIN SLJCLI AS K with(nolock) ON K.ICLIS = A.VENDS
        LEFT JOIN SLJPRO AS L with(nolock) ON B.CPROEQS = L.CPROS
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
        WHEN RTRIM( EEST.emps ) LIKE 'IGL' THEN 'IGU'
        WHEN RTRIM( EEST.emps ) LIKE 'FTH' THEN 'WEB'
        WHEN RTRIM( EEST.emps ) LIKE 'FFL' THEN 'BEL'
        WHEN RTRIM( EEST.emps ) LIKE 'LMA' THEN 'MAT'
        WHEN RTRIM( EEST.emps ) LIKE 'MPV' THEN 'MP2'
        WHEN RTRIM( EEST.vends ) LIKE '0385%' THEN 'BAT'
        ELSE RTRIM( EEST.emps )
    END AS "Empresa",
        --EEST.emps AS "Empresa",
        EEST.dopes AS "Operacao",
        CAST (EEST.numes AS NUMERIC (10)) AS "No.Oper",
        CONVERT(DATE, EEST.datas, 103) AS "Data",
        RTRIM( EEST.Contads ) AS "Cod. Cliente",
        RTRIM( H.RCLIS ) AS "Nome Cliente",

        CASE 
        WHEN RTRIM( EEST.vends ) IS NULL THEN 'WEB'
        WHEN RTRIM( EEST.vends ) LIKE '0399/6' THEN 'WEB'
        WHEN RTRIM( EEST.vends ) LIKE '0531/5' THEN 'WEB'
        WHEN RTRIM( EEST.vends ) LIKE '0720/2' THEN 'WEB'
        ELSE RTRIM( EEST.vends )
    END AS "Cod. Vend.",

        --RTRIM( EEST.vends ) AS "Cod. Vend.",

        CASE
        WHEN RTRIM( K.RCLIS ) IS NULL THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'ZAGO' + '%' THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'PERSIO' + '%' THEN 'WEB'
        WHEN RTRIM( K.RCLIS ) LIKE '%' + 'MENINO' + '%' THEN 'WEB'
        ELSE RTRIM( K.RCLIS )
    END AS "Consultora",

        --RTRIM( K.RCLIS ) AS "Consultora",

        EEST.resps AS "Cod. Acomp.",
        e.rclis AS "Acompanhante",
        B.MERCS AS "Grande Grupo",
        EESTI.cpros AS "Cod. Prod.",
        EESTI.codbarras AS "Cod. Barras",
        M.codtams AS "Tamanho",
        EESTI.qtds AS "Qtd",
        EESTI.totas + eesti.valrats AS "Total Liq.",
        EESTI.valrats AS "Desconto",
        B.PCUSS AS "Custo",
        EESTI.unitorigs AS "Total Brt",
        g.notas AS "NF",
        CONCAT( EEST.Contads,'-',  CONVERT( DATE, EEST.datas, 3)) as ID_Venda,
        CONCAT( EEST.Contads,'-',  RTRIM( g.notas )) AS ID_Pedido,
        g.codevents AS "Evento"
    FROM SLJEEST AS EEST with(nolock)
        LEFT JOIN SLJEESTI AS EESTI with(nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
        LEFT JOIN SLJOPE AS OPE with(nolock) ON EEST.DOPES = OPE.DOPES
        LEFT JOIN sljpro AS b with(nolock) ON EESTI.cpros = b.cpros
        LEFT JOIN SLJGRU AS GRU with(nolock) ON B.CGRUS = GRU.CGRUS
        LEFT JOIN SLJLIN AS LIN with(nolock) ON B.LINHAS = LIN.LINHAS
        LEFT JOIN SLJCOL AS COL with(nolock) ON B.colecoes = COL.COLECOES
        LEFT JOIN sljcli AS e with(nolock) ON EEST.resps = e.iclis
        LEFT JOIN sljeest AS g with(nolock) ON EEST.empdopnums = g.empdopnums
        LEFT JOIN sljcli AS h with(nolock) ON EEST.CONTADS = h.iclis
        LEFT JOIN SLJCLI AS J with(nolock) ON G.CONTAOS = J.ICLIS
        LEFT JOIN SLJCLI AS I with(nolock) ON G.CONTADS = I.ICLIS
        LEFT JOIN SLJCLI AS K with(nolock) ON K.ICLIS = EEST.VENDS
        LEFT JOIN SLJPRO AS L with(nolock) ON B.CPROEQS = L.CPROS
        LEFT JOIN sljeti AS M with(nolock) ON EESTI.codbarras = M.cbars
    WHERE EEST.DOPES IN ('ADTO ENCOMENDA ', 'ENCOMENDA E-COMM')
        AND EEST.emps <> 'NY'
        AND EESTI.unitorigs <> 0
        AND ( EEST.dopes <> 'VENDA PERMUTA'
        AND EEST.dopes <> 'VENDA FUNCIONARIO'
        AND EEST.dopes <> 'VENDA ENCOMENDA'
        AND EEST.dopes <> 'VENDA ENC E-COMM')
ORDER BY "Data" DESC