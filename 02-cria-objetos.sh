#!/bin/bash

# Altera o arquivo template para criar os objetos no banco
TEMPLATE=scripts/templates/cria_objetos.sql
ARQSQL=scripts/gerados/cria_objetos.sql

cp -f $TEMPLATE $ARQSQL
sed -i "
  s/@PGSCHEMA@/$PGSCHEMA/g; 
  s/@PGUSUARIO@/$PGUSUARIO/g; 
  s/@PGSENHA@/$PGSENHA/g" $ARQSQL

# Cria os objetos no PostgreSQL
export PGPASSWORD=$PGSENHADBA
psql -h $PGHOST -U $PGDBA -d $PGDATABASE -f $ARQSQL
if [ $? -ne 0 ]; then
  echo 'Erro ao criar os objetos do PostgreSQL!'
fi

exit
