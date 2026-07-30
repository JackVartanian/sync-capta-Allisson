SELECT
    RTRIM( a.emps ) AS "Empresa",
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
    and RTRIM( a.emps ) = 'NY'
GROUP BY a.emps, a.grupos, d.descrs, a.estos, c.rclis, a.cpros