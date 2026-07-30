import funcoes_comuns as fc
import pandas as pd
import numpy as np
import time
import datetime
import traceback
from warnings import simplefilter

simplefilter(action='ignore', category=FutureWarning)
simplefilter(action='ignore', category=Warning)

# SQL Fabrica
sql_consertos = 'sql/fabrica/consertos.sql'
sql_consertos_aceite = 'sql/fabrica/consertos_aceite.sql'
sql_consertos_fechamento = 'sql/fabrica/consertos_fechamento.sql'
sql_consertos_retorno = 'sql/fabrica/consertos_retorno_loja.sql'
sql_cravacao = 'sql/fabrica/cravacao.sql'
sql_eletroformacao = 'sql/fabrica/eletroformacao.sql'
sql_historico_producao = 'sql/fabrica/historico_producao.sql'
sql_ordem_producao = 'sql/fabrica/ordem_producao.sql'
sql_pedido_op = 'sql/fabrica/pedido_op.sql'
sql_servicos = 'sql/fabrica/servicos.sql'
sql_falta = 'sql/fabrica/falta.sql'
sql_fases = 'sql/fabrica/fases.sql'
sql_tipo_servico = 'sql/fabrica/tipoServico.sql'
sql_ultima_fase_producao = 'sql/fabrica/ultima_fase_producao.sql'
sql_ultima_fase_producao_v2 = 'sql/fabrica/ultima_fase_producao_v2.sql'
sql_composicao_pedras = 'sql/fabrica/composicao.sql'
sql_vendas_barra = 'sql/fabrica/vendas_barra.sql'

def ordemProducao():
    print("\n")
    try:
        start_time = time.time()

        print('Ordem Producao')
        df = fc.sqlToPandas(sql_ordem_producao)
        fc.saveCSV(df, 'ordem_producao')
        fc.saveCSV_compression(df, 'ordem_producao_gzip', 'gzip')
        fc.sendToFTP('ordem_producao')
        fc.sendToFTP('ordem_producao_gzip')

        # fc.save_parquet(df, 'ordem_producao')
        # fc.send_to_ftp_parquet('ordem_producao')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Ordem Producao')


def composicao_metal():
    print("\n")
    try:
        start_time = time.time()

        print('Composicao Metal')
        df = fc.sqlToPandas(sql_composicao_pedras)
        fc.saveCSV(df, 'composicao_metal')
        fc.saveCSV_compression(df, 'composicao_metal_gzip', 'gzip')
        fc.sendToFTP('composicao_metal')
        fc.sendToFTP('composicao_metal_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Composicao Metal' + str(e))

def composicao_pedras():
    print("\n")
    try:
        start_time = time.time()

        print('Composicao Pedras')
        df = fc.sqlToPandas(sql_composicao_pedras)
        fc.saveCSV(df, 'composicao_pedras')
        fc.saveCSV_compression(df, 'composicao_pedras_gzip', 'gzip')
        fc.sendToFTP('composicao_pedras')
        fc.sendToFTP('composicao_pedras_gzip')

        # fc.save_parquet(df, 'composicao_pedras')
        # fc.send_to_ftp_parquet('composicao_pedras')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Composicao Pedras'  + str(e))

def pedidoOP():
    print("\n")
    try:
        start_time = time.time()

        print('Pedidos OPS')
        df = fc.sqlToPandas(sql_pedido_op)
        fc.saveCSV(df, 'pedido_op')
        fc.saveCSV_compression(df, 'pedido_op_gzip', 'gzip')
        fc.sendToFTP('pedido_op')
        fc.sendToFTP('pedido_op_gzip')

        # fc.save_parquet(df, 'pedido_op')
        # fc.send_to_ftp_parquet('pedido_op')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Pedidos OPS')

def ultimaFaseProducao():
    print("\n")
    try:
        start_time = time.time()

        print('Iniciando Consulta Ultima fase producao')
        df = fc.sqlToPandas(sql_ultima_fase_producao)
        print('Consulta Ultima fase producao finalizada')
        print('Qtde de linhas: ', len(df))
        fc.saveCSV(df, 'ultima_fase_producao')
        fc.saveCSV_compression(df, 'ultima_fase_producao_gzip', 'gzip')
        fc.sendToFTP('ultima_fase_producao')
        fc.sendToFTP('ultima_fase_producao_gzip')

        # fc.save_parquet(df, 'ultima_fase_producao')
        # fc.send_to_ftp_parquet('ultima_fase_producao')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Ultima fase producao', e)

def ultimaFaseProducaoQtde():
    print("\n")
    try:
        start_time = time.time()

        print('Ultima fase producao qtdes')
        df = fc.sqlToPandas(sql_ultima_fase_producao)
        df2 = df.groupby(['OP'])['OP'].count()
        df2 = df2[df2 == 2]
        fc.saveCSV(df2, 'ultima_fase_producao_qtdes')
        fc.saveCSV_compression(df, 'ultima_fase_producao_qtdes_gzip', 'gzip')
        fc.sendToFTP('ultima_fase_producao_qtdes')
        fc.sendToFTP('ultima_fase_producao_qtdes_gzip')

        # fc.save_parquet(df, 'ultima_fase_producao_qtdes')
        # fc.send_to_ftp_parquet('ultima_fase_producao_qtdes')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Ultima fase producao')

def ultimaFaseProducaoV2():
    print("\n")
    try:
        start_time = time.time()

        print('Ultima fase producao v2')
        df = fc.sqlToPandas(sql_ultima_fase_producao_v2)
        print('Consulta Ultima fase producao v2 finalizada')
        print('Qtde de linhas: ', len(df))

        fc.saveCSV(df, 'ultima_fase_producao_v2')
        fc.saveCSV_compression(df, 'ultima_fase_producao_v2_gzip', 'gzip')
        fc.sendToFTP('ultima_fase_producao_v2')
        fc.sendToFTP('ultima_fase_producao_v2_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Ultima fase producao v2:', e)
        print(traceback.format_exc())



def faltas():
    print("\n")
    try:
        start_time = time.time()

        print('Faltas')
        df = fc.sqlToPandas(sql_falta)
        fc.saveCSV(df, 'faltas')
        fc.saveCSV_compression(df, 'faltas_gzip', 'gzip')
        fc.sendToFTP('faltas')
        fc.sendToFTP('faltas_gzip')

        # fc.save_parquet(df, 'faltas')
        # fc.send_to_ftp_parquet('faltas')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Faltas', e)

def consertos():

    print("\n")
    try:
        start_time = time.time()

        print('Conserto')
        consertos = fc.sqlToPandas(sql_consertos)
        aceite = fc.sqlToPandas(sql_consertos_aceite)
        fechamento = fc.sqlToPandas(sql_consertos_fechamento)
        retorno = fc.sqlToPandas(sql_consertos_retorno)

        consertos = consertos.join(aceite.set_index(
            'OS_ACEITE'), on='Ordem de servico', how='left')
        consertos = consertos.join(fechamento.set_index(
            'OS_FECHAMENTO'), on='Ordem de servico', how='left')
        consertos = consertos.join(retorno.set_index(
            'OS_Retorno'), on='Ordem de servico', how='left')
        consertos['Tempo_Aceite'] = consertos['Aceite_Fab'] - \
            consertos['Abertura_OS']
        consertos['Status_OS'] = np.where(consertos['Retorno_loja'].isnull() | consertos['Fechamento_OS'].isnull(), 'OS aberta',
                                          np.where(consertos['Retorno_loja'] > consertos['Abertura_OS'] + pd.Timedelta(days=15), 'atraso Fab',
                                                   np.where(consertos['Fechamento_OS'] > consertos['Abertura_OS'] + pd.Timedelta(days=15), 'atraso loja', 'Sem atraso')))

        consertos['Abertura_OS'] = pd.to_datetime(
            consertos['Abertura_OS'], format='%Y-%m-%d')
        consertos['Janela_Conversao'] = pd.to_datetime(
            consertos['Janela_Conversao'], format='%Y-%m-%d')
        consertos['Aceite_Fab'] = pd.to_datetime(
            consertos['Aceite_Fab'], format='%Y-%m-%d')
        consertos['Fechamento_OS'] = pd.to_datetime(
            consertos['Fechamento_OS'], format='%Y-%m-%d')
        consertos['Prazo de entrega'] = pd.to_datetime(
            consertos['Prazo de entrega'], format='%Y-%m-%d')
        consertos['Retorno_loja'] = pd.to_datetime(
            consertos['Retorno_loja'], format='%Y-%m-%d')

        print('Quantidade de Consertos: ', len(consertos))

        fc.saveCSV(consertos, 'consertos')
        fc.saveCSV_compression(consertos, 'consertos_gzip', 'gzip')
        fc.sendToFTP('consertos')
        fc.sendToFTP('consertos_gzip')

        # fc.save_parquet(df, 'consertos')
        # fc.send_to_ftp_parquet('consertos')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))

        return consertos
    except Exception as e:
        print('Erro ao exportar Conserto', e)

def cravacao():
    print("\n")

    try:
        start_time = time.time()

        print('Cravacao')
        df = fc.sqlToPandas(sql_cravacao)

        fc.saveCSV(df, 'cravacao')
        fc.saveCSV_compression(df, 'cravacao_gzip', 'gzip')
        fc.sendToFTP('cravacao')
        fc.sendToFTP('cravacao_gzip')

        # fc.save_parquet(df, 'cravacao')
        # fc.send_to_ftp_parquet('cravacao')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Cravacao')

def eletroformacao():
    print("\n")

    try:
        start_time = time.time()

        print('Eletroformacao')
        df = fc.sqlToPandas(sql_eletroformacao)
        fc.saveCSV(df, 'eletroformacao')
        fc.saveCSV_compression(df, 'eletroformacao_gzip', 'gzip')
        fc.sendToFTP('eletroformacao')
        fc.sendToFTP('eletroformacao_gzip')

        # fc.save_parquet(df, 'eletroformacao')
        # fc.send_to_ftp_parquet('eletroformacao')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Eletroformacao')

def servicos():

    print("\n")

    try:
        start_time = time.time()

        print('Servicos')
        df = fc.sqlToPandas(sql_servicos)
        fc.saveCSV(df, 'servicos')
        fc.saveCSV_compression(df, 'servicos_gzip', 'gzip')
        fc.sendToFTP('servicos')
        fc.sendToFTP('servicos_gzip')

        # fc.save_parquet(df, 'servicos')
        # fc.send_to_ftp_parquet('servicos')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Servicos')

def fases():
    print("\n")

    try:
        start_time = time.time()

        print('Fases')
        df = fc.sqlToPandas(sql_fases)
        fc.saveCSV(df, 'fases')
        fc.saveCSV_compression(df, 'fases_gzip', 'gzip')
        fc.sendToFTP('fases')
        fc.sendToFTP('fases_gzip')

        # fc.save_parquet(df, 'fases')
        # fc.send_to_ftp_parquet('fases')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Fases')

def tipoServico():
    print("\n")

    try:
        start_time = time.time()
        print('Tipo de Servico')
        df = fc.sqlToPandas(sql_tipo_servico)
        fc.saveCSV(df, 'tipoServico')
        fc.saveCSV_compression(df, 'tipoServico_gzip', 'gzip')
        fc.sendToFTP('tipoServico')
        fc.sendToFTP('tipoServico_gzip')

        # fc.save_parquet(df, 'tipoServico')
        # fc.send_to_ftp_parquet('tipoServico')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Tipo de Servico')

def historicoProducao():
    print("\n")
    try:
        start_time = time.time()

        print('Historico Producao')
        df = fc.sqlToPandas(sql_historico_producao)
        fc.saveCSV(df, 'historico_producao')
        fc.saveCSV_compression(df, 'historico_producao_gzip', 'gzip')
        fc.sendToFTP('historico_producao')
        fc.sendToFTP('historico_producao_gzip')

        # fc.save_parquet(df, 'historico_producao')
        # fc.send_to_ftp_parquet('historico_producao')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Historico Producao')

def consertosConvertidos():
    try:
        start_time = time.time()

        print('Consertos Convertidos')

        consertos = fc.readCSV('consertos')
        consertos = consertos.groupby(['Loja', 'Operacao', 'Ordem de servico', 'Abertura_OS',
                                        'Janela_Conversao', 'Cod.Consultora', 'Conta origem', 'Cliente']).count().reset_index()
        colunas = ['Loja', 'Operacao', 'Ordem de servico', 'Abertura_OS',
                    'Janela_Conversao', 'Cod.Consultora', 'Conta origem', 'Cliente']
        consertos = consertos[colunas]
        consertos = consertos[consertos['Conta origem'] != '11040101']
        consertos = consertos.reset_index(drop=True)

        df_vendas = fc.readCSV('vendas')
        df_vendas['Qtd'] = df_vendas['Qtd'].astype(int)
        df_vendas['Total Liq.'] = df_vendas['Total Liq.'].str.replace(',', '.')
        df_vendas['Total Liq.'] = df_vendas['Total Liq.'].astype(float)

        df_vendas = df_vendas.groupby(['Data', 'Cod. Vend.', 'Cod. Cliente', 'Nome Cliente', 'ID_Venda'], as_index=False).agg(
            {'Qtd': 'sum', 'Total Liq.': 'sum'}).sort_values(by=['Cod. Cliente', 'Data']).reset_index(drop=True)

        df_convertidos = pd.DataFrame()
        df_nao_convertidos = pd.DataFrame()

        print('Quantidade de OS: ', len(consertos))

        # consertos = consertos[0:10]

        print('Quantidade de OS: ', len(consertos))

        for i in range(len(consertos)):

            data_inicio = str(consertos.iloc[i]['Abertura_OS'])
            data_fim = str(consertos.iloc[i]['Janela_Conversao'])
            cliente = consertos.iloc[i]['Conta origem']
            ordemServico = consertos.iloc[i]['Ordem de servico']

            try:
                vendas = buscarVendaConserto(
                    vendas=df_vendas, cliente=cliente, data_inicio=data_inicio, data_fim=data_fim)

                if len(vendas) != 0:
                    print('Encontrou venda: ', cliente, data_inicio, data_fim)
                    df_novo = pd.DataFrame({'cliente': [cliente], 'OS': [
                                        ordemServico], 'id_venda': [vendas.iloc[0, 4]]})
                    df_convertidos = pd.concat([df_convertidos, df_novo], ignore_index=True)
                else:
                    df_novo_n = pd.DataFrame(
                        {'cliente': [cliente], 'OS': [ordemServico]})
                    df_nao_convertidos = pd.concat([df_nao_convertidos, df_novo_n], ignore_index=True)
            except:
                print('Erro ao buscar venda.')
                print(traceback.format_exc())

        df_convertidos = df_convertidos.drop_duplicates(
            subset=['id_venda'], keep='first').reset_index(drop=True)

        df_convertidos = df_convertidos.join(df_vendas.set_index(
            'ID_Venda'), on='id_venda', how='left', lsuffix='_left', rsuffix='_right')

        print('Quantidade de OS convertidas: ', len(df_convertidos))
        print('Quantidade de OS não convertidas: ',
                len(df_nao_convertidos), '\n')

        # df = df_convertidos.groupby(['cliente', 'id_venda']).agg(
        #     {'OS': lambda x: list(x)}).reset_index()

        fc.saveCSV(df_convertidos, 'consertos_convertidos')
        fc.saveCSV_compression(
            df_convertidos, 'consertos_convertidos_gzip', 'gzip')
        fc.sendToFTP('consertos_convertidos')
        fc.sendToFTP('consertos_convertidos_gzip')

        fc.saveCSV(df_nao_convertidos, 'consertos_nao_convertidos')
        fc.saveCSV_compression(
            df_nao_convertidos, 'consertos_nao_convertidos_gzip', 'gzip')
        fc.sendToFTP('consertos_nao_convertidos')
        fc.sendToFTP('consertos_nao_convertidos_gzip')

        print('Processo completo, executado em %s segundos ---' %
                (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Consertos Convertidos')
        print(traceback.format_exc())
    print("\n")

def buscarVendaConserto(vendas, cliente, data_inicio, data_fim):

    data_inicio = datetime.datetime.strptime(data_inicio, '%Y-%m-%d')
    data_fim = datetime.datetime.strptime(data_fim, '%Y-%m-%d')

    vendas = vendas.loc[vendas['Cod. Cliente']
                        == str(cliente)].reset_index(drop=True)

    vendas['Data'] = pd.to_datetime(vendas['Data'])

    vendas = vendas[(vendas['Data'] >= data_inicio)]
    vendas = vendas[(vendas['Data'] <= data_fim)]
    vendas = vendas.reset_index(drop=True)
    return vendas

def vendas_barra():
    print("\n")
    try:
        start_time = time.time()

        print('Vendas por barra')
        df = fc.sqlToPandas(sql_vendas_barra)
        df = df.groupby(['Empresa', 'Cod. Cliente', 'Nome Cliente', 'Cod. Prod.', 'Cod. Barras']).agg({'Data': 'max', 'Qtd': 'sum', 'Total Liq.': 'sum'}).reset_index()
        df.rename(columns={'Data': 'Data_venda'}, inplace=True)

        print('Quantidade de vendas: ', len(df))

        fc.saveCSV(df, 'vendas_barra')
        # fc.saveCSV_compression(df, 'vendas_barra_gzip', 'gzip')
        # fc.sendToFTP('vendas_barra')
        # fc.sendToFTP('vendas_barra_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
        return df
    except Exception as e:
        print('Erro ao exportar Vendas por barra', e)


def consertos_vendas():

    print("\n")
    try:
        start_time = time.time()

        print('Vendas x consertos')

        vendas = vendas_barra()
        conserto = consertos()

        conserto = conserto[['Operacao', 'Abertura_OS', 'Ordem de servico',
                             'Cod_Barras', 'Servico', 'DescServico']]
        conserto.rename(columns={'Abertura_OS': 'Data_conserto'}, inplace=True)

        # filter Cod_Barras <> 0
        conserto = conserto[conserto['Cod_Barras'] != '0']

        print('Fazendo join...')
        df_join = pd.merge(conserto, vendas,
                           left_on='Cod_Barras', right_on='Cod. Barras', how='inner')
        print('Join feito')

        # df_join = df_join.drop_duplicates(subset='Cod_Barras', keep='first')

        print('Quantidade de registros após join: ', len(df_join))

        df_join['Data_venda'] = pd.to_datetime(df_join['Data_venda'])
        df_join['Data_conserto'] = pd.to_datetime(df_join['Data_conserto'])
        df_join['Diff_datas'] = df_join['Data_conserto'] - df_join['Data_venda']
        df_join['Diff_datas'] = df_join['Diff_datas'].dt.days

        fc.saveCSV(df_join, 'vendas_consertos')
        fc.saveCSV_compression(df_join, 'vendas_consertos_gzip', 'gzip')
        fc.sendToFTP('vendas_consertos')
        fc.sendToFTP('vendas_consertos_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))

        return df_join
    except Exception as e:
        print('Erro ao exportar Vendas por barra', e)

def consultas_fabrica():

    ordemProducao()
    ultimaFaseProducao()
    ultimaFaseProducaoQtde()
    ultimaFaseProducaoV2()
    composicao_metal()

def consultas_fabrica_dia():

    consertos()
    consertosConvertidos()
    consertos_vendas()
    cravacao()
    servicos()
    eletroformacao()
    faltas()
    pedidoOP()
    historicoProducao()
    fases()
    tipoServico()
