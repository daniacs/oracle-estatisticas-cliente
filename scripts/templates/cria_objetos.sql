-- Script que cria os objetos necessarios para a transferencia e analise de 
-- estatisticas no banco de dados PostgreSQL.

-- Verifica o tempo que as operações são feitas
\timing on

-- Schema onde são guardados os objetos
-- CREATE SCHEMA @PGSCHEMA@ AUTHORIZATION @PGUSUARIO@;
DO $$
DECLARE
  namespace varchar(128);
  usuario   varchar(128);
BEGIN
  SELECT nspname, usename INTO namespace, usuario
  FROM pg_catalog.pg_namespace ns 
  JOIN pg_catalog.pg_user u ON (u.usesysid = ns.nspowner)
  WHERE nspname = lower('@PGSCHEMA@');
  IF namespace IS NULL AND usuario IS NULL THEN
    RAISE NOTICE 'Criando schema @PGSCHEMA@';
    CREATE SCHEMA @PGSCHEMA@;
  ELSE
    RAISE WARNING 'SCHEMA % ja pertence ao usuario %', namespace, usuario;
  END IF;
END
$$;

-- Cria o usuario que acessa os objetos criados
-- Se o usuario ja existe, apenas adiciona o schema criado
DO $$
DECLARE
  us varchar(128);
  cur_path varchar(256);
BEGIN
  SELECT usename INTO us FROM pg_catalog.pg_user WHERE usename = '@PGUSUARIO@';
  IF us IS NULL THEN
    RAISE NOTICE 'Criando o usuario @PGUSUARIO@';
    CREATE USER @PGUSUARIO@ LOGIN PASSWORD '@PGSENHA@';
    ALTER USER @PGUSUARIO@ SET search_path=public,@PGSCHEMA@;
  ELSE
    RAISE WARNING 'Usuario % ja existe. Alterando o search_path.', us;
    SELECT regexp_replace(setting,'^search_path[ ]*=[ ]*', '')  INTO cur_path
    FROM (
        SELECT usename, unnest(useconfig) as setting from pg_catalog.pg_user
    ) T 
    WHERE setting LIKE 'search_path%' 
    AND setting NOT ILIKE '%@PGSCHEMA@%' AND usename = '@PGUSUARIO@';
    IF cur_path IS NOT NULL THEN
      cur_path := cur_path||', @PGSCHEMA@';
    ELSE
      cur_path := 'public,@PGSCHEMA@';
    END IF;
    EXECUTE 'ALTER USER @PGUSUARIO@ SET SEARCH_PATH='||cur_path||';';
  END IF;
END
$$;

-- Transfere o schema para o usuario criado
ALTER SCHEMA @PGSCHEMA@ OWNER TO @PGUSUARIO@;

-- Criação da tabela (se ela nao existir no schema destino)
DO $$
DECLARE
  tab varchar(128);
BEGIN
  SELECT tablename into tab
  FROM pg_catalog.pg_tables 
  WHERE lower(tablename) = 'testatisticas_rac' and schemaname = '@PGSCHEMA@';

  IF tab IS NULL THEN
    RAISE NOTICE 'Criando tabela @PGSCHEMA@.testatisticas_rac';
    CREATE TABLE @PGSCHEMA@.testatisticas_rac (
      inst_id     int not null,
      sid         int not null,
      schemaname  varchar(30) not null,
      timestamp   timestamp without time zone not null,
      statistic   int not null,
      value       numeric,
      machine     varchar(64),
      program     varchar(48),
      event       int),
      logon_time  timestamp without time zone;
    
    -- Tabelas são do usuário @PGUSUARIO@
    ALTER TABLE @PGSCHEMA@.testatisticas_rac OWNER TO @PGUSUARIO@;
    
    -- Criação dos índices
    CREATE INDEX testatisticas_rac_idx01 ON @PGSCHEMA@.testatisticas_rac(timestamp);
    CREATE INDEX testatisticas_rac_idx02 ON @PGSCHEMA@.testatisticas_rac(program);
  ELSE
    RAISE WARNING 'Tabela @PGSCHEMA@.testatisticas_rac ja existe!';
  END IF;
END $$;
