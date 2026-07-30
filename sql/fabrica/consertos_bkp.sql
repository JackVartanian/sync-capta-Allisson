SELECT
    CASE
        WHEN RTRIM( a.emps ) LIKE 'IGL' THEN 'IGU'
        WHEN RTRIM( a.emps ) LIKE 'FSM' THEN 'DES'
        WHEN RTRIM( a.emps ) LIKE 'BAL' THEN 'BAT'
        WHEN RTRIM( a.emps ) LIKE 'CUR' THEN 'BAT'
        WHEN RTRIM( a.emps ) LIKE 'FTH' THEN 'WEB'
        WHEN RTRIM( a.emps ) LIKE 'FFL' THEN 'BEL'
        WHEN RTRIM( a.emps ) LIKE 'LMA' THEN 'MAT'
        WHEN RTRIM( a.emps ) LIKE 'MPV' THEN 'MP2'
        ELSE RTRIM( a.emps )
      END AS "Loja",
    RTRIM( a.dopes ) AS 'Operacao',
    RTRIM( a.cpros ) AS 'Servico',
    RTRIM( a.dpros ) AS 'DescServico',
    RTRIM( a.numes )AS 'Ordem de servico',
    CAST(b.datas AS DATE) AS 'Abertura_OS',
    CAST(g.dataes as DATE) AS 'Aceite_Fab',
    [Fechamento_OS] AS 'Fechamento_OS',
    RTRIM( c.cpros ) AS 'Produto',
    RTRIM( c.codbarras ) AS 'Cod_Barras',
    RTRIM( p.nivelqs ) AS 'Metal',
    RTRIM( b.vends ) AS 'Cod.Consultora',
    RTRIM( K.RCLIS ) AS 'Consultora',
    RTRIM( b.contaos ) AS 'Conta origem',
    RTRIM( d.rclis ) AS 'Cliente',
    RTRIM( d.cpfs ) AS 'CPF',
    [Retorno_loja] AS 'Retorno_loja',
    CASE
        WHEN RTRIM( f.emps ) LIKE 'IGL' THEN 'IGU'
        WHEN RTRIM( f.emps ) LIKE 'FSM' THEN 'DES'
        WHEN RTRIM( f.emps ) LIKE 'BAL' THEN 'BAT'
        WHEN RTRIM( f.emps ) LIKE 'CUR' THEN 'BAT'
        WHEN RTRIM( f.emps ) LIKE 'FTH' THEN 'WEB'
        WHEN RTRIM( f.emps ) LIKE 'FFL' THEN 'BEL'
        WHEN RTRIM( f.emps ) LIKE 'LMA' THEN 'MAT'
        WHEN RTRIM( f.emps ) LIKE 'MPV' THEN 'MP2'
        ELSE RTRIM( f.emps )
      END AS "Loja retorno",
    RTRIM( f.dopes ) AS 'Operacao retorno',
    RTRIM( f.numes ) AS 'OS retorno',
    -- CAST( a.dtalts AS DATE ) AS 'Data Movimentacao',
    RTRIM( g.nops ) AS 'OP',


    DATEADD(DAY, 15, CAST(b.datas AS DATE)) AS 'Prazo de entrega',

    CASE
        WHEN [Retorno_loja] IS NULL OR [Fechamento_OS] IS NULL THEN 'OS aberta'
        WHEN [Retorno_loja] > DATEADD(DAY, 15, CAST(b.datas AS DATE)) THEN 'atraso Fab'
        WHEN [Fechamento_OS] > DATEADD(DAY, 15, CAST(b.datas AS DATE)) THEN 'atraso loja'
        ELSE 'Sem atraso' 
      END AS 'Status OS',
    DATEDIFF(DAY, CAST(b.datas AS DATE), [Aceite_Fab]) AS 'Tempo de aceite',

    CASE RTRIM(b.chksubn)
           WHEN 1 THEN 'BAIXADO'
           ELSE 'PENDENTE'
       END Situacao
FROM sljesti3 a with(nolock)
    LEFT JOIN sljeest b with(nolock) ON a.empdopnums = b.empdopnums
    LEFT JOIN sljcli d with(nolock) ON b.contaos = d.iclis
    LEFT JOIN sljopi g with(nolock) ON b.empdopnums = g.empdopnums
    LEFT JOIN SLJCLI AS K with (nolock) ON b.vends = K.ICLIS
    LEFT JOIN sljeesti c with(nolock) ON a.empdopnums = c.empdopnums AND a.citens = c.citens
    LEFT JOIN SLJPRO p with(nolock) ON c.cpros = p.cpros
    LEFT JOIN sljestpe e with(nolock) ON a.empdopnums = e.empdopnumb
        AND e.dopes IN ('RETORNO LOJA CX',
                'RETORNO ESTOQUE',
                'RETORNO LOJA')
    LEFT JOIN sljeest f with(nolock) ON e.empdopnums = f.empdopnums

    LEFT JOIN (
SELECT
        CAST(datas AS DATE) AS 'Fechamento_OS',
        RTRIM(dopes) AS 'dopes',
        RTRIM(numes) AS 'os',
        empdopnums
    FROM sljeest
    WHERE dopes IN ('ENTREGA OS CLIENTE')
        AND datas >= '2020/01/01'
) fc on a.numes = fc.os

    LEFT JOIN (
    SELECT
        CAST(datas AS DATE) AS 'Retorno_loja',
        RTRIM(numes) AS 'os',
        empdopnums
    FROM sljeest
    WHERE dopes IN ('RETORNO LOJA CX',
                'RETORNO ESTOQUE',
                'RETORNO LOJA')
        AND datas >= '2020/01/01'
  ) rl on a.numes = rl.os

    LEFT JOIN (
    SELECT
        CAST(dataes AS DATE) 'Aceite_Fab',
        RTRIM(numes) AS 'OSACEITE',
        empdopnums
    FROM SLJOPI WITH (NOLOCK)
    WHERE dopps = 'ORDEM DE SERVIÇO'
        AND dopes IN ('CONSERTO JOIA','CONSERTO ESTOQUE')
        AND dataes >= '2020/01/01'
  ) ac on a.empdopnums = ac.empdopnums


WHERE a.dopes IN ('CONSERTO JOIA','CONSERTO ESTOQUE')
    AND b.datas >= '2020/01/01'
ORDER BY b.datas DESC