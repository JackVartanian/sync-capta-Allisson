SELECT DISTINCT
    RTRIM(a.emps) AS emps,
    RTRIM( z.ggrus ) AS ggrus,
    RTRIM(a.dopes) AS dopes,
    RTRIM(a.contads) AS contads,
    RTRIM(c.cpfs) AS cpfs,
    RTRIM(c.rclis) AS rclis,
    a.datas,
    b.tipoops,
    RTRIM(d.fpags) AS fpags,
    RTRIM(e.formas) AS formas,
    d.moefpgs,
    d.cotfpgs AS cotacao,
    GERADORA.opercred AS GERADORAS,
    GERADORA.certcred AS CERTIFCRED,
    (CASE
                     WHEN (b.tipoops = '5'
        OR e.trocos = '1') THEN (d.valos * (-1))
                     ELSE d.valos
                 END) AS VALOS,
    CASE
                    WHEN D.moefpgs <> 'R' THEN (CASE
                                                    WHEN (b.tipoops = '5'
        OR e.trocos = '1') THEN (d.valos * (-1)) * d.cotfpgs
                                                    ELSE d.valos * d.cotfpgs
                                                END)
                    ELSE (CASE
                              WHEN (b.tipoops = '5'
        OR e.trocos = '1') THEN (d.valos * (-1))
                              ELSE d.valos
                          END)
                END AS VALOSREAL,
    d.valocurs AS txcartao,
    A.numolds AS PRAZO_MEDIO,
    d.vencs,
    d.parcs,
    d.tparcs AS totalparc,
    RTRIM(d.dcarts) AS desccartao,
    d.agencias,
    d.bancos,
    d.contas,
    d.numeros,
    d.nocreditos AS doccartao,
    RTRIM(a.numes) AS numes,
    CASE
        WHEN f.tipos = 'D' THEN (f.porcdifs * -1)
    ELSE (f.porcdifs)
    END AS percdesc,
    CAST ((CASE
        WHEN f.tipos = 'D' THEN (CASE
                                                        WHEN d.valos = 0
        OR (100 - f.porcdifs) = 0 THEN 0
                                                        ELSE (((CASE
                                                                    WHEN (b.tipoops = '5'
        OR e.trocos = '1') THEN (d.valos * (-1))
                                                                    ELSE d.valos
                                                                END) / (100 - f.porcdifs))) * 100
                                                    END)
                           ELSE (CASE
                                     WHEN f.tipos = 'A' THEN ((CASE
                                                                   WHEN (b.tipoops = '5'
        OR e.trocos = '1') THEN (d.valos * (-1))
                                                                   ELSE d.valos
                                                               END) * (1 + (f.porcdifs / 100)))
                                     ELSE (CASE
                                               WHEN (b.tipoops = '5'
        OR e.trocos = '1') THEN (d.valos * (-1))
                                               ELSE d.valos
                                           END)
                                 END)
                       END) AS NUMERIC (14, 2)) AS valbruto,
    a.notas,
    G.umovs,
    h.rclis AS Vend,
    h.iclis AS codven,
    AGRP.ctpag,
    RTRIM(e.contaadms) AS contaadms,
    (SELECT Count(*)
    FROM sljpar AS P
    WHERE P.empdopnums IN
       (SELECT N.empdopnumb
    FROM sljestpe AS N,
        sljdevol AS M
    WHERE M.empdopnums = A.empdopnums
        AND N.empdopnums = M.empdopnumb)) AS PARCELAS,
    RTRIM(d.nsusitefs) AS nsusitefs,
    RTRIM(d.cnnsuparcs) AS cnnsuparcs,
    RTRIM(d.autorizs) AS autorizs,
    RTRIM(ADM.rclis) AS NOME_ADM,

    CASE
        WHEN E.obs = 1 THEN CONVERT (VARCHAR (100), D.obs)
        ELSE ''
    END AS obs
FROM sljeest AS a WITH (nolock)
    LEFT JOIN sljope AS b WITH (nolock) ON a.dopes = b.dopes
    LEFT JOIN sljcli AS c WITH (nolock) ON a.contads = c.iclis
    LEFT JOIN sljpar AS d WITH (nolock) ON a.empdopnums = d.empdopnums
    LEFT JOIN sljfpag AS e WITH (nolock) ON d.fpags = e.fpags
    LEFT JOIN sljestmo AS f WITH (nolock) ON a.empdopnums = f.empdopnums
    LEFT JOIN sljche AS g WITH (nolock) ON d.bancos + d.agencias + d.contas + d.numeros = g.bancos + g.agencias + g.ncontas + g.ncheques
    LEFT JOIN sljcli AS h WITH (nolock) ON a.vends = h.iclis
    LEFT JOIN sljgdmi AS z with (nolock) ON a.empdopnums = z.empdopnums
    LEFT JOIN
    (
        SELECT DISTINCT J.empdopnums AS VENDA,
        estdevol.empdncrds AS OPERCRED,
        devol.empdopnumb AS CERTCRED
    FROM sljeest AS J WITH (nolock)
        LEFT OUTER JOIN sljdevol AS devol ON J.empdopnums = devol.empdopnums
        LEFT OUTER JOIN sljeest AS estdevol WITH (nolock) ON estdevol.empdopnums = devol.empdopnumb
    WHERE estdevol.dopes = 'CR') AS GERADORA ON GERADORA.venda = a.empdopnums
    LEFT OUTER JOIN
    (SELECT Y.empdopnums AS EMPDOP,
        X.formas AS FRM,
        Count(Y.fpags) AS CTPAG
    FROM sljpar AS Y WITH (nolock)
        INNER JOIN sljfpag AS X ON X.fpags = Y.fpags
    WHERE 1 = 1
    GROUP BY Y.empdopnums, X.formas) AS AGRP ON AGRP.empdop = A.empdopnums
        AND AGRP.frm = E.formas
    LEFT OUTER JOIN sljcli AS ADM WITH (nolock) ON E.contaadms = ADM.iclis
WHERE a.datas >= '2023-01-01 00:00:00.000'
    -- AND RTRIM(a.emps) = 'FTH'
    AND RTRIM(e.formas) IN ('CARTAO')
    -- AND a.numes IN ('3760')
    -- AND c.cpfs IN ('082.751.508-17')
    AND (b.tipoops IN (4, 5, 12, 85, 89)
    OR A.dopes IN ('ANTECIPACAO CLIENTE', 'ADTO ENCOMENDA'))
ORDER  BY a.datas DESC