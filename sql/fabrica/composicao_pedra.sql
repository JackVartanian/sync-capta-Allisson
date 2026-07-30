select
    RTRIM( a.colecoes ) AS "Cod. Modelo",
    RTRIM( g.descricaos ) AS "Desc. Subgr.",
    RTRIM(t.cpros) as "Cod Prod",
    RTRIM( a.dpros ) AS "Desc. Produto",
    RTRIM(t.dcompos) as "Desc. Composicao",
    RTRIM( a.nivelqs ) AS "Metal",
    RTRIM( a.codcors ) AS "Cor Padrao",
    RTRIM( c.descs ) AS "Desc Cor",
    RTRIM(t.cgrus) as "Grupo",
    RTRIM(t.dscgrp) as "Desc. Grupo",
    CAST(a.pesoms AS DECIMAL(10,2))AS "Peso",
    SUM(CAST(t.qtds as DECIMAL(10,2))) as "Qtde",
    '' as "Pedra 1",
    '' as "CT pedra 1",
    '' as "Lapidação pedra 1",
    '' as "Pedra 2",
    '' as "CT pedra 2",
    '' as "Lapidação pedra 2"
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

WHERE RTRIM(t.cgrus) = 'PED'
    -- AND RTRIM(t.cpros) = 'BR06383T'

GROUP BY RTRIM( a.colecoes ), RTRIM( g.descricaos ), RTRIM(t.cpros), RTRIM( a.dpros ), RTRIM(t.dcompos), RTRIM( a.nivelqs ), RTRIM( a.codcors ), RTRIM( c.descs ), RTRIM(t.cgrus), RTRIM(t.dscgrp), CAST(a.pesoms AS DECIMAL(10,2))