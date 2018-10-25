#!/bin/bash

# Carregar o arquivo se ainda nao tiver sido carregado
[ "$PGDBA" = "" ] && . env.sh

# Inicialmente nao ha erros nos pre-requisitos...
COD_ERRO=0
ARQ_ERRO=`mktemp`

# Pacotes do CentOS que devem estar instalados:
# yum install perl-Pod-Perldoc
# yum install perl-CPAN.noarch
# yum install perl-Crypt-CBC.noarch
# yum install perl-DBD-Pg.x86_64
echo "##################################################"
echo "#####    PACOTES DO SISTEMA OPERACIONAL     ######"
echo "##################################################"
echo "Verificando pacotes do sistema que devem estar instalados"
FALTANDO=""
LISTAPKG="perl-Pod-Perldoc perl-CPAN perl-Crypt-CBC perl-DBD-Pg"
for PKG in $LISTAPKG; do
  CHECK=`rpm -qi $PKG | grep ^Version | awk '{print $3}'`
  if [ "$CHECK" = "" ]; then
    echo "ERRO - Pacote $PKG não instalado."
    FALTANDO="$PKG $FALTANDO"
    COD_ERRO=1
  else
    echo "OK - $PKG versao $CHECK instalada"
  fi
done
echo

echo "##################################################"
echo "#####    TESTES DE MODULOS DO PERL          ######"
echo "##################################################"
# Achar os modulos perl utilizados e testar todos
# grep -r "[ ]*use " * | grep -v constant | sed 's/[^:]*://; s/use //;s/qw.*//' | sort -u | grep '::' | tr '\n' ' ' | tr -d ';' | tr -s ' ' ' '; echo
# Alem dos que estao descritos, o Crypt::Blowfish tambem eh usado
MODS="Crypt::CBC Crypt::Blowfish Data::Dumper DBD::Oracle DBD::Pg Getopt::Long MIME::Base64 Time::HiRes Time::Local"
for MOD in $MODS; do
  printf "Testando modulo perl $MOD: "
  perl -M$MOD -e 'print "";' 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "OK"
  else
    echo "FALHOU"
    echo "Modulo $MOD com problemas ou nao existe. Instalar via pacote ou CPAN"
    echo "Lembrar que o Oracle precisa definir ORACLE_HOME / LD_LIBRARY_PATH"
    COD_ERRO=1
  fi
done
echo


echo "##################################################"
echo "#####    TESTES DE CONEXAO COM O ORACLE     ######"
echo "##################################################"
# Oracle client configurado, com arquivo tnsnames.ora?
if [ "$ORACLE_HOME" = "" ]; then
  echo "A variavel ORACLE_HOME nao esta definida. O script nao vai rodar."
  COD_ERRO=1
fi

# Testa a conexao do usuario com o Oracle
SQLPLUS=`which sqlplus 2>/dev/null`
[ "$SQLPLUS" = "" ] && SQLPLUS=`which sqlplus64 2>/dev/null`

if [ "$SQLPLUS" = "" ]; then
  echo "sqlplus nao encontrado. Instalar o cliente Oracle"
  COD_ERRO=1
else
  $SQLPLUS $ORAUSER/$ORAPWD@$ORAHOST:1521/$ORAINST <<EOF >/dev/null
  SELECT * FROM DUAL;
  QUIT;
EOF
  # Se a conexao deu erro, avisar que deve ter parametros errados
  if [ $? -ne 0 ]; then
    echo "ERRO: Nao foi possivel conectar ao oracle como usuario $ORAUSER"
    echo "Verificar parametros de conexao com o Oracle no arquivo env.sh"
    echo "Verificar se usuario nao esta bloqueado ou se pode conectar"
    COD_ERRO=1
  else
    echo "Conexao com Oracle: OK"
  fi
fi
echo

echo "##################################################"
echo "###    PARAMETROS DE CONEXAO COM O POSTGRES   ####"
echo "##################################################"
# Verificar se existe a entrada no pg_hba.conf
# senao o perl nao conecta no postgres
export PGPASSWORD=$PGSENHADBA
CMD="SHOW DATA_DIRECTORY"
DATADIR=`psql --tuples-only -U $PGDBA -h $PGHOST -d $PGDATABASE -c "$CMD"`
PG_HBA=$DATADIR/pg_hba.conf
PGHOST_IP=`ping -c 1 $PGHOST | grep ^PING | sed 's/[^(]*(\([^)]*\).*/\1/'`

HBAOK=`grep -Ei "$PGHOST|$PGHOST_IP"  $PG_HBA | grep $PGUSUARIO`
if [ "$HBAOK" = "" ]; then
  echo "ERRO: A entrada de $PGUSUARIO nao existe em $PG_HBA"
  echo "Deve-se adicionar a seguinte entrada e recarregar o servico:"
  echo "host  all   $PGUSUARIO    $PGHOST_IP/32   md5"
  exit 1
else
  echo "Entrada para $PGUSUARIO encontrada no arquivo $PG_HBA"
fi
echo

echo "##################################################"
echo "###    CRIAÇÃO DO DIRETÓRIO DE GERADOS        ####"
echo "##################################################"

! [ -d scripts/gerados ] && mkdir scripts/gerados

exit $COD_ERRO
