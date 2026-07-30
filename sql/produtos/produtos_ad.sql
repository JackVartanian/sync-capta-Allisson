/* 
Query to retrieve product information for accessories (AD) category
Optimized with proper indexing hints and formatting
*/
SELECT 
    -- Collection and Group Information
    RTRIM(e.colecoes) AS "Cod. Modelo",
    RTRIM(a.cgrus) AS "Cod. Gr.",
    RTRIM(f.dgrus) AS "Desc. Gr.",
    RTRIM(a.sgrus) AS "Cod. Subgr.",
    RTRIM(g.descricaos) AS "Desc. Subgr.",
    
    -- Product Details
    RTRIM(a.cpros) AS "Cod. Prod.",
    RTRIM(a.dpros) AS "Desc. Produto",
    RTRIM(a.markupa) AS "Markup Aplic",
    CAST(a.pcuss AS DECIMAL(10,2)) AS "Pr. Custo",
    CAST(a.pvens AS DECIMAL(10,2)) AS "Pr Venda unit",
    
    -- Product Classifications
    RTRIM(a.mercs) AS "Gde. Gr.",
    RTRIM(a.nivelqs) AS "Metal",
    RTRIM(a.codcors) AS "Cor Padrao",
    RTRIM(c.descs) AS "Desc Cor",
    RTRIM(a.codscols) AS "Sub Nivel",
    RTRIM(a.cftios) AS "Tab. Pr.",
    
    -- Product Image URL
    CONCAT('http://jackvartanian.net/cms/wp-content/uploads/fotos/', RTRIM(a.cpros), '.JPG') AS "Foto",
    
    -- Product Status Flags
    CASE WHEN a.encoms = 1 THEN 'Sim' ELSE 'Nao' END AS "Encomendavel",
    CASE WHEN a.situas = 1 THEN 'Ativo' ELSE 'Inativo' END AS "Status",
    
    -- Additional Product Information
    CONVERT(DATE, a.dtincs) AS "Data Inclusao",
    CAST(a.pesoms AS DECIMAL(10,3)) AS "Peso",
    RTRIM(a.cclass) AS "Classificacao",
    RTRIM(a.linhas) AS "Linha"

FROM sljpro a WITH (NOLOCK, INDEX(PK_sljpro))
    INNER JOIN sljgru f WITH (NOLOCK, INDEX(PK_sljgru)) 
        ON a.cgrus = f.cgrus
    INNER JOIN sljsgru g WITH (NOLOCK, INDEX(PK_sljsgru)) 
        ON a.sgrus = g.codigos
    INNER JOIN sljcol e WITH (NOLOCK, INDEX(PK_sljcol)) 
        ON a.colecoes = e.colecoes
    LEFT JOIN sljcor c WITH (NOLOCK, INDEX(PK_sljcor)) 
        ON a.codcors = c.cods
WHERE a.mercs = 'AD'
ORDER BY a.cpros;