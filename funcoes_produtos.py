import funcoes_comuns as fc
import time

from warnings import simplefilter

simplefilter(action='ignore', category=FutureWarning)
simplefilter(action='ignore', category=Warning)

# SQL Produtos
sql_consignacoes = 'sql/produtos/consignacoes.sql'
sql_dias_ultima_venda = 'sql/produtos/dias_ultima_venda_v2.sql'
sql_produtos_abc_ouro_qtd = 'sql/produtos/produtos_abc_ouro_qtd.sql'
sql_produtos_abc_ouro_total = 'sql/produtos/produtos_abc_ouro_total.sql'
sql_produtos_abc_prata_qtd = 'sql/produtos/produtos_abc_prata_qtd.sql'
sql_produtos_abc_prata_total = 'sql/produtos/produtos_abc_prata_total.sql'
sql_produtos = 'sql/produtos/produtos.sql'
sql_produtos_ad = 'sql/produtos/produtos_ad.sql'
sql_ofertas = 'sql/produtos/ofertas.sql'


def consignacoes():

    print("\n")
    try:
        start_time = time.time()

        print('Consignacoes')
        df = fc.sqlToPandas(sql_consignacoes)
        fc.saveCSV(df, 'consignacoes')
        fc.saveCSV_compression2(df, 'consignacoes_gzip', 'gzip')
        fc.sendToFTP('consignacoes')
        fc.sendToFTP('consignacoes_gzip')

        # fc.save_parquet(df, 'consignacoes')
        # fc.send_to_ftp_parquet('consignacoes')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Consignacoes')

    print("\n")

def dias_ultima_venda():
    try:
        start_time = time.time()

        print('Dias ultima venda')
        df = fc.sqlToPandas(sql_dias_ultima_venda)
        fc.saveCSV(df, 'dias_ultima_venda')
        fc.saveCSV_compression(df, 'dias_ultima_venda_gzip', 'gzip')
        fc.sendToFTP('dias_ultima_venda')
        fc.sendToFTP('dias_ultima_venda_gzip')

        # fc.save_parquet(df, 'dias_ultima_venda')
        # fc.send_to_ftp_parquet('dias_ultima_venda')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar Dias ultima venda')

    print("\n")

def produtos():

    print("\n")
    try:
        start_time = time.time()

        print('Produtos')
        df = fc.sqlToPandas(sql_produtos)
        df.loc[df['Cod. Prod.'].isin(foraVoce), 'Cod. Modelo'] = 'VOCE'
        df.loc[df['Cod. Prod.'].isin(foraVoce), 'Colecao'] = 'VOCE'
        df.loc[df['Cod. Prod.'].isin(letrasVoce), 'Desc. Gr.'] = 'LETRA'
        df.loc[df['Cod. Prod.'].isin(letrasRockChain), 'Desc. Gr.'] = 'LETRA'
        df.loc[df['Cod. Prod.'].isin(letrasPOP), 'Desc. Gr.'] = 'LETRA'
        df.loc[df['Cod. Prod.'].isin(earcuffs), 'Desc. Gr.'] = 'EARCUFF'


        fc.saveCSV(df, 'produtos')
        fc.saveCSV_compression(df, 'produtos_gzip', 'gzip')
        fc.sendToFTP('produtos')
        fc.sendToFTP('produtos_gzip')

        # fc.save_parquet(df, 'produtos')
        # fc.send_to_ftp_parquet('produtos')

        # fc.save_json(df, 'produtos')
        # fc.send_to_ftp_json('produtos')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
        return df
    except Exception as e:
        print('Erro ao exportar Produtos', e)
    print("\n")

def produtos_adega():
    try:
        start_time = time.time()

        print('Produtos Adega')
        df = fc.sqlToPandas(sql_produtos_ad)
        fc.saveCSV(df, 'produtos_ad')
        fc.saveCSV_compression(df, 'produtos_ad_gzip', 'gzip')
        fc.sendToFTP('produtos_ad')
        fc.sendToFTP('produtos_ad_gzip')

        # fc.save_parquet(df, 'produtos_ad')
        # fc.send_to_ftp_parquet('produtos_ad')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except Exception as e:
        print('Erro ao exportar Produtos Adega:', e)

    print("\n")

def ofertas():
    try:
        start_time = time.time()

        print('Ofertas')
        df = fc.sqlToPandas(sql_ofertas)
        fc.saveCSV(df, 'ofertas')
        fc.saveCSV_compression(df, 'ofertas_gzip', 'gzip')
        fc.sendToFTP('ofertas')
        fc.sendToFTP('ofertas_gzip')

        # fc.save_parquet(df, 'ofertas')
        # fc.send_to_ftp_parquet('ofertas')

        print('Processo completo, executado em %s segundos ---' %
              (round(time.time() - start_time, 2)))
    except:
        print('Erro ao exportar ofertas')

def consultas_produtos():

    produtos()
    consignacoes()
    ofertas()
    produtos_adega()
    dias_ultima_venda()


foraVoce = [
    'BR06797', 'CO01314', 'CO00023', 'CO01312',
    'CO01335', 'CO01326', 'CO01336', 'PI01843']

letrasVoce = [
    "PI01520", "PI01546", "PI01571", "PI01597", "PI01630", "PI01656", "PI01684", "PI01710", "PI01736", "PI01762",
    "PI01788", "PI01814", "PI01521", "PI01547", "PI01572", "PI01598", "PI01631", "PI01657", "PI01685", "PI01711",
    "PI01737", "PI01763", "PI01789", "PI01815", "PI01522", "PI01548", "PI01573", "PI01599", "PI01632", "PI01658",
    "PI01686", "PI01712", "PI01738", "PI01764", "PI01790", "PI01816", "PI01523", "PI01549", "PI01574", "PI01600",
    "PI01633", "PI01659", "PI01687", "PI01713", "PI01739", "PI01765", "PI01791", "PI01817", "PI01524", "PI01550",
    "PI01575", "PI01601", "PI01634", "PI01660", "PI01688", "PI01714", "PI01740", "PI01766", "PI01792", "PI01818",
    "PI01525", "PI01551", "PI01576", "PI01602", "PI01635", "PI01661", "PI01689", "PI01715", "PI01741", "PI01767",
    "PI01793", "PI01819", "PI01526", "PI01552", "PI01577", "PI01603", "PI01636", "PI01662", "PI01690", "PI01716",
    "PI01742", "PI01768", "PI01794", "PI01820", "PI01527", "PI01553", "PI01578", "PI01604", "PI01637", "PI01663",
    "PI01691", "PI01717", "PI01743", "PI01769", "PI01795", "PI01821", "PI01528", "PI01554", "PI01579", "PI01605",
    "PI01638", "PI01664", "PI01692", "PI01718", "PI01744", "PI01770", "PI01796", "PI01822", "PI01529", "PI01555",
    "PI01580", "PI01606", "PI01639", "PI01665", "PI01693", "PI01719", "PI01745", "PI01771", "PI01797", "PI01823",
    "PI01530", "PI01556", "PI01581", "PI01607", "PI01640", "PI01666", "PI01694", "PI01720", "PI01746", "PI01772",
    "PI01798", "PI01824", "PI01531", "PI01557", "PI01582", "PI01608", "PI01641", "PI01667", "PI01695", "PI01721",
    "PI01747", "PI01773", "PI01799", "PI01825", "PI01532", "PI01558", "PI01583", "PI01609", "PI01642", "PI01668",
    "PI01696", "PI01722", "PI01748", "PI01774", "PI01800", "PI01826", "PI01533", "PI01559", "PI01584", "PI01610",
    "PI01643", "PI01669", "PI01697", "PI01723", "PI01749", "PI01775", "PI01801", "PI01827", "PI01534", "PI01560",
    "PI01585", "PI01611", "PI01644", "PI01670", "PI01698", "PI01724", "PI01750", "PI01776", "PI01802", "PI01828",
    "PI01535", "PI01561", "PI01586", "PI01612", "PI01645", "PI01671", "PI01699", "PI01725", "PI01751", "PI01777",
    "PI01803", "PI01829", "PI01536", "PI01562", "PI01587", "PI01613", "PI01646", "PI01672", "PI01700", "PI01726",
    "PI01752", "PI01778", "PI01804", "PI01830", "PI01537", "PI01563", "PI01588", "PI01614", "PI01647", "PI01673",
    "PI01701", "PI01727", "PI01753", "PI01779", "PI01805", "PI01831", "PI01538", "PI01564", "PI01589", "PI01615",
    "PI01648", "PI01674", "PI01702", "PI01728", "PI01754", "PI01780", "PI01806", "PI01832", "PI01539", "PI01565",
    "PI01590", "PI01616", "PI01649", "PI01675", "PI01703", "PI01729", "PI01755", "PI01781", "PI01807", "PI01833",
    "PI01540", "PI01566", "PI01591", "PI01617", "PI01650", "PI01676", "PI01704", "PI01730", "PI01756", "PI01782",
    "PI01808", "PI01834", "PI01541", "PI01567", "PI01592", "PI01618", "PI01651", "PI01677", "PI01705", "PI01731",
    "PI01757", "PI01783", "PI01809", "PI01835", "PI01542", "PI01593", "PI01619", "PI01625", "PI01652", "PI01678",
    "PI01706", "PI01732", "PI01758", "PI01784", "PI01810", "PI01836", "PI01543", "PI01568", "PI01594", "PI01620",
    "PI01653", "PI01679", "PI01707", "PI01733", "PI01759", "PI01785", "PI01811", "PI01837", "PI01544", "PI01569",
    "PI01595", "PI01621", "PI01654", "PI01680", "PI01708", "PI01734", "PI01760", "PI01786", "PI01812", "PI01838",
    "PI01545", "PI01570", "PI01596", "PI01622", "PI01655", "PI01681", "PI01709", "PI01735", "PI01761", "PI01787",
    "PI01813", "PI01839"]

letrasRockChain = [
    "PI01399", "PI01400", "PI01401", "PI01402", "PI01403", "PI01404", "PI01405", "PI01406", "PI01407", "PI01408",
    "PI01409", "PI01410", "PI01411", "PI01412", "PI01413", "PI01414", "PI01415", "PI01416", "PI01417", "PI01418",
    "PI01419", "PI01420", "PI01421", "PI01422", "PI01423", "PI01424", "PI01428", "PI01429", "PI01430", "PI01431",
    "PI01432", "PI01433", "PI01434", "PI01435", "PI01436", "PI01437", "PI01438", "PI01439", "PI01440", "PI01441",
    "PI01442", "PI01443", "PI01444", "PI01445", "PI01446", "PI01447", "PI01448", "PI01449", "PI01450", "PI01451",
    "PI01452", "PI01453", "PI01456"]

letrasPOP = [
    "PI01072", "PI01073", "PI01074", "PI01075", "PI01076", "PI01077", "PI01078", "PI01079", "PI01080", "PI01081",
    "PI01082", "PI01083", "PI01084", "PI01085", "PI01086", "PI01087", "PI01088", "PI01089", "PI01090", "PI01091",
    "PI01092", "PI01093", "PI01094", "PI01095", "PI01096", "PI01097", "PI01098", "PI01099", "PI01100", "PI01101",
    "PI01102", "PI01103", "PI01104", "PI01105", "PI01106", "PI01107", "PI01108", "PI01109", "PI01110", "PI01111",
    "PI01112", "PI01113", "PI01114", "PI01115", "PI01116", "PI01117", "PI01118", "PI01119", "PI01120", "PI01121",
    "PI01122", "PI01123", "PI01148", "PI01149", "PI01150", "PI01151", "PI01152", "PI01153", "PI01154", "PI01155",
    "PI01156", "PI01157", "PI01158", "PI01159", "PI01160", "PI01161", "PI01162", "PI01163", "PI01164", "PI01165",
    "PI01166", "PI01167", "PI01168", "PI01169", "PI01170", "PI01171", "PI01172", "PI01173", "PI01174"]

earcuffs = [
    "BR03066T", "BR04014T", "BR03071T", "BR03063T", "BR03070T", "BR03150T", "BR03065T", "BR03067T", "BR03110T", "BR05448T",
    "BR02064T", "BR05258T", "BR05449T", "BR05271T", "BR05261T", "BR05249T", "BR05642T", "BR04824T", "BR04913T", "BR05117T",
    "BR05643T", "BR05254T", "BR04906T", "BR05587T", "BR04833T", "BR04923T", "BR05260T", "BR05262T", "BR04355T", "BR04915T",
    "BR06178T", "BR05002T", "BR05240T", "BR04852T", "BR03068T", "BR04850T", "BR05272T", "BR05397T", "BR04013T", "BR05649T",
    "BR05650T", "BR05812T", "BR06158T", "BR06192T", "BR06175T", "BR06179T", "BR05813T", "BR04922T", "BR06051T", "BR05259T",
    "BR06056T", "BR06063T", "BR06588T", "BR06159T", "BR06064T", "BR01787", "BR06176T", "BR06623T",
    "BR06155T", "BR06055T", "BR06059T", "BR06062T", "BR06621T", "BR06252T", "BR03196T", "BR06632T", "BR06633T", "BR04750T",
    "BR06901", "BR06594T", "BR06229T", "BR06674T", "BR06105T", "BR06897", "BR05392T", "BR06534T", "BR06900", "BR06620T",
    "BR06635T", "BR06262T", "BR06892", "BR06936T", "BR06940", "BR06279T", "BR06611T", "BR06642T"]