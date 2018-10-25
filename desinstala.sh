#!/bin/bash

# Leitura dos parametros de instalacao/configuracao
. env.sh

UNINSTALL_LOG=instala.log
[ -f $UNINSTALL_LOG ] && rm -f $UNINSTALL_LOG

# Remover os objetos
echo "Removendo objetos criados"
export PGPASSWORD=$PGSENHADBA
PSQL=`which psql`
$PSQL -U $PGDBA -h $PGHOST -d $PGDATABASE <<EOF
DROP SCHEMA $PGSCHEMA CASCADE;
DROP USER $PGUSUARIO;
EOF

# Apagar os scripts
echo "Apagando conteudo de $SCRIPT_DIR"
rm -rf $SCRIPT_DIR/*

echo "Lembrar de remover as entradas da crontab"
