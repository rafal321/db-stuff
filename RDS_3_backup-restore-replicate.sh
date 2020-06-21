#!/bin/bash

#### master details #####
backup_user="migration_user"
backup_pass="tesT-77d2f78c-d99b-4d38-93d5-8bb5d6dd5379"
master_server_address=10.35.241.51

#### replica details #####
restore_user="migration_user"
restore_pass="tesT-77d2f78c-d99b-4d38-93d5-8bb5d6dd5379"
replica_server_address="rk-1.cluster-cbtkbkg6ojhw.eu-west-1.rds.amazonaws.com"

#### replication details #####
replication_user="replication_user"
replication_pass='tesT-77d2f78c-d99b1102'
master_server_address=10.35.241.51

# --- DIRECTORIES --------------------------------------------------------------------------------------------------------------------------------------

backup_path="/root/bkp-dir"
general_log_file="$backup_path/general_bkp-full_$today.log"
before="$(date +%s)"
today=`date +%Y-%m-%d`
general_log_file="$backup_path/general_bkp-full_$today.log"

# create directories for full backup
if [ ! -d ${backup_path} ]
   then
    mkdir -p ${backup_path}/data
    chmod 755 ${backup_path}
else
    mkdir -p ${backup_path}/data
    chmod 755 ${backup_path}
fi

# --- BACKUP SECTION --------------------------------------------------------------------------------------------------------------------------------------

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

# --- RESTORE SECTION --------------------------------------------------------------------------------------------------------------------------------------
 
### Restoring db structure
cat $backup_path/structure_full_$today.sql | sed -e 's/DEFINER=`[A-Za-z0-9_]*`@`[A-Za-z0-9_]*`//g' > $backup_path/temp_structure_full_$today.sql
cat $backup_path/temp_structure_full_$today.sql | sed -e 's/SQL SECURITY DEFINER//g' > $backup_path/fixed_structure_full_$today.sql
mysql --user=$restore_user --password=$restore_pass --host=$replica_server_address --force  <  $backup_path/fixed_structure_full_$today.sql
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Structure restore has been successfully completed!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Structure restore has been failed!" >> $general_log_file
  exit 1
fi

### Restoring db data-only
myloader -u $restore_user --password=$restore_pass --host=$replica_server_address -t 4 -d ${backup_path}/data
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Data-only restore has been successfully completed!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB Data-only restore has been failed!" >> $general_log_file
  exit 1
fi

### Restoring db routines
cat $backup_path/routines_full_$today.sql | sed -e 's/DEFINER=`[A-Za-z0-9_]*`@`[A-Za-z0-9_]*`//g' > $backup_path/temp_routines_full_$today.sql
cat $backup_path/temp_routines_full_$today.sql | sed -e 's/SQL SECURITY DEFINER//g' > $backup_path/fixed_routines_full_$today.sql
mysql --user=$restore_user --password=$restore_pass --host=$replica_server_address --force <  $backup_path/fixed_routines_full_$today.sql
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB routines restore has been successfully completed!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB routines restore has been failed!" >> $general_log_file
  exit 1
fi

### Restoring db triggers
cat $backup_path/triggers_full_$today.sql | sed -e 's/DEFINER=`[A-Za-z0-9_]*`@`[A-Za-z0-9_]*`//g' > $backup_path/temp_triggers_full_$today.sql
cat $backup_path/temp_triggers_full_$today.sql | sed -e 's/SQL SECURITY DEFINER//g' > $backup_path/fixed_triggers_full_$today.sql
mysql --user=$restore_user --password=$restore_pass --host=$replica_server_address --force <  $backup_path/fixed_triggers_full_$today.sql
if [ $? -eq 0 ]; then
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB triggers restore has been successfully completed!" >> $general_log_file
else
  echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB triggers restore has been failed!" >> $general_log_file
  exit 1
fi

# --- REPLICATION SECTION --------------------------------------------------------------------------------------------------------------------------------------

  ### configure and setup replication streaming between master and replica ####
binlog_file=$(cat ${backup_path}/data/metadata | awk 'NR==3{print $2}')
binlog_pos=$(cat ${backup_path}/data/metadata | awk 'NR==4{print $2}')

  ### setting up replicatin streaming
  mysql --user=$restore_user --password=$restore_pass --host=$replica_server_address --force -e "CALL mysql.rds_set_external_master ('$master_server_address', 3306, '$replication_user', '$replication_pass', '$binlog_file', $binlog_pos, 0);";
  mysql --user=$restore_user --password=$restore_pass --host=$replica_server_address --force -e "CALL mysql.rds_start_replication;";
  if [ $? -eq 0 ]; then
    echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB replication streaming has been successfully completed!" >> $general_log_file
  else
    echo "[`date +%d/%m/%Y" "%H:%M:%S`] - DB replication streaming has been failed!" >> $general_log_file
    exit 1
  fi
