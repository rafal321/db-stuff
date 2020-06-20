# to dump and restore with mysqldump only - the Tarik & Emerson way

mysqldump --single-transaction --no-data --skip-triggers -v --databases sakila company > 1-structure-$(date +%F).sql
mysqldump --single-transaction --no-data --no-create-info --skip-triggers --routines --skip-opt -v --databases sakila company > 2-routines-$(date +%F).sql
mysqldump --single-transaction --no-data --no-create-info --skip-routines --triggers --skip-opt -v --databases sakila company > 4-triggers-$(date +%F).sql
mysqldump --single-transaction -n -R -c -t -e -v -K --skip-routines --skip-triggers --databases sakila company > 3-data-$(date +%F).sql

mysql --force < 1-structure-2020-06-20.sql
mysql --force < 2-routines-2020-06-20.sql
mysql --force < 3-data-2020-06-20.sql
mysql --force < 4-triggers-2020-06-20.sql

# some verification
# SELECT * FROM `information_schema`.`ROUTINES` LIMIT 1000\G
# SELECT * FROM `information_schema`.`TRIGGERS` LIMIT 1000\G
# SELECT * FROM `information_schema`.`VIEWS` LIMIT 1000\G
# SELECT * FROM `information_schema`.`INNODB_SYS_INDEXES` ORDER BY 2 LIMIT 1000;
# SELECT * FROM `information_schema`.`COLUMNS` WHERE TABLE_SCHEMA NOT IN ('mysql', 'information_schema', 'performance_schema') LIMIT 1000;

# #############################################################################
# #############################################################################

#!/bin/bash
# This script backups all databases into separate sql statements in TimeStamp directory

# https://dev.mysql.com/doc/refman/5.7/en/mysqldump-sql-format.html
# The dump output contains no CREATE DATABASE or USE statements.
# If the database to be reloaded does not exist, you must create it first.
# It enables you to reload the data into a different database.

# Script Runtime ---
res1=$(date +%s.%N)

#Provide the backup directory path in which you would like to create new direcoty and backup databases.
BACKUP_DIR=/root/backup/$(date +%F);
#Check and create new directory if not exits
test -d "$BACKUP_DIR" || mkdir -p "$BACKUP_DIR"
# Get the database list
for db in $(mysql -B -s -e 'Select distinct Table_schema from information_Schema.tables;')
do
echo " Performing backup of Database : "$db
  # backup each database in a separate file
  mysqldump "$db" --single-transaction --routines --triggers --events > "$BACKUP_DIR/$db.sql"
done

# Script Runetime ---
res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
LC_NUMERIC=C printf " Total runtime: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds

# #############################################################################
# #############################################################################

