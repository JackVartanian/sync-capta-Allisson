    SELECT
        CONVERT(DATE, a.datas, 103) AS "Data",
        RTRIM( b.nivelqs ) AS "Metal",
        RTRIM( b.colecoes ) AS "Cod. Modelo",
        RTRIM( a.cpros ) AS "Cod. Prod.",
        CONCAT('https://jvphotos.com.br/cms/wp-content/uploads/fotos/',RTRIM( a.cpros ),'.JPG') AS "Foto",
        a.qtds AS "Qtd",
        a.totas AS "Total Liq."
    FROM sljgdmi AS a with (nolock)
        LEFT OUTER JOIN sljpro AS b with (nolock) ON a.cpros = b.cpros
    WHERE
    a.codbarras <> 0
        AND a.datas >= CAST(DATEADD(DAY, -365, GETDATE()) as DATE)
        AND a.emps <> 'NY'
        AND b.nivelqs LIKE 'OURO%'
        AND b.colecoes <> ''
        AND a.vvistas <> 0
        AND a.tipoops NOT IN (91, 92)
        AND A.DOPES <> 'ADTO ENCOMENDA '
        AND (a.dopes <> 'VENDA PERMUTA'
        AND a.dopes <> 'VENDA FUNCIONARIO'
        AND a.dopes <> 'VENDA ENCOMENDA'
        AND a.dopes <> 'VENDA ENC E-COMM' )

UNION ALL

    SELECT
        CONVERT(DATE, a.datas, 103) AS "Data",
        RTRIM( b.nivelqs ) AS "Metal",
        RTRIM( b.colecoes ) AS "Cod. Modelo",
        a.cpros AS "Cod. Prod.",
        CONCAT('https://jvphotos.com.br/cms/wp-content/uploads/fotos/',RTRIM( a.cpros ),'.JPG') AS "Foto",
        a.qtds AS "Qtd",
        a.totas AS "Total Liq."
    FROM sljgdmi AS a with(nolock)
        LEFT OUTER JOIN sljpro AS b with(nolock) ON a.cpros = b.cpros
    WHERE
    a.codbarras = 0
        AND a.datas >= CAST(DATEADD(DAY, -365, GETDATE()) as DATE)
        AND a.emps <> 'NY'
        AND b.nivelqs LIKE 'OURO%'
        AND b.colecoes <> ''
        AND a.vvistas <> 0
        AND a.tipoops NOT IN (91, 92)
        AND a.dopes <> 'ADTO ENCOMENDA '
        AND
        (a.dopes <> 'VENDA PERMUTA'
        AND a.dopes <> 'VENDA FUNCIONARIO'
        AND a.dopes <> 'VENDA ENCOMENDA'
        AND a.dopes <> 'VENDA ENC E-COMM')

UNION ALL

    SELECT
        CONVERT(DATE, EEST.datas, 103) AS "Data",
        RTRIM( b.nivelqs ) AS "Metal",
        RTRIM( b.colecoes ) AS "Cod. Modelo",
        EESTI.cpros AS "Cod. Prod.",
        CONCAT('https://jvphotos.com.br/cms/wp-content/uploads/fotos/',RTRIM( EESTI.cpros ),'.JPG') AS "Foto",
        EESTI.qtds AS "Qtd",
        EESTI.totas + EESTI.valrats AS "Total Liq."
    FROM SLJEEST AS EEST with(nolock)
        LEFT OUTER JOIN SLJEESTI AS EESTI with(nolock) ON EEST.EMPDOPNUMS = EESTI.EMPDOPNUMS
        LEFT OUTER JOIN sljpro AS b with(nolock) ON EESTI.cpros = b.cpros
    WHERE 
    EEST.DOPES IN ('ADTO ENCOMENDA ', 'ENCOMENDA E-COMM')
        AND EEST.emps <> 'NY'
        AND EEST.datas >= CAST(DATEADD(DAY, -365, GETDATE()) as DATE)
        AND b.colecoes <> ''
        AND b.nivelqs LIKE 'OURO%'
        AND EESTI.unitorigs <> 0
        AND ( EEST.dopes <> 'VENDA PERMUTA'
        AND EEST.dopes <> 'VENDA FUNCIONARIO'
        AND EEST.dopes <> 'VENDA ENCOMENDA'
        AND EEST.dopes <> 'VENDA ENC E-COMM')
ORDER BY "Data" DESC