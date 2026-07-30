select
    RTRIM(t.cpros) as "Cod Prod",
    RTRIM(t.obscompos) as "Obs. Composicao",
    '' as "CT Pedra 1",
    '' as "CT diamante",
    '' as "Grau de cor",
    '' as "Grau de Pureza"
from sljcompo t WITH (NOLOCK)
    LEFT JOIN sljpro a WITH (NOLOCK) ON t.cpros = a.cpros
    INNER JOIN sljsgru g WITH(NOLOCK) ON a.cgrus+ + a.sgrus = g.cgrucods
    INNER JOIN sljcor c WITH(NOLOCK) ON a.codcors = c.cods
    INNER JOIN (
    SELECT
        RTRIM( a.cpros ) AS "Cod. Prod.",
        CAST(a.pesoms AS DECIMAL(10,2))AS "Peso",
        CASE
            WHEN [Qtd_Estoque] > 0 THEN [Qtd_Estoque]
        ELSE 0
            END AS "Estoque",
        CASE
            WHEN a.encoms = 1 THEN 'ATIVO'
            WHEN [Qtd_Estoque] > 0 THEN 'ATIVO'
            WHEN [Qtd_Estoque] < 1 AND a.encoms = 1 THEN 'ATIVO'
            WHEN [Qtd_Estoque] > 0 AND a.encoms = 1 THEN 'ATIVO'
            WHEN [Qtd_Estoque] < 1 AND a.encoms = 0 THEN 'INATIVO'
        ELSE 'INATIVO'
            END AS "STATUS_FINAL"
    FROM sljpro a with(nolock)
        LEFT JOIN(
            SELECT RTRIM( z.cpros ) AS 'Cod_Prod',
            CAST(SUM(z.qtds) AS INT) AS 'Qtd_Estoque'
        FROM
            sljeti z with(nolock)
            LEFT JOIN sljpro b with(nolock) ON z.cpros = b.cpros
            LEFT JOIN sljgccr d with(nolock) ON z.grupos = d.codigos
            LEFT JOIN sljcli c with(nolock) ON z.contas = c.iclis
        WHERE
        z.empos NOT IN ('LMA', 'MAT', 'DES', 'NY')
            AND b.mercs = 'PA'
            AND z.contas <> '          '
            AND RTRIM( c.rclis ) NOT IN ('CASSIA AVILA',
                                'ESTOQUE COFRE (JV)',
                                'ESTOQUE DE DEVOLUÇÃO',
                                'ESTOQUE ENCOMENDA',
                                'ESTOQUE FABRICA / DESENVOLVIMENTO',
                                'ESTOQUE LMA NY',
                                'ESTOQUE MARKETING',
                                'ESTOQUE MODELOS',
                                'ESTOQUE PRODUCAO',
                                'ESTOQUE TRANSITO AUDITORIA',
                                'JACK VARTANIAN',
                                'JACK VARTANIAN - IGUATEMI')
        GROUP BY
            z.cpros
        ) AS est ON a.cpros = est.Cod_Prod
    WHERE a.mercs = 'PA'
        AND (
        CASE
            WHEN a.encoms = 1 THEN 'ATIVO'
            WHEN [Qtd_Estoque] > 0 THEN 'ATIVO'
            WHEN [Qtd_Estoque] < 1 AND a.encoms = 1 THEN 'ATIVO'
            WHEN [Qtd_Estoque] > 0 AND a.encoms = 1 THEN 'ATIVO'
            WHEN [Qtd_Estoque] < 1 AND a.encoms = 0 THEN 'INATIVO'
            ELSE 'INATIVO'
        END
    ) = 'ATIVO'
) AS est ON t.cpros = est.[Cod. Prod.]
WHERE RTRIM(t.obscompos) <> ''
AND RTRIM( a.nivelqs ) = 'OURO'
AND RTRIM( a.sgrus ) = 'SP'
    -- AND RTRIM(t.cpros) = 'BR06383T'
     