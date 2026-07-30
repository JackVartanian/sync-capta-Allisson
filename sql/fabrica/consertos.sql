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
    DATEADD(DAY, 7, CAST(b.datas AS DATE)) AS 'Janela_Conversao',
    RTRIM( c.cpros ) AS 'Produto',
    RTRIM( c.codbarras ) AS 'Cod_Barras',
    RTRIM( p.nivelqs ) AS 'Metal',
    RTRIM( b.vends ) AS 'Cod.Consultora',
    RTRIM( K.RCLIS ) AS 'Consultora',
    RTRIM( b.contaos ) AS 'Conta origem',
    RTRIM( d.rclis ) AS 'Cliente',
    RTRIM( d.cpfs ) AS 'CPF',
    DATEADD(DAY, 15, CAST(b.datas AS DATE)) AS 'Prazo de entrega',
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
 WHERE a.dopes IN ('CONSERTO JOIA','CONSERTO ESTOQUE')
    AND b.datas >= '2023/01/01' 
    ORDER BY b.datas DESC