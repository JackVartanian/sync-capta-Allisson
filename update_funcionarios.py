# -*- coding: utf-8 -*-
"""
Atualiza SOMENTE o CSV de funcionarios (funcionarios.csv) e publica no FTP.

Versao leve do consultas_clientes(): roda so a funcao funcionarios(), sem
executar o update_day.py inteiro. Util para ver rapidamente um funcionario/
consultora recem-cadastrado no Capta.

Fluxo:
    funcionarios() -> consulta o Capta (sljcli, grupos FUNCIONARI/FUNCIONAR/
    FORNECEDOR) -> gera funcionarios.csv (+ gzip + parquet) e envia ao FTP.

Uso:
    ./venv/bin/python update_funcionarios.py
"""

import time

import funcoes_clientes as fc_cli

start_time = time.time()

fc_cli.funcionarios()

print('Processo completo (funcionarios), executado em %s segundos ---' %
      (round(time.time() - start_time, 2)))
