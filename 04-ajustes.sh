#!/bin/bash

# Inicialmente nao ha erros nos pre-requisitos...
COD_ERRO=0
ARQ_ERRO=`mktemp`

echo "##################################################"
echo "#####    TESTES DE CONEXAO COM O POSTGRES   ######"
echo "##################################################"

# Testa a conexao com o PostgreSQL. 
# Se nao tiver PSQL em env.sh, tenta achar no sistema
[ "$PSQL" = "" ] && PSQL=`which psql`
if [ "$PSQL" = "" ]; then
  echo "Nao foi possivel encontrar o comando psql."
  COD_ERRO=1
else
  export PGPASSWORD=$PGSENHA
  $PSQL -h $PGHOST -U $PGUSUARIO -d $PGDATABASE -c "SELECT 1;" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "ERRO: Nao foi possivel conectar ao postgresql com usuario $PGUSUARIO"
    echo "Verificar se $PGUSUARIO pode se conectar em $PGDATABASE"
    echo "A entrada $PGUSUARIO para $PGDATABASE e $PGHOST esta em pg_hba.conf?"
    COD_ERRO=1
  else
    echo "Conexao com PostgreSQL: OK"
  fi
fi
echo

echo "Removendo arquivos gerados"
rm -rf scripts/gerados/*

echo "**************************** IMPORTANTE **************************"
echo "Lembrar de configurar as variaveis de ambiente na crontab: "
echo "- ORACLE_HOME           ($ORACLE_HOME)"
echo "- LD_LIBRARY_PATH       ($LD_LIBRARY_PATH)"
echo "- PERL5LIB              ($PERL5LIB)"
echo "- PERL_MM_OPT           ($PERL_MM_OPT)"
echo "- PERL_MB_OPT           ($PERL_MB_OPT)"
echo "- PERL_LOCAL_LIB_ROOT   ($PERL_LOCAL_LIB_ROOT)"

exit $COD_ERRO
