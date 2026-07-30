SELECT
RTRIM( a.iclis ) AS "Cod. Funcionario",
RTRIM( a.rclis ) AS "Nome"
FROM sljcli a WITH(NOLOCK)
WHERE grupos = 'FUNCIONARI' OR
grupos = 'FUNCIONAR' OR
grupos = 'FORNECEDOR'