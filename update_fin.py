import funcoes_financeiro as fc_fin
import time

start_time = time.time()

fc_fin.forma_pagamento()

print('Processo completo, executado em %s segundos ---' %
      (round(time.time() - start_time, 2)))