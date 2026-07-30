SELECT
    CAST(aptmp.datas AS DATE) AS DT_APt,
    CASE WHEN RTRIM(aptmp.status) = '2' THEN 'Iniciado'
    WHEN RTRIM(aptmp.status) = '3' THEN 'Pausado'
    WHEN RTRIM(aptmp.status) = '4' THEN 'Finalizado'
END AS Status,
    --    RTRIM(aptmp.status) AS Status,
    RTRIM(aptmp.NOPS),
    RTRIM(aptmp.FASES),
    RTRIM(aptmp.ICLIS),
    RTRIM(opi.cpros),
    CAST(OPI.dataps AS DATE) AS DT_CRIACAO_OP,
    CAST(OPI.dataes AS DATE) AS DT_PREV_CONCLUSAO,
    RTRIM(OPI.emps) AS EMP_PEDIDO,
    RTRIM(OPI.dopes) AS NOME_PEDIDO,
    RTRIM(OPI.numes) AS NUM_PEDIDO,
    CAST(PRO.pesoms AS INT) AS PESO_MEDIO,
    CAST(OPI.qtds AS INT) AS QTDE_PRODUTO,
    RTRIM(GCCR.DESCRS) AS DESC_FASE_PRODUCAO,
    RTRIM(cli.rclis) AS NOME_FUNC,
    CAST(EEST.prazoents AS DATE) AS DT_ENTREGA_PED
FROM sljaptmp aptmp with(nolock)
    LEFT JOIN sljopi OPI WITH(NOLOCK) ON aptmp.NOPS = opi.nops
    LEFT JOIN sljpro PRO WITH(NOLOCK) ON PRO.cpros = OPI.cpros
    LEFT JOIN SLJGCCR GCCR WITH(NOLOCK) ON aptmp.FASES = GCCR.CODIGOS
    LEFT JOIN sljcli CLI WITH(NOLOCK) ON CLI.iclis = aptmp.iclis
    LEFT JOIN SLJEEST EEST WITH(NOLOCK) ON EEST.EMPDOPNUMS = OPI.EMPDOPNUMS
ORDER BY DT_APt DESC