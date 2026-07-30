SELECT
    CAST( dtemis AS DATE ) AS 'Data',
    RTRIM(emps) AS 'Empresa',
    RTRIM(dopes) AS 'Operacao',
    RTRIM(contads) AS 'Conta',
    RTRIM(notas) AS 'Nota',
    RTRIM(nemps) AS 'ID_Vtex',
    CAST( valos AS DECIMAL(10) ) AS 'Valor',
    CONCAT( RTRIM( contads ),'-',  RTRIM( notas )) AS ID_Pedido
FROM sljeest WITH(NOLOCK)
WHERE datas >= '2020/01/01' AND
    dopes = 'PEDIDO E-COMM       '
ORDER BY dtemis DESC