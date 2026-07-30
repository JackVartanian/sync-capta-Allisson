SELECT
    RTRIM(EEST.dopes) AS "Operacao",
    CAST(EEST.numes AS INT) AS "Num",
    RTRIM(EEST.contads) AS "Cod. Conta",
    RTRIM(CLI.rclis) AS "Desc. Conta",
    RTRIM(EEST.vends) AS "Cod. Vendedor",
    RTRIM(VEN.rclis) AS "Desc. Vendedor",
    RTRIM(EEST.emps) AS "Empresa",
    CAST(EEST.datas AS DATE) AS "Data",
    RTRIM(PRO.colecoes) AS "Colecao",
    RTRIM(PRO.cgrus) AS "Grupo",
    RTRIM(PRO.sgrus) AS "Subgrupo",
    RTRIM(EESTI.cpros) AS "Cod. Prod",
    RTRIM(EESTI.dpros) AS "Desc. Prod",
    RTRIM(EESTI.codbarras)  AS "Cod. Barras",
    CAST(EESTI.qtds AS INT) AS "Qtd",
    CAST(EESTI.units AS DECIMAL) AS "Valor Unit.",
    CAST(EESTI.totas AS DECIMAL) AS "Total",
    RTRIM(PRO.cftios) AS "Tabela"
FROM sljeest EEST WITH(NOLOCK)
    INNER JOIN sljope OPE WITH(NOLOCK) ON EEST.dopes = OPE.dopes
    INNER JOIN sljeesti EESTI WITH(NOLOCK) ON EEST.empdopnums = EESTI.empdopnums
    INNER JOIN sljpro PRO WITH(NOLOCK) ON EESTI.cpros = PRO.cpros
    INNER JOIN sljcli CLI WITH(NOLOCK) ON EEST.contads = CLI.iclis
    LEFT JOIN sljcli VEN WITH(NOLOCK) ON EEST.vends = VEN.iclis
WHERE OPE.tipoops IN ('1', '14')
    
    