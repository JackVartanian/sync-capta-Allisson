SELECT
    CAST(o.numes AS INT) as Num_Ped,
    CAST(o.nops AS INT) as OP,
    o.dataes as Abertura_op,
    CAST(o.dataps AS DATE) as 'Abertura_Pedido',
    CAST(o.dataes AS DATE) as 'Processamento_op',
    DATEDIFF(DAY, CAST(o.dataes AS DATE), CAST(GETDATE() AS DATE)) AS 'Dias em aberto',
    e.prazoents as Prev_Entrega
FROM sljopi o with(nolock)
    inner join sljeest e with(nolock) on e.empdopnums = o.empdopnums
WHERE o.dataes >= '2020/01/01 00:00:00'