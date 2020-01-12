#!/bin/bash
# script based on https://github.com/emersongaudencio/ansible-mariadb-galera-cluster

# script works only if run as  mysql root user

today=$(date +%F)
backup_path="/backup-mysql"
general_log_file="$backup_path/general_bkp-full_$today.log"

databases=`mysql -e "SELECT replace(GROUP_CONCAT(SCHEMA_NAME),',',' ') as list_databases FROM information_schema.SCHEMATA WHERE SCHEMA_NAME NOT IN('common_schema', 'information_schema','mysql','performance_schema','sys');" | tr -d "|" | grep -v list_databases`

echo "List: ${databases}"

mysqldump --single-transaction --no-data --skip-triggers -v --databases ${databases} > ${backup_path}/structure_full_$(date +%F).sql

if [ $? -eq 0 ]; then
    echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Structure backup is ok!" >> $general_log_file
  else
    echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Structure backup has been failed!" >> $general_log_file
fi

mysqldump --single-transaction --no-data --no-create-info --skip-triggers --routines --skip-opt -v --databases $databases > $backup_path/routines_full_$today.sql

if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Routines backup is ok!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Routines backup has been failed!" >> $general_log_file
fi


mysqldump --single-transaction --no-data --no-create-info --skip-routines --triggers --skip-opt -v --databases $databases > $backup_path/triggers_full_$today.sql
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Triggers backup is ok!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Triggers backup has been failed!" >> $general_log_file
fi


mydumper --regex '^(?!(mysql\.|test\.|sys\.))' --trx-consistency-only -t 4 -m --rows=500000 --compress -o ${backup_path}/data
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Data-Only backup is ok!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Data-Only backup has been failed!" >> $general_log_file
fi

