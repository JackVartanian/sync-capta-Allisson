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
    CAST (a.numes AS BIGINT ) AS "No.Oper",
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
    CAST( a.qtds AS BIGINT ) AS "Qtd",
    CAST( a.totas AS DECIMAL(10) ) AS "Total Liq.",
    CAST( a.valrats AS DECIMAL(10) ) AS "Desconto",
    CAST( a.custos AS DECIMAL(10) ) AS "Custo",
    CASE
        WHEN f.opers = 'S' THEN CAST(  f.totas AS DECIMAL(10) )
        ELSE CAST( -1 * F.TOTAS AS DECIMAL(10) )
    END AS "Total Brt",
    RTRIM( g.notas ) AS "NF",
    CONCAT( RTRIM( a.iclis ),'-', CAST( a.datas AS DATE ), '-', CAST (a.numes AS BIGINT )) AS ID_Venda,
    CONCAT( RTRIM( a.iclis ),'-', CAST( a.datas AS DATE ), '-', CAST (a.numes AS BIGINT ),'-', RTRIM( a.cpros ), '-', CAST( a.totas AS DECIMAL(10)), '-', RTRIM( a.codbarras )) AS ID_Drop,
    RTRIM( G.CODEVENTS ) AS "Evento"
FROM sljgdmi AS a with (nolock)
    LEFT JOIN sljcli AS e with (nolock) ON a.resps = e.iclis
    LEFT JOIN sljeesti AS f with (nolock) ON a.empdopnums + CONVERT (CHAR (8), a.codbarras) = f.empdopnums + CONVERT (CHAR (8), f.codbarras)
    LEFT JOIN sljeest AS g with (nolock) ON a.empdopnums = g.empdopnums
    LEFT JOIN SLJCLI AS J with (nolock) ON G.CONTAOS = J.ICLIS
    LEFT JOIN SLJCLI AS I with (nolock) ON G.CONTADS = I.ICLIS
    LEFT JOIN SLJCLI AS K with (nolock) ON K.ICLIS = A.VENDS
--aq
WHERE RTRIM( a.emps ) <> 'NY'
    AND a.vvistas <> 0
    AND a.tipoops NOT IN (91, 92)
    AND RTRIM( a.dopes ) NOT IN ('VENDA PERMUTA', 'VENDA FUNCIONARIO', 'VENDA ENCOMENDA', 'VENDA ENC E-COMM')
    AND CONCAT( RTRIM( a.iclis ),'-', CAST( a.datas AS DATE ), '-', CAST (a.numes AS BIGINT )) <> 'CMAT001705-2024-10-31-8516'
--at
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
    CAST (EEST.numes AS BIGINT ) AS "No.Oper",
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
        WHEN RTRIM( EESTI.OPERS ) = 'S' THEN CAST( EESTI.qtds AS BIGINT )
        ELSE CAST( EESTI.qtds AS BIGINT ) * -1
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
    CONCAT( EEST.Contads,'-', CAST( EEST.datas AS DATE ), '-', CAST (EEST.numes AS BIGINT )) AS ID_Venda,
    CONCAT( RTRIM( EEST.Contads ),'-', CAST( EEST.datas AS DATE ), '-', CAST (EEST.numes AS BIGINT ),'-', RTRIM( EESTI.cpros ), '-', CAST( EESTI.totas + eesti.valrats AS DECIMAL(10)) * -1, '-', RTRIM( EESTI.codbarras )) AS ID_Drop,
    RTRIM( EEST.codevents ) AS "Evento"
FROM SLJEEST AS EEST with(nolock)
    LEFT JOIN SLJEESTI AS EESTI with(nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
    LEFT JOIN sljpro AS b with(nolock) ON EESTI.cpros = b.cpros
    LEFT JOIN sljcli AS e with(nolock) ON EEST.resps = e.iclis
    LEFT JOIN SLJCLI AS J with (nolock) ON EEST.CONTAOS = J.ICLIS
    LEFT JOIN SLJCLI AS I with (nolock) ON EEST.CONTADS = I.ICLIS
    LEFT JOIN SLJCLI AS K with(nolock) ON K.ICLIS = EEST.VENDS
    LEFT JOIN sljeti AS M with(nolock) ON EESTI.codbarras = M.cbars
--aq
WHERE RTRIM( EEST.emps ) <> 'NY'
    AND EESTI.unitorigs <> 0
    AND CAST(EEST.datas AS DATE) < CAST(GETDATE() AS DATE)
    AND RTRIM( EEST.DOPES) NOT IN ('VENDA PERMUTA', 'VENDA FUNCIONARIO', 'VENDA ENCOMENDA', 'VENDA ENC E-COMM')
    AND RTRIM( EEST.DOPES) IN ('ADTO ENCOMENDA ', 'ENCOMENDA E-COMM')
    AND CONCAT( EEST.Contads,'-', CAST( EEST.datas AS DATE ), '-', CAST (EEST.numes AS BIGINT )) <> 'CMAT001705-2024-10-31-8516'
--at
UNION ALL
-- VENDA DO DIA
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
    CAST (EEST.numes AS BIGINT ) AS "No.Oper",
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
        WHEN RTRIM( EESTI.OPERS ) = 'S' THEN CAST( EESTI.qtds AS BIGINT )
        ELSE CAST( EESTI.qtds AS BIGINT ) * -1
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
    CONCAT( EEST.Contads,'-', CAST( EEST.datas AS DATE ), '-', CAST (EEST.numes AS BIGINT )) AS ID_Venda,
    CONCAT( RTRIM( EEST.Contads ),'-', CAST( EEST.datas AS DATE ), '-', CAST (EEST.numes AS BIGINT ),'-', RTRIM( EESTI.cpros ), '-', CAST( EESTI.totas + eesti.valrats AS DECIMAL(10)) * -1, '-', RTRIM( EESTI.codbarras )) AS ID_Drop,
    RTRIM( EEST.codevents ) AS "Evento"
FROM SLJEEST AS EEST with(nolock)
    LEFT JOIN SLJEESTI AS EESTI with(nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
    LEFT JOIN sljpro AS b with(nolock) ON EESTI.cpros = b.cpros
    LEFT JOIN sljcli AS e with(nolock) ON EEST.resps = e.iclis
    LEFT JOIN SLJCLI AS J with (nolock) ON EEST.CONTAOS = J.ICLIS
    LEFT JOIN SLJCLI AS I with (nolock) ON EEST.CONTADS = I.ICLIS
    LEFT JOIN SLJCLI AS K with(nolock) ON K.ICLIS = EEST.VENDS
    LEFT JOIN sljeti AS M with(nolock) ON EESTI.codbarras = M.cbars
--aq
WHERE RTRIM( EEST.emps ) <> 'NY'
    AND EESTI.unitorigs <> 0
    AND CAST(EEST.datas AS DATE) = CAST(GETDATE() AS DATE)
    AND RTRIM( EEST.DOPES) NOT IN ('VENDA PERMUTA', 'VENDA FUNCIONARIO', 'VENDA ENCOMENDA', 'VENDA ENC E-COMM')
    AND RTRIM( EEST.DOPES) IN ('ADTO ENCOMENDA', 'ENCOMENDA E-COMM', 'VENDA E-COMMERCE', 'VENDA', 'VENDA FR', 'VENDA CONSIGNACAO', 'TROCA', 'TROCA COM CREDITO', 'DEVOLUÇÃO DE VENDA', 'VENDA ENCOM SINAL', 'TROCA SEM BARRA', 'VENDA E-COMMERCE LJ', 'DEVOLUCAO DE VENDA', 'VENDA SF', 'DEV VENDA SF')
    AND CONCAT( EEST.Contads,'-', CAST( EEST.datas AS DATE ), '-', CAST (EEST.numes AS BIGINT )) <> 'CMAT001705-2024-10-31-8516'
    
    
ORDER BY "Data" DESC, "Cod. Cliente" DESC