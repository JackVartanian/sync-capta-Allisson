SELECT
    RTRIM( a.cgrus ) AS "Cod. Gr.",
    RTRIM( a.cpros ) AS "Cod. Prod.",
    RTRIM( a.dpros ) AS "Desc. Produto",
    CAST( a.pcuss AS DECIMAL(10,2)) AS "Pr. Custo",
    RTRIM( a.mercs ) AS "Gde. Gr.",
    CASE
    WHEN a.encoms = 1 THEN 'Sim'
    ELSE 'Nao'
END AS "Encomendavel",

    CASE
    WHEN a.situas = 1 THEN 'Ativo'
    ELSE 'Inativo'
END AS "Status",

    CAST(a.dtincs AS DATE)AS "Data Inclusao"
FROM sljpro a with(nolock)
WHERE a.mercs = 'EM'