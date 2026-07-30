WITH
    VendasBase
    AS
    (
        -- Unifica as vendas normais e encomendas
                    SELECT
                CASE WHEN b.encoms = 1 THEN 'Sim' ELSE 'Nao' END AS Encomendavel,
                CONVERT(DATE, a.datas, 103) AS Data,
                RTRIM(a.cpros) AS Cod_Prod,
                a.qtds AS Qtd,
                a.totas AS Total_Liq
            FROM sljgdmi a WITH (nolock)
                LEFT JOIN sljpro b WITH (nolock) ON a.cpros = b.cpros
            WHERE a.emps <> 'NY'
                AND a.vvistas <> 0
                AND b.mercs = 'PA'
                AND a.tipoops NOT IN (91, 92)
                AND a.dopes NOT IN ('ADTO ENCOMENDA', 'VENDA PERMUTA', 'VENDA FUNCIONARIO', 
                           'VENDA ENCOMENDA', 'VENDA ENC E-COMM')

        UNION ALL

            SELECT
                CASE WHEN b.encoms = 1 THEN 'Sim' ELSE 'Nao' END AS Encomendavel,
                CONVERT(DATE, EEST.datas, 103) AS Data,
                RTRIM(EESTI.cpros) AS Cod_Prod,
                EESTI.qtds AS Qtd,
                EESTI.totas + eesti.valrats AS Total_Liq
            FROM SLJEEST EEST WITH (nolock)
                LEFT JOIN SLJEESTI EESTI WITH (nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
                LEFT JOIN sljpro b WITH (nolock) ON EESTI.cpros = b.cpros
            WHERE EEST.DOPES IN ('ADTO ENCOMENDA', 'ENCOMENDA E-COMM')
                AND EEST.emps <> 'NY'
                AND b.mercs = 'PA'
                AND EESTI.unitorigs <> 0
    ),

    UltimasVendas
    AS
    (
        -- Calcula dias desde última venda
        SELECT DISTINCT
            Cod_Prod,
            MAX(Data) AS Data_Ultima_Venda,
            DATEDIFF(DAY, MAX(Data), GETDATE()) AS Dias_Ultima_Venda,
            Encomendavel
        FROM VendasBase
        GROUP BY Cod_Prod, Encomendavel
    ),

    Estoque
    AS
    (
        -- Calcula quantidade em estoque
        SELECT
            RTRIM(t.cpros) AS Cod_Prod,
            SUM(t.sqtds) AS Qtd_Estoque
        FROM sljest t WITH (nolock)
            LEFT JOIN sljpro r WITH (nolock) ON t.cpros = r.cpros
        WHERE t.sqtds <> 0
            AND r.mercs = 'PA'
            AND t.emps <> 'NY'
        GROUP BY t.cpros
    ),

    ResultadoFinal
    AS
    (
        SELECT
            u.Cod_Prod,
            u.Data_Ultima_Venda,
            u.Dias_Ultima_Venda,
            e.Qtd_Estoque,
            u.Encomendavel,
            CASE 
            WHEN u.Dias_Ultima_Venda < 365 THEN '01. Menor 365'
            WHEN u.Dias_Ultima_Venda BETWEEN 365 AND 720 THEN '02. Entre 365 e 720'
            ELSE '03. Acima 720'
        END AS Cluster_Dias_Sem_Vendas,
            CASE 
            WHEN u.Dias_Ultima_Venda < 180 THEN '01. Menor 180'
            WHEN u.Dias_Ultima_Venda BETWEEN 180 AND 360 THEN '02. Entre 180 e 360'
            WHEN u.Dias_Ultima_Venda BETWEEN 360 AND 540 THEN '03. Entre 360 e 540'
            WHEN u.Dias_Ultima_Venda BETWEEN 540 AND 720 THEN '04. Entre 540 e 720'
            ELSE '05. Acima 720'
        END AS Cluster_Detalhado
        FROM UltimasVendas u
            LEFT JOIN Estoque e ON u.Cod_Prod = e.Cod_Prod
    )

SELECT *
FROM ResultadoFinal
ORDER BY Cod_Prod;