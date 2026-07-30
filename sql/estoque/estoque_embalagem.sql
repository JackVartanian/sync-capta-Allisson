SELECT
    RTRIM( a.cpros ) AS "Cod. Prod.",
    CAST( SUM( a.sqtds ) AS INTEGER) AS "Qtd"
FROM sljest a with(nolock)
    LEFT JOIN sljpro b with(nolock) ON a.cpros = b.cpros
WHERE a.sqtds <> 0
    AND b.mercs = 'EM'
    and RTRIM( a.emps ) <> 'NY'
    GROUP BY a.cpros