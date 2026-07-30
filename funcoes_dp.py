import funcoes_comuns as fc
import time

from warnings import simplefilter

simplefilter(action='ignore', category=FutureWarning)
simplefilter(action='ignore', category=Warning)

# SQL DP e RH
sql_comissao_acomp = 'sql/dp_rh/comissao_acomp.sql'
sql_comissao_consultor = 'sql/dp_rh/comissao_consultor.sql'
sql_comissao_credito = 'sql/dp_rh/comissao_credito_acomp.sql'


def consultas_dp():

    print("\n")
    try:
        start_time = time.time()

        print('Comissao Acomp. Vendas')
        df = fc.sqlToPandas(sql_comissao_acomp)
        fc.saveCSV(df, 'comissao_acomp')
        fc.saveCSV_compression(df, 'comissao_acomp_gzip', 'gzip')
        fc.sendToFTP('comissao_acomp')
        fc.sendToFTP('comissao_acomp_gzip')

        # fc.save_parquet(df, 'comissao_acomp')
        # fc.send_to_ftp_parquet('comissao_acomp')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))

    except:
        print('Erro ao exportar Comissao Acomp. Vendas')
    print("\n")
    try:
        start_time = time.time()

        print('Comissao Consultor')
        df = fc.sqlToPandas(sql_comissao_consultor)
        fc.saveCSV(df, 'comissao_consultor')
        fc.saveCSV_compression(df, 'comissao_consultor_gzip', 'gzip')
        fc.sendToFTP('comissao_consultor')
        fc.sendToFTP('comissao_consultor_gzip')

        # fc.save_parquet(df, 'comissao_consultor')
        # fc.send_to_ftp_parquet('comissao_consultor')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))

    except:
        print('Erro ao exportar Comissao Consultor')
    print("\n")
