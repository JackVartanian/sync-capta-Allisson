import funcoes_comuns as fc
import funcoes_dp as fc_dp
import funcoes_clientes as fc_cli
import funcoes_produtos as fc_prod
import funcoes_fabrica as fc_fab
import funcoes_financeiro as fc_fin
import time

start_time = time.time()

fc.calendario()
fc.passar_datas()
fc_prod.consultas_produtos()
# fc.dolar_2023()
# fc.dolar_2022()
fc_cli.consultas_clientes()
fc_dp.consultas_dp()
# fc_fin.conciliacao()
# fc_fin.forma_pagamento()
fc_fab.consultas_fabrica_dia()


print('Processo completo, executado em %s segundos ---' %
      (round(time.time() - start_time, 2)))
