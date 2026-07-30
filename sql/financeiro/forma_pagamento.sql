    SELECT DISTINCT CASE
                    WHEN RTRIM(a.emps) LIKE 'IGL' THEN 'IGU'
                    WHEN RTRIM(a.emps) LIKE 'FTH' THEN 'WEB'
                    WHEN RTRIM(a.emps) LIKE 'FFL' THEN 'BEL'
                    WHEN RTRIM(a.emps) LIKE 'LMA' THEN 'MAT'
                    WHEN RTRIM(a.emps) LIKE 'MPV' THEN 'MP2'
                    ELSE RTRIM(a.emps)
                END AS Empresa,
        RTRIM(a.dopes) AS Operacao,
        RTRIM(a.contads) AS "Cod. Cliente",
        RTRIM(c.rclis) AS "Nome Cliente",
        CAST(a.datas AS DATE) AS "Dt Oper",
        CAST(b.tipoops AS INT) AS "Tipo Oper",
        RTRIM(d.fpags) AS "Cond Pagto",
        RTRIM(e.formas) AS "Forma Pagto",
        RTRIM(GERADORA.OPERCRED) AS "OP GERADORA",
        RIGHT(RTRIM(GERADORA.OPERCRED), 4) AS "OP GERADORA Num",
        RTRIM(GERADORA.CERTCRED) AS "OP CERTIFICADO",
        RIGHT(RTRIM(GERADORA.CERTCRED), 4) AS "OP CERTIFICADO Num",
        (CASE
                     WHEN (b.tipoops = '5'
            OR e.trocos = '1') THEN (d.valos * (-1))
                     ELSE d.valos
                 END) AS "Valor Parcela",
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
                END AS "Valor Reais",
        CAST(d.parcs AS INT) AS "Parcela",
        -- d.tparcs AS "Total Parcelas",
        d.dcarts AS "Desc Cartao",
        a.numes AS "Num Oper.",
        CASE
                    WHEN f.tipos = 'D' THEN (f.porcdifs * -1)
                    ELSE (f.porcdifs)
                END AS "% Desc",
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
                       END) AS NUMERIC (14, 2)) AS "Valor Bruto",
        RTRIM(a.notas) AS "Docto",
        RTRIM(h.iclis) AS "Cod. Vendedor",
        RTRIM(h.rclis) AS "Consultora",

        (SELECT COUNT(*)
        FROM SLJPAR AS P
        WHERE P.EMPDOPNUMS IN
       (SELECT N.EMPDOPNUMB
        FROM SLJESTPE AS N,
            SLJDEVOL AS M
        WHERE M.EMPDOPNUMS = A.EMPDOPNUMS
            AND N.EMPDOPNUMS = M.EMPDOPNUMB)) AS PARCELAS,
        RTRIM(d.fpags) AS "Cond Pagto CR"
    -- foriginal."Cond Pagto" AS "Cond Pagto Original",
    -- foriginal."Forma Pagto" AS "Forma Pagto Original"
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
        FROM sljeest J with(nolock)
            LEFT OUTER JOIN sljdevol devol ON J.empdopnums = devol.empdopnums
            LEFT OUTER JOIN sljeest estdevol with(nolock) ON estdevol.empdopnums = devol.empdopnumb
        WHERE estdevol.dopes = 'CR' ) AS GERADORA ON GERADORA.VENDA = a.empdopnums
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
        LEFT JOIN
        (SELECT DISTINCT CASE
                            WHEN RTRIM(a.emps) LIKE 'IGL' THEN 'IGU'
                            WHEN RTRIM(a.emps) LIKE 'FTH' THEN 'WEB'
                            WHEN RTRIM(a.emps) LIKE 'FFL' THEN 'BEL'
                            WHEN RTRIM(a.emps) LIKE 'LMA' THEN 'MAT'
                            WHEN RTRIM(a.emps) LIKE 'MPV' THEN 'MP2'
                            ELSE RTRIM(a.emps)
                        END AS Empresa,
            RTRIM(a.dopes) AS Operacao,
            RTRIM(a.contads) AS "Cod. Cliente",
            RTRIM(c.rclis) AS "Nome Cliente",
            CAST(a.datas AS DATE) AS "Dt Oper",
            CAST(b.tipoops AS INT) AS "Tipo Oper",
            RTRIM(d.fpags) AS "Cond Pagto",
            RTRIM(e.formas) AS "Forma Pagto",
            RTRIM(GERADORA.OPERCRED) AS "OP GERADORA",
            RTRIM(GERADORA.CERTCRED) AS "OP CERTIFICADO",
            (CASE
                            WHEN (b.tipoops = '5'
                OR e.trocos = '1') THEN (d.valos * (-1))
                            ELSE d.valos
                        END) AS "Valor Parcela",
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
                        END AS "Valor Reais",
            d.parcs AS "Parcela",
            -- d.tparcs AS "Total Parcelas",
            d.dcarts AS "Desc Cartao",
            a.numes AS "Num Oper.",
            CASE
                            WHEN f.tipos = 'D' THEN (f.porcdifs * -1)
                            ELSE (f.porcdifs)
                        END AS "% Desc",
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
                            END) AS NUMERIC (14, 2)) AS "Valor Bruto",
            RTRIM(a.notas) AS "Docto",
            RTRIM(h.iclis) AS "Cod. Vendedor",
            RTRIM(h.rclis) AS "Consultora",
            (SELECT COUNT(*)
            FROM SLJPAR AS P
            WHERE P.EMPDOPNUMS IN
            (SELECT N.EMPDOPNUMB
            FROM SLJESTPE AS N,
                SLJDEVOL AS M
            WHERE M.EMPDOPNUMS = A.EMPDOPNUMS
                AND N.EMPDOPNUMS = M.EMPDOPNUMB)) AS PARCELAS
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
            FROM sljeest J with(nolock)
                LEFT OUTER JOIN sljdevol devol ON J.empdopnums = devol.empdopnums
                LEFT OUTER JOIN sljeest estdevol with(nolock) ON estdevol.empdopnums = devol.empdopnumb
            WHERE estdevol.dopes = 'CR' ) AS GERADORA ON GERADORA.VENDA = a.empdopnums
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
            OR A.dopes = 'ANTECIPACAO CLIENTE'
            OR A.dopes = 'RECALL PERDA')
            AND A.datas >= '2020/01/01 00:00:00'
            AND A.datas < '2030/01/01 00:00:00'
            AND RTRIM( A.dopes ) <> 'VENDA FUNCIONARIO'
            AND RTRIM( A.dopes ) <> 'VENDA LJ EXTERIOR'
            -- AND RTRIM( A.dopes ) <> 'RECBTO C/C'
            -- AND RTRIM( A.dopes ) <> 'ANTECIPACAO CLIENTE'
            AND RTRIM( A.dopes ) <> 'VENDA PERMUTA')
    -- AND RTRIM(a.numes) = '3031'
    -- AND RTRIM(a.contads) = 'CIGU011542')
    AS foriginal ON CONCAT( RTRIM(a.contads),'-',  RIGHT(RTRIM(GERADORA.OPERCRED), 4)) = CONCAT( RTRIM( foriginal."Cod. Cliente" ),'-',  RTRIM( foriginal."Num Oper."))
    WHERE (b.tipoops IN (4,
                     5,
                     12,
                     85,
                     89)
        OR A.dopes = 'ANTECIPACAO CLIENTE'
        OR A.dopes = 'RECALL PERDA')
        AND A.datas >= '2020/01/01 00:00:00'
        AND A.datas < '2030/01/01 00:00:00'
        AND RTRIM(A.dopes) <> 'VENDA FUNCIONARIO'
        AND RTRIM(A.dopes) <> 'VENDA LJ EXTERIOR'
        AND RTRIM(A.dopes) <> 'RECBTO C/C'
        AND RTRIM(A.dopes) <> 'ANTECIPACAO CLIENTE'
        AND RTRIM(A.dopes) <> 'VENDA PERMUTA'
        AND RTRIM(d.fpags) <> 'CR ANTECIPA.'

UNION ALL

    SELECT DISTINCT CASE
                    WHEN RTRIM(a.emps) LIKE 'IGL' THEN 'IGU'
                    WHEN RTRIM(a.emps) LIKE 'FTH' THEN 'WEB'
                    WHEN RTRIM(a.emps) LIKE 'FFL' THEN 'BEL'
                    WHEN RTRIM(a.emps) LIKE 'LMA' THEN 'MAT'
                    WHEN RTRIM(a.emps) LIKE 'MPV' THEN 'MP2'
                    ELSE RTRIM(a.emps)
                END AS Empresa,
        RTRIM(a.dopes) AS Operacao,
        RTRIM(a.contads) AS "Cod. Cliente",
        RTRIM(c.rclis) AS "Nome Cliente",
        CAST(a.datas AS DATE) AS "Dt Oper",
        CAST(b.tipoops AS INT) AS "Tipo Oper",
        foriginal."Cond Pagto" AS "Cond Pagto",
        foriginal."Forma Pagto" AS "Forma Pagto",
        RTRIM(GERADORA.OPERCRED) AS "OP GERADORA",
        RIGHT(RTRIM(GERADORA.OPERCRED), 4) AS "OP GERADORA Num",
        RTRIM(GERADORA.CERTCRED) AS "OP CERTIFICADO",
        RIGHT(RTRIM(GERADORA.CERTCRED), 4) AS "OP CERTIFICADO Num",
        (CASE
                     WHEN (b.tipoops = '5'
            OR e.trocos = '1') THEN (d.valos * (-1))
                     ELSE d.valos
                 END) AS "Valor Parcela",
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
                END AS "Valor Reais",
        CAST(d.parcs AS INT) AS "Parcela",
        -- d.tparcs AS "Total Parcelas",
        d.dcarts AS "Desc Cartao",
        a.numes AS "Num Oper.",
        CASE
                    WHEN f.tipos = 'D' THEN (f.porcdifs * -1)
                    ELSE (f.porcdifs)
                END AS "% Desc",
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
                       END) AS NUMERIC (14, 2)) AS "Valor Bruto",
        RTRIM(a.notas) AS "Docto",
        RTRIM(h.iclis) AS "Cod. Vendedor",
        RTRIM(h.rclis) AS "Consultora",

        (SELECT COUNT(*)
        FROM SLJPAR AS P
        WHERE P.EMPDOPNUMS IN
       (SELECT N.EMPDOPNUMB
        FROM SLJESTPE AS N,
            SLJDEVOL AS M
        WHERE M.EMPDOPNUMS = A.EMPDOPNUMS
            AND N.EMPDOPNUMS = M.EMPDOPNUMB)) AS PARCELAS,
        RTRIM(d.fpags) AS "Cond Pagto CR"


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
        FROM sljeest J with(nolock)
            LEFT OUTER JOIN sljdevol devol ON J.empdopnums = devol.empdopnums
            LEFT OUTER JOIN sljeest estdevol with(nolock) ON estdevol.empdopnums = devol.empdopnumb
        WHERE estdevol.dopes = 'CR' ) AS GERADORA ON GERADORA.VENDA = a.empdopnums
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

        LEFT JOIN
        (SELECT DISTINCT CASE
                    WHEN RTRIM(a.emps) LIKE 'IGL' THEN 'IGU'
                    WHEN RTRIM(a.emps) LIKE 'FTH' THEN 'WEB'
                    WHEN RTRIM(a.emps) LIKE 'FFL' THEN 'BEL'
                    WHEN RTRIM(a.emps) LIKE 'LMA' THEN 'MAT'
                    WHEN RTRIM(a.emps) LIKE 'MPV' THEN 'MP2'
                    ELSE RTRIM(a.emps)
                END AS Empresa,
            RTRIM(a.dopes) AS Operacao,
            RTRIM(a.contads) AS "Cod. Cliente",
            RTRIM(c.rclis) AS "Nome Cliente",
            CAST(a.datas AS DATE) AS "Dt Oper",
            CAST(b.tipoops AS INT) AS "Tipo Oper",
            RTRIM(d.fpags) AS "Cond Pagto",
            RTRIM(e.formas) AS "Forma Pagto",
            RTRIM(GERADORA.OPERCRED) AS "OP GERADORA",
            RTRIM(GERADORA.CERTCRED) AS "OP CERTIFICADO",
            (CASE
                     WHEN (b.tipoops = '5'
                OR e.trocos = '1') THEN (d.valos * (-1))
                     ELSE d.valos
                 END) AS "Valor Parcela",
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
                END AS "Valor Reais",
            d.parcs AS "Parcela",
            -- d.tparcs AS "Total Parcelas",
            d.dcarts AS "Desc Cartao",
            a.numes AS "Num Oper.",
            CASE
                    WHEN f.tipos = 'D' THEN (f.porcdifs * -1)
                    ELSE (f.porcdifs)
                END AS "% Desc",
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
                       END) AS NUMERIC (14, 2)) AS "Valor Bruto",
            RTRIM(a.notas) AS "Docto",
            RTRIM(h.iclis) AS "Cod. Vendedor",
            RTRIM(h.rclis) AS "Consultora",

            (SELECT COUNT(*)
            FROM SLJPAR AS P
            WHERE P.EMPDOPNUMS IN
       (SELECT N.EMPDOPNUMB
            FROM SLJESTPE AS N,
                SLJDEVOL AS M
            WHERE M.EMPDOPNUMS = A.EMPDOPNUMS
                AND N.EMPDOPNUMS = M.EMPDOPNUMB)) AS PARCELAS
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
            FROM sljeest J with(nolock)
                LEFT OUTER JOIN sljdevol devol ON J.empdopnums = devol.empdopnums
                LEFT OUTER JOIN sljeest estdevol with(nolock) ON estdevol.empdopnums = devol.empdopnumb
            WHERE estdevol.dopes = 'CR' ) AS GERADORA ON GERADORA.VENDA = a.empdopnums
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
            OR A.dopes = 'ANTECIPACAO CLIENTE'
            OR A.dopes = 'RECALL PERDA')
            AND A.datas >= '2020/01/01 00:00:00'
            AND A.datas < '2030/01/01 00:00:00'
            AND RTRIM( A.dopes ) <> 'VENDA FUNCIONARIO'
            AND RTRIM( A.dopes ) <> 'VENDA LJ EXTERIOR'
            -- AND RTRIM( A.dopes ) <> 'RECBTO C/C'
            -- AND RTRIM( A.dopes ) <> 'ANTECIPACAO CLIENTE'
            AND RTRIM( A.dopes ) <> 'VENDA PERMUTA')
    -- AND RTRIM(a.numes) = '3031'
    -- AND RTRIM(a.contads) = 'CIGU011542')
    AS foriginal ON CONCAT( RTRIM(a.contads),'-',  RIGHT(RTRIM(GERADORA.OPERCRED), 4)) = CONCAT( RTRIM( foriginal."Cod. Cliente" ),'-',  RTRIM( foriginal."Num Oper."))

    WHERE (b.tipoops IN (4,
                     5,
                     12,
                     85,
                     89)
        OR A.dopes = 'ANTECIPACAO CLIENTE'
        OR A.dopes = 'RECALL PERDA')
        AND A.datas >= '2020/01/01 00:00:00'
        AND A.datas < '2030/01/01 00:00:00'
        AND RTRIM(A.dopes) <> 'VENDA FUNCIONARIO'
        AND RTRIM(A.dopes) <> 'VENDA LJ EXTERIOR'
        AND RTRIM(A.dopes) <> 'RECBTO C/C'
        AND RTRIM(A.dopes) <> 'ANTECIPACAO CLIENTE'
        AND RTRIM(A.dopes) <> 'VENDA PERMUTA'
        AND RTRIM(d.fpags) = 'CR ANTECIPA.'
    -- AND RTRIM(a.contads) = 'CIGU011542'