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
    FORMAT ( a.dtincs, 'dd/MM/yyyy') AS "Inclusao",
    DATEDIFF(DAY, a.dtincs, GETDATE()) AS "Dias_Inclusao",
    FORMAT ( a.dtmovs, 'dd/MM/yyyy') AS "Movimentacao",
    RTRIM ( d.descrs) as 'Desc. Gr. Est.',
    RTRIM ( a.contas ) as contas,
    RTRIM ( c.rclis ) as 'Desc. Cta Est',
    RTRIM ( a.cpros ) as 'Cod. Prod',
    CAST( a.qtds as INT) as Qtde,
    RTRIM ( a.cbars ) AS 'Cod. Barra',
    RTRIM ( a.codtams ) AS 'Cod. Tam'
FROM sljeti a WITH(NOLOCK)
    LEFT JOIN sljcli c with(nolock) ON a.contas = c.iclis
    LEFT JOIN sljpro b WITH(NOLOCK) ON a.cpros = b.cpros
    LEFT JOIN sljgccr d with(nolock) ON a.grupos = d.codigos
WHERE a.contas <> '' AND b.mercs = 'PA' and RTRIM( a.empos ) <> 'NY'
    -- AND CONCAT( RTRIM( a.empos ), ' - ' , RTRIM( d.descrs )) NOT IN
    --                     ('LMA - CONSERTOS',
    --                     'LMA - ESTOQUE CONSIGNADO',
    --                     'MAT - CONSERTOS',
    --                     'LMA - ESTOQUE ESPECIAL',
    --                     'LMA - ESTOQUE LMA.PRIMA',
    --                     'MAT - ESTOQUE MAT.PRIMA',
    --                     'LMA - ESTOQUE TRANSIT PROD',
    --                     'MAT - ESTOQUE TRANSIT PROD',
    --                     'MPV - ESTOQUE PRODUTOS',
    --                     'NY - ESTOQUE CONSIG EXT',
    --                     'NY - ESTOQUE CONSIGNADO',
    --                     'NY - ESTOQUE PRODUTOS',
    --                     'NY - ESTOQUE TRANSITO')
    -- AND RTRIM( c.rclis ) NOT IN ('CASSIA AVILA',
    --             'ESTOQUE COFRE (JV)',
    --             'ESTOQUE DE DEVOLUÇÃO',
    --             'ESTOQUE ENCOMENDA',
    --             'ESTOQUE FABRICA / DESENVOLVIMENTO',
    --             'ESTOQUE LMA NY',
    --             'ESTOQUE MARKETING',
    --             'ESTOQUE MODELOS',
    --             'ESTOQUE PRODUCAO',
    --             'ESTOQUE TRANSITO AUDITORIA',
    --             'JACK VARTANIAN',
    --             'JACK VARTANIAN - IGUATEMI')