# -*- coding: utf-8 -*-
"""
Atualiza SOMENTE o CSV de clientes (clientes.csv) e publica no FTP.

Versao LEVE do consultas_clientes(), pensada para rodar a cada 5 minutos
via cron, SEM executar o update_day.py inteiro (que tambem faz produtos,
calendario, dolar, DP e fabrica).

Fluxo (a ordem importa):
    1) clientesRfv2()  -> le datasets/vendas.csv, calcula o RFV e gera
                          clientes_rfv_2 (arquivo que o clientes() consome)
    2) clientes()      -> 1 consulta no Capta (sql_clientes) + le vendas.csv e
                          clientes_rfv_2, monta o clientes.csv (e variantes) e
                          envia tudo para o FTP

Dependencias de arquivos locais (gerados por outros crons):
    - datasets/vendas.csv  -> update_minutes.py (a cada 30 min, 08h-22h)
      Se ainda nao existir, clientes()/clientesRfv2() tratam a excecao e apenas
      nao regeram o CSV naquela rodada (sem corromper o arquivo atual).

Uso:
    ./venv/bin/python update_clientes.py
"""

import time

import funcoes_clientes as fc_cli

start_time = time.time()

# RFV precisa ser gerado antes, pois clientes() le o clientes_rfv_2.
fc_cli.clientesRfv2()
fc_cli.clientes()

print('Processo completo (clientes), executado em %s segundos ---' %
      (round(time.time() - start_time, 2)))
