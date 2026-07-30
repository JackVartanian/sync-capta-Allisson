SELECT
    CASE
        WHEN RTRIM (a.emps) LIKE 'IGL' THEN 'IGU'
        WHEN RTRIM (a.emps) LIKE 'FSM' THEN 'DES'
        WHEN RTRIM (a.emps) LIKE 'BAL' THEN 'BAT'
        WHEN RTRIM (a.emps) LIKE 'CUR' THEN 'BAT'
        WHEN RTRIM (a.emps) LIKE 'FTH' THEN 'WEB'
        WHEN RTRIM (a.emps) LIKE 'FFL' THEN 'BEL'
        WHEN RTRIM (a.emps) LIKE 'LMA' THEN 'MAT'
        WHEN RTRIM (a.emps) LIKE 'MPV' THEN 'MP2'
        ELSE RTRIM (a.emps)
    END AS "Empresa",
    RTRIM (a.grupos) AS "Cod. Gr. Est.",
    MAX(RTRIM (d.descrs)) AS "Desc. Gr. Est.",  -- Adicionado MAX
    RTRIM (a.estos) AS "Cod. Cta. Est.",
    MAX(RTRIM (c.rclis)) AS "Desc. Cta. Est.",  -- Adicionado MAX
    MAX(CONCAT (
        CASE
            WHEN RTRIM (a.emps) LIKE 'IGL' THEN 'IGU'
            WHEN RTRIM (a.emps) LIKE 'FSM' THEN 'DES'
            WHEN RTRIM (a.emps) LIKE 'BAL' THEN 'BAT'
            WHEN RTRIM (a.emps) LIKE 'CUR' THEN 'BAT'
            WHEN RTRIM (a.emps) LIKE 'FTH' THEN 'WEB'
            WHEN RTRIM (a.emps) LIKE 'FFL' THEN 'BEL'
            WHEN RTRIM (a.emps) LIKE 'LMA' THEN 'MAT'
            WHEN RTRIM (a.emps) LIKE 'MPV' THEN 'MP2'
            ELSE RTRIM (a.emps)
        END,
        ' - ',
        RTRIM (d.descrs)
    )) AS "Loja Desc. Gr. Est.",  -- Adicionado MAX
    RTRIM (a.cpros) AS "Cod. Prod.",
    CAST(SUM(a.sqtds) AS INTEGER) AS "Qtd"
FROM
    sljest a
with
    (nolock)
    LEFT JOIN sljpro b
with
    (nolock) ON a.cpros = b.cpros
    LEFT JOIN sljcli c
with
    (nolock) ON a.estos = c.iclis
    LEFT JOIN sljgccr d
with
    (nolock) ON a.grupos = d.codigos
WHERE
    a.sqtds <> 0
    AND b.mercs = 'PA'
    and RTRIM (a.emps) <> 'NY'
    -- AND RTRIM( a.cpros ) = 'PU02153T'
    AND CONCAT (RTRIM (a.emps), ' - ', RTRIM (d.descrs)) NOT IN (
        'LMA - CONSERTOS',
        -- 'LMA - ESTOQUE CONSIGNADO',
        'MAT - CONSERTOS',
        'LMA - ESTOQUE ESPECIAL',
        'LMA - ESTOQUE LMA.PRIMA',
        'MAT - ESTOQUE MAT.PRIMA',
        'LMA - ESTOQUE TRANSIT PROD',
        'MAT - ESTOQUE TRANSIT PROD',
        'MPV - ESTOQUE PRODUTOS',
        'NY - ESTOQUE CONSIG EXT',
        'NY - ESTOQUE CONSIGNADO',
        'NY - ESTOQUE PRODUTOS',
        'NY - ESTOQUE TRANSITO'
    )
    AND RTRIM (c.rclis) NOT IN (
        'CASSIA AVILA',
        'ESTOQUE COFRE (JV)',
        'ESTOQUE DE DEVOLUÇÃO',
        'ESTOQUE ENCOMENDA',
        'ESTOQUE FABRICA / DESENVOLVIMENTO',
        'ESTOQUE LMA NY',
        'ESTOQUE MODELOS',
        'ESTOQUE PRODUCAO',
        'ESTOQUE TRANSITO AUDITORIA',
        'JACK VARTANIAN',
        'JACK VARTANIAN - IGUATEMI'
    )
GROUP BY
    a.emps,
    a.grupos,
    d.descrs,
    a.estos,
    c.rclis,
    a.cpros