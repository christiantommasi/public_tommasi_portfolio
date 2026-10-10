-- =====================================================================
-- Script: criacao e importacao da tabela clientes_bet_aml_fraude
-- Uso: PostgreSQL / pgAdmin
-- Arquivo de origem: clientes_bet_aml_fraude.csv (500.000 linhas)
-- =====================================================================

DROP TABLE IF EXISTS public.clientes_bet_aml_fraude;

CREATE TABLE public.clientes_bet_aml_fraude (
    id_cliente                                     INTEGER PRIMARY KEY,
    nome                                            VARCHAR(60)     NOT NULL,
    sobrenome                                       VARCHAR(80)     NOT NULL,
    email                                           VARCHAR(120)    NOT NULL,
    telefone                                        VARCHAR(20)     NOT NULL,
    data_cadastro                                   DATE            NOT NULL,
    pais_registro                                   VARCHAR(40),
    pais_ip_ultima_transacao                        VARCHAR(40),
    geolocalizacao_inconsistente                    VARCHAR(3),
    uso_vpn_proxy                                   VARCHAR(3),
    numero_dispositivos_distintos                   SMALLINT,
    numero_contas_mesmo_dispositivo                 SMALLINT,
    numero_contas_mesmo_documento                   SMALLINT,
    numero_contas_mesmo_metodo_pagamento            SMALLINT,
    numero_metodos_pagamento_distintos              SMALLINT,
    valor_deposito_total                            NUMERIC(14,2),
    numero_depositos                                INTEGER,
    valor_medio_deposito                            NUMERIC(14,2),
    numero_depositos_proximos_limite_declaracao     SMALLINT,
    valor_saque_total                               NUMERIC(14,2),
    numero_saques                                   INTEGER,
    razao_saque_deposito                            NUMERIC(8,4),
    tempo_medio_deposito_saque_horas                NUMERIC(10,2),
    valor_apostado_cassino                          NUMERIC(14,2),
    valor_apostado_sportbook                        NUMERIC(14,2),
    valor_ganho_cassino                             NUMERIC(14,2),
    valor_ganho_sportbook                           NUMERIC(14,2),
    razao_ganho_aposta_cassino                      NUMERIC(8,4),
    desvio_padrao_valor_aposta                      NUMERIC(10,2),
    numero_apostas_espelhadas                       INTEGER,
    id_conta_relacionada_suspeita                   INTEGER,
    bonus_usados                                    NUMERIC(14,2),
    bonus_ganhos                                    NUMERIC(14,2),
    numero_alertas_compliance                       SMALLINT,
    score_risco_aml                                 NUMERIC(5,1),
    flag_estruturacao                               VARCHAR(3),
    flag_multiplas_contas                           VARCHAR(3),
    flag_chip_dumping                               VARCHAR(3),
    flag_padrao_baixo_risco_lavagem                 VARCHAR(3),
    flag_saque_rapido                               VARCHAR(3),
    flag_suspeita_lavagem_dinheiro                  VARCHAR(3),
    status_investigacao                             VARCHAR(20),
    status_conta                                    VARCHAR(20),
    pendente_validacao_documento                    VARCHAR(3),
    data_ultimo_alerta                              DATE
);

-- Indices para consultas analiticas e de compliance
CREATE INDEX idx_aml_flag_suspeita        ON public.clientes_bet_aml_fraude (flag_suspeita_lavagem_dinheiro);
CREATE INDEX idx_aml_score_risco          ON public.clientes_bet_aml_fraude (score_risco_aml);
CREATE INDEX idx_aml_status_investigacao  ON public.clientes_bet_aml_fraude (status_investigacao);
CREATE INDEX idx_aml_status_conta         ON public.clientes_bet_aml_fraude (status_conta);
CREATE INDEX idx_aml_conta_relacionada    ON public.clientes_bet_aml_fraude (id_conta_relacionada_suspeita);
CREATE INDEX idx_aml_data_cadastro        ON public.clientes_bet_aml_fraude (data_cadastro);

-- =====================================================================
-- IMPORTACAO DO CSV
-- =====================================================================
-- Observacao: a coluna "data_ultimo_alerta" pode vir vazia no CSV
-- (string vazia) para clientes sem alertas. O COPY/\copy do Postgres
-- trata string vazia como NULL automaticamente quando o tipo da coluna
-- e DATE, contanto que nao seja definida uma opcao NULL AS diferente.

-- Opcao A) COPY executado no proprio servidor (arquivo precisa estar
-- na maquina do Postgres):
-- COPY public.clientes_bet_aml_fraude
-- FROM '/caminho/completo/clientes_bet_aml_fraude.csv'
-- WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', DELIMITER ',');

-- Opcao B) RECOMENDADA no pgAdmin (le o arquivo do seu computador,
-- funciona mesmo com banco remoto):
-- 1. Rode os comandos CREATE TABLE acima.
-- 2. Clique com o botao direito na tabela "clientes_bet_aml_fraude"
--    no painel esquerdo -> Import/Export Data...
-- 3. Import = On; General: Filename = caminho do
--    clientes_bet_aml_fraude.csv na sua maquina.
-- 4. Options: Format = csv, Header = Yes, Delimiter = , (virgula),
--    Encoding = UTF8.
-- 5. Columns: confira se a ordem das colunas bate com a da tabela
--    (deve bater, pois foi gerada na mesma ordem).
-- 6. OK para iniciar a importacao.

-- Opcao C) via terminal psql:
-- \copy public.clientes_bet_aml_fraude FROM 'clientes_bet_aml_fraude.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', DELIMITER ',');

-- =====================================================================
-- Consultas uteis apos a importacao
-- =====================================================================
-- Total de registros
-- SELECT COUNT(*) FROM public.clientes_bet_aml_fraude;

-- Distribuicao do score de risco entre suspeitos e nao suspeitos
-- SELECT flag_suspeita_lavagem_dinheiro,
--        COUNT(*) AS total,
--        ROUND(AVG(score_risco_aml), 1) AS score_medio
-- FROM public.clientes_bet_aml_fraude
-- GROUP BY flag_suspeita_lavagem_dinheiro;

-- Top 20 contas com maior score de risco ainda sem investigacao
-- SELECT id_cliente, nome, sobrenome, score_risco_aml, status_investigacao
-- FROM public.clientes_bet_aml_fraude
-- WHERE status_investigacao = 'Nenhuma'
-- ORDER BY score_risco_aml DESC
-- LIMIT 20;

-- Possiveis pares de contas ligadas por apostas espelhadas (chip dumping)
-- SELECT a.id_cliente AS conta_a, b.id_cliente AS conta_b,
--        a.numero_apostas_espelhadas, a.score_risco_aml
-- FROM public.clientes_bet_aml_fraude a
-- JOIN public.clientes_bet_aml_fraude b
--   ON a.id_conta_relacionada_suspeita = b.id_cliente
-- WHERE a.flag_chip_dumping = 'Sim'
-- ORDER BY a.numero_apostas_espelhadas DESC
-- LIMIT 50;

-- Padrao de estruturacao (depositos proximos ao limite de declaracao)
-- SELECT id_cliente, nome, sobrenome, numero_depositos_proximos_limite_declaracao,
--        valor_deposito_total, score_risco_aml
-- FROM public.clientes_bet_aml_fraude
-- WHERE flag_estruturacao = 'Sim'
-- ORDER BY numero_depositos_proximos_limite_declaracao DESC
-- LIMIT 50;