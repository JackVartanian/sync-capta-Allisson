# -*- coding: utf-8 -*-
"""
Explorador do banco do Capta (SOMENTE LEITURA).

Serve para descobrir tabelas/colunas no Capta — por ex., achar a tabela de
MOVIMENTACAO de estoque (entradas/saidas com data), que permitiria reconstruir
o estoque historico.

Reaproveita a conexao do .env (funcoes_comuns.conn_pymssql), entao funciona no
servidor com o IP publico liberado.

Uso (no servidor):
    ./venv/bin/python explora_capta.py tabelas mov        # tabelas com 'mov' no nome
    ./venv/bin/python explora_capta.py tabelas esto       # tabelas com 'esto'
    ./venv/bin/python explora_capta.py colunas sljeti     # colunas da tabela sljeti
    ./venv/bin/python explora_capta.py amostra sljeti      # 5 primeiras linhas
    ./venv/bin/python explora_capta.py sql "SELECT TOP 10 * FROM sljeti WITH(NOLOCK)"

So aceita consultas de leitura (SELECT). Nada e alterado no Capta.
"""

import sys
import pandas as pd
import funcoes_comuns as fc

pd.set_option('display.max_columns', None)
pd.set_option('display.width', 220)
pd.set_option('display.max_rows', 200)


def rodar(sql, params=None):
    conn = fc.conn_pymssql()
    try:
        return pd.read_sql(sql, conn, params=params)
    finally:
        conn.close()


def tabelas(palavra):
    sql = """
        SELECT TABLE_NAME AS tabela,
               (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS c
                 WHERE c.TABLE_NAME = t.TABLE_NAME) AS qtd_colunas
        FROM INFORMATION_SCHEMA.TABLES t
        WHERE TABLE_TYPE = 'BASE TABLE' AND LOWER(TABLE_NAME) LIKE %s
        ORDER BY TABLE_NAME
    """
    df = rodar(sql, params=('%' + palavra.lower() + '%',))
    print(f'\n{len(df)} tabela(s) com "{palavra}" no nome:\n')
    print(df.to_string(index=False) if not df.empty else '(nenhuma)')


def colunas(tabela):
    sql = """
        SELECT COLUMN_NAME AS coluna, DATA_TYPE AS tipo,
               CHARACTER_MAXIMUM_LENGTH AS tamanho, IS_NULLABLE AS aceita_nulo
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = %s
        ORDER BY ORDINAL_POSITION
    """
    df = rodar(sql, params=(tabela,))
    print(f'\nColunas de "{tabela}" ({len(df)}):\n')
    print(df.to_string(index=False) if not df.empty else '(tabela nao encontrada)')


def amostra(tabela):
    df = rodar(f'SELECT TOP 5 * FROM {tabela} WITH(NOLOCK)')
    print(f'\nAmostra de "{tabela}":\n')
    print(df.to_string(index=False))


def sql_livre(query):
    q = query.strip()
    if not q.lower().startswith('select'):
        print('Por seguranca, so SELECT e permitido.')
        return
    df = rodar(q)
    print(f'\n{len(df)} linha(s):\n')
    print(df.to_string(index=False))


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return
    cmd = sys.argv[1].lower()
    arg = ' '.join(sys.argv[2:])
    if cmd == 'tabelas':
        tabelas(arg or '')
    elif cmd == 'colunas':
        colunas(arg)
    elif cmd == 'amostra':
        amostra(arg)
    elif cmd == 'sql':
        sql_livre(arg)
    else:
        print(__doc__)


if __name__ == '__main__':
    main()
