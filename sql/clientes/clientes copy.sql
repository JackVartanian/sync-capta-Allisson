SELECT
    1 AS contador,
    RTRIM(a.iclis) AS "Cod_Cliente",
    RTRIM(a.rclis) AS "Nome",
    RTRIM(a.sexos) AS "Sexo",
    RTRIM(a.estcivils) AS "Estado Civil",
    RTRIM(a.cpfs) AS "CPF",
    CAST(a.nascs AS DATE) AS "Data Nascimento",
    DATEDIFF(YEAR, a.nascs, GETDATE()) AS "Idade",
    CAST(a.dtcasas AS DATE) AS "Data Casamento",
    DATEDIFF(YEAR, a.dtcasas, GETDATE()) AS "Idade_Casamento",
    RTRIM(a.contavens) AS "Cod_Vend.",
    RTRIM(k.rclis) AS "Consultora",
    RTRIM(a.ddds) AS "DDD",
    RTRIM(a.faxs) AS "Cel",
    RTRIM(a.tel1s) AS "Tel1",
    RTRIM(a.tel2s) AS "Tel2",
    RTRIM(a.tel3s) AS "Tel3",
    CASE
        WHEN RTRIM(a.faxs) <> '' AND RTRIM(a.faxs) <> '0' THEN RTRIM(a.faxs)
        WHEN (RTRIM(a.faxs) = '' OR RTRIM(a.faxs) = '0') AND (RTRIM(a.tel2s) <> '' AND RTRIM(a.tel2s) <> '0') THEN RTRIM(a.tel2s)
        WHEN (RTRIM(a.faxs) = '' OR RTRIM(a.faxs) = '0') AND (RTRIM(a.tel1s) <> '' AND RTRIM(a.tel1s) <> '0') THEN RTRIM(a.tel1s)
        WHEN (RTRIM(a.faxs) = '' OR RTRIM(a.faxs) = '0') AND (RTRIM(a.tel3s) <> '' AND RTRIM(a.tel3s) <> '0') THEN RTRIM(a.tel3s)
        ELSE ''
    END AS "Telefone",
    RTRIM(a.emails) AS "Email",
    RTRIM(a.grupos) AS "Grupo",
    RTRIM(a.conjuges) AS "Conjuge",
    RTRIM(a.cpfcs) AS "CPF Conjuge",
    RTRIM(a.ceps) AS "CEP",
    RTRIM(a.endes) AS "Endereco",
    RTRIM(a.nums) AS "Numero",
    RTRIM(a.compls) AS "Complemento",
    RTRIM(a.bairs) AS "Bairro",
    RTRIM(a.cidas) AS "Cidade",
    RTRIM(a.estas) AS "Estado",
    RTRIM(a.paises) AS "Pais",
    RTRIM(a.situas) AS "Situacao",
    RTRIM(a.fpubls) AS "VIP",
    CAST(a.ultcomps AS DATE) AS "Ultima Compra",
    CAST(a.dataincs AS DATE) AS "Data Inclusao",
    CASE
        WHEN RTRIM(a.situas) IN ('PSP', 'DES') AND a.ultcomps IS NOT NULL THEN YEAR(GETDATE()) - YEAR(a.dataincs)
        ELSE YEAR(GETDATE()) - YEAR(a.ultcomps)
    END AS "Anos_Marca",
    CAST(a.dtalts AS DATE) AS "Data Alteracao",
    a.ctelems,
    RTRIM(a.inativas) AS "Inativo",
    DAY(a.nascs) AS "Anos_Nascimento",
    MONTH(a.nascs) AS "Mes_Nascimento",
    CASE
        WHEN RTRIM(a.situas) IN ('PSP', 'DES') AND a.ultcomps IS NOT NULL THEN
            CASE
                WHEN MONTH(a.nascs) >= MONTH(GETDATE()) AND DAY(a.nascs) > DAY(GETDATE()) THEN CONCAT(DAY(a.nascs), '/', MONTH(a.nascs), '/', YEAR(GETDATE()))
                WHEN MONTH(a.nascs) >= MONTH(GETDATE()) AND DAY(a.nascs) <= DAY(GETDATE()) THEN CONCAT(DAY(a.nascs), '/', MONTH(a.nascs), '/', YEAR(GETDATE()) + 1)
                ELSE CONCAT(DAY(a.nascs), '/', MONTH(a.nascs), '/', YEAR(GETDATE()) + 1)
            END
        ELSE
            CONCAT(
                FORMAT(a.nascs, 'dd/MM'), '/',
                CASE
                    WHEN FORMAT(a.nascs, 'MMdd') < FORMAT(GETDATE(), 'MMdd') THEN YEAR(GETDATE()) + 1
                    ELSE YEAR(GETDATE())
                END
            )
    END AS "Aniver. Fresh"
FROM sljcli a WITH (NOLOCK)
    LEFT JOIN sljscli b WITH (NOLOCK) ON a.situas = b.codigos
    LEFT JOIN sljfpubl c WITH (NOLOCK) ON a.fpubls = c.cods
    LEFT JOIN sljcli d WITH (NOLOCK) ON a.contavens = d.iclis
    LEFT JOIN sljcli k WITH (NOLOCK) ON k.iclis = a.contavens
WHERE
    (RTRIM(a.rclis) <> '' AND RTRIM(a.situas) IN ('', 'AMA', 'CD', 'CEL', 'CLI', 'FOP', 'IMP', 'INA', 'PRO', 'PSO', 'PSP', 'SS'))
    OR
    (RTRIM(a.situas) IN ('PSP', 'DES') AND a.ultcomps IS NOT NULL);
