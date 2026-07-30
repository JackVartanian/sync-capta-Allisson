IF OBJECT_ID ('tempdb.dbo.#ult_vend', 'U') IS NOT NULL
DROP TABLE #ult_vend;

SELECT cli.iclis,
  (SELECT top 1 CASE
                    WHEN vd.vends = ' ' THEN vd.dopes
                    ELSE vd.vends
                END
   FROM sljgdmi vd
   WHERE cli.iclis = vd.iclis
     AND vd.tipoops in ('4',
                        '89')
   ORDER BY vd.datas DESC) Vends INTO #ult_vend
FROM sljcli cli
WHERE cli.grupos in ('CLIENTES',
                   'PROSPECT',
                   'ACOMP LOJA',
                   'P SOCIAL',
                   'PRODUTORES',
                   'IMPRENSA');

SELECT 1 AS contador,
    RTRIM( a.iclis) AS "Cod_Cliente",
    RTRIM( a.rclis) AS "Nome",
    RTRIM( a.sexos) AS "Sexo",
    RTRIM( a.estcivils) AS "Estado Civil",
    RTRIM( a.cpfs) AS "CPF",
    a.nascs AS "Data Nascimento",
    a.dtcasas AS "Data Casamento",
    RTRIM( a.contavens) AS "Cod_Vend.",
    RTRIM( a.ddds) AS "DDD",
    RTRIM( a.faxs) AS "Cel",
    RTRIM( a.tel1s) AS "Tel1",
    RTRIM( a.tel2s) AS "Tel2",
    RTRIM( a.tel3s) AS "Tel3",
    CASE
        WHEN RTRIM(a.faxs) = ''
        AND RTRIM(a.tel1s) = ''
        AND RTRIM(a.tel2s) = '' THEN RTRIM(a.tel3s)

        WHEN RTRIM(a.faxs) = ''
        AND RTRIM(a.tel1s) = '' THEN RTRIM(a.tel2s)

        WHEN RTRIM(a.faxs) = ''
        AND RTRIM(a.tel1s) <> '' THEN RTRIM(a.tel1s)
        ELSE RTRIM(a.faxs)
    END AS "Telefone",
    RTRIM( a.emails) AS "Email",
    RTRIM( a.grupos) AS "Grupo",
    RTRIM( a.conjuges) AS "Conjuge",
    RTRIM( a.cpfcs) AS "CPF Conjuge",
    RTRIM( a.ceps) AS "CEP",
    RTRIM( a.endes) AS "Endereco",
    RTRIM( a.nums) AS "Numero",
    RTRIM( a.compls) AS "Complemento" ,
    RTRIM( a.bairs) AS "Bairro",
    RTRIM( a.cidas) AS "Cidade",
    RTRIM( a.estas) AS "Estado",
    RTRIM( a.paises) AS "Pais",
    RTRIM( a.situas) AS "Situacao",
    RTRIM( a.fpubls) AS "VIP",
    a.ultcomps AS "Ultima Compra",
    a.dataincs AS "Data Inclusao",
    a.dtalts AS "Data Alteracao",
     RTRIM( uvd.vends) AS "Cod_Ult_Vend",
    CASE
           WHEN RTRIM( vd.rclis ) IS NULL THEN RTRIM( uvd.vends )
           ELSE RTRIM( vd.rclis )
       END Desc_Ult_Vend,
    a.ctelems,
    RTRIM( a.inativas) AS "Inativo"
FROM sljcli a WITH(NOLOCK)
    LEFT OUTER JOIN sljscli b WITH(NOLOCK) ON a.situas=b.codigos
    LEFT OUTER JOIN sljfpubl c WITH(NOLOCK) ON a.fpubls=c.cods
    LEFT OUTER JOIN sljcli d WITH(NOLOCK) ON a.contavens=d.iclis
    LEFT JOIN #ult_vend uvd ON a.iclis = uvd.iclis
    LEFT JOIN sljcli vd ON uvd.Vends = vd.iclis
WHERE a.grupos IN ('CLIENTES',
                   'PROSPECT',
                   'ACOMP LOJA',
                   'P SOCIAL',
                   'PRODUTORES',
                   'IMPRENSA')
    AND a.dataincs >= '2022-01-01'
ORDER BY "Data Inclusao" DESC