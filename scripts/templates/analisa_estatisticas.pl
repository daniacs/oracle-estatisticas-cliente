#!/usr/bin/perl
# Busca as estatisticas dos programas gravados na tabela testatisticas_rac
# Sumariza a utilizacao por programa/data/hora (nao granulariza por minuto)
# Grava em uma tabela para analise em ferramenta de visualizacao como o 
# Apache/AirBnB Superset 
#   (https://superset.incubator.apache.org/)
#   https://github.com/apache/incubator-superset
#
#
# Exemplo 1:
#
# [time] perl analisa_estatisticas.pl \
#   --inicio=04072018-0000 \
#   --fim=05072018-0000 \
#   --tabout tanalise_todos
#
# Busca da tabela testatisticas_rac, no PostgreSQL, as estatisticas de 
# utilização de CPU de todos os programas, processa a utilizacao por 
# programa/dia/hora e grava o resultado na tabela tanalise_todos.
# Os programas sao convertidos para CAIXA ALTA.
#
# Exemplo 2:
#
# [time] perl analisa_estatisticas.pl \
#   --inicio=04072018-0000 \
#   --fim=05072018-0000 \
#   --tabin  testatisticas_rac2 \
#   --tabout tanalise_aux \
#   --prog "'ssi.exe'"
#
# Busca da tabela testatisticas_rac2, no PostgreSQL, as estatisticas de CPU
# do programa ssi.exe *case insensitive*, processa a utilizacao por dia/hora
# e grava o resultado na tabela tanalise_aux.
#
# Pode buscar mais de um programa (desde que os programas sejam delimitados
# por aspas simples e separados por virgula):
# --prog "'Intranet - JDBC TC','pagamentos'"

use strict;
use lib "@LIB_DIR_STR@";
use Postgres;
use Senha;
use Data;
use Data::Dumper;
use Getopt::Long;
use Time::HiRes qw(time);


# Parametros de conexao com o Postgres
use constant PG_SRV   =>  '@PGHOST@';
use constant PG_INST  =>  '@PGDATABASE@';
use constant PG_USR   =>  '@PGUSUARIO@';
use constant PG_PWD_FILE => '@ENC_PGPWD@';
use constant LOGOFF   =>  3;

sub ajuda {
  print "Analisa a tabela <TABIN> e grava o processamento em <TABOUT>\n";
  print "Utilizar: $0 [--inicio <DATA_0>] [--fim <DATA_F>] [--stat STAT#] ";
  print "[--log <ARQ_LOG>] [--tabin TABIN] [--tabout TABOUT] \n";
  print "Formato da data: DDMMAAAA ou DDMMAAAA-[hhmm] ou DD-MM-AAAA\n";
  exit(0);
}

# Quem recebe o log de execução
my $emails = 'gti-dba@almg.gov.br';

# Parametros
my $data0;
my $dataF;
my $formato_data0 = "DDMMYYYY";
my $formato_dataF = "DDMMYYYY";
my $mostra_ajuda = 0;
my $log_file;
my $table_in;
my $table_out;
my $program;
my $stat;
# Schema do postgres onde ficam as tabelas de analise
my $schema = "@PGSCHEMA@";

# Tempos de execucao
my $tempoInicio = time();
my $checkpoint;
my $deltaT = 0;

# --inicio=<data_inicio>
# --fim=<data_fim>
# --Datas válidas:
#   DDMMAAAA, DDMMAAAA-HHmm, DD-MM-AAAA
GetOptions(
  'inicio=s'  =>  \$data0,
  'fim=s'     =>  \$dataF,
  'help'      =>  \$mostra_ajuda,
  'ajuda'     =>  \$mostra_ajuda,
  'log=s'     =>  \$log_file,
  'tabin=s'   =>  \$table_in,
  'tabout=s'   => \$table_out,
  'stat=i'   =>   \$stat,
  'prog=s'    =>  \$program)
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
  ($data0, $formato_data0) = Data::dataPadrao($data0);
}
else {
  $data0 = Data::data(-1);
}

if ($dataF) {
  ($dataF, $formato_dataF) = Data::dataPadrao($dataF);
}
else {
  $dataF = Data::data(0);
}

# Definicao dos nomes das tabelas analisada e gerada e código da estatistica.
$table_in = "testatisticas_rac" if (!$table_in);
$table_out = "tanalise_estatisticas" if (!$table_out);
$stat = 19 if (!$stat);

# Verificar quantos programas serao analisados e se foram 
# delimitados corretamente, usando aspas simples
my $numprogs = 0;
if ($program) {
  my @arr = split(/,/, $program);
  my @validos;
  $numprogs = @arr;
  if ($numprogs > 1) {
    foreach my $item(@arr) {
      $item =~ s/^\s+//;    # Se tiver espacos do tipo "'p1', 'p2'"
      if (!($item =~ /^'([^']+)'/)) {
        die("Forma incorreta de $1\n");
      }
      else {
        push(@validos, $item);
      }
    }
    $program = join(",", @validos);
  }
}
$program = uc($program);

print localtime()." - Inicio da execução\n";
print "Data inicial: $data0\n";
print "Data final  : $dataF\n\n";

my $cred_postgres = Senha::getPwd({arquivo=>PG_PWD_FILE});

my $db_pg = Postgres::conexaoPG(
  {host=>PG_SRV,base=>PG_INST,usuario=>PG_USR,senha=>$cred_postgres}
);

######## Criacao da tabela que recebe o processamento

my $retorno;

$db_pg->do(qq{
  create table if not exists $schema.$table_out (
  program    varchar(60),
  stat       numeric,
  timestamp  timestamp,
  total      numeric);});
$retorno = $db_pg->commit();
if ($retorno < 0) {
  print $DBI::errstr;
}

$db_pg->do(qq{TRUNCATE TABLE $schema.$table_out;});
$retorno = $db_pg->commit();
if ($retorno < 0) {
  print $DBI::errstr;
}

$checkpoint = time();
$deltaT = $checkpoint - $tempoInicio;
printf("CREATE/TRUNCATE TABLE: %.2f s\n", $deltaT);

########### Extração dos dados de CPU desempenho

my $sql_pg;
my $sth_pg;
my $rows;
my $fname_pg;
my $fnum_pg;
my $result;
my $totalRows;
my $countTotal = 0;

#$sql_pg = "SHOW max_parallel_workers;";
#$sth_pg = $db_pg->prepare($sql_pg);
#$rows = $sth_pg->execute();
#$result = $sth_pg->fetchrow_hashref();
#print Dumper($result);
#$sth_pg->finish;
#$db_pg->disconnect;
#exit(0);

# Os parametros "schemaname, machine" NÃO fazem parte do grupo de janela!

$sql_pg = qq{
  SELECT 
    ctid, inst_id, sid, program, schemaname, machine, timestamp, 
    extract(year from timestamp) as year, 
    extract(month from timestamp) as month, 
    extract(day from timestamp) as day, 
    extract (hour from timestamp) as hour,
    extract(minute from timestamp) as minute,
    value, 
    coalesce(lag(value) over (
      partition by inst_id, sid
      order by timestamp, value, event), 
      0) as lastval,
    coalesce(value - lag(value) over (
      partition by inst_id, sid
      order by timestamp, value, event), 
      0) as delta,
    event
  FROM $schema.$table_in
  WHERE 
    statistic = $stat
    AND timestamp >= '$data0'::timestamp
    AND timestamp <  '$dataF'::timestamp
};

if ($numprogs == 1) {
  $sql_pg .= "    AND UPPER(program) = $program\n";
}
elsif ($numprogs > 1) {
  $sql_pg .= "    AND UPPER(program) IN ($program)\n";
}

$sql_pg .= "  ORDER BY 
    inst_id, sid, timestamp, value, event";

$sth_pg = $db_pg->prepare($sql_pg);
$rows = $sth_pg->execute();
$fname_pg = $sth_pg->{NAME};
$fnum_pg = $sth_pg->{NUM_OF_FIELDS};

die("Não há nenhum resultado a ser sumarizado. Consulta retornou vazio.")
  unless ($rows > 0);

$deltaT = time() - $checkpoint;
$checkpoint = time();
printf("SELECT:                %.2f s\n", $deltaT);

my $ctid;
my $inst;
my $sid;
my $prog;
my $schema;
my $machine;
my $timestamp;
my $year;
my $month;
my $day;
my $hour;
my $min;
my $val;
my $lastval;
my $delta;
my $event;
my $hashkey;
my %table;
my $last_sid = 0;
my $last_event = 0;
my $cond1;
my $cond2;
my $incremento;
my $cond3;

# Granularidade (chave hash/agregação): programa/dia/hora
# Minutos nao foram levados em conta!

# O incremento do valor deve ser feito da seguinte forma:
# SID == LAST_SID?
# SIM: Mesmo numero de sessao. Continuada ou reiniciada?
#   Ultimo evento == LOGOFF?
#   SIM -> Sessao foi reaproveitada. Incremento = $val
#   NAO -> Sessao continuada.        Incremento = $delta
# NAO: SIDs diferentes! Registro unico ou inicio de outra com mais registros?
#   Evento == LOGOFF?
#   SIM -> So teve um registro pra essa sessao. Incremento = $val
#   NAO -> Sessao pode ou nao ser continuada.   Incremento = 0.

#print "prog;inst;sid;last_sid;schema;day;hour;min;val;lastval;delta;event;last_event;incr;acumulado\n";
# A primeira linha não possui incremento.
# Então last_sid e last_event já podem ser atribuídos com os valores atuais.
$result = $sth_pg->fetchrow_arrayref();
($ctid, $inst, $last_sid, $prog, $schema, $machine, $timestamp, $year,
  $month, $day, $hour, $min, $val, $lastval, $delta, $last_event) = @$result;

while ($result = $sth_pg->fetchrow_arrayref()) {
  ($ctid, $inst, $sid, $prog, $schema, $machine, $timestamp, $year,
    $month, $day, $hour, $min, $val, $lastval, $delta, $event) = @$result;
  $delta = 0 if $delta < 0;
  $hashkey = uc($prog)."\t$stat\t$year-$month-$day $hour:00:00";

  $cond1 = ($sid == $last_sid);
  $cond2 = ($last_event == LOGOFF);
  $cond3 = ($event == LOGOFF);

  $incremento = (1 - $cond1)*$val*($cond3) + $cond1*(
    $cond2*$val + (1 - $cond2)*$delta
  );
  $table{$hashkey} += $incremento;

  #printf("%s\t%.4d\t%.4d\t%d\t%.2d\t%.6d\t%.6d\t%.6d\t%d\t%d\t%.6d\t%.5d\n", 
  #printf("%s;%d;%.4d;%.4d;%s;%d;%.2d;%.2d;%.6d;%.6d;%.6d;%d;%d;%.6d;%.5d\n", 
  #  $prog, $inst, $sid, $last_sid, $schema, $day, $hour, $min, $val, $lastval,
  #  $delta, $event, $last_event, $incremento, $table{$hashkey});
  $last_event = $event;
  $last_sid = $sid;
}

$sth_pg->finish;
$deltaT = time() - $checkpoint;
$checkpoint = time();
printf("PERL PROCESSING        %.2f s\n", $deltaT);

my $rows_pg = 0;
eval {
  $db_pg->do("COPY $table_out FROM STDIN");
  foreach $hashkey (sort keys(%table)) {
    $db_pg->pg_putcopydata($hashkey."\t".$table{$hashkey}."\n");
    $rows_pg++;
  }
  $db_pg->pg_putcopyend();
};

if ($@) {
  print "Erro no COPY do PostgreSQL!\n";
  $db_pg->rollback();
}
else {
  $db_pg->commit();
}

$deltaT = time() - $checkpoint;
$checkpoint = time();
$checkpoint -= $tempoInicio;

printf("PG COPY                %.2f s\n", $deltaT);
printf("Tempo total:           %.2f s\n", $checkpoint);
printf("Total agregada:        %d\n", $rows);
printf("Total copiada:         %d\n", $rows_pg);
printf("Redução %.2f %%\n", 100*(1-$rows_pg/$rows));

$db_pg->disconnect if defined($db_pg);
