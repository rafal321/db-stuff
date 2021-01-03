# to dump and restore with mysqldump only - the Tarik & Emerson way

# databases=db_name
mysqldump --single-transaction --no-data --skip-triggers -v --databases sakila company > 1-structure-$(date +%F).sql
mysqldump --single-transaction --no-data --no-create-info --skip-triggers --routines --skip-opt -v --databases sakila company > 2-routines-$(date +%F).sql
mysqldump --single-transaction --no-data --no-create-info --skip-routines --triggers --skip-opt -v --databases sakila company > 4-triggers-$(date +%F).sql
mysqldump --single-transaction -n -R -c -t -e -v -K --skip-routines --skip-triggers --databases sakila company > 3-data-$(date +%F).sql
# mydumper --database=$databases --trx-consistency-only -t 4 -m --rows=500000 --compress -o ./3-data_$(date +%F)

mysql --force < 1-structure-2020-06-20.sql
mysql --force < 2-routines-2020-06-20.sql
mysql --force < 3-data-2020-06-20.sql
mysql --force < 4-triggers-2020-06-20.sql
# myloader -t 4 -d 3-data_2020-12-24

# some verification
# SELECT * FROM `information_schema`.`ROUTINES` LIMIT 1000\G
# SELECT * FROM `information_schema`.`TRIGGERS` LIMIT 1000\G
# SELECT * FROM `information_schema`.`VIEWS` LIMIT 1000\G
# SELECT * FROM `information_schema`.`INNODB_SYS_INDEXES` ORDER BY 2 LIMIT 1000;
# SELECT * FROM `information_schema`.`COLUMNS` WHERE TABLE_SCHEMA NOT IN ('mysql', 'information_schema', 'performance_schema') LIMIT 1000;
# ----
mysqldump --single-transaction --routines --triggers --events company | gzip > company_db-$(date +%F).dmp.gz
gunzip company_db-2020-02-21.dmp.gz
# ----

# #############################################################################
# #############################################################################
#!/bin/bash
# INFO: https://serversforhackers.com/c/mysqldump-with-modern-mysql
# simple mysqldump - dump some databases with all its components > explains why --skip-lock-tables is used ...

today=$(date +%F)
databases=`mysql -e "SELECT replace(GROUP_CONCAT(SCHEMA_NAME),',',' ') as list_databases FROM information_schema.SCHEMATA WHERE SCHEMA_NAME NOT IN('common_schema', 'information_schema','mysql','performance_schema','sys');" | tr -d "|" | grep -v list_databases`
# echo "List: ${databases}"

# Option 1
# mysqldump --single-transaction --skip-lock-tables --routines --events --triggers --databases ${databases} > dump2-${today}.sql

# Option 2
mysqldump --single-transaction --skip-lock-tables --routines --events --triggers --databases ${databases} | gzip > dump4-${today}.sql.gz
# To restore:    gunzip < dump3-2020-06-27.sql.gz | mysql

# Option 3 - https://galeracluster.com/library/training/videos/galera-standard-replication.html
mysqldump --single-transaction --routines --triggers --events --master-data=2 --flush-logs --databases ${databases} > dump-$(date +%F).sql
CHANGE MASTER TO MASTER_HOST='10.35.241.160', MASTER_USER='replicator',  MASTER_PASSWORD='Rover123[]', MASTER_LOG_FILE='bin.000005', MASTER_LOG_POS=154;
START SLAVE;                   (Test it as per codership vid had to manualy enter Log Pos etc...)

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
# dump grants for all users
mysql --skip-column-names -A -e"SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') FROM mysql.user WHERE user<>''" | mysql --skip-column-names -A | sed 's/$/;/g' > MySQLGrants.sql

#_________________________________________________________________________
# Archive stuff             directory/ 2.8G
tar -c --use-compress-program=pigz -f name-of.tgz directory/
tar -xf name-of.tgz
--------------------------
tar -cf - directory/ | pigz -9 > archive-$(date +%F).tgz    3m27.728s	  1008M       SLOW
tar -cf - directory/ | pigz > archive-$(date +%F).tgz		    1m35.293s	  1015M       MEDIUM 
tar -cf - directory/ | pigz -1 > archive-$(date +%F).tgz	  0m37.064s	  1100M 1.1G  FAST


tar -xf archive-2020-10-08.tgz
--------------------------
zip -P password archive-$(date +%F).zip testing-mysqldump/*	2m23.285s 1015M (single-thread)
zip -e archive-$(date +%F).zip testing-mysqldump/*

unzip archive-2020-10-08.zip

