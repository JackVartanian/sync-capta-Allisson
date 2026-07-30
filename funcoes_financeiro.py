import funcoes_comuns as fc
import time
import pandas as pd
import numpy as np
import glob

from warnings import simplefilter

simplefilter(action='ignore', category=FutureWarning)
simplefilter(action='ignore', category=Warning)

# SQL DP e RH
sql_forma_pagamento = 'sql/financeiro/forma_pagamento.sql'
sql_forma_pagamento_original = 'sql/financeiro/forma_pagamento.sql'
sql_formaPgtoCartao = 'sql/financeiro/forma_pagamento_cartao.sql'


def transform_data(df):

    # Perform transformations step by step
    df['Dt Oper'] = pd.to_datetime(df['Dt Oper'], format='%Y-%m-%d')
    df = df.replace('None', '', regex=True)
    df = df.replace(np.nan, '', regex=True)
    df["Dt Oper"] = pd.to_datetime(df["Dt Oper"]).dt.date
    df["Cond Pagto"] = df["Cond Pagto"].str.replace(
        ".", "").str.replace("CHEQUE R", "CHEQUE").str.replace("-", "")
    df["% Desc"] = df["% Desc"].str.replace("-", "")
    df["Docto"] = df["Docto"].str.replace(".", "")
    df["OP CERTIFICADO"] = df["OP CERTIFICADO"].str.split(" ").str[-1]
    df["OP GERADORA"] = df["OP GERADORA"].str[-8:]
    df["Num Oper."] = df["Num Oper."].str.replace(".0", "")

    # # Combine columns to create new ones
    df["ID_OP_GERADORA"] = (df["Cod. Cliente"] + " | " +
                            df["OP GERADORA"]).astype(str)
    df["ID_OP"] = (df["Cod. Cliente"] + " | " + df["Num Oper."]).astype(str)
    df["ID"] = df["Empresa"] + " | " + df["Num Oper."]
    df["Dt Oper"] = pd.to_datetime(df["Dt Oper"])
    df["Dt Oper"] = df["Dt Oper"].dt.strftime("%d-%m-%Y")
    df["ID TICKET"] = df["Cod. Cliente"] + "-" + df["Dt Oper"]

    df["Valor Parcela"] = df["Valor Parcela"].astype(float)
    df["Valor Reais"] = df["Valor Reais"].astype(float)
    df["Valor Bruto"] = df["Valor Bruto"].astype(float)

    return df


def forma_pagamento():

    print("\n")
    try:
        start_time = time.time()

        print('Forma de Pagamento')
        df = fc.sqlToPandas(sql_forma_pagamento).astype(str)
        df_tratado = transform_data(df).reset_index(drop=True)
        fc.saveCSV(df_tratado, 'forma_pagamento')
        fc.saveCSV_compression(df_tratado, 'forma_pagamento_gzip', 'gzip')
        fc.sendToFTP('forma_pagamento')
        fc.sendToFTP('forma_pagamento_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))

    except Exception as e:
        print('Erro ao exportar Forma de Pagamento', e)

    print("\n")
    try:
        start_time = time.time()

        print('Forma de Pagamento Original')
        df = fc.sqlToPandas(sql_forma_pagamento_original).astype(str)
        df_tratado = transform_data(df).reset_index(drop=True)
        fc.saveCSV(df_tratado, 'forma_pagamento_original')
        fc.saveCSV_compression(
            df_tratado, 'forma_pagamento_original_gzip', 'gzip')
        fc.sendToFTP('forma_pagamento_original')
        fc.sendToFTP('forma_pagamento_original_gzip')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))

    except Exception as e:
        print('Erro ao exportar Forma de Pagamento Original', e)
    print("\n")


def transform_loja():

    sql_formaPgtoCartao = 'sql/financeiro/forma_pagamento_cartao.sql'
    df = fc.sqlToPandas(sql_formaPgtoCartao)

    df['cpfs'] = df['cpfs'].str.replace('.', '').str.replace('-', '').str.replace('/', '').str.replace(' ', '')

    debito = ['MASTER DEBIT', 'VISA DB GET', 'VISA DEB GET', 'VISA DB REDE', 'VISA DEBITO', 'ELO DB REDE', 'ELO DEBITO']

    df['CredDeb'] = np.where(df['fpags'].isin(debito), 2, 1)
    df['NumCartao'] = ''
    df['NSUAdmin'] = ''
    df['TID'] = ''

    df['VALOR_TOTAL'] = df['VALOS']

    df[df['cpfs'] == '01769403167'].reset_index(drop=True)

    colunas = ['emps', 'datas', 'autorizs', 'nsusitefs', 'NSUAdmin', 'NOME_ADM', 'desccartao',
            'CredDeb', 'VALOR_TOTAL', 'totalparc', 'NumCartao', 'TID', 'numes', 'cpfs', 'rclis']
    df = df[colunas]

    df.columns = ['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin',
                            'Bandeira', 'CredDeb', 'Valor', 'QtParc', 'NumCartao', 'TID', 'NumPedido', 'CPF', 'Cliente']

    df = df.groupby(['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin', 'Bandeira',
                                              'CredDeb', 'NumCartao', 'TID', 'NumPedido', 'CPF', 'Cliente']).agg({'Valor': 'sum', 'QtParc': 'mean'}).reset_index()

    admin = {
        'PAGBRASIL PAGAMENTOS ELETRONICOS LTDA': 137,
        'REDECARD': 3,
        'PAY PAL': 91,
        'GETNET': 19,
        'MOKA CONSULTORIA EM INVESTIMENTOS LTDA': 136}

    bandeiras = {'PAGBRASIL': 0, 'VISA': 7, 'HIPER': 82, 'MASTER': 3, 'AMEX': 1, 'ELO': 14, 'MAESTRO': 83, 'ELO DEBITO': 14}

    df['Bandeira'] = df['Bandeira'].map(bandeiras)
    df['Admin'] = df['Admin'].map(admin)

    df['ID'] = df['Filial'] + df['Data'].astype(str) + df['Autorizacao'] + df['NumPedido'] + df['CPF']
    df['ID'] = df['ID'].str.replace(' ', '')
    df = df.drop_duplicates(subset='ID', keep='first').reset_index(drop=True)
    df = df.drop(columns='ID')

    df['Data'] = pd.to_datetime(df['Data'], format='%Y%m%d')
    df['Data'] = df['Data'].dt.strftime('%Y%m%d')

    df['ID_Venda'] = df['CPF'].astype(str) + '-' + df['Valor'].astype(str)
    df['ID_Venda'] = df['ID_Venda'].str.replace('.0', '')

    df['Valor'] = df['Valor'].astype(str)
    df['Valor'] = df['Valor'].str.replace('.00', '')
    df['Valor'] = df['Valor'].astype(float).astype(int)

    # df = df.drop(columns=['CPF', 'Cliente', 'ID_Venda'])

    df_lojas = df[df['Filial'] != 'FTH'].reset_index(drop=True)

    df_lojas['Bandeira'] = df_lojas['Bandeira'].replace('', 0)
    df_lojas['Admin'] = df_lojas['Admin'].replace('', 0)

    df_lojas['Admin'] = df_lojas['Admin'].astype(int)
    df_lojas['Bandeira'] = df_lojas['Bandeira'].astype(int)
    df_lojas['Valor'] = df_lojas['Valor'].astype(int)
    df_lojas['QtParc'] = df_lojas['QtParc'].astype(int)
    df_lojas['CPF'] = df_lojas['CPF'].astype(str)

    df_lojas = df_lojas.sort_values(
        by='Data', ascending=False).reset_index(drop=True)

    return df_lojas


def transform_site_vtex():

    sql_formaPgtoCartao = 'sql/financeiro/forma_pagamento_cartao.sql'
    formaPgtoCartao = fc.sqlToPandas(sql_formaPgtoCartao)

    formaPgtoCartao = formaPgtoCartao[formaPgtoCartao['emps'] == 'FTH'].reset_index(drop=True)

    formaPgtoCartao['cpfs'] = formaPgtoCartao['cpfs'].str.replace('.', '').str.replace('-', '').str.replace('/', '').str.replace(' ', '')

    debito = ['MASTER DEBIT', 'VISA DB GET', 'VISA DEB GET', 'VISA DB REDE', 'VISA DEBITO', 'ELO DB REDE', 'ELO DEBITO']

    formaPgtoCartao['CredDeb'] = np.where(formaPgtoCartao['fpags'].isin(debito), 2, 1)
    formaPgtoCartao['NumCartao'] = ''
    formaPgtoCartao['NSUAdmin'] = ''
    formaPgtoCartao['TID'] = ''

    formaPgtoCartao['VALOR_TOTAL'] = formaPgtoCartao['VALOS']

    formaPgtoCartao[formaPgtoCartao['cpfs'] == '01769403167'].reset_index(drop=True)

    colunas = ['emps', 'datas', 'autorizs', 'nsusitefs', 'NSUAdmin', 'NOME_ADM', 'desccartao',
            'CredDeb', 'VALOR_TOTAL', 'totalparc', 'NumCartao', 'TID', 'numes', 'cpfs', 'rclis']
    formaPgtoCartao = formaPgtoCartao[colunas]

    formaPgtoCartao.columns = ['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin',
                            'Bandeira', 'CredDeb', 'Valor', 'QtParc', 'NumCartao', 'TID', 'NumPedido', 'CPF', 'Cliente']

    formaPgtoCartao = formaPgtoCartao.groupby(['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin', 'Bandeira',
                                              'CredDeb', 'NumCartao', 'TID', 'NumPedido', 'CPF', 'Cliente']).agg({'Valor': 'sum', 'QtParc': 'mean'}).reset_index()

    bandeiras = {'PAGBRASIL': 0, 'VISA': 7, 'HIPER': 82, 'MASTER': 3, 'AMEX': 1, 'ELO': 14, 'MAESTRO': 83, 'ELO DEBITO': 14}
    admin = {'PAGBRASIL PAGAMENTOS ELETRONICOS LTDA': 137, 'REDECARD': 3, 'PAY PAL': 91, 'GETNET': 19, 'MOKA CONSULTORIA EM INVESTIMENTOS LTDA': 136}

    formaPgtoCartao['Data'] = pd.to_datetime(formaPgtoCartao['Data'], format='%Y-%m-%d')

    formaPgtoCartao = formaPgtoCartao[formaPgtoCartao['Data'] < '2023-09-14']

    formaPgtoCartao['Bandeira'] = formaPgtoCartao['Bandeira'].map(bandeiras)
    formaPgtoCartao['Admin'] = formaPgtoCartao['Admin'].map(admin)

    formaPgtoCartao['ID'] = formaPgtoCartao['Filial'] + formaPgtoCartao['Data'].astype(str) + formaPgtoCartao['Autorizacao'] + formaPgtoCartao['NumPedido'] + formaPgtoCartao['CPF']
    formaPgtoCartao['ID'] = formaPgtoCartao['ID'].str.replace(' ', '')
    formaPgtoCartao = formaPgtoCartao.drop_duplicates(subset='ID', keep='first').reset_index(drop=True)
    formaPgtoCartao = formaPgtoCartao.drop(columns='ID')

    formaPgtoCartao['ID_Venda'] = formaPgtoCartao['CPF'].astype(str) + '-' + formaPgtoCartao['Valor'].astype(str)
    formaPgtoCartao['ID_Venda'] = formaPgtoCartao['ID_Venda'].str.replace('.0', '')

    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].astype(str)
    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].str.replace('.00', '')
    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].astype(float).astype(int)

    # formaPgtoCartao = formaPgtoCartao.drop(columns=['CPF', 'Cliente', 'ID_Venda'])

    formaPgtoCartao = formaPgtoCartao.fillna('')
    formaPgtoCartao['Data'] = formaPgtoCartao['Data'].dt.strftime('%Y%m%d')

    formaPgtoCartao['Bandeira'] = formaPgtoCartao['Bandeira'].replace('', 0)
    formaPgtoCartao['Admin'] = formaPgtoCartao['Admin'].replace('', 0)

    formaPgtoCartao['Admin'] = formaPgtoCartao['Admin'].astype(int)
    formaPgtoCartao['Bandeira'] = formaPgtoCartao['Bandeira'].astype(int)
    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].astype(int)
    formaPgtoCartao['QtParc'] = formaPgtoCartao['QtParc'].astype(int)
    formaPgtoCartao['CPF'] = formaPgtoCartao['CPF'].astype(str)

    formaPgtoCartao = formaPgtoCartao.sort_values(by='Data', ascending=False).reset_index(drop=True)

    return formaPgtoCartao


def transform_site_shopify():

    sql_formaPgtoCartao = 'sql/financeiro/forma_pagamento_cartao.sql'
    formaPgtoCartao = fc.sqlToPandas(sql_formaPgtoCartao)

    print('Quantidade de registros:', formaPgtoCartao.shape[0])

    formaPgtoCartao = formaPgtoCartao[formaPgtoCartao['emps'] == 'FTH'].reset_index(
        drop=True)

    formaPgtoCartao['cpfs'] = formaPgtoCartao['cpfs'].str.replace(
        '.', '').str.replace('-', '').str.replace(' ', '').str.zfill(11)

    debito = ['MASTER DEBIT', 'VISA DB GET', 'VISA DEB GET',
              'VISA DB REDE', 'VISA DEBITO', 'ELO DB REDE', 'ELO DEBITO']

    formaPgtoCartao['CredDeb'] = np.where(
        formaPgtoCartao['fpags'].isin(debito), 2, 1)
    formaPgtoCartao['NumCartao'] = ''
    formaPgtoCartao['NSUAdmin'] = ''
    formaPgtoCartao['TID'] = ''

    formaPgtoCartao['VALOR_TOTAL'] = formaPgtoCartao['VALOS']

    colunas = ['emps', 'datas', 'autorizs', 'nsusitefs', 'NSUAdmin', 'NOME_ADM', 'desccartao',
               'CredDeb', 'VALOR_TOTAL', 'totalparc', 'NumCartao', 'TID', 'numes', 'cpfs', 'rclis']

    formaPgtoCartao = formaPgtoCartao[colunas]

    formaPgtoCartao.columns = ['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin',
                               'Bandeira', 'CredDeb', 'Valor', 'QtParc', 'NumCartao', 'TID', 'NumPedido', 'CPF', 'Cliente']

    formaPgtoCartao = formaPgtoCartao.groupby(['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin', 'Bandeira', 'CredDeb', 'NumCartao', 'TID', 'NumPedido', 'CPF', 'Cliente']).agg({'Valor': 'sum', 'QtParc': 'mean'}).reset_index()

    bandeiras = {'PAGBRASIL': 0, 'VISA': 7, 'HIPER': 82, 'MASTER': 3,
                 'AMEX': 1, 'ELO': 14, 'MAESTRO': 83, 'ELO DEBITO': 14}
    admin = {'PAGBRASIL PAGAMENTOS ELETRONICOS LTDA': 137, 'REDECARD': 3,
             'PAY PAL': 91, 'GETNET': 19, 'MOKA CONSULTORIA EM INVESTIMENTOS LTDA': 136}

    formaPgtoCartao['Data'] = pd.to_datetime(formaPgtoCartao['Data'], format='%Y-%m-%d')

    formaPgtoCartao = formaPgtoCartao[formaPgtoCartao['Data'] >= '2023-09-14']

    print('Quantidade de registros após filtro:', formaPgtoCartao.shape[0])

    formaPgtoCartao['Bandeira'] = formaPgtoCartao['Bandeira'].map(bandeiras)
    formaPgtoCartao['Admin'] = formaPgtoCartao['Admin'].map(admin)

    formaPgtoCartao['ID'] = formaPgtoCartao['Filial'] + formaPgtoCartao['Data'].astype(str) + formaPgtoCartao['Autorizacao'] + formaPgtoCartao['NumPedido'] + formaPgtoCartao['CPF']
    formaPgtoCartao['ID'] = formaPgtoCartao['ID'].str.replace(' ', '')
    formaPgtoCartao = formaPgtoCartao.drop_duplicates(subset='ID', keep='first').reset_index(drop=True)
    formaPgtoCartao = formaPgtoCartao.drop(columns='ID')

    formaPgtoCartao['ID_Venda'] = formaPgtoCartao['CPF'].astype(str) + '-' + formaPgtoCartao['Valor'].astype(str)
    formaPgtoCartao['ID_Venda'] = formaPgtoCartao['ID_Venda'].str.replace('.0', '')

    formaPgtoCartao = formaPgtoCartao.fillna('')
    formaPgtoCartao['Data'] = formaPgtoCartao['Data'].dt.strftime('%Y%m%d')

    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].astype(str)
    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].str.replace('.00', '')
    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].astype(float).astype(int)

    formaPgtoCartao['Bandeira'] = formaPgtoCartao['Bandeira'].replace('', 0)
    formaPgtoCartao['Admin'] = formaPgtoCartao['Admin'].replace('', 0)

    formaPgtoCartao['Admin'] = formaPgtoCartao['Admin'].astype(int)
    formaPgtoCartao['Bandeira'] = formaPgtoCartao['Bandeira'].astype(int)
    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].astype(int)
    formaPgtoCartao['QtParc'] = formaPgtoCartao['QtParc'].astype(int)
    formaPgtoCartao['CPF'] = formaPgtoCartao['CPF'].astype(str)

    formaPgtoCartao = formaPgtoCartao.sort_values(by='Data', ascending=False).reset_index(drop=True)

    fc.saveCSV(formaPgtoCartao, 'forma_pagamento_site_shopify_cpf')

    # formaPgtoCartao = formaPgtoCartao.drop(
    #     columns=['CPF', 'Cliente', 'ID_Venda'])
    # filter  admin != 137
    # formaPgtoCartao = formaPgtoCartao[formaPgtoCartao['Admin'] != 137].reset_index(drop=True)

    # export to csv
    fc.saveCSV(formaPgtoCartao, 'forma_pagamento_site_shopify')

    return formaPgtoCartao


def transform_site_shopify_cpf():

    sql_formaPgtoCartao = 'sql/financeiro/forma_pagamento_cartao.sql'
    formaPgtoCartao = fc.sqlToPandas(sql_formaPgtoCartao)

    print('Quantidade de registros:', formaPgtoCartao.shape[0])

    formaPgtoCartao = formaPgtoCartao[formaPgtoCartao['emps'] == 'FTH'].reset_index(
        drop=True)

    formaPgtoCartao['cpfs'] = formaPgtoCartao['cpfs'].str.replace(
        '.', '').str.replace('-', '').str.replace(' ', '').str.zfill(11)

    debito = ['MASTER DEBIT', 'VISA DB GET', 'VISA DEB GET',
              'VISA DB REDE', 'VISA DEBITO', 'ELO DB REDE', 'ELO DEBITO']

    formaPgtoCartao['CredDeb'] = np.where(
        formaPgtoCartao['fpags'].isin(debito), 2, 1)
    formaPgtoCartao['NumCartao'] = ''
    formaPgtoCartao['NSUAdmin'] = ''
    formaPgtoCartao['TID'] = ''

    formaPgtoCartao['VALOR_TOTAL'] = formaPgtoCartao['VALOS']

    colunas = ['emps', 'datas', 'autorizs', 'nsusitefs', 'NSUAdmin', 'NOME_ADM', 'desccartao',
               'CredDeb', 'VALOR_TOTAL', 'totalparc', 'NumCartao', 'TID', 'numes', 'cpfs', 'rclis']

    formaPgtoCartao = formaPgtoCartao[colunas]

    formaPgtoCartao.columns = ['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin',
                               'Bandeira', 'CredDeb', 'Valor', 'QtParc', 'NumCartao', 'TID', 'NumPedido', 'CPF', 'Cliente']

    # group by 'Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin', 'Bandeira', 'CredDeb', 'NumCartao', 'TID', 'NumPedido', 'CPF', 'Cliente', SUM(VALOR_TOTAL) AND AVERAGE(totalparc)
    formaPgtoCartao = formaPgtoCartao.groupby(['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin', 'Bandeira',
                                              'CredDeb', 'NumCartao', 'TID', 'NumPedido', 'CPF', 'Cliente']).agg({'Valor': 'sum', 'QtParc': 'mean'}).reset_index()

    bandeiras = {'PAGBRASIL': 0, 'VISA': 7, 'HIPER': 82, 'MASTER': 3,
                 'AMEX': 1, 'ELO': 14, 'MAESTRO': 83, 'ELO DEBITO': 14}
    admin = {'PAGBRASIL PAGAMENTOS ELETRONICOS LTDA': 137, 'REDECARD': 3,
             'PAY PAL': 91, 'GETNET': 19, 'MOKA CONSULTORIA EM INVESTIMENTOS LTDA': 136}

    formaPgtoCartao['Data'] = pd.to_datetime(
        formaPgtoCartao['Data'], format='%Y-%m-%d')

    formaPgtoCartao = formaPgtoCartao[formaPgtoCartao['Data'] >= '2023-09-14']

    print('Quantidade de registros após filtro:', formaPgtoCartao.shape[0])

    formaPgtoCartao['Bandeira'] = formaPgtoCartao['Bandeira'].map(bandeiras)
    formaPgtoCartao['Admin'] = formaPgtoCartao['Admin'].map(admin)

    formaPgtoCartao['ID'] = formaPgtoCartao['Filial'] + formaPgtoCartao['Data'].astype(
        str) + formaPgtoCartao['Autorizacao'] + formaPgtoCartao['NumPedido'] + formaPgtoCartao['CPF']
    formaPgtoCartao['ID'] = formaPgtoCartao['ID'].str.replace(' ', '')
    formaPgtoCartao = formaPgtoCartao.drop_duplicates(
        subset='ID', keep='first').reset_index(drop=True)
    formaPgtoCartao = formaPgtoCartao.drop(columns='ID')

    formaPgtoCartao['ID_Venda'] = formaPgtoCartao['CPF'].astype(
        str) + '-' + formaPgtoCartao['Valor'].astype(str)
    formaPgtoCartao['ID_Venda'] = formaPgtoCartao['ID_Venda'].str.replace(
        '.0', '')

    formaPgtoCartao = formaPgtoCartao.fillna('')
    formaPgtoCartao['Data'] = formaPgtoCartao['Data'].dt.strftime('%Y%m%d')

    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].astype(str)
    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].str.replace('.00', '')
    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].astype(
        float).astype(int)

    formaPgtoCartao['Bandeira'] = formaPgtoCartao['Bandeira'].replace('', 0)
    formaPgtoCartao['Admin'] = formaPgtoCartao['Admin'].replace('', 0)

    formaPgtoCartao['Admin'] = formaPgtoCartao['Admin'].astype(int)
    formaPgtoCartao['Bandeira'] = formaPgtoCartao['Bandeira'].astype(int)
    formaPgtoCartao['Valor'] = formaPgtoCartao['Valor'].astype(int)
    formaPgtoCartao['QtParc'] = formaPgtoCartao['QtParc'].astype(int)

    formaPgtoCartao['CPF'] = formaPgtoCartao['CPF'].astype(str)

    # sort by 'Data' desc
    formaPgtoCartao = formaPgtoCartao.sort_values(
        by='Data', ascending=False).reset_index(drop=True)

    fc.saveCSV(formaPgtoCartao, 'forma_pagamento_site_shopify_cpf')

    # formaPgtoCartao = formaPgtoCartao.drop(
    #     columns=['CPF', 'Cliente', 'ID_Venda'])
    # filter  admin != 137
    # formaPgtoCartao = formaPgtoCartao[formaPgtoCartao['Admin'] != 137].reset_index(drop=True)

    # export to csv
    # fc.saveCSV(formaPgtoCartao, 'forma_pagamento_site_shopify')

    return formaPgtoCartao


def transform_site():

    colunas = ['Order number', 'Payment method', 'Submission date', 'Order status',
               'Payment date', 'End Customer Tax ID', 'End Customer name',
               'Installments', 'CC brand', 'Authorization code', 'Amount paid in BRL by End Customer']

    dataframes = []

    for filename in glob.glob('pagBrasil/*.csv'):

        df = pd.read_csv(filename, sep=';')
        dataframes.append(df)

        df_final = pd.concat(dataframes, ignore_index=True)
        df_final = df_final[colunas]
        df_final = df_final[df_final['Payment method']
                            == 'Credit card'].reset_index(drop=True)
        df_final = df_final[df_final['Authorization code'].notna()
                            ].reset_index(drop=True)
        df_final = df_final[df_final['Amount paid in BRL by End Customer'].notna(
        )].reset_index(drop=True)

        df_final['Amount paid in BRL by End Customer'] = df_final['Amount paid in BRL by End Customer'].astype(
            str)
        # df_final['Amount paid in BRL by End Customer'] = df_final['Amount paid in BRL by End Customer'].str.replace(
        #     '.', '').str.replace(',', '.').astype(float)
        df_final['Installments'] = df_final['Installments'].astype(str)
        # df_final['Installments'] = df_final['Installments'].str.replace(
        #     '.0', '').astype(int)
        df_final['Authorization code'] = df_final['Authorization code'].astype(str)
        df_final['Authorization code'] = df_final['Authorization code'].str.replace(
            '.0', '')
        df_final['Submission date'] = pd.to_datetime(df_final['Submission date'], format='%d/%m/%Y')
        df_final['Payment date'] = pd.to_datetime(df_final['Payment date'], format='%d/%m/%Y')


        df_final['Filial'] = 'FTH'
        df_final['CredDeb'] = 1
        df_final['NSUSitef'] = ''
        df_final['NSUAdmin'] = ''
        df_final['NumCartao'] = ''
        df_final['Admin'] = 137
        df_final['TID'] = ''

        bandeiras = {'V': 7, 'H': 82, 'M': 3, 'A': 1, 'E': 14}
        df_final['CC brand'] = df_final['CC brand'].map(bandeiras)
        df_final

        df_final.columns = ['NumPedido', 'FormaPgto', 'DataPedido', 'Status', 'Data', 'CPF', 'Nome', 'QtParc',
                            'Bandeira', 'Autorizacao', 'Valor', 'Filial', 'CredDeb', 'NSUSitef', 'NumCartao', 'NSUAdmin',  'Admin', 'TID']

        df_final = df_final[['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin',
                            'Bandeira', 'CredDeb', 'Valor', 'QtParc', 'NumCartao', 'TID', 'NumPedido']]

        df_final['Data'] = df_final['Data'].dt.strftime('%Y%m%d')

    return df_final


def conciliacao():

    print("\n")
    try:
        start_time = time.time()

        print('Conciliação Financeira')
        loja = transform_loja()
        site_vtex = transform_site_vtex()
        site_shopify = transform_site_shopify()
        comparar_vendas = compare_vendas()

        loja_site = pd.concat(
            [loja, site_vtex, site_shopify], axis=0).reset_index(drop=True)

        loja_site['Data'] = pd.to_datetime(loja_site['Data'], format='%Y%m%d')
        loja_site['Data'] = loja_site['Data'].dt.strftime('%d/%m/%Y')

        loja_site['ID'] = loja_site['CPF'].astype(
            str) + '-' + loja_site['Valor'].astype(str) + '-' + loja_site['QtParc'].astype(str)

        loja_site = pd.merge(loja_site, comparar_vendas, on='ID', how='left')

        loja_site = loja_site.sort_values(
            by='Data', ascending=False).reset_index(drop=True)

        loja_site['TID'] = np.where(
            loja_site['Order'].notnull(), loja_site['Order'], loja_site['TID'])

        loja_site.drop(columns=['CPF', 'Cliente',
                       'ID_Venda', 'ID', 'Order'], inplace=True)

        loja_site = loja_site[['Filial', 'Data', 'Autorizacao', 'NSUSitef', 'NSUAdmin', 'Admin',
                                 'Bandeira', 'CredDeb', 'Valor', 'QtParc', 'NumCartao', 'TID', 'NumPedido']]

        nomeArquivo = 'Vendas_Jack'
        fc.saveCSV(loja_site, nomeArquivo)
        fc.sendToFTP(nomeArquivo)

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
        return loja_site
    except Exception as e:
        print('Erro ao exportar Conciliação Financeira', e)


def read_pagBrasil():

    csv_files = glob.glob('pagBrasil/*.csv')
    dataframes = [pd.read_csv(f, sep=';') for f in csv_files]
    all_data = pd.concat(dataframes, ignore_index=True)

    all_data = all_data[['Order number', 'Submission date', 'Payment date', 'Payment method', 'Order status', 'End Customer Tax ID',
                        'Amount paid in BRL by End Customer', 'Installments']]
    all_data.columns = ['Order', 'Created Dated', 'Date', 'Forma Pagamento', 'Status', 'CPF', 'Valor', 'QtParc']
    all_data = all_data[all_data['CPF'] != '-']

    all_data = all_data[all_data['Date'].notnull()]
    all_data['Valor'] = all_data['Valor'].str.replace(',00', '')
    all_data['Valor'] = all_data['Valor'].str.replace('.', '')
    all_data['QtParc'] = all_data['QtParc'].astype(str)
    all_data['QtParc'] = all_data['QtParc'].str.replace('.0', '')
    all_data['QtParc'] = all_data['QtParc'].replace('nan', 1)

    all_data['Date'] = pd.to_datetime(all_data['Date'], format='%d/%m/%Y')
    all_data = all_data.sort_values(by='Date', ascending=False).reset_index(drop=True)

    all_data['ID'] = all_data['CPF'] + '-' + \
        all_data['Valor'].astype(str) + '-' + all_data['QtParc'].astype(str)

    credit_card = all_data[all_data['Forma Pagamento'] == 'Credit card']
    credit_card_orders = credit_card.groupby('Forma Pagamento').size()[0]

    print('Quantidade de Orders Credit Card:', credit_card_orders)
    # colunasFinal = ['ID', 'Order']
    # all_data = all_data[colunasFinal]

    return all_data


def read_shopify_cpf():

    vendas_shopify = fc.readCSV_str('forma_pagamento_site_shopify_cpf')
    vendas_shopify = vendas_shopify[['Data', 'Valor', 'QtParc', 'CPF', 'Admin']]
    vendas_shopify['Data'] = pd.to_datetime(vendas_shopify['Data'], format='%Y%m%d')
    vendas_shopify['Data'] = vendas_shopify['Data'].dt.strftime('%d/%m/%Y')
    vendas_shopify['Valor'] = pd.to_numeric(vendas_shopify['Valor'], errors='coerce')
    vendas_shopify['QtParc'] = vendas_shopify['QtParc'].astype(int)

    vendas_shopify = vendas_shopify.groupby(['Data', 'CPF', 'Admin']).agg(
        {'Valor': 'sum', 'QtParc': 'mean'}).reset_index()

    vendas_shopify['QtParc'] = vendas_shopify['QtParc'].astype(int)

    vendas_shopify['ID'] = vendas_shopify['CPF'].astype(
        str) + '-' + vendas_shopify['Valor'].astype(str) + '-' + vendas_shopify['QtParc'].astype(str)

    return vendas_shopify.reset_index(drop=True)


def compare_vendas():

    pagBrasil = read_pagBrasil()
    vendas_shopify = read_shopify_cpf()
    vendas_shopify = vendas_shopify[vendas_shopify['Admin'] == '137']

    print('Quantidade de vendas capta: ', vendas_shopify.shape[0])

    vendas = pd.merge(vendas_shopify, pagBrasil, on='ID', how='left')

    print("Qtde vendas com Order: ", vendas[vendas['Order'].notna()].shape[0], "\nQtde vendas sem Order: ", vendas[vendas['Order'].isna()].shape[0])

    colunas = ['ID', 'Order']
    vendas = vendas[colunas]

    return vendas
