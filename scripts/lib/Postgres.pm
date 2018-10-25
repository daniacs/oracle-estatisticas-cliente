package Postgres;
use DBD::Pg;

sub conexaoPG {
  my $parametros  = shift;
  my $server = $parametros->{'host'};
  my $base  = $parametros->{'base'};
  my $user  = $parametros->{'usuario'};
  my $password  = $parametros->{'senha'};
  my $dbh_pg = DBI->connect( "dbi:Pg:dbname=$base;host=$server",
    $user, $password ) || die( $DBI::errstr . "\n" );

  $dbh_pg->{AutoCommit}    = 0;
  $dbh_pg->{RaiseError}    = 1;
  $dbh_pg->{PrintError}    = 0;
  $dbh_pg->{pg_enable_utf8} = 0; # Se default ou 1, tá retornando ISO8859-1!
  return $dbh_pg;
};
1;
