    SELECT
        CONVERT(DATE, a.datas, 103) AS "Data",
        RTRIM( b.colecoes ) AS "Colecao",
        RTRIM( a.cpros ) AS "Cod. Prod.",
        b.pcuss AS "Custo",
        a.qtds AS "Qtd",
        a.totas AS "Total Liq.",
        CONCAT( a.iclis,'-',  CONVERT(DATE, a.datas, 3)) AS ID_Venda
    FROM sljgdmi AS a with (nolock)
        LEFT OUTER JOIN sljpro AS b with (nolock) ON a.cpros = b.cpros
        LEFT OUTER JOIN sljcli AS c with (nolock) ON a.contaests = c.iclis
        LEFT OUTER JOIN sljcli AS e with (nolock) ON a.resps = e.iclis
        LEFT OUTER JOIN sljeesti AS f with (nolock) ON a.empdopnums + CONVERT (CHAR (8), a.codbarras) = f.empdopnums + CONVERT (CHAR (8), f.codbarras)
        LEFT OUTER JOIN sljeest AS g with (nolock) ON a.empdopnums = g.empdopnums
        LEFT OUTER JOIN sljcli AS h with (nolock) ON a.iclis = h.iclis
        LEFT OUTER JOIN SLJCLI AS J with (nolock) ON G.CONTAOS = J.ICLIS
        LEFT OUTER JOIN SLJCLI AS I with (nolock) ON G.CONTADS = I.ICLIS
        LEFT OUTER JOIN SLJCLI AS K with (nolock) ON K.ICLIS = A.VENDS
        LEFT OUTER JOIN SLJPRO AS L with (nolock) ON B.CPROEQS = L.CPROS
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
        CONVERT(DATE, a.datas, 103) AS "Data",
        RTRIM( b.colecoes ) AS "Colecao",
        RTRIM( a.cpros ) AS "Cod. Prod.",
        b.pcuss AS "Custo",
        a.qtds AS "Qtd",
        a.totas AS "Total Liq.",
        CONCAT( a.iclis,'-',  CONVERT(DATE, a.datas, 3)) AS ID_Venda
    FROM sljgdmi AS a with(nolock)
        LEFT OUTER JOIN sljpro AS b with(nolock) ON a.cpros = b.cpros
        LEFT OUTER JOIN sljcli AS c with(nolock) ON a.contaests = c.iclis
        LEFT OUTER JOIN sljcli AS e with(nolock) ON a.resps = e.iclis
        LEFT OUTER JOIN sljeest AS g with(nolock) ON a.empdopnums = g.empdopnums
        LEFT OUTER JOIN sljcli AS h with(nolock) ON a.iclis = h.iclis
        LEFT OUTER JOIN SLJCLI AS J with(nolock) ON G.CONTAOS = J.ICLIS
        LEFT OUTER JOIN SLJCLI AS I with(nolock) ON G.CONTADS = I.ICLIS
        LEFT OUTER JOIN SLJCLI AS K with(nolock) ON K.ICLIS = A.VENDS
        LEFT OUTER JOIN SLJPRO AS L with(nolock) ON B.CPROEQS = L.CPROS
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
        CONVERT(DATE, EEST.datas, 103) AS "Data",
        RTRIM( b.colecoes ) AS "Colecao",
        EESTI.cpros AS "Cod. Prod.",
        b.pcuss AS "Custo",
        EESTI.qtds AS "Qtd",
        EESTI.totas + eesti.valrats AS "Total Liq.",
        CONCAT( EEST.Contads,'-',  CONVERT( DATE, EEST.datas, 3)) as ID_Venda
    FROM SLJEEST AS EEST with(nolock)
        LEFT OUTER JOIN SLJEESTI AS EESTI with(nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
        LEFT OUTER JOIN SLJOPE AS OPE with(nolock) ON EEST.DOPES = OPE.DOPES
        LEFT OUTER JOIN sljpro AS b with(nolock) ON EESTI.cpros = b.cpros
        LEFT OUTER JOIN SLJGRU AS GRU with(nolock) ON B.CGRUS = GRU.CGRUS
        LEFT OUTER JOIN SLJLIN AS LIN with(nolock) ON B.LINHAS = LIN.LINHAS
        LEFT OUTER JOIN SLJCOL AS COL with(nolock) ON B.colecoes = COL.COLECOES
        LEFT OUTER JOIN sljcli AS e with(nolock) ON EEST.resps = e.iclis
        LEFT OUTER JOIN sljeest AS g with(nolock) ON EEST.empdopnums = g.empdopnums
        LEFT OUTER JOIN sljcli AS h with(nolock) ON EEST.CONTADS = h.iclis
        LEFT OUTER JOIN SLJCLI AS J with(nolock) ON G.CONTAOS = J.ICLIS
        LEFT OUTER JOIN SLJCLI AS I with(nolock) ON G.CONTADS = I.ICLIS
        LEFT OUTER JOIN SLJCLI AS K with(nolock) ON K.ICLIS = EEST.VENDS
        LEFT OUTER JOIN SLJPRO AS L with(nolock) ON B.CPROEQS = L.CPROS
        LEFT OUTER JOIN sljeti AS M with(nolock) ON EESTI.codbarras = M.cbars
    WHERE EEST.DOPES IN ('ADTO ENCOMENDA ', 'ENCOMENDA E-COMM')
        AND EEST.emps <> 'NY'
        AND EESTI.unitorigs <> 0
        AND ( EEST.dopes <> 'VENDA PERMUTA'
        AND EEST.dopes <> 'VENDA FUNCIONARIO'
        AND EEST.dopes <> 'VENDA ENCOMENDA'
        AND EEST.dopes <> 'VENDA ENC E-COMM')
ORDER BY "Data" DESC