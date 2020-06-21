#!/bin/bash
# all on intermidiary instance + install mysql but don't configure/run - yum install mysql
# yum install https://github.com/maxbube/mydumper/releases/download/v0.9.5/mydumper-0.9.5-2.el7.x86_64.rpm
# we use the same user "migration_user" to dump and restore and "replication_user" for replication only.

# --- create user ---
# GRANT USAGE ON *.* TO 'migration_user'@'%' IDENTIFIED BY 'tesT-77d2f78c-d99b-4d38-93d5-8bb5d6dd5379';
# GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO 'migration_user'@'%' WITH GRANT OPTION;
# flush privileges;

backup_path="/root/bkp-dir"
general_log_file="$backup_path/general_bkp-full_$today.log"
before="$(date +%s)"
today=`date +%Y-%m-%d`
general_log_file="$backup_path/general_bkp-full_$today.log"

#### master details #####
backup_user="migration_user"
backup_pass="tesT-77d2f78c-d99b-4d38-93d5-8bb5d6dd5379"
master_server_address=10.35.241.51

# create directories for full backup
if [ ! -d ${backup_path} ]
   then
    mkdir -p ${backup_path}/data
    chmod 755 ${backup_path}
else
    mkdir -p ${backup_path}/data
    chmod 755 ${backup_path}
fi

### Get list of databases who will be back it up ###
databases=`mysql --user=$backup_user --password=$backup_pass --host=$master_server_address -e "SELECT replace(GROUP_CONCAT(SCHEMA_NAME),',',' ') as list_databases FROM information_schema.SCHEMATA WHERE SCHEMA_NAME NOT IN('common_schema', 'information_schema','mysql','performance_schema','sys');" | tr -d "|" | grep -v list_databases`

echo "[`date +%d/%m/%Y" "%H:%M:%S`] - BEGIN REPLICA" >> $general_log_file
echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB List: $databases" >> $general_log_file

### struture-only backup ###
mysqldump --user=$backup_user --password=$backup_pass --host=$master_server_address --single-transaction --no-data --skip-triggers -v --databases $databases > $backup_path/structure_full_$today.sql
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Structure backup has been successfully completed!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Structure backup has been failed!" >> $general_log_file
  exit 1
fi

mysqldump --user=$backup_user --password=$backup_pass --host=$master_server_address --single-transaction --no-data --no-create-info --skip-triggers --routines --skip-opt -v --databases $databases > $backup_path/routines_full_$today.sql
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Routines backup has been successfully completed!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Routines backup has been failed!" >> $general_log_file
  exit 1
fi

mysqldump --user=$backup_user --password=$backup_pass --host=$master_server_address --single-transaction --no-data --no-create-info --skip-routines --triggers --skip-opt -v --databases $databases > $backup_path/triggers_full_$today.sql
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Triggers backup has been successfully completed!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Triggers backup has been failed!" >> $general_log_file
  exit 1
fi

mydumper -u $backup_user -p $backup_pass -h $master_server_address --regex '^(?!(mysql\.|test\.|sys\.))' ${extra_options} --trx-consistency-only -t 4 -m --rows=500000 --compress -o ${backup_path}/data
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Data-Only backup has been successfully completed!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Data-Only backup has been failed!" >> $general_log_file
  exit 1
fi
