SELECT
    CASE
        WHEN RTRIM( a.empos ) LIKE 'IGL' THEN 'IGU'
        WHEN RTRIM( a.empos ) LIKE 'FSM' THEN 'DES'
        WHEN RTRIM( a.empos ) LIKE 'BAL' THEN 'BAT'
        WHEN RTRIM( a.empos ) LIKE 'CUR' THEN 'BAT'
        WHEN RTRIM( a.empos ) LIKE 'FTH' THEN 'WEB'
        WHEN RTRIM( a.empos ) LIKE 'FFL' THEN 'BEL'
        WHEN RTRIM( a.empos ) LIKE 'LMA' THEN 'MAT'
        WHEN RTRIM( a.empos ) LIKE 'MPV' THEN 'MP2'
        ELSE RTRIM( a.empos )
    END AS "Loja",
    CAST( a.dtincs AS DATE ) AS "Data Inclusão",
    DATEDIFF(DAY, a.dtincs, GETDATE()) AS "Dias Inclusão",
    CAST( a.dtmovs AS DATE ) AS "Data Movimentação",
    RTRIM ( d.descrs) as 'Desc. Gr. Est.',
    RTRIM ( c.rclis ) as 'Desc. Cta Est',
    RTRIM( b.nivelqs ) AS "Metal",
    RTRIM( b.colecoes ) AS "Cod. Modelo",
    RTRIM ( a.cpros ) as 'Cod. Prod',
    RTRIM( b.dpros ) AS "Desc. Produto",
    CAST( b.pesoms AS DECIMAL(10,2))AS "Peso",
    CAST( b.pcuss AS DECIMAL(10,2)) AS "Pr. Custo",
    CAST( b.pvens AS DECIMAL(10)) AS "Pr Venda unit",
    CAST( a.qtds as INT) as Qtde,
    RTRIM ( a.cbars ) AS 'Cod. Barra'
FROM sljeti a WITH(NOLOCK)
    LEFT JOIN sljcli c with(nolock) ON a.contas = c.iclis
    LEFT JOIN sljpro b WITH(NOLOCK) ON a.cpros = b.cpros
    LEFT JOIN sljgccr d with(nolock) ON a.grupos = d.codigos
WHERE RTRIM( a.contas ) <> ''
    AND RTRIM( b.mercs ) = 'PA'
    AND RTRIM( a.emps ) <> 'NY'
    AND RTRIM( b.nivelqs ) = 'OURO'
ORDER BY a.dtincs ASC