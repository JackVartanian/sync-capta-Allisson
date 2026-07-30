SELECT
    RTRIM(o.cpros) AS Cod_Prod,
    SUM(CAST(o.qtds AS INT)) as Qtde,
    CAST(o.nops AS INT) as OP,
    CAST(o.numes AS INT) as Num_Pedido,
    CAST(o.dataps AS DATE) as Abertura_Pedido,
    CAST(o.dataes AS DATE) as Processamento_op,
    RTRIM(o.dopps) as Operacao,
    RTRIM(o.dopes) as Desc_Operacao,
    CAST(e.prazoents AS DATE) as Prev_Entrega
FROM sljopi o with(nolock)
    inner join sljeest e with(nolock) on e.empdopnums = o.empdopnums
WHERE o.dataes >= '2020/01/01 00:00:00'
-- AND o.numes = '375472'
-- AND RTRIM(o.cpros) = 'PI01604'
GROUP BY o.cpros, o.nops, o.numes, o.dataps, o.dataes, o.dopps, o.dopes, e.prazoents