package Oracle;
use DBD::Oracle;

sub conexaoOracle {
  my $parametros  = shift;
  my $base  = $parametros->{'base'};
  my $user  = $parametros->{'usuario'};
  my $password  = $parametros->{'senha'};
  my $host  = $parametros->{'host'};
  my $dbh_oracle = undef;

  # Conexoes feitas sem o tnsnames.ora
  if ((defined($host)) && (defined($base))) {                           
    #$dbh_oracle = DBI->connect( "dbi:Oracle:host=$host;SID=$sid;port=1521", "$user/$password" )
    $dbh_oracle = DBI->connect( "dbi:Oracle://$host:1521/$base", "$user", "$password")
      or die( $DBI::errstr . "\n" );
  }
  else {
    $dbh_oracle = DBI->connect( "dbi:Oracle:$base", $user, $password )
      or die( $DBI::errstr . "\n" );
  }

  $dbh_oracle->{AutoCommit}    = 0;
  $dbh_oracle->{RaiseError}    = 1;
  $dbh_oracle->{PrintError}    = 0;
  $dbh_oracle->{ora_check_sql} = 0;
  #$dbh_oracle->{RowCacheSize}  = 16;
  $dbh_oracle->do("alter session set NLS_DATE_FORMAT='yyyy-mm-dd HH24:mi:ss'");
  $dbh_oracle->do("alter session set NLS_NUMERIC_CHARACTERS = '. '");
  return $dbh_oracle;
};

1;
