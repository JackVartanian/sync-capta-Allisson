SELECT
    CAST(datas AS DATE) AS 'Retorno_loja',
    CASE
        WHEN RTRIM( emps ) LIKE 'IGL' THEN 'IGU'
        WHEN RTRIM( emps ) LIKE 'FSM' THEN 'DES'
        WHEN RTRIM( emps ) LIKE 'BAL' THEN 'BAT'
        WHEN RTRIM( emps ) LIKE 'CUR' THEN 'BAT'
        WHEN RTRIM( emps ) LIKE 'FTH' THEN 'WEB'
        WHEN RTRIM( emps ) LIKE 'FFL' THEN 'BEL'
        WHEN RTRIM( emps ) LIKE 'LMA' THEN 'MAT'
        WHEN RTRIM( emps ) LIKE 'MPV' THEN 'MP2'
        ELSE RTRIM( emps )
      END AS "Loja retorno",
    RTRIM(dopes) AS 'Operacao_Retorno',
    RTRIM(numes) AS 'OS_Retorno'
FROM sljeest
WHERE dopes IN ('RETORNO LOJA CX', 'RETORNO ESTOQUE', 'RETORNO LOJA')
    AND datas >= '2018/01/01'
  ORDER BY datas DESC
