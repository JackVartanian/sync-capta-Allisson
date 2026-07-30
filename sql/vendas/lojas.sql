SELECT DISTINCT
CASE
        WHEN RTRIM( a.emps ) LIKE 'IGL' THEN 'IGU'
        WHEN RTRIM( a.emps ) LIKE 'FSM' THEN 'DES'
        WHEN RTRIM( a.emps ) LIKE 'BAL' THEN 'BAT'
        WHEN RTRIM( a.emps ) LIKE 'CUR' THEN 'BAT'
        WHEN RTRIM( a.emps ) LIKE 'FTH' THEN 'WEB'
        WHEN RTRIM( a.emps ) LIKE 'FFL' THEN 'BEL'
        WHEN RTRIM( a.emps ) LIKE 'LMA' THEN 'MAT'
        WHEN RTRIM( a.emps ) LIKE 'MPV' THEN 'MP2'
        ELSE RTRIM( a.emps )
            END AS "Empresa"
FROM sljgdmi AS a with (nolock)
WHERE a.emps <> 'NY' AND a.tipoops NOT IN (91, 92)
group by a.emps, a.vends
ORDER BY "Empresa"