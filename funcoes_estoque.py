import traceback
import funcoes_comuns as fc
import time

from warnings import simplefilter

simplefilter(action='ignore', category=FutureWarning)
simplefilter(action='ignore', category=Warning)

# SQL Estoque
sql_estoque_venda = 'sql/estoque/estoque_venda.sql'
sql_estoque_venda_reposicao = 'sql/estoque/estoque_venda_reposicao.sql'
sql_estoque_total = 'sql/estoque/estoque_total.sql'
sql_estoque_ny = 'sql/estoque/estoque_ny.sql'
sql_estoque_mat_consertos = 'sql/estoque/estoque_lma_consertos.sql'
sql_estoque_adega = 'sql/estoque/estoque_adega.sql'
sql_estoque_barra = 'sql/estoque/estoque_barra.sql'
sql_estoque_barra_giro = 'sql/estoque/estoque_barra_giro.sql'
sql_estoque_mkt = 'sql/estoque/estoque_marketing.sql'
sql_estoque_emb = 'sql/estoque/estoque_embalagem.sql'

def consultas_estoque():

    estoqueVenda()
    estoqueVendaReposicao()
    estoqueBarra()
    estoqueBarraGiro()
    estoqueNY()
    estoqueMatConsertos()
    estoqueAdega()
    estoqueTotal()


def estoqueVendaReposicao():
    print("\n")
    try:
        start_time = time.time()

        print('Estoque')
        df = fc.sqlToPandas(sql_estoque_venda_reposicao)
        fc.saveCSV(df, 'estoque_venda_reposicao')
        fc.saveCSV_compression(df, 'estoque_venda_reposicao_gzip', 'gzip')
        fc.sendToFTP('estoque_venda_reposicao')
        fc.sendToFTP('estoque_venda_reposicao_gzip')

        # fc.save_parquet(df, 'estoque_venda')
        # fc.send_to_ftp_parquet('estoque_venda')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Estoque Reposicao')
        print(traceback.format_exc())


def estoqueVenda():
    print("\n")
    try:
        start_time = time.time()

        print('Estoque')
        df = fc.sqlToPandas(sql_estoque_venda)
        fc.saveCSV(df, 'estoque_venda')
        fc.saveCSV_compression(df, 'estoque_venda_gzip', 'gzip')
        fc.sendToFTP('estoque_venda')
        fc.sendToFTP('estoque_venda_gzip')

        fc.saveTXT(df, 'estoque_venda_txt')
        fc.sendToFTP_txt('estoque_venda_txt')

        # fc.save_parquet(df, 'estoque_venda')
        # fc.send_to_ftp_parquet('estoque_venda')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Estoque')
        print(traceback.format_exc())


def estoque_ai():

    df = fc.readCSV_compression('estoque_venda_gzip', 'gzip')
    df.drop(columns=['Cod. Gr. Est.', 'Cod. Cta. Est.', 'Loja Desc. Gr. Est.'], inplace=True)
    df.columns = ['Loja', 'Grupo', 'Subgrupo', 'Produto', 'Quantidade']

    fc.saveCSV_ai(df, 'estoque_venda_ai')
    fc.saveCSV_ai_compression(df, 'estoque_venda_ai_gzip', 'gzip')

    with open('ai_datasets/estoque.jsonl', 'w', encoding='utf-8') as f:
        df.to_json(f, orient='records', lines=True, force_ascii=False)

    df.to_json('ai_datasets/estoque.json', orient='records',
               indent=4, force_ascii=False)

    return df


def estoqueBarraGiro():
    print("\n")
    try:
        start_time = time.time()

        print('Estoque Barra Giro')
        df = fc.sqlToPandas(sql_estoque_barra)
        fc.saveCSV(df, 'estoque_barra_giro')
        fc.saveCSV_compression(df, 'estoque_barra_giro_gzip', 'gzip')
        fc.sendToFTP('estoque_barra_giro')
        fc.sendToFTP('estoque_barra_giro_gzip')

        # fc.save_parquet(df, 'estoque_barra')
        # fc.send_to_ftp_parquet('estoque_barra')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Estoque')
        print(traceback.format_exc())


def estoqueBarra():
    print("\n")
    try:
        start_time = time.time()

        print('Estoque Barra')
        df = fc.sqlToPandas(sql_estoque_barra)
        fc.saveCSV(df, 'estoque_barra')
        fc.saveCSV_compression(df, 'estoque_barra_gzip', 'gzip')
        fc.sendToFTP('estoque_barra')
        fc.sendToFTP('estoque_barra_gzip')

        # fc.save_parquet(df, 'estoque_barra')
        # fc.send_to_ftp_parquet('estoque_barra')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Estoque')
        print(traceback.format_exc())


def estoqueNY():
    print("\n")

    try:
        start_time = time.time()

        print('Estoque NY')
        df = fc.sqlToPandas(sql_estoque_ny)
        fc.saveCSV(df, 'estoque_ny')
        fc.saveCSV_compression(df, 'estoque_ny_gzip', 'gzip')
        fc.sendToFTP('estoque_ny')
        fc.sendToFTP('estoque_ny_gzip')

        fc.save_parquet(df, 'estoque_ny')
        fc.send_to_ftp_parquet('estoque_ny')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Estoque NY')
        print(traceback.format_exc())


def estoqueMatConsertos():
    print("\n")
    try:
        start_time = time.time()

        print('Estoque MAT Consertos')
        df = fc.sqlToPandas(sql_estoque_mat_consertos)
        fc.saveCSV(df, 'estoque_mat_consertos')
        fc.saveCSV_compression(df, 'estoque_mat_consertos_gzip', 'gzip')
        fc.sendToFTP('estoque_mat_consertos')
        fc.sendToFTP('estoque_mat_consertos_gzip')

        fc.save_parquet(df, 'estoque_mat_consertos')
        fc.send_to_ftp_parquet('estoque_mat_consertos')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Estoque MAT Consertos')
        print(traceback.format_exc())


def estoqueAdega():
    print("\n")
    try:
        start_time = time.time()

        print('Estoque Adega')
        df = fc.sqlToPandas(sql_estoque_adega)
        fc.saveCSV(df, 'estoque_adega')
        fc.saveCSV_compression(df, 'estoque_adega_gzip', 'gzip')
        fc.sendToFTP('estoque_adega')
        fc.sendToFTP('estoque_adega_gzip')

        # fc.save_parquet(df, 'estoque_adega')
        # fc.send_to_ftp_parquet('estoque_adega')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar estoque_adega')
        print(traceback.format_exc())


def estoqueTotal():
    print("\n")
    try:
        start_time = time.time()

        print('Estoque Total')
        df = fc.sqlToPandas(sql_estoque_total)
        fc.saveCSV(df, 'estoque_total')
        fc.sendToFTP('estoque_total')

        # fc.save_parquet(df, 'estoque_total')
        # fc.send_to_ftp_parquet('estoque_total')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar estoque_total')
        print(traceback.format_exc())


def estoqueMarketing():
    print("\n")
    try:
        start_time = time.time()

        print('Estoque Marketing')
        df = fc.sqlToPandas(sql_estoque_mkt)
        fc.saveCSV(df, 'estoque_marketing')
        fc.sendToFTP('estoque_marketing')

        # fc.save_parquet(df, 'estoque_marketing')
        # fc.send_to_ftp_parquet('estoque_marketing')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar estoque_marketing')
        print(traceback.format_exc())


def estoqueEmbalagem():
    print("\n")
    try:
        start_time = time.time()

        print('Estoque Embalagem')

        df = fc.sqlToPandas(sql_estoque_emb)

        fc.saveCSV(df, 'estoque_embalagem')
        fc.saveCSV_compression(df, 'estoque_embalagem_gzip', 'gzip')
        fc.sendToFTP('estoque_embalagem')
        fc.sendToFTP('estoque_embalagem_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar estoque_embalagem')
        print(traceback.format_exc())
