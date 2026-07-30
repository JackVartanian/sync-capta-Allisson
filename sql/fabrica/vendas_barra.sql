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
        RTRIM( a.ggrus ) AS "Grande Grupo",
        RTRIM( a.cpros ) AS "Cod. Prod.",
        RTRIM( a.codbarras ) AS "Cod. Barras",
        CAST( a.qtds AS INTEGER ) AS "Qtd",
        CAST( a.totas AS DECIMAL(10) ) AS "Total Liq."
    FROM sljgdmi AS a with (nolock)
        -- LEFT JOIN sljcli AS e with (nolock) ON a.resps = e.iclis
        LEFT JOIN sljeesti AS f with (nolock) ON a.empdopnums + CONVERT (CHAR (8), a.codbarras) = f.empdopnums + CONVERT (CHAR (8), f.codbarras)
        LEFT JOIN sljeest AS g with (nolock) ON a.empdopnums = g.empdopnums
        LEFT JOIN SLJCLI AS J with (nolock) ON G.CONTAOS = J.ICLIS
        LEFT JOIN SLJCLI AS I with (nolock) ON G.CONTADS = I.ICLIS
    -- LEFT JOIN SLJCLI AS K with (nolock) ON K.ICLIS = A.VENDS
    WHERE RTRIM( a.emps ) <> 'NY'
        AND RTRIM( a.ggrus ) = 'PA'
        AND a.vvistas <> 0
        AND a.tipoops NOT IN (91, 92)
        AND CAST( a.qtds AS INTEGER ) > 0
        AND RTRIM( a.dopes ) NOT IN ('VENDA PERMUTA', 'VENDA FUNCIONARIO', 'VENDA ENCOMENDA', 'VENDA ENC E-COMM')
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
        RTRIM(B.MERCS) AS "Grande Grupo",
        RTRIM(EESTI.cpros) AS "Cod. Prod.",
        RTRIM(EESTI.codbarras) AS "Cod. Barras",
        CASE 
        WHEN RTRIM( EESTI.OPERS ) = 'S' THEN CAST( EESTI.qtds AS INTEGER )
        ELSE CAST( EESTI.qtds AS INTEGER ) * -1 
    END AS "Qtd",
        CASE
        WHEN RTRIM( EESTI.OPERS ) = 'S' THEN CAST( EESTI.totas + eesti.valrats AS DECIMAL(10))
        ELSE CAST( EESTI.totas + eesti.valrats AS DECIMAL(10)) * -1
    END AS "Total Liq."
    FROM SLJEEST AS EEST with(nolock)
        LEFT JOIN SLJEESTI AS EESTI with(nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
        LEFT JOIN sljpro AS b with(nolock) ON EESTI.cpros = b.cpros
        -- LEFT JOIN sljcli AS e with(nolock) ON EEST.resps = e.iclis
        LEFT JOIN SLJCLI AS J with (nolock) ON EEST.CONTAOS = J.ICLIS
        LEFT JOIN SLJCLI AS I with (nolock) ON EEST.CONTADS = I.ICLIS
    -- LEFT JOIN SLJCLI AS K with(nolock) ON K.ICLIS = EEST.VENDS
    -- LEFT JOIN sljeti AS M with(nolock) ON EESTI.codbarras = M.cbars
    WHERE RTRIM( EEST.emps ) <> 'NY'
        AND RTRIM( B.MERCS ) = 'PA'
        AND EESTI.unitorigs <> 0
        AND CAST(EEST.datas AS DATE) < CAST(GETDATE() AS DATE)
        AND CAST( EESTI.qtds AS INTEGER ) > 0
        AND RTRIM( EEST.DOPES) NOT IN ('VENDA PERMUTA', 'VENDA FUNCIONARIO', 'VENDA ENCOMENDA', 'VENDA ENC E-COMM')
        AND RTRIM( EEST.DOPES) IN ('ADTO ENCOMENDA ', 'ENCOMENDA E-COMM')
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
        RTRIM(B.MERCS) AS "Grande Grupo",
        RTRIM(EESTI.cpros) AS "Cod. Prod.",
        RTRIM(EESTI.codbarras) AS "Cod. Barras",
        CASE 
        WHEN RTRIM( EESTI.OPERS ) = 'S' THEN CAST( EESTI.qtds AS INTEGER )
        ELSE CAST( EESTI.qtds AS INTEGER ) * -1 
    END AS "Qtd",
        CASE
        WHEN RTRIM( EESTI.OPERS ) = 'S' THEN CAST( EESTI.totas + eesti.valrats AS DECIMAL(10))
        ELSE CAST( EESTI.totas + eesti.valrats AS DECIMAL(10)) * -1
    END AS "Total Liq."
    FROM SLJEEST AS EEST with(nolock)
        LEFT JOIN SLJEESTI AS EESTI with(nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
        LEFT JOIN sljpro AS b with(nolock) ON EESTI.cpros = b.cpros
        -- LEFT JOIN sljcli AS e with(nolock) ON EEST.resps = e.iclis
        LEFT JOIN SLJCLI AS J with (nolock) ON EEST.CONTAOS = J.ICLIS
        LEFT JOIN SLJCLI AS I with (nolock) ON EEST.CONTADS = I.ICLIS
    -- LEFT JOIN SLJCLI AS K with(nolock) ON K.ICLIS = EEST.VENDS
    -- LEFT JOIN sljeti AS M with(nolock) ON EESTI.codbarras = M.cbars
    WHERE RTRIM( EEST.emps ) <> 'NY'
        AND RTRIM( B.MERCS ) = 'PA'
        AND EESTI.unitorigs <> 0
        AND CAST(EEST.datas AS DATE) = CAST(GETDATE() AS DATE)
        AND CAST( EESTI.qtds AS INTEGER ) > 0
        AND RTRIM( EEST.DOPES) NOT IN ('VENDA PERMUTA', 'VENDA FUNCIONARIO', 'VENDA ENCOMENDA', 'VENDA ENC E-COMM')
        AND RTRIM( EEST.DOPES) IN ('ADTO ENCOMENDA', 'ENCOMENDA E-COMM', 'VENDA E-COMMERCE', 'VENDA', 'VENDA FR', 'VENDA CONSIGNACAO', 'TROCA', 'VENDA ENCOM SINAL', 'TROCA SEM BARRA', 'VENDA E-COMMERCE LJ', 'VENDA SF')
ORDER BY "Data" ASC