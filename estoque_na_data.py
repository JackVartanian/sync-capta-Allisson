# -*- coding: utf-8 -*-
"""
Reconstrucao de estoque historico a partir do livro-razao de pecas (sljeti).

O estoque do dashboard vem da tabela sljest (saldo atual, sem data). A sljeti
guarda cada peca com dtincs (entrada) e dtbaixa (saida), entao da pra reconstruir
o estoque de qualquer data: uma peca estava em estoque na data D se
    dtincs <= D  E  (dtbaixa IS NULL OR dtbaixa > D).

Este script aplica O MESMO FILTRO do dashboard (estoque_venda.sql) na sljeti.

Uso (no servidor):
    ./venv/bin/python estoque_na_data.py valida
        -> compara o TOTAL de hoje: sljest (saldo) x sljeti (pecas sem baixa).
           Se baterem, a reconstrucao e confiavel.

    ./venv/bin/python estoque_na_data.py data 2026-06-30
        -> total de estoque reconstruido naquela data (soma geral).

    ./venv/bin/python estoque_na_data.py data 2026-06-30 --por-produto
        -> estoque por produto naquela data (primeiras linhas).

SOMENTE LEITURA. Nada e alterado no Capta.
"""

import sys
import pandas as pd
import funcoes_comuns as fc

pd.set_option('display.max_columns', None)
pd.set_option('display.width', 200)
pd.set_option('display.max_rows', 60)

# Mesmas exclusoes do sql/estoque/estoque_venda.sql
EXCL_EMP_GRUPO = (
    'LMA - CONSERTOS', 'MAT - CONSERTOS', 'LMA - ESTOQUE ESPECIAL',
    'LMA - ESTOQUE LMA.PRIMA', 'MAT - ESTOQUE MAT.PRIMA',
    'LMA - ESTOQUE TRANSIT PROD', 'MAT - ESTOQUE TRANSIT PROD',
    'MPV - ESTOQUE PRODUTOS', 'NY - ESTOQUE CONSIG EXT',
    'NY - ESTOQUE CONSIGNADO', 'NY - ESTOQUE PRODUTOS', 'NY - ESTOQUE TRANSITO',
)
EXCL_CONTA = (
    'CASSIA AVILA', 'ESTOQUE COFRE (JV)', 'ESTOQUE DE DEVOLUCAO',
    'ESTOQUE ENCOMENDA', 'ESTOQUE FABRICA / DESENVOLVIMENTO', 'ESTOQUE LMA NY',
    'ESTOQUE MODELOS', 'ESTOQUE PRODUCAO', 'ESTOQUE TRANSITO AUDITORIA',
    'JACK VARTANIAN', 'JACK VARTANIAN - IGUATEMI',
)


def _in(lst):
    return '(' + ','.join("'" + x.replace("'", "''") + "'" for x in lst) + ')'


FILTRO_COMUM = f"""
    b.mercs = 'PA'
    AND RTRIM(a.emps) <> 'NY'
    AND CONCAT(RTRIM(a.emps),' - ',RTRIM(d.descrs)) NOT IN {_in(EXCL_EMP_GRUPO)}
    AND RTRIM(c.rclis) NOT IN {_in(EXCL_CONTA)}
"""


def rodar(sql, params=None):
    conn = fc.conn_pymssql()
    try:
        return pd.read_sql(sql, conn, params=params)
    finally:
        conn.close()


def total_sljest_hoje():
    sql = f"""
        SELECT CAST(SUM(a.sqtds) AS INT) AS total
        FROM sljest a WITH(NOLOCK)
        LEFT JOIN sljpro b WITH(NOLOCK) ON a.cpros = b.cpros
        LEFT JOIN sljcli c WITH(NOLOCK) ON a.estos = c.iclis
        LEFT JOIN sljgccr d WITH(NOLOCK) ON a.grupos = d.codigos
        WHERE a.sqtds <> 0 AND {FILTRO_COMUM}
    """
    return rodar(sql)['total'].iloc[0]


def total_sljeti(data=None, por_produto=False):
    # data=None -> hoje (dtbaixa IS NULL). data='YYYY-MM-DD' -> reconstrucao historica.
    if data is None:
        cond = "a.dtbaixa IS NULL"
        params = None
    else:
        cond = "a.dtincs <= %s AND (a.dtbaixa IS NULL OR a.dtbaixa > %s)"
        params = (data, data)

    sel = "RTRIM(a.cpros) AS cod_prod, CAST(SUM(a.qtds) AS INT) AS qtd" if por_produto \
          else "CAST(SUM(a.qtds) AS INT) AS total"
    grp = "GROUP BY a.cpros ORDER BY SUM(a.qtds) DESC" if por_produto else ""

    sql = f"""
        SELECT {sel}
        FROM sljeti a WITH(NOLOCK)
        LEFT JOIN sljpro b WITH(NOLOCK) ON a.cpros = b.cpros
        LEFT JOIN sljcli c WITH(NOLOCK) ON a.contas = c.iclis
        LEFT JOIN sljgccr d WITH(NOLOCK) ON a.grupos = d.codigos
        WHERE {cond} AND {FILTRO_COMUM}
        {grp}
    """
    return rodar(sql, params=params)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return
    cmd = sys.argv[1].lower()

    if cmd == 'valida':
        print('Comparando o total de estoque de HOJE...')
        t_est = total_sljest_hoje()
        t_eti = total_sljeti(data=None)['total'].iloc[0]
        print(f'  sljest (saldo dashboard):      {t_est}')
        print(f'  sljeti (pecas sem baixa):      {t_eti}')
        if t_est:
            dif = (t_eti - t_est)
            print(f'  diferenca:                     {dif}  ({round(100*dif/t_est,2)}%)')
        print('\nSe os dois estiverem iguais/muito proximos, a reconstrucao historica e confiavel.')
        return

    if cmd == 'data':
        if len(sys.argv) < 3:
            print('Informe a data: estoque_na_data.py data 2026-06-30')
            return
        data = sys.argv[2]
        por_produto = '--por-produto' in sys.argv
        df = total_sljeti(data=data, por_produto=por_produto)
        if por_produto:
            print(f'\nEstoque reconstruido em {data} (por produto, top linhas):\n')
            print(df.to_string(index=False))
        else:
            print(f'\nTotal de estoque reconstruido em {data}: {df["total"].iloc[0]}')
        return

    print(__doc__)


if __name__ == '__main__':
    main()
