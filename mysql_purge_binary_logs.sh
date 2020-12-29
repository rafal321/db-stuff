crontab -e
*/5 * * * * /root/scripts/mysql_purge_binary_logs.sh 2>&1 > /dev/null

/root/scripts/mysql_purge_binary_logs.sh
#!/bin/bash
# Remove all the binlogs except the last 3 so we don't break replication

MYSQL_EXTRA_CONFIG=/root/.my.cnf

USEDSPACE=$(df /var/lib/mysql-logs/ | awk '/[0-9]%/{print $(NF-1)}' | tr -d %)
if [ $USEDSPACE -lt 70 ]
then
          exit 0
fi

# FIXME: replace all this script with a backup + purge (inside of xtrabackup_create.sh)
# xtrabackup_create.sh -t binlog -d /backups -l /backups/logs -p prefix_client -c ~/.my.cnf -e asym -k asym_key -z bzip2

# Find mysql-bin.index
MYSQL_BIN_INDEX=$(grep "log-bin" /etc/my.cnf.d/server.cnf | awk '{print $3}').index

# If file doesn't have more than 3 lines, stop, we don't want to remove more files
NUM_ROWS=$(cat $MYSQL_BIN_INDEX | wc -l)
if [ $NUM_ROWS -le 3 ]
then
          exit 0
fi

# Get the 3rd line starting from the end
DELETE_UNTIL=$(basename `cat $MYSQL_BIN_INDEX | tail -n 3 | head -n 1`)

MYSQL="`which mysql 2> /dev/null`"
MYSQL_CMD="$MYSQL --defaults-file=$MYSQL_EXTRA_CONFIG -Bse"
$MYSQL_CMD "PURGE BINARY LOGS TO '$DELETE_UNTIL'"

