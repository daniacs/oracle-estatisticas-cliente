-- Verifica o tempo que as operações são feitas

\timing on

-- Criar a tablespace

CREATE TABLESPACE ts_estatisticas OWNER abd7  LOCATION '/pgsql/tablespaces/ts_estatisticas';

-- Se a tabela já existe, renomear

ALTER TABLE testatisticas_rac RENAME TO testatisticas_rac_full;

-- Criação da tabela mãe

CREATE TABLE testatisticas_rac (
  inst_id     int not null,
  sid         int not null,
  schemaname  varchar(30) not null,
  timestamp   timestamp without time zone not null,
  statistic   int not null,
  value       numeric,
  machine     varchar(64),
  program     varchar(48),
  event       int)
PARTITION BY RANGE(timestamp)
TABLESPACE ts_estatisticas;

-- Criação das partições

------------- 2017 -------------
CREATE TABLE testatisticas_rac_2017_08 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2017-08-01') TO ('2017-09-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2017_09 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2017-09-01') TO ('2017-10-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2017_10 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2017-10-01') TO ('2017-11-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2017_11 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2017-11-01') TO ('2017-12-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2017_12 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2017-12-01') TO ('2018-01-01')
  TABLESPACE ts_estatisticas;

------------- 2018 -------------
CREATE TABLE testatisticas_rac_2018_01 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-01-01') TO ('2018-02-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_02 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-02-01') TO ('2018-03-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_03 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-03-01') TO ('2018-04-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_04 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-04-01') TO ('2018-05-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_05 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-05-01') TO ('2018-06-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_06 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-06-01') TO ('2018-07-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_07 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-07-01') TO ('2018-08-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_08 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-08-01') TO ('2018-09-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_09 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-09-01') TO ('2018-10-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_10 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-10-01') TO ('2018-11-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_11 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-11-01') TO ('2018-12-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2018_12 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2018-12-01') TO ('2019-01-01')
  TABLESPACE ts_estatisticas;

------------- 2019 -------------
CREATE TABLE testatisticas_rac_2019_01 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-01-01') TO ('2019-02-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_02 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-02-01') TO ('2019-03-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_03 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-03-01') TO ('2019-04-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_04 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-04-01') TO ('2019-05-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_05 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-05-01') TO ('2019-06-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_06 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-06-01') TO ('2019-07-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_07 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-07-01') TO ('2019-08-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_08 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-08-01') TO ('2019-09-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_09 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-09-01') TO ('2019-10-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_10 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-10-01') TO ('2019-11-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_11 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-11-01') TO ('2019-12-01')
  TABLESPACE ts_estatisticas;

CREATE TABLE testatisticas_rac_2019_12 PARTITION OF testatisticas_rac
  FOR VALUES FROM ('2019-12-01') TO ('2020-01-01')
  TABLESPACE ts_estatisticas;

-- Tabelas são do usuário abd7
ALTER TABLE testatisticas_rac OWNER TO abd7;
ALTER TABLE testatisticas_rac_2017_08 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2017_09 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2017_10 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2017_11 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2017_12 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_01 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_02 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_03 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_04 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_05 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_06 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_07 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_08 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_09 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_10 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_11 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2018_12 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_01 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_02 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_03 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_04 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_05 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_06 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_07 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_08 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_09 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_10 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_11 OWNER TO abd7;
ALTER TABLE testatisticas_rac_2019_12 OWNER TO abd7;


-- Inserção dos dados
INSERT INTO testatisticas_rac SELECT * FROM testatisticas_rac_full;

-- Criação dos índices
CREATE INDEX testatisticas_rac_2017_08_idx ON testatisticas_rac_2017_08(timestamp);
CREATE INDEX testatisticas_rac_2017_09_idx ON testatisticas_rac_2017_09(timestamp);
CREATE INDEX testatisticas_rac_2017_10_idx ON testatisticas_rac_2017_10(timestamp);
CREATE INDEX testatisticas_rac_2017_11_idx ON testatisticas_rac_2017_11(timestamp);
CREATE INDEX testatisticas_rac_2017_12_idx ON testatisticas_rac_2017_12(timestamp);
CREATE INDEX testatisticas_rac_2018_01_idx ON testatisticas_rac_2018_01(timestamp);
CREATE INDEX testatisticas_rac_2018_02_idx ON testatisticas_rac_2018_02(timestamp);
CREATE INDEX testatisticas_rac_2018_03_idx ON testatisticas_rac_2018_03(timestamp);
CREATE INDEX testatisticas_rac_2018_04_idx ON testatisticas_rac_2018_04(timestamp);
CREATE INDEX testatisticas_rac_2018_05_idx ON testatisticas_rac_2018_05(timestamp);
CREATE INDEX testatisticas_rac_2018_06_idx ON testatisticas_rac_2018_06(timestamp);
CREATE INDEX testatisticas_rac_2018_07_idx ON testatisticas_rac_2018_07(timestamp);
CREATE INDEX testatisticas_rac_2018_08_idx ON testatisticas_rac_2018_08(timestamp);
CREATE INDEX testatisticas_rac_2018_09_idx ON testatisticas_rac_2018_09(timestamp);
CREATE INDEX testatisticas_rac_2018_10_idx ON testatisticas_rac_2018_10(timestamp);
CREATE INDEX testatisticas_rac_2018_11_idx ON testatisticas_rac_2018_11(timestamp);
CREATE INDEX testatisticas_rac_2018_12_idx ON testatisticas_rac_2018_12(timestamp);
CREATE INDEX testatisticas_rac_2019_01_idx ON testatisticas_rac_2019_01(timestamp);
CREATE INDEX testatisticas_rac_2019_02_idx ON testatisticas_rac_2019_02(timestamp);
CREATE INDEX testatisticas_rac_2019_03_idx ON testatisticas_rac_2019_03(timestamp);
CREATE INDEX testatisticas_rac_2019_04_idx ON testatisticas_rac_2019_04(timestamp);
CREATE INDEX testatisticas_rac_2019_05_idx ON testatisticas_rac_2019_05(timestamp);
CREATE INDEX testatisticas_rac_2019_06_idx ON testatisticas_rac_2019_06(timestamp);
CREATE INDEX testatisticas_rac_2019_07_idx ON testatisticas_rac_2019_07(timestamp);
CREATE INDEX testatisticas_rac_2019_08_idx ON testatisticas_rac_2019_08(timestamp);
CREATE INDEX testatisticas_rac_2019_09_idx ON testatisticas_rac_2019_09(timestamp);
CREATE INDEX testatisticas_rac_2019_10_idx ON testatisticas_rac_2019_10(timestamp);
CREATE INDEX testatisticas_rac_2019_11_idx ON testatisticas_rac_2019_11(timestamp);
CREATE INDEX testatisticas_rac_2019_12_idx ON testatisticas_rac_2019_12(timestamp);


-- Jogar as tabelas para o schema pgstat
CREATE SCHEMA pgstat AUTHORIZATION abd7;
ALTER TABLE testatisticas_rac            SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2017_08    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2017_09    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2017_10    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2017_11    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2017_12    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_01    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_02    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_03    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_04    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_05    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_06    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_07    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_08    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_09    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_10    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_11    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2018_12    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_01    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_02    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_03    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_04    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_05    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_06    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_07    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_08    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_09    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_10    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_11    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_2019_12    SET SCHEMA pgstat;
ALTER TABLE testatisticas_rac_full       SET SCHEMA pgstat;

ALTER USER abd7 SET search_path=abd7,pgdba,pgstat,public;