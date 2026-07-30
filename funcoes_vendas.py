import funcoes_comuns as fc
import numpy as np
import pandas as pd
import time
from datetime import datetime, timedelta


from warnings import simplefilter

simplefilter(action='ignore', category=FutureWarning)
simplefilter(action='ignore', category=Warning)

# SQL Vendas
sql_vendas = 'sql/vendas/vendas.sql'
sql_vendas_Web = 'sql/vendas/vendasWEB.sql'
sql_lojas = 'sql/vendas/lojas.sql'
sql_pedido_ecomm = 'sql/vendas/pedido_ecomm.sql'
sql_vendas_colecao = 'sql/vendas/vendas_colecao.sql'
sql_vendas_colecao_dias = 'sql/vendas/vendas_colecao_dias.sql'
sql_vendasNdias = 'sql/vendas/vendas_SeteDias.sql'

def consultas_vendas():

    vendas_old()
    vendas_ai()
    # vendas_tipo_cliente()
    vendas_3meses()
    vendas_ontem()
    # vendas()
    # vendas_filtros()
    # vendasWEB()
    # vendas_bi()
    # vendas_crm()
    lojas()
    vendasColecao()
    vendasColecaoDia()



def vendasColecaoDia():
    print("\n")
    try:
        start_time = time.time()

        print('Vendas Colecao Dia')
        df = fc.sqlToPandas(sql_vendas_colecao_dias)
        fc.saveCSV(df, 'vendas_colecao_dias')
        fc.saveCSV_compression(df, 'vendas_colecao_dias_gzip', 'gzip')
        fc.sendToFTP('vendas_colecao_dias')
        fc.sendToFTP('vendas_colecao_dias_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Vendas Colecao Dia')


def vendasColecao():
    print("\n")

    try:
        start_time = time.time()

        print('Vendas Colecao')
        df = fc.sqlToPandas(sql_vendas_colecao)
        fc.saveCSV(df, 'vendas_colecao')
        fc.saveCSV_compression(df, 'vendas_colecao_gzip', 'gzip')
        fc.sendToFTP('vendas_colecao')
        fc.sendToFTP('vendas_colecao_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Vendas Colecao')


def lojas():
    print("\n")

    try:
        start_time = time.time()

        print('Lojas')
        df = fc.sqlToPandas(sql_lojas)

        lojas_d = ['IGU_D', 'BEL_D', 'WEB_D']

        df_lojas_d = pd.DataFrame(lojas_d, columns=['Empresa'])

        df = pd.concat([df, df_lojas_d], ignore_index=True)

        fc.saveCSV(df, 'lojas')
        fc.saveCSV_compression(df, 'lojas_gzip', 'gzip')
        fc.sendToFTP('lojas')
        fc.sendToFTP('lojas_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Lojas', e)


def vendasWEB():
    print("\n")
    try:
        start_time = time.time()

        print('Vendas WEB')
        df = fc.sqlToPandas(sql_vendas_Web)
        fc.saveCSV(df, 'vendas_web')
        fc.saveCSV_compression(df, 'vendas_web_gzip', 'gzip')
        fc.sendToFTP('vendas_web')
        fc.sendToFTP('vendas_web_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Vendas')


def vendas_bruto():

    print("\n")

    try:
        start_time = time.time()

        print('Vendas Bruto')

        df = fc.sqlToPandas(sql_vendas)

        fc.saveCSV(df, 'vendas_bruto')
        fc.saveCSV_compression(df, 'vendas_bruto_gzip', 'gzip')

        print('Processo completo, executado em %s segundos ---' % (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Vendas', e)


def vendas_old():

    print("\n")

    try:
        start_time = time.time()

        print('Vendas')

        df = fc.sqlToPandas(sql_vendas)
        df['Data'] = pd.to_datetime(df['Data'])
        df['Primeira Compra bi'] = df.groupby('Cod. Cliente')['Data'].transform('min')
        df['Ultima Compra bi'] = df.groupby('Cod. Cliente')['Data'].transform('max')
        df['Ano ultima compra bi'] = df['Ultima Compra bi'].dt.year

        df['Ultima compra label'] = np.where(df['Ultima Compra bi'] == df['Data'], 'Ultima compra', '')

        df = df.sort_values(['Cod. Cliente', 'Data'])

        df['Primeira_Compra_Dt'] = df.groupby('Cod. Cliente')['Data'].transform('min')
        df['Primeira_Compra_Dt'] = pd.to_datetime(df['Primeira_Compra_Dt'], errors='coerce')
        df['Ano_Ultima_Compra'] = df['Primeira_Compra_Dt'].dt.year
        df['Primeira_Compra'] = np.where(df['Primeira_Compra_Dt'] == df['Data'], 'Primeira compra', '')

        df['Ultima_Compra_Dt'] = df.groupby('Cod. Cliente')['Data'].transform('max')
        df['Ultima_Compra_Dt'] = pd.to_datetime(df['Ultima_Compra_Dt'], errors='coerce')
        df['Ano_Ultima_Compra'] = df['Ultima_Compra_Dt'].dt.year
        df['Ultima_Compra'] = np.where(df['Ultima_Compra_Dt'] == df['Data'], 'Ultima compra', '')

        df['Dias_Ultima_Compra'] = (pd.to_datetime('today') - df['Ultima_Compra_Dt']).dt.days

        print('Quantidade de registros', len(df))

        fc.saveCSV(df, 'vendas')
        fc.saveCSV_compression(df, 'vendas_gzip', 'gzip')
        fc.sendToFTP('vendas')
        fc.sendToFTP('vendas_gzip')

        # fc.save_parquet(df, 'vendas')
        # fc.send_to_ftp_parquet('vendas')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Vendas', e)


def vendas():

    print("\n")

    try:
        start_time = time.time()

        print('Vendas')

        # print('Lendo CSV vendas_gzip')
        # df_vendas = fc.readCSV_compression('vendas_bruto_gzip', 'gzip')

        # hoje = pd.to_datetime('today')
        # quinze_dias_atras = hoje - pd.Timedelta(days=15)
        # df_vendas['Data'] = pd.to_datetime(df_vendas['Data'], errors='coerce')
        # df_vendas_ultimos_15_dias = df_vendas[df_vendas['Data'] >= quinze_dias_atras]

        df = fc.sqlToPandas(sql_vendas)
        # df = fc.sqlToPandas(sql_vendasNdias)

        # df = pd.concat([df_vendas_ultimos_15_dias, df], ignore_index=True)
        # df['Data'] = pd.to_datetime(df['Data'], errors='coerce')
        # df = df.sort_values(['Data'], ascending=False).reset_index(drop=True)
        # df = df.drop_duplicates(subset=['ID_Drop'], keep='last')

        # df_vendas = df_vendas[~df_vendas['ID_Drop'].isin(
        #     df_vendas_ultimos_15_dias['ID_Drop'])]

        # df = pd.concat([df_vendas, df], ignore_index=True)
        df['Data'] = pd.to_datetime(df['Data'], errors='coerce')
        df = df.sort_values(['Data'], ascending=False).reset_index(drop=True)

        fc.saveCSV(df, 'vendas_bruto')
        fc.saveCSV_compression(df, 'vendas_bruto_gzip', 'gzip')
        # fc.sendToFTP('vendas_bruto')
        # fc.sendToFTP('vendas_bruto_gzip')

        print('Processo completo, executado em %s segundos ---' % (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Vendas', e)


def vendas_filtros():

    try:

        df = fc.readCSV_compression('vendas_gzip', 'gzip')

        df['Data'] = pd.to_datetime(df['Data'], errors='coerce')
        df = df.sort_values(['Cod. Cliente', 'Data'])

        df['Primeira_Compra_Dt'] = df.groupby(
            'Cod. Cliente')['Data'].transform('min')
        df['Primeira_Compra_Dt'] = pd.to_datetime(
            df['Primeira_Compra_Dt'], errors='coerce')

        df['Primeira_Compra'] = np.where(
            df['Primeira_Compra_Dt'] == df['Data'], 'Primeira compra', '')

        df['Ultima_Compra_Dt'] = df.groupby(
            'Cod. Cliente')['Data'].transform('max')
        df['Ultima_Compra_Dt'] = pd.to_datetime(
            df['Ultima_Compra_Dt'], errors='coerce')

        df['Ano_Ultima_Compra'] = df['Ultima_Compra_Dt'].dt.year

        df['Ultima_Compra'] = np.where(
            df['Ultima_Compra_Dt'] == df['Data'], 'Ultima compra', '')

        df['Dias_Ultima_Compra'] = (pd.to_datetime('today') - df['Ultima_Compra_Dt']).dt.days

        # df['compraAnterior'] = df.groupby(['Cod. Cliente'])['Data'].shift()

        # df['Data'] = pd.to_datetime(df['Data'])
        # df['compraAnterior'] = pd.to_datetime(df['compraAnterior'])
        # df['Primeira_Compra_Dt'] = pd.to_datetime(vendas['Primeira_Compra_Dt'])

        # df['Dias_entre_compras'] = (df['Data'] - df['compraAnterior']).dt.days
        # df['Dias_entre_compras'] = df['Dias_entre_compras'].fillna(0)
        # df['Dias_entre_compras'] = df['Dias_entre_compras'].astype(int)

        # df['DiasPrimeiraCompra'] = (
        #     df['Data'] - df['Primeira_Compra_Dt']).dt.days

        # df['TipoCliente'] = np.where(df['DiasPrimeiraCompra'] < 30, 'Novo',
        #                                  np.where(df['Dias_entre_compras'] <= 365, 'Recorrente',
        #                                           np.where(df['Dias_entre_compras'] > 365, 'Resgaste', 'Outro')))

        # df['Faixa de valor'] = np.where(df['Total Liq.'] <= 2000, '0-2000',
        #                     np.where(df['Total Liq.'] <= 5000, '2000-5000',
        #                     np.where(df['Total Liq.'] <= 10000, '5000-10000',
        #                     np.where(df['Total Liq.'] <= 20000, '10000-20000',
        #                     np.where(df['Total Liq.'] <= 50000, '20000-50000',
        #                     np.where(df['Total Liq.'] <= 100000, '50000-100000',
        #                     np.where(df['Total Liq.'] <= 200000, '100000-200000',
        #                     np.where(df['Total Liq.'] <= 500000, '200000-500000',
        #                     np.where(df['Total Liq.'] <= 1000000, '500000-1000000', '> 1000000')))))))))

        idToExclude = ['CWEB000572-2023-12-18', 'CWEB000572-2023-12-15']

        df = df[~df['ID_Venda'].isin(idToExclude)]

        fc.saveCSV(df, 'vendas')
        fc.saveCSV_compression(df, 'vendas_gzip', 'gzip')
        fc.sendToFTP('vendas')
        fc.sendToFTP('vendas_gzip')

        fc.save_parquet(df, 'vendas')
        fc.send_to_ftp_parquet('vendas')

    except Exception as e:
        print('Erro ao exportar Vendas', e)


def vendas_bi():

    print("\n")
    try:
        start_time = time.time()

        print('Vendas BI')
        df = fc.readCSV_compression('vendas_gzip', 'gzip')
        df = df[df['Grande Grupo'] == 'PA']
        df['Data'] = pd.to_datetime(df['Data'], errors='coerce')

        meses3 = pd.to_datetime('today') - pd.DateOffset(months=3)
        meses3 = meses3.strftime('%Y-%m-%d')

        # df = df[(df['Data'] >= '2020-01-01')]
        df['Total Liq.'] = df['Total Liq.'].str.replace(',00', '').astype(int)
        df['Qtd'] = df['Qtd'].astype(int)

        df_online = df.copy()
        df_online['Qtde_Empresas'] = df_online.groupby(['Cod. Cliente'])['Empresa'].transform('nunique')
        df_online['Cliente_Online'] = np.where( (df_online['Qtde_Empresas'] == 1) & (df_online['Empresa'] == 'WEB'), 'Online', 'Loja')
        df_online = df_online.drop_duplicates(subset=['Cod. Cliente', 'Cliente_Online'])
        df_online = df_online[['Cod. Cliente', 'Cliente_Online']]

        df_copy = df.copy()
        df_copy = df_copy.sort_values(['Total Liq.'], ascending=[True])

        df_tickets = df_copy.groupby(['Cod. Cliente'])['ID_Venda'].unique().reset_index(name='Tickets')
        df_tickets['Tickets'] = df_tickets['Tickets'].str.len()

        df_total = df_copy.groupby(['Cod. Cliente', 'Data'])['Total Liq.'].sum().reset_index(name='Total Liq.')

        df_mean = df_total.groupby(['Cod. Cliente'])['Total Liq.'].mean().reset_index(name='Media')
        df_mean = df_mean.sort_values(['Cod. Cliente'], ascending=[True])
        df_mean['Media'] = df_mean['Media'].astype(int)

        df_median = df_total.groupby(['Cod. Cliente'])['Total Liq.'].median().reset_index(name='Mediana')
        df_median = df_median.sort_values(['Cod. Cliente'], ascending=[True])
        df_median['Mediana'] = df_median['Mediana'].astype(int)

        df_std = df_total.groupby(['Cod. Cliente'])['Total Liq.'].std().reset_index(name='Desvio Padrao')
        df_std = df_std.sort_values(['Cod. Cliente'], ascending=[True])
        df_std['Desvio Padrao'] = df_std['Desvio Padrao'].fillna(0).astype(int)

        df_total = df_total.groupby(['Cod. Cliente'])['Total Liq.'].sum().reset_index(name='Total Liq.')

        df_final = df_mean.merge(df_median, on='Cod. Cliente', how='left')
        df_final = df_final.merge(df_std, on='Cod. Cliente', how='left')
        df_final = df_final.merge(df_tickets, on='Cod. Cliente', how='left')
        df_final = df_final.merge(df_total, on='Cod. Cliente', how='left')
        df_final['coeficiente de variação'] = df_final['Desvio Padrao'] / df_final['Media']

        df = df[['Cod. Cliente', 'Data']]
        df = df.sort_values(['Cod. Cliente', 'Data']).reset_index(drop=True)
        df = df.groupby(['Cod. Cliente', 'Data']).size().reset_index(name='Qtd')
        df = df.drop(['Qtd'], axis=1)
        df['compraAnterior'] = df.groupby(['Cod. Cliente'])['Data'].shift()
        df['Dias entre compras'] = (df['Data'] - df['compraAnterior']).dt.days
        df['Dias entre compras'] = df['Dias entre compras'].fillna(0).astype(int)
        df['Primeira Compra'] = df.groupby('Cod. Cliente')['Data'].transform('min')
        df['Ultima Compra'] = df.groupby('Cod. Cliente')['Data'].transform('max')
        df['Ano ultima compra'] = df['Ultima Compra'].dt.year
        df['Ultima compra label'] = np.where(df['Ultima Compra'] == df['Data'], 'Ultima compra', '')
        df['Dias da ultima compra'] = (pd.to_datetime('today') - df['Data']).dt.days
        df['Anos de marca'] = (pd.to_datetime('today').year - df['Primeira Compra'].dt.year).astype(int)
        df['Anos desde Primeira compra'] = (df['Data'].dt.year - df['Primeira Compra'].dt.year).astype(int)

        df = df[(df['Data'] >= '2020-01-01')]

        df['Status cliente'] = (
            np.where((df['Anos desde Primeira compra'] <= 1) & (df['Dias entre compras'] <= 365), 'Aquisição',
            np.where((df['Anos desde Primeira compra'] <= 2) & (df['Dias entre compras'] > 0) & (df['Dias da ultima compra'] <= 365), 'Retenção',
            np.where((df['Anos de marca'] <= 1) & (df['Dias da ultima compra'] >= 0 & (df['Dias da ultima compra'] <= 365)), 'Aquisição',
            np.where((df['Anos de marca'] <= 2) & (df['Dias entre compras'] > 0) & (df['Dias da ultima compra'] <= 365), 'Retenção',
            np.where((df['Anos de marca'] >= 3) & (df['Dias da ultima compra'] >= 0) & (df['Dias da ultima compra'] <= 365), 'Resgate',
            np.where((df['Dias da ultima compra'] >= 730), 'Perdido',
            np.where((df['Dias da ultima compra'] >= 545), 'Risco',
            np.where((df['Dias da ultima compra'] >= 365), 'Acompanhar','Outros')))))))))

        df = df.merge(df_online, on='Cod. Cliente', how='left')
        df = df.sort_values(['Data'], ascending=False).reset_index(drop=True)

        df = df[df['Ultima compra label'] == 'Ultima compra'].reset_index(drop=True)

        df = df.merge(df_final, on='Cod. Cliente', how='left')

        # df['Media'] = df['Media'].astype(str).str.replace('.0', '')
        # df['Mediana'] = df['Mediana'].astype(str).str.replace('.0', '')
        # df['Desvio Padrao'] = df['Desvio Padrao'].astype(str).str.replace('.0', '')
        # df['Tickets'] = df['Tickets'].astype(str).str.replace('.0', '')
        # df['Total Liq.'] = df['Total Liq.'].astype(str).str.replace('.0', '')

        df['Media'] = df['Media'].fillna(0).astype(int)
        df['Mediana'] = df['Mediana'].fillna(0).astype(int)
        df['Desvio Padrao'] = df['Desvio Padrao'].fillna(0).astype(int)
        df['Tickets'] = df['Tickets'].fillna(0).astype(int)
        df['Total Liq.'] = df['Total Liq.'].fillna(0).astype(int)

        df['Segmentos_Clientes'] = (
            np.where((df['Cliente_Online'] == 'Online') & (df['Media'] <= 5000), '01. Ate 5k',
            np.where((df['Cliente_Online'] == 'Online') & (df['Media'] > 5000) & (df['Media'] <= 15000), '02. 5k a 15k',
            np.where((df['Cliente_Online'] == 'Online') & (df['Media'] > 15000), '03. Acima de 15k',
            np.where((df['Cliente_Online'] == 'Loja') & (df['Media'] <= 10000), '01. Ate 10k',
            np.where((df['Cliente_Online'] == 'Loja') & (df['Media'] > 10000) & (df['Media'] <= 30000), '02. 10k a 30k',
            np.where((df['Cliente_Online'] == 'Loja') & (df['Media'] > 30000), '03. Acima de 30k', 'Outros')))))))

        df = df[df['Media'] > 0].reset_index(drop=True)

        fc.saveCSV(df, 'vendas_bi')
        fc.saveCSV_compression(df, 'vendas_bi_gzip', 'gzip')
        fc.sendToFTP('vendas_bi')
        fc.sendToFTP('vendas_bi_gzip')

        print('Processo completo, executado em %s segundos ---' % (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Vendas', e)


def vendas_crm():

    print("\n")
    try:
        start_time = time.time()

        print('Vendas CRM')
        df = fc.readCSV_compression('vendas_gzip', 'gzip')
        df = df[df['Grande Grupo'] == 'PA']
        df['Data'] = pd.to_datetime(df['Data'])
        df['Total Liq.'] = df['Total Liq.'].str.replace(',00', '').astype(int)
        df['Qtd'] = df['Qtd'].astype(int)

        df_online = df.copy()
        df_online['Qtde_Empresas'] = df_online.groupby(['Cod. Cliente'])['Empresa'].transform('nunique')
        df_online['Cliente_Online'] = np.where( (df_online['Qtde_Empresas'] == 1) & (df_online['Empresa'] == 'WEB'), 'Online', 'Loja')
        df_online = df_online.drop_duplicates(subset=['Cod. Cliente', 'Cliente_Online'])
        df_online = df_online[['Cod. Cliente', 'Cliente_Online']]

        df_copy = df.copy()
        df_copy = df_copy.sort_values(['Total Liq.'], ascending=[True])

        df = df[['Cod. Cliente', 'Data', 'Cod. Vend.', 'Consultora']]
        df = df.sort_values(['Cod. Cliente', 'Data']).reset_index(drop=True)
        df = df.groupby(['Cod. Cliente', 'Data', 'Cod. Vend.', 'Consultora']).size().reset_index(name='Qtd')
        df = df.drop(['Qtd'], axis=1)
        df['compraAnterior'] = df.groupby(['Cod. Cliente'])['Data'].shift()
        df['Dias entre compras'] = (df['Data'] - df['compraAnterior']).dt.days
        df['Dias entre compras'] = df['Dias entre compras'].fillna(0).astype(int)
        df['Primeira Compra'] = df.groupby('Cod. Cliente')['Data'].transform('min')
        df['Ultima Compra'] = df.groupby('Cod. Cliente')['Data'].transform('max')
        df['Ano ultima compra'] = df['Ultima Compra'].dt.year
        df['Ultima compra label'] = np.where(df['Ultima Compra'] == df['Data'], 'Ultima compra', '')
        df['Dias da ultima compra'] = (pd.to_datetime('today') - df['Data']).dt.days
        df['Anos de marca'] = (pd.to_datetime('today').year - df['Primeira Compra'].dt.year).astype(int)
        df['Anos desde Primeira compra'] = (df['Data'].dt.year - df['Primeira Compra'].dt.year).astype(int)

        df['Status cliente'] = (
            np.where((df['Anos desde Primeira compra'] <= 1) & (df['Dias entre compras'] <= 365), 'Aquisição',
            np.where((df['Anos desde Primeira compra'] <= 2) & (df['Dias entre compras'] > 0) & (df['Dias da ultima compra'] <= 365), 'Retenção',
            np.where((df['Anos de marca'] <= 1) & (df['Dias da ultima compra'] >= 0 & (df['Dias da ultima compra'] <= 365)), 'Aquisição',
            np.where((df['Anos de marca'] <= 2) & (df['Dias entre compras'] > 0) & (df['Dias da ultima compra'] <= 365), 'Retenção',
            np.where((df['Anos de marca'] >= 3) & (df['Dias da ultima compra'] >= 0) & (df['Dias da ultima compra'] <= 365), 'Resgate',
            np.where((df['Dias da ultima compra'] >= 730), 'Perdido',
            np.where((df['Dias da ultima compra'] >= 545), 'Risco', 'Outros'))))))))

        df = df.merge(df_online, on='Cod. Cliente', how='left')
        df = df.sort_values(['Data'], ascending=False).reset_index(drop=True)

        fc.saveCSV(df, 'vendas_crm')
        fc.saveCSV_compression(df, 'vendas_crm_gzip', 'gzip')
        fc.sendToFTP('vendas_crm')
        fc.sendToFTP('vendas_crm_gzip')

        print('Processo completo, executado em %s segundos ---' % (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Vendas', e)


def vendas_ai():

    df = fc.readCSV_compression('vendas_gzip', 'gzip')
    df['Data'] = pd.to_datetime(df['Data'])
    df = df[df['Grande Grupo'] != 'AD']
    colunas = ['Empresa', 'Data', 'Cod. Cliente', 'Nome Cliente',
            'Consultora', 'Cod. Prod.', 'Qtd', 'Total Liq.', 'Desconto']
    df = df[colunas]
    df['ID_Pedido'] = df['Cod. Cliente'] + df['Data'].astype(str)
    df = df.rename(columns={'Empresa': 'Loja', 'Cod. Cliente': 'Cod_Cliente',
                'Cod. Prod.': 'Cod_Produto', 'Total Liq.': 'Total_Liq'})

    df['Total_Liq'] = df['Total_Liq'].astype(int)
    df['Desconto'] = df['Desconto'].astype(int)

    df = df.sort_values(by='Data', ascending=False)

    # df = df[~df['Cod_Produto'].str.contains('C')]
    # df = df[~df['Cod_Produto'].str.contains('FRETE')]

    fc.saveCSV_ai(df, 'vendas_ai')
    fc.saveCSV_ai_compression(df, 'vendas_ai_gzip', 'gzip')
    # fc.sendToFTP('vendas_ai')
    # fc.sendToFTP('vendas_ai_gzip')

    return df


def vendas_ontem():

    df = fc.readCSV_compression('vendas_gzip', 'gzip')
    df = df[df['Grande Grupo'] == 'PA']
    df['Data'] = pd.to_datetime(df['Data'])

    df = df[df['Data'] == (pd.to_datetime('today') - pd.DateOffset(days=1)).normalize()]

    fc.saveCSV(df, 'vendas_ontem')
    fc.saveCSV_compression(df, 'vendas_ontem_gzip', 'gzip')
    fc.sendToFTP('vendas_ontem')
    fc.sendToFTP('vendas_ontem_gzip')


def vendas_3meses():

    print('Vendas 3 meses')

    df = fc.readCSV_compression('vendas_gzip', 'gzip')

    print('Quantidade de registros', len(df))

    df = df[df['Grande Grupo'] == 'PA']
    df['Data'] = pd.to_datetime(df['Data'])

    data_limite = datetime.now() - timedelta(days=90)
    df = df[df['Data'] >= data_limite]

    # rename Cod. Cliente to Cod_Cliente e Cod. Vend. to Cod_Vend
    df = df.rename(columns={'Cod. Cliente': 'Cod_Cliente', 'Cod. Vend.': 'Cod_Vend'})

    df = df.drop_duplicates(subset=['ID_Venda'], keep='last')
    colunas = ['Data', 'Cod_Cliente', 'Nome Cliente',
               'Cod_Vend', 'Consultora', 'Empresa', 'ID_Venda']

    df = df[colunas]

    # df = df[df['Data'] == (pd.to_datetime('today') - pd.DateOffset(days=90)).normalize()]

    print('Quantidade de registros', len(df))

    fc.saveCSV(df, 'vendas_3meses')
    fc.saveCSV_compression(df, 'vendas_3meses_gzip', 'gzip')
    fc.sendToFTP('vendas_3meses')
    fc.sendToFTP('vendas_3meses_gzip')


def vendas_tipo_cliente():

    print("\n")

    try:
        start_time = time.time()

        print('Vendas')
        df = fc.readCSV_compression('vendas_gzip', 'gzip')
        df['Data'] = pd.to_datetime(df['Data'])
        df = df[['Data', 'Cod. Cliente', 'Empresa']]
        df = df.rename(columns={'Cod. Cliente': 'Cod_Cliente'})

        # Update the classification logic to include "Ambos"
        customer_store_info = (
            df.groupby('Cod_Cliente')['Empresa']
            .apply(lambda x: set(x))
            .reset_index(name='Empresas')
        )

        def classify_customer(stores):
            if stores == {'WEB'}:
                return 'Online'
            elif 'WEB' in stores and len(stores) > 1:
                return 'Ambos'
            else:
                return 'Fisica'

        # Apply the new classification logic
        customer_store_info['Tipo_Cliente'] = customer_store_info['Empresas'].apply(
            classify_customer)

        # Merge with the last purchase date
        customer_last_purchase = (
            df.groupby('Cod_Cliente')['Data']
            .max()
            .reset_index(name='Ultima_Compra')
        )
        customer_store_info = customer_store_info.merge(
            customer_last_purchase, on='Cod_Cliente')

        # Drop the intermediate 'Empresas' column
        customer_store_info = customer_store_info.drop(columns=['Empresas'])

        fc.saveCSV(customer_store_info, 'tipo_cliente')
        fc.saveCSV_compression(customer_store_info, 'tipo_cliente_gzip', 'gzip')
        fc.sendToFTP('tipo_cliente')
        fc.sendToFTP('tipo_cliente_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Vendas', e)
