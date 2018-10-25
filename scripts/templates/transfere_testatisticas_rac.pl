#!/usr/bin/perl

#q// same thing as using single quotes - doesn't interpolate values 
#qq// is the same as double quoting a string. It interpolates.
#qw// @q = qw/this is a test/ <==> @q = ('this', 'is', 'a', 'test')
#qx// is the same thing as using the backtick operators.
#qr// quote expressao regular

# Copia os registros da tabela TESTATISTICAS_RAC do Oracle para o PostgreSQL
# Se a data não for definida, copia as entradas do dia anterior
# Se a data de inicio não for definida, ela é definida como "ontem"
# Se a data de fim não for definida, é definida como "hoje"
#
# Exemplos:
#
# * Faz a contagem de linhas entre o dia anterior (0h) e o dia atual (0h)
# ./transfere_testatisticas_rac.pl --contagem
#
# * Transfere as linhas 0h do dia anterior e 0h de "hoje"
# transfere_testatisticas_rac.pl
#
# * Transfere as linhas entre 10h e 12:30 do dia 01/01/2018
# ./transfere_testatisticas_rac.pl --inicio=01012018-1000 --fim=01012018-1230
# 
# * Transfere as linhas do dia 12/02/2018 e envia o log por e-mail
# ./transfere_testatisticas_rac.pl --inicio=12022018 --fim=13022018 --log /tmp/tranf.log
#
#
# ************************* IMPORTANTE ***************************
# AS TABELAS NO ORACLE E NO POSTGRESQL DEVEM TER A MESMA ESTRUTURA
# OS ATRIBUTOS DEVEM TER MESMO NOME E TIPO NOS DOIS BANCOS

use strict;
use lib "@LIB_DIR_STR@";
use Oracle;
use Postgres;
use Data;
use Data::Dumper;
use Senha;
use Getopt::Long;
use Time::HiRes qw(time);
use constant ORA_SRV  =>  '@ORAHOST@';
use constant ORA_INST =>  '@ORAINST@';
use constant ORA_USR  =>  '@ORAUSER@';
use constant PG_SRV   =>  '@PGHOST@';
use constant PG_INST  =>  '@PGDATABASE@';
use constant PG_USR   =>  '@PGUSUARIO@';

use constant ORA_PWD_FILE => '@ENC_ORAPWD@';
use constant PG_PWD_FILE => '@ENC_PGPWD@';

sub ajuda {
  print "Utilizar: $0 [--inicio <DATA_0>] [--fim <DATA_F>] [--contagem] ";
  print "--log <ARQ_LOG>\n";
  print "Formato da data: DDMMAAAA ou DDMMAAAA-[hhmm] ou DD-MM-AAAA\n";
  exit(0);
}

my $orapwd = Senha::getPwd({arquivo=>ORA_PWD_FILE});
my $pgpwd =  Senha::getPwd({arquivo=>PG_PWD_FILE});

# Quem recebe o log de execução
my $emails = 'gti-dba@almg.gov.br';

# Parametros
my $data0;
my $dataF;
my $formato_data0 = "DDMMYYYY";
my $formato_dataF = "DDMMYYYY";
my $apenas_contagem;
my $mostra_ajuda = 0;
my $log_file;

# Tempos de execucao
my $tempoInicio = time();
my $tempoValidacao;
my $tempoPG;
my $tempoORA;
my $tempoTotal;

# --inicio=<data_inicio>
# --fim=<data_fim>
# --Datas válidas:
#   DDMMAAAA, DDMMAAAA-HHmm, DD-MM-AAAA
GetOptions(
  'inicio=s'  =>  \$data0,
  'fim=s'     =>  \$dataF,
  'contagem'  =>  \$apenas_contagem,
  'help'      =>  \$mostra_ajuda,
  'ajuda'     =>  \$mostra_ajuda,
  'log=s'     =>  \$log_file)
  or die("Parametros passados de forma incorreta. Usar --help/--ajuda.");

if ($mostra_ajuda) {
  ajuda();
}

# Se tiver algum arquivo de saída, redireciona o STDOUT pra ele
if ($log_file) {
  close(STDOUT);
  open(STDOUT, ">>", $log_file);
}

if ($data0) {
  $formato_data0 = Data::defineFormato($data0);
}
else {
  $data0 = Data::data(-1);
}

if ($dataF) {
  $formato_dataF = Data::defineFormato($dataF);
}
else {
  $dataF = Data::data(0);
}

print localtime()." - Inicio da execução\n";
print "Data inicial: $data0\n";
print "Data final  : $dataF\n\n";

my $db_pg = Postgres::conexaoPG(
  {host=>PG_SRV,base=>PG_INST,usuario=>PG_USR,senha=>$pgpwd}
);

my $db_ora = Oracle::conexaoOracle(
  {host=>ORA_SRV,base=>ORA_INST,usuario=>ORA_USR,senha=>$orapwd}
);

my $sql_ora = qq{
  SELECT ROWID, T.*
  FROM TESTATISTICAS_RAC T
  WHERE 
    TIMESTAMP >= TO_DATE('$data0', '$formato_data0') 
    AND TIMESTAMP < TO_DATE('$dataF', '$formato_dataF')
};

my $sql_pg = qq{
  SELECT *
  FROM testatisticas_rac t
  LIMIT 1
};

my $sth_ora = $db_ora->prepare($sql_ora);
$sth_ora->execute();

my $sth_pg = $db_pg->prepare($sql_pg);
$sth_pg->execute();

my $fname_ora = $sth_ora->{NAME};
my $fnum_ora = $sth_ora->{NUM_OF_FIELDS};
my $fname_pg = $sth_pg->{NAME};
my $fnum_pg = $sth_pg->{NUM_OF_FIELDS};
$sth_pg->finish;

# Validacao dos resultados (compara o numero e o nome dos atributos)
my $i;
if ($fnum_ora-1 == $fnum_pg) {
  for ($i = 0; $i < @$fname_pg; $i++) {
    next if (@$fname_ora[$i+1] =~ /@$fname_pg[$i]/i);
    print("Nomes / ordem das colunas são incompatíveis\n")
      and die();
  }
}
else {
  print("Erro de validação - Número de colunas da tabela é diferente\n")
    and die();
}

# Se ta tudo validado, pode fazer a transferencia
# Carrega o resultado do Oracle
my $res_ora = $sth_ora->fetchall_arrayref();
#my $nrows_ora = scalar @$res_ora;
my $nrows_ora = $sth_ora->rows;
#print Dumper($res_ora);

print "SQL utilizada:";
print "$sql_ora\n";
print "Serão transferidas $nrows_ora linhas para o PostgreSQL\n";

# Se apenas a contagem foi solicitada, interrompe o script.
if ($apenas_contagem) {
  $sth_ora->finish;
  $db_ora->disconnect;
  $db_pg->disconnect;
  print localtime()." - Término da execução: \n";
  print "\n\n\n";
  exit(0);
}

#my $res_ora = $sth_ora->fetchall_hashref("ROWID");
#my $nrows_ora = keys %$res_ora;
## Remove ROWID da especificação de atributos
shift @$fname_ora;

#foreach my $key (keys %$res_ora) {
#  #print $res_ora->{$key}->{"VALUE"}."\n";
#  #print Dumper($res_ora->{$key});
#  foreach
#}

my $nrows_pg = 0;
my $nrows_ora_del = 0;
$tempoValidacao = time();
my $rowlen;

eval {
  $db_pg->do("COPY testatisticas_rac FROM STDIN");
  foreach my $item (@$res_ora) {
    shift(@$item);
    # Necessario para ajuste do atributo logon_time
    $rowlen = @$item;
    @$item[$rowlen-1] = '\N' if (not defined(@$item[$rowlen-1]));
    #print join("\t", @$item)."\n";
    $db_pg->pg_putcopydata(join("\t", @$item)."\n");
    $nrows_pg++;
  }
  $db_pg->pg_putcopyend();
};

if ($@) {
  $tempoPG = time();
  print localtime()." - Postgres COPY ERRO\n";
  print "Alguma coisa deu errado durante os INSERTS no PostgreSQL!\n";
  print "Fazendo ROLLBACK\n";
  $db_pg->rollback();
}
else {
  $tempoPG = time();
  print localtime()." - Postgres COPY OK\n";
  $db_pg->commit();

  # Se deu tudo certo, podemos apagar as linhas de TESTATISTICAS_RAC
  # do periodo transferido.
  eval {
    $sql_ora = qq{
      DELETE FROM TESTATISTICAS_RAC 
      WHERE 
        TIMESTAMP >= TO_DATE('$data0', '$formato_data0')
        AND TIMESTAMP < TO_DATE('$dataF', '$formato_dataF')};
    $nrows_ora_del = $db_ora->do($sql_ora) or die($db_ora->errstr);
  };

  if ($@) {
    $tempoORA = time();
    print localtime()." - Oracle Delete ERRO\n";
    print "Erro ao remover as linhas no Oracle - fazendo ROLLBACK!\n";
    $db_ora->rollback();
  }
  else {
    $tempoORA = time();
    print localtime()." - Oracle DELETE OK\n";
    $db_ora->commit();
  }
}

$tempoTotal = time();
$tempoORA = $tempoORA - $tempoPG;
$tempoPG = $tempoPG - $tempoValidacao;
$tempoTotal = $tempoTotal - $tempoInicio;

printf "\n\n-------------------------------------------\n";
printf "Linhas processadas: $nrows_ora\n";
printf "Linhas copiadas para o Postgres: $nrows_pg\n";
printf "Tempo (s) de execução no Postgres: %.4f\n", $tempoPG;
printf "Linhas removidas do Oracle: $nrows_ora_del\n";
printf "Tempo (s) de execução no Oracle: %.4f\n", $tempoORA;
printf "Tempo total de execução (s): %.4f\n", $tempoTotal;
printf localtime()." - término da execução\n\n";

$db_pg->disconnect if defined($db_pg);
$db_ora->disconnect if defined($db_ora);

if ($log_file) {
  close(STDOUT);
  my $tit = "Transferência de estatísticas Oracle -> Postgres";
  `cat $log_file | mail -s "$tit" $emails`;
}

# Delete log file
unlink $log_file;
exit(0);
