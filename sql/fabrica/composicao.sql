select
  RTRIM(t.cpros) as "Cod Prod",
  RTRIM(t.mats) as "Item",
  RTRIM(t.cats) as "Categoria",
  RTRIM(t.cgrus) as "Grupo",
  RTRIM(t.dscgrp) as "Desc. Grupo",
  RTRIM(t.compos) as "Composicao",
  RTRIM(t.dcompos) as "Desc. Composicao",
  CAST(t.qtds as DECIMAL(10,2)) as "Qtde",
  RTRIM(t.unicompos) as "Unid",
  CAST(t.pcompos as DECIMAL(10,3)) as "Custo",
  CAST(t.qtds as DECIMAL (10,2)) * CAST(t.pcompos as DECIMAL(10,3)) as "Custo Total",
  RTRIM(t.moeds) as "Moeda",
  CAST(t.dtmovs AS DATE) as "Data"
from sljcompo t WITH (NOLOCK)
  -- left join ( 
  -- select cpros, max(dtmovs) as MaxDate
  -- from sljcompo WITH (NOLOCK)
  -- -- WHERE dtmovs > '1999/01/01 00:00:00'
  -- group by cpros )
  -- tm on t.cpros = tm.cpros and t.dtmovs = tm.MaxDate

  -- INNER JOIN(
  --   SELECT
  --     RTRIM( a.cpros ) AS "Cod. Prod.",
  --     CAST(a.pesoms AS DECIMAL(10,2))AS "Peso",
  --     CASE
  --         WHEN [Qtd_Estoque] > 0 THEN [Qtd_Estoque]
  --         ELSE 0
  --     END AS "Estoque",
  --     CASE
  --         WHEN a.encoms = 1 THEN 'ATIVO'
  --         WHEN [Qtd_Estoque] > 0 THEN 'ATIVO'
  --         WHEN [Qtd_Estoque] < 1 AND a.encoms = 1 THEN 'ATIVO'
  --         WHEN [Qtd_Estoque] > 0 AND a.encoms = 1 THEN 'ATIVO'
  --         WHEN [Qtd_Estoque] < 1 AND a.encoms = 0 THEN 'INATIVO'
  --         ELSE 'INATIVO'
  --     END AS "STATUS_FINAL"
  -- FROM sljpro a with(nolock)
  --   LEFT JOIN(
  --       SELECT RTRIM( z.cpros ) AS 'Cod_Prod',
  --     CAST(SUM(z.qtds) AS INT) AS 'Qtd_Estoque'
  --   FROM
  --     sljeti z with(nolock)
  --     LEFT JOIN sljpro b with(nolock) ON z.cpros = b.cpros
  --     LEFT JOIN sljgccr d with(nolock) ON z.grupos = d.codigos
  --     LEFT JOIN sljcli c with(nolock) ON z.contas = c.iclis
  --   WHERE
  --   z.empos NOT IN ('LMA', 'MAT', 'DES', 'NY')
  --     AND b.mercs = 'PA'
  --     AND z.contas <> '          '
  --     AND RTRIM( c.rclis ) NOT IN ('CASSIA AVILA',
  --                           'ESTOQUE COFRE (JV)',
  --                           'ESTOQUE DE DEVOLUÇÃO',
  --                           'ESTOQUE ENCOMENDA',
  --                           'ESTOQUE FABRICA / DESENVOLVIMENTO',
  --                           'ESTOQUE LMA NY',
  --                           'ESTOQUE MARKETING',
  --                           'ESTOQUE MODELOS',
  --                           'ESTOQUE PRODUCAO',
  --                           'ESTOQUE TRANSITO AUDITORIA',
  --                           'JACK VARTANIAN',
  --                           'JACK VARTANIAN - IGUATEMI')
  --   GROUP BY
  --       z.cpros
  --   ) AS est ON a.cpros = est.Cod_Prod
  -- WHERE a.mercs = 'PA'
  --   AND (
  --       CASE
  --           WHEN a.encoms = 1 THEN 'ATIVO'
  --           WHEN [Qtd_Estoque] > 0 THEN 'ATIVO'
  --           WHEN [Qtd_Estoque] < 1 AND a.encoms = 1 THEN 'ATIVO'
  --           WHEN [Qtd_Estoque] > 0 AND a.encoms = 1 THEN 'ATIVO'
  --           WHEN [Qtd_Estoque] < 1 AND a.encoms = 0 THEN 'INATIVO'
  --           ELSE 'INATIVO'
  --       END
  --   ) = 'ATIVO'
  -- ) as prods on t.cpros = prods."Cod. Prod."
  WHERE RTRIM(t.cgrus) = 'MET'
  -- RTRIM(t.cpros) = 'BR06590T'
  -- AND RTRIM(t.cgrus) = 'MET'
