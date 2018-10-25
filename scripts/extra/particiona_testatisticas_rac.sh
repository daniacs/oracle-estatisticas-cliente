TSDIR=/pgsql/tablespaces/ts_estatisticas

[ -d $TSDIR ] && rm -rf $TSDIR
mkdir -p $TSDIR
chown -R postgres:postgres $TSDIR

SCRIPT=/pgsql/scripts/particiona_testatisticas_rac.sql
psql -h postgresql1h -U postgres -d p10 --no-password < $SCRIPT
