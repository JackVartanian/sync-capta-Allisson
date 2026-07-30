# -*- coding: utf-8 -*-
"""
Testa a conexao com o banco do Capta (SQL Server) a partir de qualquer servidor.
Feito para rodar no servidor da Hostinger e validar a configuracao de VPN/rede.

Uso:
    python3 testa_conexao_capta.py

Requisitos:
    pip install pymssql python-dotenv
    (e o arquivo .env preenchido na raiz do projeto)
"""

import os
import socket
import sys

from dotenv import load_dotenv

load_dotenv()

SERVER = os.getenv('CAPTA_DB_SERVER')
PORT = int(os.getenv('CAPTA_DB_PORT', '1433'))  # porta padrao do SQL Server
DATABASE = os.getenv('CAPTA_DB_DATABASE')
USERNAME = os.getenv('CAPTA_DB_USERNAME')
PASSWORD = os.getenv('CAPTA_DB_PASSWORD')
TIMEOUT = 10  # segundos


def teste_1_rede():
    """Verifica se o servidor/porta esta alcancavel na rede (TCP)."""
    print(f'[1/2] Testando rede: {SERVER}:{PORT} (timeout {TIMEOUT}s)...')
    try:
        s = socket.create_connection((SERVER, PORT), timeout=TIMEOUT)
        s.close()
        print('      OK - porta 1433 alcancavel!\n')
        return True
    except socket.timeout:
        print('      FALHOU - timeout: servidor nao respondeu.')
        print('      Provavel causa: VPN/rota ate a rede da empresa ainda nao configurada.\n')
        return False
    except OSError as e:
        print(f'      FALHOU - {e}')
        print('      Provavel causa: sem rota/VPN ate a rede da empresa, ou firewall bloqueando.\n')
        return False


def teste_2_banco():
    """Tenta autenticar no SQL Server e rodar um SELECT."""
    print(f'[2/2] Testando login no banco {DATABASE}...')
    try:
        import pymssql
    except ImportError:
        print('      pymssql nao instalado. Rode: pip install pymssql\n')
        return False

    try:
        conn = pymssql.connect(SERVER, USERNAME, PASSWORD, DATABASE,
                               login_timeout=TIMEOUT)
        cur = conn.cursor()
        cur.execute("SELECT @@SERVERNAME, DB_NAME(), COUNT(*) FROM sljpro WITH(NOLOCK)")
        servidor, banco, qtd = cur.fetchone()
        conn.close()
        print(f'      OK - conectado ao servidor "{servidor}", banco "{banco}".')
        print(f'      Tabela de produtos acessivel: {qtd} registros.\n')
        return True
    except Exception as e:
        print(f'      FALHOU - {e}\n')
        return False


if __name__ == '__main__':
    print('=' * 55)
    print('TESTE DE CONEXAO - BANCO CAPTA (SQL Server)')
    print('=' * 55 + '\n')

    if not SERVER or not PASSWORD:
        print('ERRO: variaveis de ambiente nao carregadas.')
        print('Confira se o arquivo .env existe na raiz do projeto e esta preenchido.')
        sys.exit(1)

    rede_ok = teste_1_rede()
    banco_ok = teste_2_banco() if rede_ok else False

    print('=' * 55)
    if banco_ok:
        print('RESULTADO: CONEXAO OK - tudo funcionando!')
    elif rede_ok:
        print('RESULTADO: rede OK, mas o login no banco falhou.')
        print('Verificar usuario/senha ou permissoes no SQL Server.')
    else:
        print('RESULTADO: SEM CONEXAO - a rede nao alcanca o servidor.')
        print('Aguardando configuracao de VPN/rota pelo pessoal de TI.')
    print('=' * 55)
    sys.exit(0 if banco_ok else 1)
