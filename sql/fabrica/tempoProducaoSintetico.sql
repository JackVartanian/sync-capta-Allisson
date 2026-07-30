IF OBJECT_ID('tempdb.dbo.#AnaliseApt','U') is not null  
	DROP TABLE #AnaliseApt;

IF OBJECT_ID('tempdb.dbo.#AnaliseTempo','U') is not null  
DROP TABLE #AnaliseTempo;

SELECT *,
       ROW_NUMBER() OVER (PARTITION BY NOPS,
                                       FASES,
                                       ICLIS
                          ORDER BY DATAS ASC) ORdem INTO #AnaliseApt
FROM SLJAPTMP
ORDER BY DATAS ASC ;


SELECT a.ordem,
       CASE a.status
           WHEN 2 THEN 'INICIO'
           WHEN 3 THEN 'PAUSA'
           WHEN 4 THEN 'FIM'
       END Status_ini,
       a.datas Dt_Ini,
       CASE b.status
           WHEN 2 THEN 'INICIO'
           WHEN 3 THEN 'PAUSA'
           WHEN 4 THEN 'FIM'
       END Status_fim,
       b.datas Dt_Fim,
       Convert(int,CASE
                       WHEN a.status =2
                            AND round(convert(numeric(14, 2), Datediff(SECOND, a.datas, b.datas))/60, 0, 0) = 0 THEN 1
                       WHEN a.status = 2 THEN round(convert(numeric(14, 2), Datediff(SECOND, a.datas, b.datas))/60, 0, 0)
                       ELSE 0
                   END) Tempo ,
       a.NOPS,
       a.FASES,
       a.ICLIS INTO #AnaliseTempo
FROM #AnaliseApt a
LEFT JOIN #AnaliseApt b ON a.ordem = b.ordem -1
AND a.NOPS = b.NOPS
AND a.FASES = b.FASES
AND a.ICLIS = b.ICLIS
ORDER BY 1 ;


SELECT RTRIM(ANALISE.NOPS) AS NOPS,
       RTRIM(ANALISE.FASES) AS FASES,
       RTRIM(ANALISE.ICLIS) AS ICLIS,
       RTRIM(opi.cpros) AS CPROS,
       CAST(OPI.dataps AS DATE) AS DT_CRIACAO_OP,
       CAST(OPI.dataes AS DATE) AS DT_PREV_CONCLUSAO,
       RTRIM(OPI.emps) AS EMP_PEDIDO,
       RTRIM(OPI.dopes) AS NOME_PEDIDO,
       RTRIM(OPI.numes) AS NUM_PEDIDO,
       CAST(PRO.pesoms AS INT) AS PESO_MEDIO,
       CAST(OPI.qtds AS INT) AS QTDE_PRODUTO,
       RTRIM(GCCR.DESCRS) AS DESC_FASE_PRODUCAO,
       RTRIM(cli.rclis) AS NOME_FUNC,
       CAST(EEST.prazoents AS DATE) AS DT_ENTREGA_PED,
       SUM(ANALISE.TEMPO) AS MINUTOS_TOTAL
FROM #AnaliseTempo ANALISE
LEFT JOIN sljopi OPI WITH(NOLOCK) ON ANALISE.NOPS = opi.nops
LEFT JOIN sljpro PRO WITH(NOLOCK) ON PRO.cpros = OPI.cpros
LEFT JOIN SLJGCCR GCCR WITH(NOLOCK) ON ANALISE.FASES = GCCR.CODIGOS
LEFT JOIN sljcli CLI WITH(NOLOCK) ON CLI.iclis = ANALISE.iclis
LEFT JOIN SLJEEST EEST WITH(NOLOCK) ON EEST.EMPDOPNUMS = OPI.EMPDOPNUMS
WHERE Status_ini = 'INICIO'
GROUP BY ANALISE.NOPS,
         ANALISE.FASES,
         ANALISE.ICLIS,
         OPI.CPROS,
         OPI.dataps,
         OPI.dataes,
         OPI.emps,
         OPI.dopes,
         OPI.numes,
         PRO.pesoms,
         OPI.qtds,
         GCCR.descrs,
         CLI.rclis,
         EEST.prazoents