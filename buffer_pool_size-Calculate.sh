# I need a bash script which would calculate InnoDB Buffer Pool Size for MySQL Server running on linux OS. 
# The server memory can range from 2GB up to 256GB in memory size.

# BING-CHAT - 2023-12-26
# Here is a bash script that calculates the InnoDB Buffer Pool Size for MySQL Server running on Linux OS:
# -------------------------------------
#!/bin/bash

# Get the total memory of the server in bytes
total_memory=$(grep MemTotal /proc/meminfo | awk '{print $2}')

# Convert the total memory to GB
total_memory_gb=$(echo "scale=2; $total_memory/1024/1024" | bc)

# Set the minimum and maximum buffer pool sizes
min_buffer_pool_size=128M
max_buffer_pool_size=80% # of total memory

# Calculate the buffer pool size based on the total memory
if (( $(echo "$total_memory_gb < 2" | bc -l) )); then
    buffer_pool_size=$min_buffer_pool_size
elif (( $(echo "$total_memory_gb > 256" | bc -l) )); then
    buffer_pool_size=$max_buffer_pool_size
else
    buffer_pool_size=$(echo "scale=0; $total_memory_gb*0.5*1024*1024" | bc)"B"
fi

echo "The recommended InnoDB Buffer Pool Size for a MySQL Server running on Linux OS with a total memory of $total_memory_gb GB is $buffer_pool_size."

# This script calculates the InnoDB Buffer Pool Size based on the total memory of the server. The minimum buffer pool
# Raf: not so good as it calculate half of mem overall
# -------------------------------------
# GOOGLE - BART experiment
#!/bin/bash

# Check if the MySQL service is running
if [ ! -f /var/run/mysqld/mysqld.pid ]; then
  echo "MySQL service is not running!"
  exit 1
fi

# Get the total amount of system memory
total_memory=$(free -m | grep Mem | awk '{print $2}')

# Calculate the InnoDB Buffer Pool Size
if [ $total_memory -le 128 ]; then
  innodb_buffer_pool_size=16G
elif [ $total_memory -le 256 ]; then
  innodb_buffer_pool_size=32G
elif [ $total_memory -le 512 ]; then
  innodb_buffer_pool_size=64G
elif [ $total_memory -le 1024 ]; then
  innodb_buffer_pool_size=128G
else
  innodb_buffer_pool_size=256G
fi

echo "InnoDB Buffer Pool Size: ${innodb_buffer_pool_size}"
#======================================
# Amazon Linux 2
# [1] echo $(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
# [2] echo $(free -m | grep Mem | awk '{print $2}')
# [3] echo $(free -h | grep Mem | awk '{print $2}')
#           |[1]        |[2]      |[3]
# t3a.small |   1994912 |   1948  | 1.9G
#
#
#
#

#
#

