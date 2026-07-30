import time

import funcoes_comuns as fc
import funcoes_estoque as fc_est
import funcoes_fabrica as fc_fab
import funcoes_vendas as fc_vendas

start_time = time.time()


fc_est.estoqueVenda()
fc_est.estoqueVendaReposicao()
# fc_est.estoqueNY()
fc_est.estoqueBarraGiro()
fc_est.estoqueBarra()
fc_est.estoqueAdega()
fc_est.estoqueEmbalagem()

print('Processo completo, executado em %s segundos ---' %
      (round(time.time() - start_time, 2)))
