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
    RTRIM( a.grupos ) AS "Cod. Gr. Est.",
    RTRIM( d.descrs ) AS "Desc. Gr. Est.",
    RTRIM( a.estos ) AS "Cod. Cta. Est.",
    RTRIM( c.rclis ) AS "Desc. Cta. Est.",
    CONCAT( RTRIM( a.emps ), ' - ' , RTRIM( d.descrs )) AS "Loja Desc. Gr. Est.",
    RTRIM( a.cpros ) AS "Cod. Prod.",
    CAST( SUM( a.sqtds ) AS INTEGER) AS "Qtd"
FROM sljest a with(nolock)
    LEFT JOIN sljpro b with(nolock) ON a.cpros = b.cpros
    LEFT JOIN sljcli c with(nolock) ON a.estos = c.iclis
    LEFT JOIN sljgccr d with(nolock) ON a.grupos = d.codigos
WHERE a.sqtds <> 0
    AND b.mercs = 'PA'
    and RTRIM( a.emps ) <> 'NY'
    AND RTRIM( c.rclis ) IN ('ESTOQUE MARKETING')
    GROUP BY a.emps, a.grupos, d.descrs, a.estos, c.rclis, a.cpros
