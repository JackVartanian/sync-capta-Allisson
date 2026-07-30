
   SELECT a.emps,
      a.dopes,
      CAST (a.numes AS NUMERIC (10)) AS numes,
      a.datas,
      a.tipoops,
      a.empdopnums,
      CASE
                WHEN A.ICLIS LIKE '110401%' THEN (CASE
                                                      WHEN F.OPERS = 'S' THEN G.GRUPODS
                                                      ELSE G.GRUPOOS
                                                  END)
                ELSE a.grupos
            END AS 'grpcli',
      CASE
                WHEN A.ICLIS LIKE '110401%' THEN (CASE
                                                      WHEN F.OPERS = 'S' THEN G.CONTADS
                                                      ELSE G.CONTAOS
                                                  END)
                ELSE a.iclis
            END AS ICLIS,
      CASE
                WHEN A.ICLIS = '' THEN ''
                ELSE (CASE
                          WHEN A.ICLIS LIKE '110401%' THEN (CASE
                                                                WHEN F.OPERS = 'S' THEN I.RCLIS
                                                                ELSE J.RCLIS
                                                            END)
                          ELSE a.rclis
                      END)
            END AS 'cliente',
      a.grvends,
      a.valrats,
      CASE
                WHEN (a.totas - a.valrats) <> 0 THEN a.valrats / (a.totas - a.valrats) * 100
                ELSE 0
            END AS PercDesc,
      a.vends,
      K.RCLIS AS nvends,
      a.grresps,
      a.resps,
      e.rclis AS 'respons',
      a.ggrus,
      a.cgrus,
      a.dgrus,
      a.sgrus,
      a.linhas,
      a.dlinhas,
      a.colecoes,
      a.dcolecoes,
      b.reffs,
      a.cpros,
      b.dpros,
      a.codbarras,
      b.codcors AS 'corpad',
      a.cunis,
      a.qtds,
      b.pesoms AS pesos,
      a.custos,
      a.moecus,
      b.custofs,
      b.moecusfs,
      b.pvens,
      b.moevs,
      b.pvideals,
      a.totas,
      CASE
                WHEN f.opers = 'S' THEN f.totas
                ELSE -1 * F.TOTAS
            END AS totbrt,
      CASE
                WHEN F.OPERS = 'S' THEN F.TOTAS
                ELSE 0
            END AS VLRSAIDA,
      a.anos,
      a.mess,
      a.trimestres,
      g.notas,
      a.tabds,
      a.grupoests,
      a.contaests,
      a.sqtds,
      c.rclis AS 'estoque',
      d.descrs AS 'grpestoq',
      b.codmatp AS ctdiam,
      b.cftios,
      h.nascs,
      h.dmnascs,
      h.dtcasas,
      h.dtncons,
      h.ddds,
      h.tel1s,
      h.tel2s,
      h.faxs,
      h.emails,
      h.mailnfes,
      H.CPFS,
      h.ultcomps,
      B.CPROEQS,
      B.CODSCOLS,
      S.DESCS AS DESC_SCOL,
      L.DPROS AS DPROEQS,
      m.codtams,
      a.tpesos,
      b.pesoms,
      b.ultcomps AS ult_comp_pro,
      pmov.data_pmov,
      umov.data_pmov AS data_umov,
      b.pcuss AS Custo_Pro,
      b.moecs,
      isnull(est.sqtds, 0) AS qtd_ests,
      '11040101' AS estos,
      '110401' AS grupoest,
      med.TicketM,
      med.pa,
      med.TICKETS,
      G.CODEVENTS
   FROM sljgdmi AS a
      LEFT OUTER JOIN sljpro AS b ON a.cpros = b.cpros
      LEFT OUTER JOIN sljcli AS c ON a.contaests = c.iclis
      LEFT OUTER JOIN sljgccr AS d ON a.grupoests = d.codigos
      LEFT OUTER JOIN sljcli AS e ON a.resps = e.iclis
      LEFT OUTER JOIN sljeesti AS f ON a.empdopnums + CONVERT (CHAR (8),
                                                         a.codbarras) = f.empdopnums + CONVERT (CHAR (8),
                                                                                                f.codbarras)
      LEFT OUTER JOIN sljeest AS g ON a.empdopnums = g.empdopnums
      LEFT OUTER JOIN sljcli AS h ON a.iclis = h.iclis
      LEFT OUTER JOIN SLJCLI AS J ON G.CONTAOS = J.ICLIS
      LEFT OUTER JOIN SLJCLI AS I ON G.CONTADS = I.ICLIS
      LEFT OUTER JOIN SLJCLI AS K ON K.ICLIS = A.VENDS
      LEFT OUTER JOIN SLJPRO AS L ON B.CPROEQS = L.CPROS
      LEFT OUTER JOIN sljeti AS M ON A.codbarras = M.cbars
      LEFT OUTER JOIN SLJSCOL AS S ON S.CODIGOS = B.CODSCOLS
      LEFT OUTER JOIN
      (SELECT it.cpros,
         min(op.datas) AS data_pmov
      FROM sljeesti AS it WITH (NOLOCK)
         INNER JOIN sljeest AS op WITH (NOLOCK) ON it.empdopnums = op.empdopnums
      WHERE it.opers = 'E'
      GROUP BY it.cpros) AS pmov ON pmov.cpros = b.cpros
      LEFT OUTER JOIN
      (SELECT it.cpros,
         max(op.datas) AS data_pmov
      FROM sljeesti AS it WITH (NOLOCK)
         INNER JOIN sljeest AS op WITH (NOLOCK) ON it.empdopnums = op.empdopnums
      WHERE it.opers = 'E'
      GROUP BY it.cpros) AS umov ON umov.cpros = b.cpros
      LEFT OUTER JOIN sljest AS est ON a.cpros = est.cpros
         AND a.emps = est.emps
         AND EST.grupos = '110401'
         AND EST.ESTOS = '11040101'
      LEFT OUTER JOIN
      (SELECT MED.emps,
         MED.mes,
         med.ano,
         med.vendedor,
         COUNT(MED.empdatavendcli) AS TICKETS,
         SUM(MED.PECAS) AS QTD_PCAS,
         SUM(MED.TOTAL) AS VAL_TOTAL,
         CONVERT (NUMERIC (14, 2),
                   CONVERT (FLOAT, SUM(MED.TOTAL)) / CONVERT (FLOAT, COUNT(MED.empdatavendcli))) AS TicketM,
         CONVERT (NUMERIC (14, 2),
                           CONVERT (FLOAT, SUM(MED.PECAS)) / CONVERT (FLOAT, COUNT(MED.empdatavendcli))) AS Pa
      FROM
         (SELECT gp.emps,
            day(gp.datas) AS dia,
            month(gp.datas) AS mes,
            YEAR(gp.datas) AS ano,
            gp.vends AS vendedor,
            sum(gp.qtds) AS Pecas,
            SUM(totas) AS total,
            gp.iclis,
            gp.emps + rtrim(CONVERT (CHAR, gp.datas, 103)) + gp.vends + gp.iclis AS empdatavendcli
         FROM sljgdmi AS gp
         WHERE gp.dopes NOT LIKE '%oferta%'
            AND gp.dopes NOT LIKE '%troca%'
         GROUP BY gp.EMPS,
               gp.datas,
               gp.vends,
               gp.iclis) AS MED
      WHERE 1=1
      GROUP BY MED.emps,
            MED.mes,
            med.ano,
            med.vendedor) AS MED ON med.emps = a.emps
         AND med.mes = month(a.datas)
         AND med.ano = YEAR(a.datas)
         AND a.vends = med.vendedor
   WHERE a.codbarras <> 0
      AND a.tipoops NOT IN (91,
                        92)
      AND A.DOPES <> 'ADTO ENCOMENDA '
UNION ALL
   SELECT a.emps,
      a.dopes,
      CAST (a.numes AS NUMERIC (10)) AS numes,
      a.datas,
      a.tipoops,
      a.empdopnums,
      CASE
                WHEN A.ICLIS LIKE '110401%' THEN G.GRUPODS
                ELSE a.grupos
            END AS 'grpcli',
      CASE
                WHEN A.ICLIS LIKE '110401%' THEN G.CONTADS
                ELSE a.iclis
            END AS ICLIS,
      CASE
                WHEN A.ICLIS = '' THEN ''
                ELSE (CASE
                          WHEN A.ICLIS LIKE '110401%' THEN I.RCLIS
                          ELSE a.rclis
                      END)
            END AS 'cliente',
      a.grvends,
      a.valrats,
      CASE
                WHEN (a.totas - a.valrats) <> 0 THEN a.valrats / (a.totas - a.valrats) * 100
                ELSE 0
            END AS PercDesc,
      a.vends,
      K.RCLIS AS nvends,
      a.grresps,
      a.resps,
      e.rclis AS 'respons',
      a.ggrus,
      a.cgrus,
      a.dgrus,
      a.sgrus,
      a.linhas,
      a.dlinhas,
      a.colecoes,
      a.dcolecoes,
      b.reffs,
      a.cpros,
      b.dpros,
      a.codbarras,
      b.codcors AS 'corpad',
      a.cunis,
      a.qtds,
      b.pesoms AS pesos,
      a.custos,
      a.moecus,
      b.custofs,
      b.moecusfs,
      b.pvens,
      b.moevs,
      b.pvideals,
      a.totas,
      a.totas AS totbrt,
      CASE
                WHEN A.TOTAS > 0 THEN A.TOTAS
                ELSE 0
            END AS VLRSAIDA,
      a.anos,
      a.mess,
      a.trimestres,
      g.notas,
      a.tabds,
      a.grupoests,
      a.contaests,
      a.sqtds,
      c.rclis AS 'estoque',
      d.descrs AS 'grpestoq',
      b.codmatp AS ctdiam,
      b.cftios,
      h.nascs,
      h.dmnascs,
      h.dtcasas,
      h.dtncons,
      h.ddds,
      h.tel1s,
      h.tel2s,
      h.faxs,
      h.emails,
      h.mailnfes,
      H.CPFS,
      h.ultcomps,
      B.CPROEQS,
      B.CODSCOLS,
      S.DESCS AS DESC_SCOL,
      L.DPROS AS DPROEQS,
      M.CODTAMS,
      a.tpesos,
      b.pesoms,
      b.ultcomps AS ult_comp_pro,
      pmov.data_pmov,
      umov.data_pmov AS data_umov,
      b.pcuss AS Custo_pro,
      b.moecs,
      ISNULL(est.SQTDS, 0) AS qtd_ests,
      '11040101' AS estos,
      '110401' AS grupoest,
      med.TicketM,
      med.Pa,
      med.tickets,
      G.CODEVENTS
   FROM sljgdmi AS a
      LEFT OUTER JOIN sljpro AS b ON a.cpros = b.cpros
      LEFT OUTER JOIN sljcli AS c ON a.contaests = c.iclis
      LEFT OUTER JOIN sljgccr AS d ON a.grupoests = d.codigos
      LEFT OUTER JOIN sljcli AS e ON a.resps = e.iclis
      LEFT OUTER JOIN sljeest AS g ON a.empdopnums = g.empdopnums
      LEFT OUTER JOIN sljcli AS h ON a.iclis = h.iclis
      LEFT OUTER JOIN SLJCLI AS J ON G.CONTAOS = J.ICLIS
      LEFT OUTER JOIN SLJCLI AS I ON G.CONTADS = I.ICLIS
      LEFT OUTER JOIN SLJCLI AS K ON K.ICLIS = A.VENDS
      LEFT OUTER JOIN SLJPRO AS L ON B.CPROEQS = L.CPROS
      LEFT OUTER JOIN sljeti AS M ON A.codbarras = M.cbars
      LEFT OUTER JOIN SLJSCOL AS S ON S.CODIGOS = B.CODSCOLS
      LEFT OUTER JOIN
      (SELECT it.cpros,
         min(op.datas) AS data_pmov
      FROM sljeesti AS it WITH (NOLOCK)
         INNER JOIN sljeest AS op WITH (NOLOCK) ON it.empdopnums = op.empdopnums
      WHERE it.opers = 'E'
      GROUP BY it.cpros) AS pmov ON pmov.cpros = b.cpros
      LEFT OUTER JOIN
      (SELECT it.cpros,
         max(op.datas) AS data_pmov
      FROM sljeesti AS it WITH (NOLOCK)
         INNER JOIN sljeest AS op WITH (NOLOCK) ON it.empdopnums = op.empdopnums
      WHERE it.opers = 'E'
      GROUP BY it.cpros) AS umov ON umov.cpros = b.cpros
      LEFT OUTER JOIN sljest AS est ON a.cpros = est.cpros
         AND a.emps = est.emps
         AND EST.grupos = '110401'
         AND EST.ESTOS = '11040101'
      LEFT OUTER JOIN
      (SELECT MED.emps,
         MED.mes,
         med.ano,
         med.vendedor,
         COUNT(MED.empdatavendcli) AS TICKETS,
         SUM(MED.PECAS) AS QTD_PCAS,
         SUM(MED.TOTAL) AS VAL_TOTAL,
         CONVERT (NUMERIC (14, 2),
                   CONVERT (FLOAT, SUM(MED.TOTAL)) / CONVERT (FLOAT, COUNT(MED.empdatavendcli))) AS TicketM,
         CONVERT (NUMERIC (14, 2),
                           CONVERT (FLOAT, SUM(MED.PECAS)) / CONVERT (FLOAT, COUNT(MED.empdatavendcli))) AS Pa
      FROM
         (SELECT gp.emps,
            day(gp.datas) AS dia,
            month(gp.datas) AS mes,
            YEAR(gp.datas) AS ano,
            gp.vends AS vendedor,
            sum(gp.qtds) AS Pecas,
            SUM(totas) AS total,
            gp.iclis,
            gp.emps + rtrim(CONVERT (CHAR, gp.datas, 103)) + gp.vends + gp.iclis AS empdatavendcli
         FROM sljgdmi AS gp
         WHERE gp.dopes NOT LIKE '%oferta%'
            AND gp.dopes NOT LIKE '%troca%'
         GROUP BY gp.EMPS,
               gp.datas,
               gp.vends,
               gp.iclis) AS MED
      WHERE 1=1
      GROUP BY MED.emps,
            MED.mes,
            med.ano,
            med.vendedor) AS MED ON med.emps = a.emps
         AND med.mes = month(a.datas)
         AND med.ano = YEAR(a.datas)
         AND a.vends = med.vendedor
   WHERE a.codbarras = 0
      AND a.tipoops NOT IN (91,
                        92)
      AND a.dopes <> 'ADTO ENCOMENDA '
UNION ALL
   SELECT EEST.emps,
      EEST.dopes,
      CAST (EEST.numes AS NUMERIC (10)) AS numes,
      EEST.datas,
      OPE.tipoops,
      EEST.empdopnums,
      Eest.Grupods AS GRPCLI,
      Eest.Contads AS Iclis,
      H.RCLIS AS 'cliente',
      EEST.grvends,
      EESTI.valrats,
      CASE
                WHEN (EESTI.totas - EESTI.valrats) <> 0 THEN EESTI.valrats / (EESTI.totas - EESTI.valrats) * 100
                ELSE 0
            END AS PercDesc,
      EEST.vends,
      K.RCLIS AS nvends,
      EEST.grresps,
      EEST.resps,
      e.rclis AS 'respons',
      B.MERCS AS ggrus,
      B.cgrus,
      GRU.dgrus,
      B.sgrus,
      B.linhas,
      LIN.DESCS AS dlinhas,
      b.colecoes,
      COL.DESCS AS dcolecoes,
      b.reffs,
      EESTI.cpros,
      b.dpros,
      EESTI.codbarras,
      b.codcors AS 'corpad',
      EESTI.cunis,
      EESTI.qtds,
      b.pesoms AS pesos,
      B.PCUSS AS custos,
      B.MOECS AS moecus,
      b.custofs,
      b.moecusfs,
      b.pvens,
      b.moevs,
      b.pvideals,
      EESTI.totas + eesti.valrats AS totas,
      EESTI.totas AS totbrt,
      CASE
                WHEN EESTI.TOTAS > 0 THEN EESTI.TOTAS
                ELSE 0
            END AS VLRSAIDA,
      YEAR(EEST.DATAS) AS anos,
      MONTH(EEST.DATAS) AS mess,
      CASE
                WHEN MONTH(EEST.DATAS) <= 3 THEN 1
                WHEN MONTH(EEST.DATAS) <= 6 THEN 2
                WHEN MONTH(EEST.DATAS) <= 9 THEN 3
                WHEN MONTH(EEST.DATAS) <= 12 THEN 4
            END AS trimestres,
      g.notas,
      EEST.tabds,
      '' AS grupoests,
      '' AS contaests,
      0 AS sqtds,
      '' AS 'estoque',
      '' AS 'grpestoq',
      b.codmatp AS ctdiam,
      b.cftios,
      h.nascs,
      h.dmnascs,
      h.dtcasas,
      h.dtncons,
      h.ddds,
      h.tel1s,
      h.tel2s,
      h.faxs,
      h.emails,
      h.mailnfes,
      H.CPFS,
      h.ultcomps,
      B.CPROEQS,
      B.CODSCOLS,
      S.DESCS AS DESC_SCOL,
      L.DPROS AS DPROEQS,
      M.CODTAMS,
      EESTi.tpesos,
      b.pesoms,
      b.ultcomps AS ult_comp_pro,
      pmov.data_pmov,
      umov.data_pmov AS data_umov,
      b.pcuss AS Custo_pro,
      b.moecs,
      ISNULL(est.SQTDS, 0) AS qtd_ests,
      '11040101' AS estos,
      '110401' AS grupoest,
      med.TicketM,
      med.Pa,
      med.tickets,
      g.codevents
   FROM SLJEEST AS EEST
      LEFT OUTER JOIN SLJEESTI AS EESTI ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
      LEFT OUTER JOIN SLJOPE AS OPE ON EEST.DOPES = OPE.DOPES
      LEFT OUTER JOIN sljpro AS b ON EESTI.cpros = b.cpros
      LEFT OUTER JOIN SLJGRU AS GRU ON B.CGRUS = GRU.CGRUS
      LEFT OUTER JOIN SLJLIN AS LIN ON B.LINHAS = LIN.LINHAS
      LEFT OUTER JOIN SLJCOL AS COL ON B.colecoes = COL.COLECOES
      LEFT OUTER JOIN sljcli AS e ON EEST.resps = e.iclis
      LEFT OUTER JOIN sljeest AS g ON EEST.empdopnums = g.empdopnums
      LEFT OUTER JOIN sljcli AS h ON EEST.CONTADS = h.iclis
      LEFT OUTER JOIN SLJCLI AS J ON G.CONTAOS = J.ICLIS
      LEFT OUTER JOIN SLJCLI AS I ON G.CONTADS = I.ICLIS
      LEFT OUTER JOIN SLJCLI AS K ON K.ICLIS = EEST.VENDS
      LEFT OUTER JOIN SLJPRO AS L ON B.CPROEQS = L.CPROS
      LEFT OUTER JOIN sljeti AS M ON EESTI.codbarras = M.cbars
      LEFT OUTER JOIN SLJSCOL AS S ON S.CODIGOS = B.CODSCOLS
      LEFT OUTER JOIN
      (SELECT it.cpros,
         min(op.datas) AS data_pmov
      FROM sljeesti AS it WITH (NOLOCK)
         INNER JOIN sljeest AS op WITH (NOLOCK) ON it.empdopnums = op.empdopnums
      WHERE it.opers = 'E'
      GROUP BY it.cpros) AS pmov ON pmov.cpros = b.cpros
      LEFT OUTER JOIN
      (SELECT it.cpros,
         max(op.datas) AS data_pmov
      FROM sljeesti AS it WITH (NOLOCK)
         INNER JOIN sljeest AS op WITH (NOLOCK) ON it.empdopnums = op.empdopnums
      WHERE it.opers = 'E'
      GROUP BY it.cpros) AS umov ON umov.cpros = b.cpros
      LEFT OUTER JOIN sljest AS est ON EESTi.cpros = est.cpros
         AND EEST.emps = est.emps
         AND EST.grupos = '110401'
         AND EST.ESTOS = '11040101'
      LEFT OUTER JOIN
      (SELECT MED.emps,
         MED.mes,
         med.ano,
         med.vendedor,
         COUNT(MED.empdatavendcli) AS TICKETS,
         SUM(MED.PECAS) AS QTD_PCAS,
         SUM(MED.TOTAL) AS VAL_TOTAL,
         CONVERT (NUMERIC (14, 2),
                   CONVERT (FLOAT, SUM(MED.TOTAL)) / CONVERT (FLOAT, COUNT(MED.empdatavendcli))) AS TicketM,
         CONVERT (NUMERIC (14, 2),
                           CONVERT (FLOAT, SUM(MED.PECAS)) / CONVERT (FLOAT, COUNT(MED.empdatavendcli))) AS Pa
      FROM
         (SELECT gp.emps,
            day(gp.datas) AS dia,
            month(gp.datas) AS mes,
            YEAR(gp.datas) AS ano,
            gp.vends AS vendedor,
            sum(gp.qtds) AS Pecas,
            SUM(totas) AS total,
            gp.iclis,
            gp.emps + rtrim(CONVERT (CHAR, gp.datas, 103)) + gp.vends + gp.iclis AS empdatavendcli
         FROM sljgdmi AS gp
         WHERE gp.dopes NOT LIKE '%oferta%'
            AND gp.dopes NOT LIKE '%troca%'
         GROUP BY gp.EMPS,
               gp.datas,
               gp.vends,
               gp.iclis) AS MED
      WHERE 1=1
      GROUP BY MED.emps,
            MED.mes,
            med.ano,
            med.vendedor) AS MED ON med.emps = EEST.emps
         AND med.mes = month(EEST.datas)
         AND med.ano = YEAR(EEST.datas)
         AND EEST.vends = med.vendedor
   WHERE EEST.DOPES IN ('ADTO ENCOMENDA ',
                     'ENCOMENDA E-COMM')