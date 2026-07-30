SELECT 1 AS contador,
    RTRIM( a.iclis) AS "Cod_Cliente",
    RTRIM( a.rclis) AS "Nome",
    RTRIM( a.sexos) AS "Sexo",
    RTRIM( a.estcivils) AS "Estado Civil",
    RTRIM( a.cpfs) AS "CPF",
    CAST( a.nascs AS DATE) AS "Data Nascimento",
    DATEDIFF(YEAR, a.nascs, GETDATE()) AS "Idade",
    CAST( a.dtcasas AS DATE) AS "Data Casamento",
    DATEDIFF(YEAR, a.dtcasas, GETDATE()) AS "Idade_Casamento",
    RTRIM( a.contavens) AS "Cod_Vend.",
    RTRIM( k.rclis) AS "Consultora",
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
    CAST( a.ultcomps AS DATE) AS "Ultima Compra",
    CAST( a.dataincs AS DATE) AS "Data Inclusao",
    YEAR(GETDATE()) - YEAR(a.dataincs) AS "Anos_Marca",
    CAST( a.dtalts AS DATE) AS "Data Alteracao",
    a.ctelems,
    RTRIM( a.inativas) AS "Inativo"
FROM sljcli a WITH(NOLOCK)
    LEFT JOIN sljscli b WITH(NOLOCK) ON a.situas=b.codigos
    LEFT JOIN sljfpubl c WITH(NOLOCK) ON a.fpubls=c.cods
    LEFT JOIN sljcli d WITH(NOLOCK) ON a.contavens=d.iclis
    LEFT JOIN SLJCLI AS K with(nolock) ON K.ICLIS = A.contavens
WHERE a.grupos IN ('CLIENTES',
                   'PROSPECT',
                   'ACOMP LOJA',
                   'P SOCIAL',
                   'PRODUTORES',
                   'IMPRENSA')
AND RTRIM( a.rclis) <> ''

UNION ALL

SELECT 1 AS contador,
    RTRIM( a.iclis) AS "Cod_Cliente",
    RTRIM( a.rclis) AS "Nome",
    RTRIM( a.sexos) AS "Sexo",
    RTRIM( a.estcivils) AS "Estado Civil",
    RTRIM( a.cpfs) AS "CPF",
    CAST( a.nascs AS DATE) AS "Data Nascimento",
    DATEDIFF(YEAR, a.nascs, GETDATE()) AS "Idade",
    CAST( a.dtcasas AS DATE) AS "Data Casamento",
    DATEDIFF(YEAR, a.dtcasas, GETDATE()) AS "Idade_Casamento",
    RTRIM( a.contavens) AS "Cod_Vend.",
    RTRIM( k.rclis) AS "Consultora",
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
    CAST( a.ultcomps AS DATE) AS "Ultima Compra",
    CAST( a.dataincs AS DATE) AS "Data Inclusao",
    YEAR(GETDATE()) - YEAR(a.dataincs) AS "Anos_Marca",
    CAST( a.dtalts AS DATE) AS "Data Alteracao",
    a.ctelems,
    RTRIM( a.inativas) AS "Inativo"
FROM sljcli a WITH(NOLOCK)
    LEFT JOIN sljscli b WITH(NOLOCK) ON a.situas=b.codigos
    LEFT JOIN sljfpubl c WITH(NOLOCK) ON a.fpubls=c.cods
    LEFT JOIN sljcli d WITH(NOLOCK) ON a.contavens=d.iclis
    LEFT JOIN SLJCLI AS K with(nolock) ON K.ICLIS = A.contavens
WHERE a.grupos IN ('EXCLUIDOS')
AND a.ultcomps IS NOT NULL