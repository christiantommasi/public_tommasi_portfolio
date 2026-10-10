-- =====================================================================
-- Script: criacao e importacao da tabela clientes_bet_online
-- Uso: PostgreSQL / pgAdmin
-- Arquivo de origem: clientes_bet_online.csv (500.000 linhas)
-- =====================================================================

-- 1) (Opcional) Cria um schema dedicado
-- CREATE SCHEMA IF NOT EXISTS bet;

-- 2) Remove a tabela se ja existir (cuidado em producao)
DROP TABLE IF EXISTS public.clientes_bet_online;

-- 3) Cria a tabela com os tipos equivalentes as colunas do CSV
CREATE TABLE public.clientes_bet_online (
    id_cliente                     INTEGER PRIMARY KEY,
    nome                            VARCHAR(60)     NOT NULL,
    sobrenome                       VARCHAR(80)     NOT NULL,
    email                            VARCHAR(120)    NOT NULL,
    telefone                        VARCHAR(20)     NOT NULL,
    data_cadastro                   DATE            NOT NULL,
    valor_deposito_total             NUMERIC(14,2)   NOT NULL DEFAULT 0,
    valor_saque_total                NUMERIC(14,2)   NOT NULL DEFAULT 0,
    bonus_usados                    NUMERIC(14,2)   NOT NULL DEFAULT 0,
    bonus_ganhos                    NUMERIC(14,2)   NOT NULL DEFAULT 0,
    valor_apostado_cassino           NUMERIC(14,2)   NOT NULL DEFAULT 0,
    valor_apostado_sportbook         NUMERIC(14,2)   NOT NULL DEFAULT 0,
    valor_ganho_cassino              NUMERIC(14,2)   NOT NULL DEFAULT 0,
    valor_ganho_sportbook            NUMERIC(14,2)   NOT NULL DEFAULT 0,
    tipo_jogo_preferido              VARCHAR(30),
    status_conta                    VARCHAR(20),
    pendente_validacao_documento     VARCHAR(3)      -- 'Sim' / 'Nao'
);

-- Indices uteis para consultas analiticas
CREATE INDEX idx_clientes_bet_status         ON public.clientes_bet_online (status_conta);
CREATE INDEX idx_clientes_bet_tipo_jogo      ON public.clientes_bet_online (tipo_jogo_preferido);
CREATE INDEX idx_clientes_bet_data_cadastro  ON public.clientes_bet_online (data_cadastro);

-- =====================================================================
-- 4) IMPORTACAO DO CSV
-- =====================================================================
-- O comando COPY abaixo roda NO SERVIDOR do PostgreSQL, ou seja, o
-- caminho do arquivo precisa existir na maquina onde o Postgres esta
-- rodando (nao na sua maquina local, se o banco for remoto).
--
-- Ajuste o caminho conforme onde voce salvar o arquivo no servidor:

-- COPY public.clientes_bet_online
-- FROM 'C:\caminho\completo\clientes_bet_online.csv'   -- Windows
-- -- FROM '/caminho/completo/clientes_bet_online.csv'   -- Linux/Mac
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', DELIMITER ',');

-- ---------------------------------------------------------------------
-- OPCAO RECOMENDADA para pgAdmin (funciona mesmo com banco remoto):
-- ---------------------------------------------------------------------
-- 1. No pgAdmin, crie a tabela executando os comandos CREATE TABLE acima.
-- 2. No painel esquerdo, clique com o botao direito na tabela
--    "clientes_bet_online" -> Import/Export Data...
-- 3. Selecione "Import", aponte para o arquivo clientes_bet_online.csv
--    (no SEU computador local).
-- 4. Em "Options": Format = csv, Header = ativado (Yes),
--    Delimiter = , (virgula), Encoding = UTF8.
-- 5. Clique em OK. O pgAdmin usa \copy internamente, que le o arquivo
--    da sua maquina local e envia os dados pela conexao, funcionando
--    tanto para banco local quanto remoto.
--
-- ---------------------------------------------------------------------
-- OPCAO alternativa via terminal psql (tambem le do lado do cliente):
-- ---------------------------------------------------------------------
-- \copy public.clientes_bet_online FROM 'clientes_bet_online.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', DELIMITER ',');

-- =====================================================================
-- 5) Conferencia rapida apos a importacao
-- =====================================================================
-- SELECT COUNT(*) FROM public.clientes_bet_online;
-- SELECT * FROM public.clientes_bet_online LIMIT 10;
-- SELECT status_conta, COUNT(*) FROM public.clientes_bet_online GROUP BY status_conta;
