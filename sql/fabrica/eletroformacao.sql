SELECT DISTINCT RTRIM(cpros) AS 'cpros',
    RTRIM(dcompos) AS 'dcompos',
    IIF(dcompos LIKE '%ELETROLITICA%' , 'Eletro', '') AS 'Formacao'
FROM sljcomp2 WITH (NOLOCK)
WHERE cgrus = 'MET'
    AND dcompos LIKE '%ELETROLITICA%'
    AND cpros NOT LIKE 'CO%'
    AND cpros NOT IN ('PI01380','PU01937T','CL04314','PU01915T', 'CL04621', 'CL04619')
ORDER BY cpros

