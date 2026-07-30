# from sklearn.cluster import KMeans
# from sklearn.preprocessing import OneHotEncoder
# from sklearn.preprocessing import LabelEncoder, StandardScaler
import time
import traceback
from datetime import datetime as dt
from warnings import simplefilter

import funcoes_comuns as fc
import numpy as np
import pandas as pd

simplefilter(action='ignore', category=FutureWarning)
simplefilter(action='ignore', category=Warning)

# SQL Clientes
sql_clientes = 'sql/clientes/clientes.sql'
sql_clientes_all = 'sql/clientes/clientes_all.sql'
sql_clientes_origem = 'sql/clientes/clientes_origem.sql'
sql_clientes_hist = 'sql/clientes/clientes_hist.sql'
sql_clientes_rfv = 'sql/clientes/clientes_rfv.sql'
sql_funcionarios = 'sql/clientes/funcionarios.sql'


def consultas_clientes():

    clientesRfv2()
    clientes()
    clientes_ai()
    clientes_all()
    # clientesOrigem()
    # clientesRfv2()
    # clientesrfv()
    funcionarios()


def clientes():
    print("\n")
    try:
        start_time = time.time()

        print('Clientes')
        df = fc.sqlToPandas(sql_clientes)
        df = df.drop(columns=['Ultima Compra'])

        regioes = {
            'AC': 'Norte',
            'AL': 'Nordeste',
            'AP': 'Norte',
            'AM': 'Norte',
            'BA': 'Nordeste',
            'CE': 'Nordeste',
            'DF': 'Centro-Oeste',
            'ES': 'Sudeste',
            'GO': 'Centro-Oeste',
            'MA': 'Nordeste',
            'MT': 'Centro-Oeste',
            'MS': 'Centro-Oeste',
            'MG': 'Sudeste',
            'PA': 'Norte',
            'PB': 'Nordeste',
            'PR': 'Sul',
            'PE': 'Nordeste',
            'PI': 'Nordeste',
            'RJ': 'Sudeste',
            'RN': 'Nordeste',
            'RS': 'Sul',
            'RO': 'Norte',
            'RR': 'Norte',
            'SC': 'Sul',
            'SP': 'Sudeste',
            'SE': 'Nordeste',
            'TO': 'Norte'}

        df['Regiao'] = df['Estado'].map(regioes)

        vendas = fc.readCSV_compression('vendas_gzip', 'gzip')

        vendas = vendas[vendas['Grande Grupo'] == 'PA']

        ultimaConsultora = vendas[['Data', 'Cod. Cliente', 'Consultora']].sort_values(by=['Cod. Cliente', 'Data'], ascending=True).drop_duplicates(
            subset=['Cod. Cliente'], keep='last').sort_values(
                by=['Cod. Cliente'], ascending=True)
        ultimaConsultora = ultimaConsultora[['Cod. Cliente', 'Consultora']].rename( columns={'Consultora': 'Consultora_UltimaCompra'})

        df = df.join(ultimaConsultora.set_index('Cod. Cliente'), on='Cod_Cliente', how='left')

        ultimaCompra = vendas.groupby(['Cod. Cliente'], as_index=False).agg({'Data': 'max'}).rename( columns={'Data': 'Ultima_Compra'})
        df = df.join(ultimaCompra.set_index('Cod. Cliente'), on='Cod_Cliente', how='left')

        media_idade = df['Idade'].mean()
        df['Idade'] = df['Idade'].fillna(media_idade).astype(int)

        df['Faixa_Etaria'] = pd.cut(df['Idade'], bins=[20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 99], labels=[
                                  '20-25', '25-30', '30-35', '35-40', '40-45', '45-50', '50-55', '55-60', '60-65', '65-70', '70-75', '75+'])

        # maxAnos = df['Anos_Marca'].max()
        df['Faixa_Anos_Marca'] = pd.cut(df['Anos_Marca'], bins=[0, 1, 2, 4, 6, 8, 10, 14, 20], labels=[
                                        '0-1', '1-2', '2-4', '4-6', '6-8', '8-10', '10-15', '15+'], right=False, include_lowest=True)



        df['Sexo_peso'] = np.where(df['Sexo'].isnull(), 0, 1)
        df['Estado Civil_peso'] = np.where(df['Estado Civil'].isnull(), 0, 1)
        df['CPF_peso'] = np.where(df['CPF'].isnull(), 0, 1)
        df['Data Nascimento_peso'] = np.where(df['Data Nascimento'].isnull(), 0, 1)
        df['DDD_peso'] = np.where(df['DDD'].isnull(), 0, 1)
        df['Telefone_peso'] = np.where(df['Telefone'].isnull(), 0, 1)
        df['Email_peso'] = np.where(df['Email'].isnull(), 0, 1)
        df['CEP_peso'] = np.where(df['CEP'].isnull(), 0, 1)
        df['Numero_peso'] = np.where(df['Numero'].isnull(), 0, 1)
        df['Complemento_peso'] = np.where(df['Complemento'].isnull(), 0, 1)

        df['percentual'] = df['Sexo_peso'] + df['Estado Civil_peso'] + df['CPF_peso'] + df['Data Nascimento_peso'] + df['DDD_peso'] + df['Telefone_peso'] + df['Email_peso'] + df['CEP_peso'] + df['Numero_peso'] + df['Complemento_peso']
        df['percentual'] = (df['percentual'] / 10)
        df['Qualidade Cadastro'] = df['percentual'].apply(lambda x: round(x, 2))
        df = df.drop(columns=[col for col in df if col.endswith('_peso')])
        df = df.drop(columns=['percentual'])

        df['Tel_Qtd_Carac'] = df['Telefone'].str.len().fillna(0).astype(int)

        rfv_results = fc.readCSV_compression('clientes_rfv_2_gzip', 'gzip')
        colunas_rfv = ['Cod. Cliente', 'CLUSTER', 'Cluster frequencia',
                       'Tipo cliente', 'Qtd tickets', 'Media entre compras', 'Dias ultima compra']
        rfv_results = rfv_results[colunas_rfv]

        df = pd.merge(df, rfv_results, left_on='Cod_Cliente', right_on='Cod. Cliente', how='left')
        df = df.drop(columns=['Cod. Cliente'])

        df = df[~((df['Qtd_Caracteres_Nome'] <= 10) &
                  (df['Dias ultima compra'] == 0))]

        fc.saveCSV(df, 'clientes')
        fc.saveCSV_compression(df, 'clientes_gzip', 'gzip')

        fc.saveCSV2(df, 'clientes2')
        fc.saveCSV_compression2(df, 'clientes_gzip2', 'gzip')

        fc.sendToFTP('clientes')
        fc.sendToFTP('clientes_gzip')

        fc.sendToFTP('clientes2')
        fc.sendToFTP('clientes_gzip2')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))

    except Exception as e:
        print('Erro ao exportar Clientes', e)


def clientes_all():
    print("\n")
    try:
        start_time = time.time()

        print('Clientes All')
        df = fc.sqlToPandas(sql_clientes_all)
        fc.saveCSV(df, 'clientes_all')
        fc.saveCSV_compression(df, 'clientes_all_gzip', 'gzip')
        fc.sendToFTP('clientes_all')
        fc.sendToFTP('clientes_all_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Clientes All', e)


def clientes_ai():

    df = fc.readCSV_compression('clientes_gzip', 'gzip')
    colunas = ['Cod_Cliente', 'Nome', 'Sexo', 'Estado Civil', 'Data Nascimento', 'Idade', 'Data Casamento',
               'Idade_Casamento', 'Consultora', 'DDD', 'Telefone', 'Email', 'Grupo', 'Cidade', 'Estado', 'VIP', 'Ultima_Compra']
    df = df[colunas]
    df['Idade_Casamento'] = df['Idade_Casamento'].fillna(0).astype(int)

    fc.saveCSV_ai(df, 'clientes_ai')
    fc.saveCSV_ai_compression(df, 'clientes_ai_gzip', 'gzip')

    fc.sendToFTP('clientes_ai')
    fc.sendToFTP('clientes_ai_gzip')

    return df


def clientesOrigem():
    print("\n")
    try:
        start_time = time.time()

        print('Clientes Origem')
        df = fc.sqlToPandas(sql_clientes_origem)
        fc.saveCSV(df, 'clientes_origem')
        fc.saveCSV_compression(df, 'clientes_origem_gzip', 'gzip')
        fc.sendToFTP('clientes_origem')
        fc.sendToFTP('clientes_origem_gzip')
        fc.save_parquet(df, 'clientes_origem')
        fc.send_to_ftp_parquet('clientes_origem')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Clientes Origem', e)


def clientesrfv():
    print("\n")
    try:
        start_time = time.time()

        print('Clientes RFV')
        df = fc.sqlToPandas(sql_clientes_rfv)
        fc.saveCSV(df, 'clientes_rfv')
        fc.saveCSV_compression(df, 'clientes_rfv_gzip', 'gzip')
        fc.sendToFTP('clientes_rfv')
        fc.sendToFTP('clientes_rfv_gzip')

        fc.save_parquet(df, 'clientes_rfv')
        fc.send_to_ftp_parquet('clientes_rfv')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Clientes RFV', e)


def funcionarios():
    print("\n")

    try:
        start_time = time.time()

        print('Funcionarios')
        df = fc.sqlToPandas(sql_funcionarios)
        fc.saveCSV(df, 'funcionarios')
        fc.saveCSV_compression(df, 'funcionarios_gzip', 'gzip')
        fc.sendToFTP('funcionarios')
        fc.sendToFTP('funcionarios_gzip')

        fc.save_parquet(df, 'funcionarios')
        fc.send_to_ftp_parquet('funcionarios')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Funcionarios', e)


def clientesRfv2():
    print("\n")
    try:
        start_time = time.time()

        print('Clientes RFV')
        df = fc.readCSV_compression('vendas_gzip', 'gzip')
        rfv = analyze_rfv(df)

        fc.saveCSV(rfv, 'clientes_rfv_2')
        fc.saveCSV_compression(rfv, 'clientes_rfv_2_gzip', 'gzip')
        fc.sendToFTP('clientes_rfv_2')
        fc.sendToFTP('clientes_rfv_2_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Clientes RFV', e)


def analyze_rfv(df):
    """
    Analyze customer RFV (Recency, Frequency, Value) from sales data.

    Parameters:
    df (pandas.DataFrame): DataFrame with columns similar to the SQL query structure
        Required columns: 'Empresa', 'Data', 'Cod. Cliente', 'Total Liq.', 'Grande Grupo'

    Returns:
    pandas.DataFrame: RFV analysis results with customer segmentation
    """

    # Step 1: Initial data preparation and type conversion
    df = df.copy()

    # filtrar empresa diferente de EXT
    df = df[df['Empresa'] != 'EXT']

    # Convert Data column to datetime
    df['Data'] = pd.to_datetime(df['Data'])

    # Convert numeric columns if needed
    if not np.issubdtype(df['Total Liq.'].dtype, np.number):
        df['Total Liq.'] = pd.to_numeric(df['Total Liq.'].str.replace(',', '.'), errors='coerce')

    # Standardize company names
    company_mapping = {
        'IGL': 'IGU', 'FSM': 'DES', 'BAL': 'BAT', 'CUR': 'BAT',
        'FTH': 'WEB', 'FFL': 'BEL', 'LMA': 'MAT', 'MPV': 'MP2'
    }
    df['Empresa'] = df['Empresa'].str.strip().map(lambda x: company_mapping.get(x, x))

    # Create unique identifiers
    df['ID_Venda'] = df['Cod. Cliente'] + '-' + df['Data'].dt.strftime('%Y-%m-%d')

    # Step 2: Calculate days between purchases
    df['Tipo Compra'] = np.where(df['Empresa'] == 'WEB', 'Online', 'Fisica')
    df = df.sort_values(['Cod. Cliente', 'Data'], ascending=[True, False])
    df['Prxdata'] = df.groupby('Cod. Cliente')['Data'].shift(-1)
    df['DIAS'] = (df['Data'] - df['Prxdata']).dt.days


    # Step 3: Customer aggregation
    customer_stats = df.groupby('Cod. Cliente').agg({
        'Data': ['min', 'max'],
        'Total Liq.': 'sum',
        'ID_Venda': 'nunique',
        'Tipo Compra': 'nunique',
        'DIAS': 'mean'
    }).reset_index()

    customer_stats.columns = [
        'Cod. Cliente', 'Primeira compra', 'Ultima compra',
        'Total liq.', 'Qtd tickets', 'Tipo compra n', 'Media entre compras'
    ]

    # Add tipo compra result
    tipo_compra_result = df.groupby('Cod. Cliente')['Tipo Compra'].last().reset_index()
    customer_stats = customer_stats.merge(tipo_compra_result, on='Cod. Cliente')
    customer_stats['Resultado da compra'] = customer_stats['Tipo Compra']
    customer_stats.drop('Tipo Compra', axis=1, inplace=True)

    # Step 4: Calculate customer type and metrics
    current_date = pd.Timestamp.now()
    customer_stats['Ticket medio'] = customer_stats['Total liq.'] / customer_stats['Qtd tickets']
    customer_stats['Dias ultima compra'] = (current_date - customer_stats['Ultima compra']).dt.days
    customer_stats['Tipo cliente'] = np.where(
        customer_stats['Tipo compra n'] == 2,
        'Ambos',
        np.where(customer_stats['Tipo compra n'] == 1, customer_stats['Resultado da compra'], 'null')
    )

    # Step 5: Calculate RFV scores
    def calculate_recency(row):
        if row['Tipo cliente'] == 'Online':
            if 0 <= row['Dias ultima compra'] <= 365: return 5
            elif 366 <= row['Dias ultima compra'] <= 545: return 4
            elif 546 <= row['Dias ultima compra'] <= 725: return 3
            elif 726 <= row['Dias ultima compra'] <= 1095: return 2
            else: return 1
        else:
            if 0 <= row['Dias ultima compra'] <= 180: return 5
            elif 181 <= row['Dias ultima compra'] <= 365: return 4
            elif 366 <= row['Dias ultima compra'] <= 730: return 3
            elif 731 <= row['Dias ultima compra'] <= 1095: return 2
            else: return 1

    def calculate_frequency(row):
        if row['Tipo cliente'] == 'Online':
            if row['Qtd tickets'] == 1: return 1
            elif 2 <= row['Qtd tickets'] <= 3: return 2
            elif row['Qtd tickets'] == 4: return 3
            elif row['Qtd tickets'] == 5: return 4
            else: return 5
        else:
            if row['Qtd tickets'] == 1: return 1
            elif 2 <= row['Qtd tickets'] <= 4: return 2
            elif 5 <= row['Qtd tickets'] <= 7: return 3
            elif 8 <= row['Qtd tickets'] <= 10: return 4
            else: return 5

    def calculate_value(row):
        if row['Tipo cliente'] == 'Online':
            if 0 <= row['Total liq.'] <= 4999: return 1
            elif 5000 <= row['Total liq.'] <= 7999: return 2
            elif 8000 <= row['Total liq.'] <= 11999: return 3
            elif 12000 <= row['Total liq.'] <= 17999: return 4
            else: return 5
        else:
            if 0 <= row['Total liq.'] <= 14999: return 1
            elif 15000 <= row['Total liq.'] <= 34999: return 2
            elif 35000 <= row['Total liq.'] <= 69999: return 3
            elif 70000 <= row['Total liq.'] <= 99999: return 4
            else: return 5

    customer_stats['Recencia'] = customer_stats.apply(calculate_recency, axis=1)
    customer_stats['Frequencia'] = customer_stats.apply(calculate_frequency, axis=1)
    customer_stats['Valor'] = customer_stats.apply(calculate_value, axis=1)

    # Calculate frequency cluster
    def get_frequency_cluster(qtd_tickets):
        if qtd_tickets == 1: return '01-Esporadico'
        elif 2 <= qtd_tickets <= 3: return '02-Ocasional'
        elif 4 <= qtd_tickets <= 5: return '03-Recorrente'
        elif 6 <= qtd_tickets <= 8: return '04-Frequente'
        elif qtd_tickets >= 9: return '05-Consistente'
        return None

    customer_stats['Cluster frequencia'] = customer_stats['Qtd tickets'].apply(get_frequency_cluster)

    # Calculate final cluster
    def get_final_cluster(row):
        r, f, v = row['Recencia'], row['Frequencia'], row['Valor']

        if r >= 5 and f >= 3 and v >= 4:
            return '01.Especial'
        elif 4 <= r <= 5 and 2 <= f <= 5 and 4 <= v <= 5:
            return '02.Muito potencial'
        elif 4 <= r <= 5 and 2 <= f <= 5 and 2 <= v <= 5:
            return '03.Potencial'
        elif 2 <= r <= 3 and 2 <= f <= 5 and 4 <= v <= 5:
            return '06.Nao podemos perde-los'
        elif 3 <= r <= 4 and 2 <= f <= 5 and 2 <= v <= 5:
            return '07.Precisam de atencao'
        elif r == 5 and f == 1 and v <= 3:
            return '04.Novo'
        elif 4 <= r <= 5 and 1 <= f <= 4 and 1 <= v <= 5:
            return '05.Promissor'
        elif 2 <= r <= 3 and 1 <= f <= 5 and 1 <= v <= 5:
            return '08.Prestes a perde-lo'
        elif r == 1 and f <= 5 and v <= 5:
            return '09.Perdido'
        else:
            return 'Nao segmentado'

    customer_stats['CLUSTER'] = customer_stats.apply(get_final_cluster, axis=1)

    # Select and order final columns
    final_columns = [
        'Cod. Cliente', 'Primeira compra', 'Ultima compra', 'Total liq.',
        'Qtd tickets', 'Ticket medio', 'Dias ultima compra', 'Tipo cliente',
        'Recencia', 'Frequencia', 'Valor', 'Cluster frequencia',
        'Media entre compras', 'CLUSTER'
    ]

    return customer_stats[final_columns]
