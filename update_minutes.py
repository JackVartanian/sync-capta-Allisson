import funcoes_fabrica as fc_fab
import funcoes_estoque as fc_est
import funcoes_vendas as fc_vendas
import funcoes_comuns as fc
import time


start_time = time.time()

# fc.vpn()
fc_vendas.consultas_vendas()
# fc_est.consultas_estoque()
fc_fab.consultas_fabrica()

print('Processo completo, executado em %s segundos ---' %
      (round(time.time() - start_time, 2)))
