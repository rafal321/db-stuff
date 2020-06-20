# to dump and restore with mysqldump only - the Tarik & Emerson way

mysqldump --single-transaction --no-data --skip-triggers -v --databases sakila company > 1-structure-$(date +%F).sql
mysqldump --single-transaction --no-data --no-create-info --skip-triggers --routines --skip-opt -v --databases sakila company > 2-routines-$(date +%F).sql
mysqldump --single-transaction --no-data --no-create-info --skip-routines --triggers --skip-opt -v --databases sakila company > 4-triggers-$(date +%F).sql
mysqldump --single-transaction -n -R -c -t -e -v -K --skip-routines --skip-triggers --databases sakila company > 3-data-$(date +%F).sql

mysql --force < 1-structure-2020-06-20.sql
mysql --force < 2-routines-2020-06-20.sql
mysql --force < 3-data-2020-06-20.sql
mysql --force < 4-triggers-2020-06-20.sql

