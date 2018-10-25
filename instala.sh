#!/bin/bash

# Leitura dos parametros de instalacao/configuracao
. env.sh

INSTALL_LOG=instala.log
[ -f $INSTALL_LOG ] && rm -f $INSTALL_LOG

# Verifica se o sistema possui os pre-requisitos instalados
./01-verifica-prerequisitos.sh
if [ $? -ne 0 ]; then
  echo "Pre-requisitos nao atendidos. Verificar log."
  exit 1
fi

# Criacao dos objetos no PostgreSQL
./02-cria-objetos.sh

# Copia dos scripts
./03-cria-scripts.sh

# Ajustes e validacoes finais 
./04-ajustes.sh
