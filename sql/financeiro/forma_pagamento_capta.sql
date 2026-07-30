SELECT DISTINCT a.emps,
    a.dopes,
    a.contads,
    c.rclis,
    a.datas,
    b.tipoops,
    d.fpags,
    e.formas,
    d.moefpgs,
    d.cotfpgs AS cotacao,
    GERADORA.OPERCRED AS GERADORAS,
    GERADORA.CERTCRED AS CERTIFCRED,
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
    A.NUMOLDS AS PRAZO_MEDIO,
    d.vencs,
    d.parcs,
    d.tparcs AS totalparc,
    d.dcarts AS desccartao,
    d.agencias,
    d.bancos,
    d.contas,
    d.numeros,
    d.nocreditos AS doccartao,
    a.numes,
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
    AGRP.CTPAG,
    c.cpfs,
    e.contaadms,

    (SELECT COUNT(*)
    FROM SLJPAR AS P
    WHERE P.EMPDOPNUMS IN
       (SELECT N.EMPDOPNUMB
    FROM SLJESTPE AS N,
        SLJDEVOL AS M
    WHERE M.EMPDOPNUMS = A.EMPDOPNUMS
        AND N.EMPDOPNUMS = M.EMPDOPNUMB)) AS PARCELAS,
    d.nsusitefs,
    d.cnnsuparcs,
    d.autorizs,
    ADM.RCLIS AS NOME_ADM,
    CASE
                         WHEN E.OBS = 1 THEN CONVERT (VARCHAR (100),
                                                      D.OBS)
                         ELSE ''
                     END AS obs
FROM sljeest AS a WITH (NOLOCK)
    LEFT OUTER JOIN sljope AS b WITH (NOLOCK) ON a.dopes = b.dopes
    LEFT OUTER JOIN sljcli AS c WITH (NOLOCK) ON a.contads = c.iclis
    LEFT OUTER JOIN sljpar AS d WITH (NOLOCK) ON a.empdopnums = d.empdopnums
    LEFT OUTER JOIN sljfpag AS e WITH (NOLOCK) ON d.fpags = e.fpags
    LEFT OUTER JOIN sljestmo AS f WITH (NOLOCK) ON a.empdopnums = f.empdopnums
    LEFT OUTER JOIN sljche AS g WITH (NOLOCK) ON d.bancos + d.agencias + d.contas + d.numeros = g.bancos + g.agencias + g.ncontas + g.ncheques
    LEFT OUTER JOIN sljcli AS h WITH (NOLOCK) ON a.vends = h.iclis
    LEFT OUTER JOIN
    (SELECT DISTINCT J.empdopnums AS VENDA,
        estdevol.empdncrds AS OPERCRED,
        devol.empdopnumb AS CERTCRED
    FROM sljeest AS J WITH (NOLOCK)
        LEFT OUTER JOIN sljdevol AS devol ON J.empdopnums = devol.empdopnums
        LEFT OUTER JOIN sljeest AS estdevol WITH (NOLOCK) ON estdevol.empdopnums = devol.empdopnumb
    WHERE estdevol.dopes = 'CR') AS GERADORA ON GERADORA.VENDA = a.empdopnums
    LEFT OUTER JOIN
    (SELECT Y.EMPDOPNUMS AS EMPDOP,
        X.FORMAS AS FRM,
        COUNT(Y.FPAGS) AS CTPAG
    FROM SLJPAR AS Y WITH (NOLOCK)
        INNER JOIN SLJFPAG AS X ON X.FPAGS = Y.FPAGS
    WHERE 1=1
    GROUP BY Y.EMPDOPNUMS,
            X.FORMAS) AS AGRP ON AGRP.EMPDOP = A.EMPDOPNUMS
        AND AGRP.FRM = E.FORMAS
    LEFT OUTER JOIN SLJCLI AS ADM WITH (NOLOCK) ON E.contaadms = ADM.ICLIS
WHERE (b.tipoops IN (4,
                     5,
                     12,
                     85,
                     89)
    OR A.dopes IN ('ANTECIPACAO CLIENTE'))
    AND A.datas >= '2023/01/01 00:00:00'
    AND A.datas < '2030/01/01 00:00:00'
    AND RTRIM(A.dopes) <> 'VENDA FUNCIONARIO'
    AND RTRIM(A.dopes) <> 'VENDA LJ EXTERIOR'
    AND RTRIM(A.dopes) <> 'RECBTO C/C'
    AND RTRIM(A.dopes) <> 'ANTECIPACAO CLIENTE'
    AND RTRIM(A.dopes) <> 'VENDA PERMUTA'