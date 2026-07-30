SELECT
       RTRIM( a.emps ) AS "Empresa",
       RTRIM( a.grupos ) AS "Cod. Gr. Est.",
       RTRIM( d.descrs ) AS "Desc. Gr. Est.",
       RTRIM( a.estos ) AS "Cod. Cta. Est.",
       RTRIM( c.rclis ) AS "Desc. Cta. Est.",
       RTRIM( a.cpros ) AS "Cod. Prod.",
       a.sqtds AS "Qtd",
       RTRIM( b.situas ) AS "Ativo(1)/Inativo(2)"
FROM sljest a with(nolock)
LEFT JOIN sljpro b with(nolock) ON a.cpros = b.cpros
LEFT JOIN sljcli c with(nolock) ON a.estos = c.iclis
LEFT JOIN sljgccr d with(nolock) ON a.grupos = d.codigos
WHERE a.sqtds <> 0 AND b.mercs = 'AD'