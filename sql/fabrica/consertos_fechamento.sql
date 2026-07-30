SELECT
  CAST(datas AS DATE) AS 'Fechamento_OS',
  RTRIM(numes) AS 'OS_FECHAMENTO'
FROM sljeest
WHERE dopes IN ('ENTREGA OS CLIENTE')
  AND datas >= '2018/01/01'
  ORDER BY datas DESC