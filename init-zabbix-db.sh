#!/bin/sh

echo "[Init] Waiting for MariaDB..."
until mysql -h mariadb -uzabbix -pzabbixpass -e "select 1;" > /dev/null 2>&1; do
  sleep 2
done
echo "[Init] MariaDB is up."

echo "[Init] Importing Zabbix DB schema..."
mysql -h mariadb -uzabbix -pzabbixpass zabbix < /usr/local/share/zabbix/database/mysql/schema.sql
mysql -h mariadb -uzabbix -pzabbixpass zabbix < /usr/local/share/zabbix/database/mysql/images.sql
mysql -h mariadb -uzabbix -pzabbixpass zabbix < /usr/local/share/zabbix/database/mysql/data.sql

echo "[Init] Zabbix DB initialized."

