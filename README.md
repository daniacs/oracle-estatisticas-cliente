
* Sistema de extração e análise das estatisticas do Oracle para o PostgreSQL

Instalacao:
1. Editar TODOS os parametros no arquivo env.sh
2. Executar o ./instala.sh

Passos da instalacao:
1. Verifica os pré-requisitos para instalar a ferramenta de extração e análise
2. Chama o script cria_objetos.sql;
  1. Cria o schema definido em $PGSCHEMA
  2. Cria o usuario definido em $PGUSUARIO com senha $PGSENHA
  3. Cria a tabela $PGSCHEMA.testatisticas_rac que ira receber a transferencia da tabela original
3. Copia os scripts (com os parametros definidos em env.sh) para o diretorio destino ($SCRIPT_DIR)
4. Verifica se o usuario criado no PostgreSQL pode se conectar ao banco

Configuração
1.  Incluir na crontab do usuario postgres o script $SCRIPT_DIR/transfere_testatisticas_rac.pl

Desinstalação
1.  Remover da crontab a entrada de $SCRIPT_DIR/transfere_testatisticas_rac.pl
2.  Executar o script ./desinstala.sh com os parametros corretos, definidos em env.sh
