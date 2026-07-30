SELECT cpros,
dpros,
custofs,
pvens
FROM SLJPRO with(nolock)
WHERE mercs = 'SER' AND cgrus = 'SOF'