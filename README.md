# Capta ETL

ETL que extrai dados do ERP Capta (SQL Server), gera CSVs/Parquet e publica
via FTP em `jackvartanian.net/cms/wp-content/uploads/datasets/` para consumo
dos dashboards (Power BI / Streamlit).

Migrado do Agendador de Tarefas do Windows para rodar em servidor Linux (Hostinger).

## Estrutura

| Arquivo | Papel |
|---|---|
| `update_day.py` | Atualizacao diaria: calendario, dolar, produtos, clientes, DP, fabrica |
| `update_minutes.py` | Atualizacao frequente: vendas e fabrica |
| `update_estoque.py` | Atualizacao de estoques (venda, reposicao, barra, adega, embalagem) |
| `update_conciliacao.py` / `update_fin.py` | Financeiro (desabilitados no agendador atual) |
| `funcoes_comuns.py` | Conexoes (SQL Server, Postgres, FTP) e utilitarios de CSV/Parquet |
| `funcoes_*.py` | Consultas e transformacoes por area |
| `sql/` | Queries SQL organizadas por area |
| `datasets/` | Saida local dos arquivos gerados (nao versionado) |
| `testa_conexao_capta.py` | Diagnostico de rede + login no banco do Capta |

## Setup no servidor

```bash
sudo apt update && sudo apt install -y python3 python3-pip python3-venv freetds-dev

git clone <url-do-repositorio> capta-etl
cd capta-etl

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
nano .env   # preencher as credenciais

# validar acesso ao banco (exige VPN para a rede da empresa)
python testa_conexao_capta.py
```

## Credenciais (.env)

Todas as credenciais ficam no arquivo `.env` (nunca versionado — ver `.gitignore`).
O `.env.example` documenta as variaveis necessarias:

- `CAPTA_DB_*` — SQL Server do ERP (rede interna, exige VPN)
- `POSTGRES_URL` — PostgreSQL (EasyPanel)
- `FTP_*` — FTP de publicacao dos datasets

## Agendamento (cron)

Equivalente as tarefas do Agendador do Windows (`crontab -e`):

```cron
# Capta_Diario - todos os dias as 06:08
8 6 * * * cd /caminho/capta-etl && ./venv/bin/python update_day.py >> logs_dia.txt 2>&1

# Capta_Meia_Hora - a cada 30 min (06:15 as 23:45)
15,45 6-23 * * * cd /caminho/capta-etl && ./venv/bin/python update_minutes.py >> logs_min.txt 2>&1

# Capta_estoque - a cada 5 min
*/5 * * * * cd /caminho/capta-etl && ./venv/bin/python update_estoque.py >> logs_estoque.txt 2>&1
```

Conferir o fuso do servidor (`timedatectl`); se estiver em UTC, ajustar os
horarios ou rodar `sudo timedatectl set-timezone America/Sao_Paulo`.

## Requisitos de rede

O SQL Server (`192.168.48.9:1433`) so e alcancavel pela rede interna da
empresa. O servidor precisa de VPN/rota configurada pelo TI. Use
`python testa_conexao_capta.py` para diagnosticar.
