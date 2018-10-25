#!/bin/bash

# Cria a estrutura do script que sumariza e analisa as estatisticas coletadas
! [ -d $SCRIPT_DIR ] && mkdir -p $SCRIPT_DIR

# Bibliotecas perl necessarias para rodar os scripts
# CentOS, RedHat, etc usam alias para confirmacao do cp
\cp -a scripts/lib $SCRIPT_DIR

# Script transfere_testatisticas_rac.pl
TEMPLATE=scripts/templates/transfere_testatisticas_rac.pl
SCRIPT=scripts/gerados/transfere_testatisticas_rac.pl
cp -f $TEMPLATE $SCRIPT
chmod 755 $SCRIPT
sed -i "
  s!@LIB_DIR_STR@!$LIB_DIR_STR!g;
  s/@ORAHOST@/$ORAHOST/g;
  s/@ORAINST@/$ORAINST/g;
  s/@ORAUSER@/$ORAUSER/g;
  s/@PGHOST@/$PGHOST/g;
  s/@PGDATABASE@/$PGDATABASE/g;
  s/@PGSCHEMA@/$PGSCHEMA/g; 
  s/@PGUSUARIO@/$PGUSUARIO/g; 
  s/@PGSENHA@/$PGSENHA/g;
  s!@ENC_ORAPWD@!$ENC_ORAPWD!g;
  s!@ENC_PGPWD@!$ENC_PGPWD!g;
" $SCRIPT

mv -fv $SCRIPT $SCRIPT_DIR


# Script gerador de senhas criptografadas
TEMPLATE=scripts/templates/gera-senha.pl
SCRIPT=scripts/gerados/gera-senha.pl
cp -f $TEMPLATE $SCRIPT
chmod 755 $SCRIPT
sed -i "
  s!@LIB_DIR_STR@!$LIB_DIR_STR!g;
" $SCRIPT

mv -fv $SCRIPT $SCRIPT_DIR


# Gera a senha do Oracle e do PostgreSQL
GERADOR=$SCRIPT_DIR/gera-senha.pl
ARQ=`mktemp`
echo $ORAPWD > $ARQ
$GERADOR "$ARQ" "$ENC_ORAPWD"
echo $PGSENHA > $ARQ
$GERADOR "$ARQ" "$ENC_PGPWD"

echo "Definindo as permissoes para $SCRIPT_DIR"
chown -R postgres:postgres $SCRIPT_DIR


# Gera o arquivo de analise
TEMPLATE=scripts/templates/analisa_estatisticas.pl
SCRIPT=scripts/gerados/analisa_estatisticas.pl
cp -f $TEMPLATE $SCRIPT
chmod 755 $SCRIPT
sed -i "
  s!@LIB_DIR_STR@!$LIB_DIR_STR!g;
  s/@PGHOST@/$PGHOST/g;
  s/@PGDATABASE@/$PGDATABASE/g;
  s/@PGSCHEMA@/$PGSCHEMA/g; 
  s/@PGUSUARIO@/$PGUSUARIO/g; 
  s!@ENC_PGPWD@!$ENC_PGPWD!g;
" $SCRIPT

mv -fv $SCRIPT $SCRIPT_DIR



exit
