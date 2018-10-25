# Parametros para configuracao do processo de transferencia e analise 
# de estatisticas geradas pelo Oracle para o PostgreSQL

#echo "VERIFIQUE AS VARIAVEIS E COMENTE ESTA LINHA" && exit

# Banco/Instancia do Postgres
export PGDATABASE=
# Host de conexao
export PGHOST=
# Schema onde vao ficar os objetos criados (tabelas)
export PGSCHEMA=
# Usuario e senha donos do schema e dos objetos criados
export PGUSUARIO=
export PGSENHA=
# DBA / postgres
export PGDBA=
export PGSENHADBA=
# Usuario que conecta no Oracle para buscar as estatisticas
export ORAUSER=
export ORAPWD=
export ORAHOST=
export ORAINST=

# Estrutura de scripts
export SCRIPT_DIR=/pgsql/scripts/
export LIB_DIR=$SCRIPT_DIR/lib
export LIB_DIR_STR='/pgsql/scripts/lib'
export ENC_ORAPWD='/pgsql/scripts/senha_ora.dat';
export ENC_PGPWD='/pgsql/scripts/senha_pg.dat';
