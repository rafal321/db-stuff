#>>>>>> ===================================================================================================
# 2323-12-23
	https://cloudkatha.com/how-to-install-mysql-8-on-amazon-linux-2-instance/
	https://dev.mysql.com/downloads/repo/yum/
	
yum install https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm
yum repolist enabled
yum install mysql-community-server
mysql -V							//mysql  Ver 8.0.35 for Linux on x86_64 (MySQL Community Server - GPL)
[1]
mysql_configure.sh
[2]
systemctl start mysqld 						//Starts MySQL service
systemctl enable mysqld 					//Enabled mySQL service to restart on bot
systemctl status mysqld 					//Check MySQL service running status
grep 'temporary password' /var/log/mysqld.log
mysql_secure_installation -p  
-----------------------------------------------
mysql> show variables like '%charac%';
+-------------------------------------------------+--------------------------------+
| Variable_name                                   | Value                          |
+-------------------------------------------------+--------------------------------+
| character_set_client                            | utf8mb4                        |
| character_set_connection                        | utf8mb4                        |
| character_set_database                          | utf8mb4                        |
| character_set_filesystem                        | binary                         |
| character_set_results                           | utf8mb4                        |
| character_set_server                            | utf8mb4                        |
| character_set_system                            | utf8mb3                        |
| character_sets_dir                              | /usr/share/mysql-8.0/charsets/ |
| validate_password.changed_characters_percentage | 0                              |
+-------------------------------------------------+--------------------------------+
#>>>>>> ===================================================================================================
