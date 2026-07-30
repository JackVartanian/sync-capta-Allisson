import datetime
import ftplib
import io
import os
import subprocess
import time
from datetime import date, timedelta
from urllib.parse import urlparse
from warnings import simplefilter

import pandas as pd
import psycopg2
import pymssql
import requests
from dotenv import load_dotenv
from sqlalchemy import create_engine

simplefilter(action='ignore', category=FutureWarning)
simplefilter(action='ignore', category=Warning)

# Carrega as variaveis de ambiente do arquivo .env (na raiz do projeto)
load_dotenv()


def conn_pymssql():
    # Parametros do banco de dados (definidos no arquivo .env)
    server = os.getenv('CAPTA_DB_SERVER')
    database = os.getenv('CAPTA_DB_DATABASE')
    username = os.getenv('CAPTA_DB_USERNAME')
    password = os.getenv('CAPTA_DB_PASSWORD')

    # Criar Conexão com banco de dados
    conn = pymssql.connect(
        server, username, password, database
    )
    return conn


def conn_postgres():
    # URL de conexão (definida no arquivo .env)
    db_url = os.getenv('POSTGRES_URL')

    # Parse da URL
    url = urlparse(db_url)

    # Criar conexão com banco de dados
    conn = psycopg2.connect(
        host=url.hostname,
        port=url.port,
        database=url.path[1:],
        user=url.username,
        password=url.password
    )
    return conn


def conn_ftp():
    """Cria conexao FTP usando as credenciais do arquivo .env."""
    hostname = os.getenv('FTP_HOST')
    username = os.getenv('FTP_USERNAME')
    password = os.getenv('FTP_PASSWORD')

    ftp_server = ftplib.FTP(hostname, username, password)
    ftp_server.encoding = "utf-8"
    return ftp_server


def listar_tabelas_postgres():
    """
    Lista todas as tabelas do banco de dados PostgreSQL
    Retorna um DataFrame com schema e nome das tabelas
    """
    sql = """
    SELECT
        table_schema,
        table_name,
        table_type
    FROM information_schema.tables
    WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY table_schema, table_name;
    """

    conn = conn_postgres()
    df = pd.read_sql(sql, conn)
    conn.close()

    print(f'Total de tabelas encontradas: {len(df)}')
    return df


def estrutura_tabela_postgres(table_name, schema='public'):
    """
    Retorna estrutura de uma tabela PostgreSQL
    Args:
        table_name (str): Nome da tabela
        schema (str): Schema do banco, default 'public'
    Returns:
        pandas.DataFrame: Estrutura da tabela
    """
    sql = f"""
    SELECT
        column_name,
        data_type,
        character_maximum_length,
        is_nullable,
        column_default
    FROM information_schema.columns
    WHERE table_schema = '{schema}'
    AND table_name = '{table_name}'
    ORDER BY ordinal_position;
    """

    try:
        df = postgresToPandas(sql)
        print(f'\nEstrutura da tabela {schema}.{table_name}:')
        return df

    except Exception as e:
        print(f'Erro ao consultar estrutura: {str(e)}')
        raise


def insert_dataframe_postgres(df, table_name, schema='public'):
    """
    Insere um DataFrame no PostgreSQL
    Args:
        df (pandas.DataFrame): DataFrame a ser inserido
        table_name (str): Nome da tabela
        schema (str): Schema do banco, default 'public'
    """
    start_time = time.time()

    try:
        with conn_postgres() as conn:
            print(f'Iniciando inserção de {len(df):,} registros em {schema}.{table_name}')

            df.to_sql(
                name=table_name,
                con=conn,
                schema=schema,
                if_exists='append',
                index=False
            )

            exec_time = round(time.time() - start_time, 2)
            print(f'Inserção concluída em {exec_time}s')

    except Exception as e:
        print(f'Erro ao inserir dados: {str(e)}')
        raise


def postgresToPandas(query):
    """
    Executa uma query no PostgreSQL e retorna um DataFrame
    Args:
        query (str): Query SQL a ser executada
    Returns:
        pandas.DataFrame: Resultado da query
    """
    start_time = time.time()

    try:
        with conn_postgres() as conn:
            df = pd.read_sql(query, conn)
            print(f'Query executada em {round(time.time() - start_time, 2)}s')
            # conn.close()
            return df

    except Exception as e:
        print(f'Erro: {str(e)}')
        raise


def sqlToPandas(sql):
    start_time = time.time()

    print('Executando SQL: ' + sql)
    conn = conn_pymssql()
    query = open(sql, 'r').read()

    print('Executando query no banco de dados')
    df = pd.read_sql(query, conn)

    print('Query executada com sucesso em %s segundos ---' %
          (round(time.time() - start_time, 2)))
    return df


def saveCSV(df, file):
    start_time = time.time()
    df.to_csv('datasets/' + file + '.csv', index=False,
              sep=';', decimal=',', float_format='%.2f')
    print('Arquivo CSV gerado em %s segundos ---' %
          (round(time.time() - start_time, 2)))


def saveCSV_ai(df, file):
    start_time = time.time()
    df.to_csv('ai_datasets/' + file + '.csv', index=False, sep=',')
    print('Arquivo CSV gerado em %s segundos ---' %
          (round(time.time() - start_time, 2)))

# criar uma função para salvar em .txt	text/plain
def saveTXT(df, file):
    start_time = time.time()
    df.to_csv('datasets/' + file + '.txt', index=False,
                sep=';', decimal=',', float_format='%.2f')
    print('Arquivo TXT gerado em %s segundos ---' %
            (round(time.time() - start_time, 2)))


def saveCSV_compression(df, file, compression):
    start_time = time.time()
    df.to_csv('datasets/' + file + '.csv', index=False,
              sep=';', compression=compression)
    print('Arquivo CSV Gzip gerado em %s segundos ---' %
          (round(time.time() - start_time, 2)))


def saveCSV_ai_compression(df, file, compression):
    start_time = time.time()
    df.to_csv('ai_datasets/' + file + '.csv', index=False,
              sep=',', compression=compression)
    print('Arquivo CSV Gzip gerado em %s segundos ---' %
          (round(time.time() - start_time, 2)))


def saveCSV2(df, file):
    start_time = time.time()
    df.to_csv('datasets/' + file + '.csv', index=False,
              sep='$', decimal=',', float_format='%.2f')
    print('Arquivo CSV gerado em %s segundos ---' %
          (round(time.time() - start_time, 2)))


def saveCSV_compression2(df, file, compression):
    start_time = time.time()
    df.to_csv('datasets/' + file + '.csv', index=False,
              sep='$', compression=compression)
    print('Arquivo CSV Gzip gerado em %s segundos ---' % (round(time.time() - start_time, 2)))


def readCSV(file):
    df = pd.read_csv('datasets/' + file + '.csv', sep=';', engine='pyarrow')
    return df


def readCSV_compression(file, compression):
    df = pd.read_csv('datasets/' + file + '.csv', sep=';', engine='pyarrow', compression=compression)
    return df


def readCSV2(file):
    df = pd.read_csv('datasets/' + file + '.csv', sep='$',
                     engine='pyarrow')
    return df


def readCSV_compression2(file, compression):
    df = pd.read_csv('datasets/' + file + '.csv', sep='$',
                     engine='pyarrow', compression=compression)
    return df


def readCSV_str(file):
    df = pd.read_csv('datasets/' + file + '.csv', sep=';',dtype=str,
                     engine='pyarrow')
    return df


def vendas_helena():
    url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRdZuUOa3HmlD3IcwufAPxnA-E3QKGYIKPa6UmhqlQ9hChcZ4cH-UE3ZYNiw2Gc4r03AGm9-VVuv8oe/pub?gid=0&single=true&output=csv"
    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:66.0) Gecko/20100101 Firefox/66.0"}
    response = requests.get(url, headers=headers)
    df = pd.read_csv(io.BytesIO(response.content), sep=",", low_memory=True)
    df = df[df['Cod. Cliente'].notna()]
    df['ID_Venda'] = df['Cod. Cliente'].astype(
        str) + '-' + df['Data'].astype(str)
    df['Venda_Helena'] = 'Venda_Helena'
    return df


def sendToFTP(filename):

    start_time = time.time()

    ftp_server = conn_ftp()

    file = open('datasets/' + filename + '.csv', 'rb')

    ftp_server.storbinary('STOR ' + filename + '.csv', file, 102400)

    ftp_server.quit()

    print('Arquivo CSV enviado para o FTP em %s segundos ---' %
          (round(time.time() - start_time, 2)))

# enviar para o FTP em formato .txt	text/plain
def sendToFTP_txt(filename):

    start_time = time.time()

    ftp_server = conn_ftp()
    file = open('datasets/' + filename + '.txt', 'rb')
    ftp_server.storbinary('STOR ' + filename + '.txt', file, 102400)
    ftp_server.quit()

    print('Arquivo TXT enviado para o FTP em %s segundos ---' %
            (round(time.time() - start_time, 2)))


def sendToFTP_xlsx(filename):

    start_time = time.time()

    ftp_server = conn_ftp()

    file = open('datasets/' + filename + '.xlsx', 'rb')

    ftp_server.storbinary('STOR ' + 'Fresh/' +
                          filename + '.xlsx', file, 102400)

    ftp_server.quit()

    print('Arquivo CSV enviado para o FTP em %s segundos ---' %
          (round(time.time() - start_time, 2)))


def calendario():

    try:
        start_time = time.time()

        # get the current date

        today = datetime.datetime.now().date()
        today = time.strftime("%Y/%m/%d")
        date_range = pd.date_range(start='1999/1/1', end=today)
        print('Menor data: ' + str(date_range.min()))
        print('Maior data: ' + str(date_range.max()))
        df = date_range.to_frame(index=False)
        df.rename(columns={0: "date"}, inplace=True)

        df['year'] = df['date'].dt.year
        df['month'] = df['date'].dt.month
        df['day'] = df['date'].dt.day
        df['day_name'] = df['date'].dt.day_name()
        df['month_name'] = df['date'].dt.month_name()
        df['days_in_month'] = df['date'].dt.days_in_month
        df['month_abr'] = df['date'].dt.strftime('%b')
        df['day_month'] = df['date'].dt.strftime('%d-%m')
        df['year_month'] = df['date'].dt.strftime('%Y-%m')

        df['month_name'] = df['month_name'].replace(
            ['January', 'February', 'March', 'April', 'May', 'June', 'July',
                'August', 'September', 'October', 'November', 'December'],
            ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'])

        df['month_abr'] = df['month_abr'].replace(
            ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
            ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'])

        df['day_name'] = df['day_name'].replace(
            ['Monday', 'Tuesday', 'Wednesday', 'Thursday',
                'Friday', 'Saturday', 'Sunday'],
            ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'])

        df.rename(columns={'date': 'Data', 'year': 'Ano', 'month': 'Mes', 'day': 'Dia', 'day_name': 'Nome do Dia', 'month_name': 'Nome do Mes',
                           'days_in_month': 'Dias do Mes', 'month_abr': 'Mes Abr.', 'day_month': 'Dia_Mes', 'year_month': 'Ano_Mes'}, inplace=True)

        saveCSV(df, 'calendario')
        saveCSV_compression(df, 'calendario_gzip', 'gzip')
        sendToFTP('calendario')
        sendToFTP('calendario_gzip')

        print('Calendario atualizado em %s segundos ---' % (round(time.time() - start_time, 2)))
        return df
    except Exception as e:
        print(e)


def dolar_2023():
    url = 'http://www.yahii.com.br/dolardiario23.html'

    # response = requests.get(url)
    # response.encoding = 'utf-8'
    # html = response.text
    response = requests.get(url)
    response.encoding = 'ISO-8859-1'  # Altere a codificação aqui
    html = response.text

    df = pd.read_html(html, decimal=',', thousands='.')[3]
    df.columns = ['Data', 'Compra', 'Venda']
    df = df.drop(df.index[0:2])
    df = df.fillna('')
    df = df[~df['Compra'].str.contains('2023')]
    df = df[~df['Compra'].str.contains('Compra')]

    df = df[df['Data'] != '']

    saveCSV_compression(df, 'dolar_2023_gzip', 'gzip')
    sendToFTP('dolar_2023_gzip')

    return df


def dolar_2022():
    url = 'http://www.yahii.com.br/dolardiario22.html'

    response = requests.get(url)
    response.encoding = 'ISO-8859-1'  # Altere a codificação aqui
    html = response.text

    df = pd.read_html(html, decimal=',', thousands='.')[3]
    df.columns = ['Data', 'Compra', 'Venda']
    df = df.drop(df.index[0:2])
    df = df.fillna('')
    df = df[~df['Compra'].str.contains('2022')]
    df = df[~df['Compra'].str.contains('Compra')]

    df = df[df['Data'] != '']

    saveCSV_compression(df, 'dolar_2022_gzip', 'gzip')
    sendToFTP('dolar_2022_gzip')

    return df


def save_parquet(df, file):

    filename = f'datasets/parquet/{file}.parquet'

    try:
        df.to_parquet(filename, engine='pyarrow', compression='snappy')
    except Exception as e:
        raise Exception(f'Erro ao salvar o arquivo {filename}: {e}')


def save_json(df, file):
    if df.empty:
        raise ValueError("O DataFrame está vazio")

    if 'Data Inclusao' in df.columns:
        # formatar Data Inclusao as datetime
        df['Data Inclusao'] = pd.to_datetime(df['Data Inclusao'])
        df['Data Inclusao'] = df['Data Inclusao'].dt.strftime('%Y-%m-%d')

    filename = f'datasets/json/{file}.json'

    try:
        df.to_json(filename, orient='records', lines=True)
    except Exception as e:
        raise Exception(f'Erro ao salvar o arquivo {filename}: {e}')


def read_parquet(file: str) -> pd.DataFrame:

    filepath = f'datasets/parquet/{file}.parquet'

    try:
        return pd.read_parquet(filepath)
    except Exception as e:
        raise Exception(f'Erro ao ler o arquivo {filepath}: {e}')


def read_json(file: str) -> pd.DataFrame:

    filepath = f'datasets/json/{file}.json'

    try:
        return pd.read_json(filepath, lines=True)
    except Exception as e:
        raise Exception(f'Erro ao ler o arquivo {filepath}: {e}')


def send_to_ftp_parquet(filename):

    start_time = time.time()

    buffer_size = 1024*100

    with open(f"datasets/parquet/{filename}.parquet", "rb") as file:
        try:
            ftp_server = conn_ftp()

            ftp_server.storbinary(
                f"STOR parquet/{filename}.parquet", file, buffer_size)

            ftp_server.quit()
        except Exception as e:
            print(f"Erro ao enviar o arquivo {filename}.parquet: {e}")
            raise

    print(f"Arquivo {filename}.parquet enviado para o FTP em {round(time.time() - start_time, 2)} segundos")


def send_to_ftp_json(filename):

    start_time = time.time()

    with open(f"datasets/json/{filename}.json", "rb") as file:
        try:
            ftp_server = conn_ftp()

            ftp_server.storbinary(
                f"STOR json/{filename}.json", file, 1024*100)

            ftp_server.quit()
        except Exception as e:
            print(f"Erro ao enviar o arquivo {filename}.json: {e}")
            raise

    print(f"Arquivo {filename}.json enviado para o FTP em {round(time.time() - start_time, 2)} segundos")


def calendario_exchange():

    try:
        # get the current date

        today = datetime.datetime.now().date()
        today = time.strftime("%Y/%m/%d")
        date_range = pd.date_range(start='1999/1/1', end=today)
        df = date_range.to_frame(index=False)
        df.rename(columns={0: "date"}, inplace=True)

        return df

    except Exception as e:
        print(e)


def get_exchange_rates(start_date, end_date):
    base_url = "https://api.bcb.gov.br/dados/serie/bcdata.sgs.10813/dados?formato=json&dataInicial={}&dataFinal={}"
    url = base_url.format(start_date, end_date)
    response = requests.get(url)
    data = response.json()
    df = pd.DataFrame(data)
    df['data'] = pd.to_datetime(df['data'], dayfirst=True)
    df.set_index('data', inplace=True)
    return df


def complete_weekend_dates(df):
    # Obter todos os dias da semana
    all_days = pd.date_range(start=df.index.min(), end=df.index.max())

    # Remover os dias que já estão presentes no DataFrame
    missing_days = all_days[~all_days.isin(df.index)]

    # Preencher os dados das datas ausentes com os valores da sexta-feira anterior
    for day in missing_days:
        if day.weekday() == 5:  # Se for sábado (5)
            friday = day - pd.Timedelta(days=1)
            if friday in df.index:
                df.loc[day] = df.loc[friday]
        elif day.weekday() == 6:  # Se for domingo (6)
            friday = day - pd.Timedelta(days=2)
            if friday in df.index:
                df.loc[day] = df.loc[friday]

    # Ordenar o DataFrame por data
    df.sort_index(inplace=True)
    return df


def completa_feriados(df):

    #preencher para baixo as linhas de data vazias com valor do dia anterior
    df.ffill(inplace=True)
    return df


def passar_datas():


    try:
        calendario_data = calendario_exchange()

        start_date = "01/01/1999"
        end_date = pd.to_datetime(date.today()).strftime('%d/%m/%Y')
        exchange_rates = get_exchange_rates(start_date, end_date)
        exchange_rates = complete_weekend_dates(exchange_rates)
        #formatar campo de data dd/mm/aaaa
        exchange_rates.index = exchange_rates.index.strftime('%d/%m/%Y')
        exchange_rates.index = pd.to_datetime(exchange_rates.index, dayfirst=True)
        calendario_data = pd.merge(calendario_data, exchange_rates, left_on='date', right_index=True, how='left')
        exchange_rates = completa_feriados(calendario_data)
        saveCSV(exchange_rates, 'dolar')
        saveCSV_compression(exchange_rates, 'dolar_gzip', 'gzip')
        sendToFTP('dolar')
        sendToFTP('dolar_gzip')
    except Exception as e:
        print(e)
