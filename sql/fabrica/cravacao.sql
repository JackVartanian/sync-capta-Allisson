SELECT
    RTRIM(b.nops) as OP,
    RTRIM(b.cats ) as Categoria,
    RTRIM(b.cdescs)	as Desc_Categoria,
    RTRIM(fa.codpds) as Cod_Prod_Ref,
    CAST(fa.qtds AS INT) as Qtde_Ref,
    CAST(b.qtds AS INT) as Qtde_Pedras,
    CAST(a.datas AS DATE) as Data,
    CAST(a.totpesos AS INT) as Peso,
    RTRIM(a.numps) 	as Numps,
    RTRIM(a.dopps )	as Operacao,
    RTRIM(a.grupoos) as Grupo_Origem,
    RTRIM(a.contaos ) as Conta_Origem,
    RTRIM(o.rclis) as Nome_Origem,
    RTRIM(a.grupods ) as Grupo_Destino,
    RTRIM(a.contads ) as Conta_Destino,
    RTRIM(o.rclis )	as Nome_Destino
FROM SLJNENSI b with (nolock)
    LEFT JOIN SLJNENS a with (nolock) ON a.empdnps = b.empdnps
    LEFT JOIN sljopi op with (nolock) ON op.numes = b.nops
    LEFT JOIN SLJMFAS f with (nolock) ON CONCAT(b.emps, b.dopps, b.nops, b.numps) = CONCAT(f.emps, f.dopps, f.nops, f.numps)
    LEFT JOIN SLJMFAS fa with (nolock) ON CONCAT(b.emps, b.dopps, b.nops, b.numps) = CONCAT(fa.emps, fa.dopps, fa.nenvs, fa.numps)
    LEFT JOIN SLJCLI o with (nolock) ON a.contaos = o.iclis
WHERE b.cats IN ('C01','C02')
    AND a.datas >= '01/01/2018 00:00:00'
ORDER BY a.datas DESC
